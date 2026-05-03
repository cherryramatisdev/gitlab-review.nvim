local M = {}

function M.run()
  local bufnr = vim.api.nvim_get_current_buf()
  local row = vim.fn.line(".") - 1
  local context = require("gitlab-review.treesitter").get_context_at_row(bufnr, row)

  if not context then
    vim.notify("Could not determine diff context at cursor", vim.log.levels.WARN)
    return
  end

  local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1]
  if line then
    line = line:gsub("^[%-%+ ]", "")
  else
    line = ""
  end

  local initial_lines = { "```suggestion", line, "```", "" }

  require("gitlab-review.actions.submit").open_comment_window(
    context,
    nil,
    initial_lines,
    { start_at_insert_mode = false }
  )
end

return M
