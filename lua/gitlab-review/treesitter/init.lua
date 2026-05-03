local diff = require("gitlab-review.treesitter.diff")

return {
  get_context_at_row = diff.get_context_at_row,
}
