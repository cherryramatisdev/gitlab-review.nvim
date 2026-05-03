--- Submit actions for gitlab-review
--- This module handles the process of opening a UI window to draft comments and
--- submitting those comments as discussions to GitLab Merge Requests.
---
--- WARNING: This module performs side effects by opening Neovim windows,
--- modifying buffers, and making network requests to the GitLab API.

local M = {}

---@class SubmitCommentWindowOpts
---@field start_at_insert_mode? boolean Whether to start the comment window in insert mode (default: true)

--- @param start_ctx table The context table for the starting line.
--- @param end_ctx table|nil The context table for the ending line (optional, for multi-line comments).
--- @param initial_lines table|nil An array of strings representing initial lines to populate the comment window (optional).
--- @param opts? SubmitCommentWindowOpts Additional options for the comment window (optional).
function M.open_comment_window(start_ctx, end_ctx, initial_lines, opts)
  opts = opts or {}

  require("gitlab-review.api").fetch_mr_context(function(err, mr_ctx)
    if err then
      vim.notify(err, vim.log.levels.ERROR)
      return
    end

    require("gitlab-review.ui").open_window({
      title = " Draft Comment (ZZ to submit) ",
      initial_lines = initial_lines,
      start_in_insert_mode = opts.start_at_insert_mode or true,
      on_submit = function(lines, comment_buf, comment_win)
        if #lines == 0 or (#lines == 1 and lines[1] == "") then
          vim.notify("Comment cannot be empty", vim.log.levels.WARN)
          return
        end

        local stop = require("gitlab-review.ui").set_loading_title(comment_win, "Submitting")
        assert(stop, "Failed to start loading animation")

        vim.api.nvim_set_option_value("modifiable", false, { buf = comment_buf })

        -- Build payload
        local position
        if end_ctx then
          position = require("gitlab-review.payload.builder").build_position(mr_ctx, start_ctx, end_ctx)
        else
          position = require("gitlab-review.payload.builder").build_position(mr_ctx, start_ctx)
        end

        local payload = {
          body = table.concat(lines, "\n"),
          position = position,
        }

        local config = require("gitlab-review").config
        if config.verbose then
          vim.notify("Sending payload to GitLab:\n" .. vim.inspect(payload), vim.log.levels.INFO)
        end

        require("gitlab-review.api").create_discussion(mr_ctx, payload, function(cb_err, _)
          vim.schedule(function()
            if cb_err then
              stop(" Failed to submit comment (ZZ to try again) ")
              vim.notify("Failed to post comment: " .. cb_err, vim.log.levels.ERROR)
              if vim.api.nvim_buf_is_valid(comment_buf) then
                vim.api.nvim_set_option_value("modifiable", true, { buf = comment_buf })
              end
            else
              stop()
              vim.notify("Comment posted successfully!", vim.log.levels.INFO)
              if vim.api.nvim_win_is_valid(comment_win) then
                vim.api.nvim_win_close(comment_win, true)
              end
            end
          end)
        end)
      end,
    })
  end)
end

return M
