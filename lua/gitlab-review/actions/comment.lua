local M = {}

function M.run()
  local bufnr = vim.api.nvim_get_current_buf()
  local row = vim.fn.line(".") - 1
  local context = require("gitlab-review.treesitter").get_context_at_row(bufnr, row)

  if not context then
    vim.notify("Could not determine diff context at cursor", vim.log.levels.WARN)
    return
  end

  require("gitlab-review.actions.submit").open_comment_window(context)
end

return M
