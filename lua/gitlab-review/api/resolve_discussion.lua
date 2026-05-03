local client = require("gitlab-review.api.client")

local M = {}

function M.resolve_discussion(mr_ctx, discussion_id, callback)
  local endpoint = string.format(
    "/projects/%s/merge_requests/%s/discussions/%s",
    mr_ctx.project_id,
    mr_ctx.iid,
    discussion_id
  )
  client.call(endpoint, "PUT", { resolved = true }, callback)
end

return M
