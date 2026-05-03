local api = require("gitlab-review.api")
local ui = require("gitlab-review.ui")

local M = {}

local function fetch_and_populate(buf, win)
  vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "Loading discussions..." })

  local stop_loading = ui.set_loading_title(win, "Fetching discussions")

  vim.system({ "glab", "mr", "note", "list", "--state", "unresolved", "-F", "json" }, { text = true }, function(obj)
    vim.schedule(function()
      if stop_loading then
        stop_loading(" Discussions ")
      end

      if obj.code ~= 0 then
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "Error fetching discussions: " .. (obj.stderr or "") })
        vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
        return
      end

      local ok, parsed = pcall(vim.json.decode, obj.stdout)
      if not ok or type(parsed) ~= "table" then
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "Failed to parse JSON response." })
        vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
        return
      end

      local lines = {}
      for _, discussion in ipairs(parsed) do
        if discussion.id and discussion.notes and #discussion.notes > 0 then
          local first_note = discussion.notes[1]
          if first_note.author and first_note.body then
            local formatted_body = first_note.body:gsub("\r?\n", " ")
            table.insert(
              lines,
              string.format("- [id: %s] @%s: %s", discussion.id, first_note.author.username, formatted_body)
            )

            for i = 2, #discussion.notes do
              local note = discussion.notes[i]
              if note.author and note.body then
                local note_body = note.body:gsub("\r?\n", " ")
                table.insert(
                  lines,
                  string.format("  - [id: %s] @%s: %s", discussion.id, note.author.username, note_body)
                )
              end
            end
          end
        end
      end

      if #lines == 0 then
        table.insert(lines, "No unresolved discussions found.")
      end

      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
      vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
    end)
  end)
end

function M.run()
  api.fetch_mr_context(function(err, mr_ctx)
    if err then
      vim.notify(err, vim.log.levels.ERROR)
      return
    end

    local buf, win = ui.open_window({
      title = " Discussions ",
      width_ratio = 0.9,
      height_ratio = 0.9,
      start_in_insert_mode = false,
      initial_lines = { "Loading discussions..." },
    })

    fetch_and_populate(buf, win)

    vim.keymap.set("n", "<c-r>", function()
      fetch_and_populate(buf, win)
    end, { buffer = buf, desc = "Refresh discussions" })

    vim.keymap.set("n", "-", function()
      local line = vim.api.nvim_get_current_line()

      if line:match("^%s+%- %[id:") then
        vim.notify("Cannot resolve from a reply. Use the top-level comment.", vim.log.levels.WARN)
        return
      end

      local discussion_id = line:match("^%- %[id:%s*([%w-]+)%]")
      if not discussion_id then
        vim.notify("No top-level discussion ID found on this line.", vim.log.levels.WARN)
        return
      end

      local stop_loading = ui.set_loading_title(win, "Resolving discussion")

      api.resolve_discussion(mr_ctx, discussion_id, function(resolve_err)
        vim.schedule(function()
          if stop_loading then
            stop_loading(" Discussions ")
          end
          if resolve_err then
            vim.notify("Failed to resolve discussion: " .. vim.inspect(resolve_err), vim.log.levels.ERROR)
          else
            vim.notify("Discussion resolved successfully!", vim.log.levels.INFO)
            fetch_and_populate(buf, win)
          end
        end)
      end)
    end, { buffer = buf, desc = "Resolve discussion" })

    vim.keymap.set("n", "R", function()
      local line = vim.api.nvim_get_current_line()
      local discussion_id = line:match("%[id:%s*([%w-]+)%]")
      if not discussion_id then
        vim.notify("No discussion ID found on this line.", vim.log.levels.WARN)
        return
      end

      ui.open_window({
        title = " Reply to Discussion ",
        width_ratio = 0.6,
        height_ratio = 0.4,
        start_in_insert_mode = true,
        on_submit = function(reply_lines, reply_buf, reply_win)
          local reply_body = table.concat(reply_lines, "\n")
          if reply_body:match("^%s*$") then
            vim.notify("Cannot submit empty reply.", vim.log.levels.WARN)
            return
          end

          vim.api.nvim_win_close(reply_win, true)
          local reply_stop_loading = ui.set_loading_title(win, "Submitting reply")

          api.reply_discussion(mr_ctx, discussion_id, { body = reply_body }, function(reply_err)
            vim.schedule(function()
              if reply_stop_loading then
                reply_stop_loading(" Discussions ")
              end
              if reply_err then
                vim.notify("Failed to reply: " .. vim.inspect(reply_err), vim.log.levels.ERROR)
              else
                vim.notify("Reply submitted successfully!", vim.log.levels.INFO)
                -- Re-fetch or close? Just notify success as per requirements
              end
            end)
          end)
        end,
      })
    end, { buffer = buf, desc = "Reply to discussion" })
  end)
end

return M
