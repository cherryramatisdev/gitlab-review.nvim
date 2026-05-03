local fetch_mr_context = require("gitlab-review.api.fetch_mr_context")
local create_discussion = require("gitlab-review.api.create_discussion")
local reply_discussion = require("gitlab-review.api.reply_discussion")
local resolve_discussion = require("gitlab-review.api.resolve_discussion")

return {
  fetch_mr_context = fetch_mr_context.fetch_mr_context,
  create_discussion = create_discussion.create_discussion,
  reply_discussion = reply_discussion.reply_discussion,
  resolve_discussion = resolve_discussion.resolve_discussion,
}
