local client = require("gitlab-review.api.client")

local M = {}

function M.reply_discussion(mr_ctx, discussion_id, payload, callback)
  local endpoint = string.format(
    "/projects/%s/merge_requests/%s/discussions/%s/notes",
    mr_ctx.project_id,
    mr_ctx.iid,
    discussion_id
  )
  client.call(endpoint, "POST", payload, callback)
end

return M
