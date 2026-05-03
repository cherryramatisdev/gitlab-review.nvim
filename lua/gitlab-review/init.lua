local M = {}

M.config = {
  verbose = false,
  default_keybindings = false,
}

function M.setup(opts)
  opts = opts or {}
  M.config = vim.tbl_deep_extend("force", M.config, opts)

  local group = vim.api.nvim_create_augroup("GlabReview", { clear = true })

  if M.config.default_keybindings then
    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      pattern = "diff",
      callback = function(args)
        local bufnr = args.buf
        local actions = require("gitlab-review.actions")

        vim.keymap.set("n", "C", actions.comment, { buffer = bufnr, desc = "Add GitLab comment" })
        vim.keymap.set("x", "C", actions.multiline_comment, { buffer = bufnr, desc = "Add multiline GitLab comment" })
        vim.keymap.set("n", "S", actions.suggestion, { buffer = bufnr, desc = "Add GitLab suggestion" })
        vim.keymap.set(
          "x",
          "S",
          actions.multiline_suggestion,
          { buffer = bufnr, desc = "Add multiline GitLab suggestion" }
        )
        vim.keymap.set("n", "gR", actions.list_discussions, { buffer = bufnr, desc = "List GitLab MR discussions" })
      end,
    })
  end
end

return M
