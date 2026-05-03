--- API module for creating discussions in GitLab merge requests
--- This module provides a function to create a new discussion on a specific merge request using the GitLab API.
---
--- WARNING: This module performs side effects by making network requests to the GitLab API.
local client = require("gitlab-review.api.client")

local M = {}

function M.create_discussion(mr_ctx, payload, callback)
  local endpoint = string.format("/projects/%s/merge_requests/%s/discussions", mr_ctx.project_id, mr_ctx.iid)
  client.call(endpoint, "POST", payload, callback)
end

return M
