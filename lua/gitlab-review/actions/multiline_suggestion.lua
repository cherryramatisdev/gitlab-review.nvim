local M = {}

function M.run()
  local bufnr = vim.api.nvim_get_current_buf()
  local v_pos = vim.fn.getpos("v")
  local cur_pos = vim.fn.getpos(".")

  local start_row = v_pos[2]
  local end_row = cur_pos[2]

  if start_row > end_row then
    start_row, end_row = end_row, start_row
  end

  local start_row_0 = start_row - 1
  local end_row_0 = end_row - 1

  local treesitter = require("gitlab-review.treesitter")
  local start_ctx = treesitter.get_context_at_row(bufnr, start_row_0)
  local end_ctx = treesitter.get_context_at_row(bufnr, end_row_0)

  if not start_ctx or not end_ctx then
    vim.notify("Could not determine diff context for selection", vim.log.levels.WARN)
    return
  end

  local ok, err_msg = require("gitlab-review.payload.validator").validate_multiline_context(start_ctx, end_ctx)
  if not ok then
    vim.notify("Invalid selection: " .. err_msg, vim.log.levels.WARN)
    return
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, start_row_0, end_row_0 + 1, false)
  local initial_lines = { "```suggestion" }
  for _, line in ipairs(lines) do
    local cleaned_line = line:gsub("^[%-%+ ]", "")
    table.insert(initial_lines, cleaned_line)
  end
  table.insert(initial_lines, "```")
  table.insert(initial_lines, "")

  require("gitlab-review.actions.submit").open_comment_window(
    start_ctx,
    end_ctx,
    initial_lines,
    { start_at_insert_mode = false }
  )
end

return M
