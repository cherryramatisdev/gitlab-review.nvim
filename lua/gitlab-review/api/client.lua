--- API Client for gitlab-review
--- This module provides a wrapper around the `glab api` CLI command using `vim.system`.
--- It handles encoding the payload as JSON, executing the command, and parsing the JSON response.
---
--- WARNING: This module performs side effects by executing external shell commands
--- and making network requests to the GitLab API.
local M = {}

function M.call(endpoint, method, payload, callback)
  local json_payload = vim.json.encode(payload)

  vim.system({
    "glab",
    "api",
    endpoint,
    "-X",
    method,
    "-H",
    "Content-Type: application/json",
    "--input",
    "-",
  }, {
    stdin = json_payload,
    text = true,
  }, function(obj)
    if obj.code ~= 0 then
      callback(obj.stderr or "Unknown error", nil)
      return
    end

    local ok, parsed = pcall(vim.json.decode, obj.stdout)
    if not ok then
      callback("Failed to parse glab JSON output", nil)
      return
    end

    callback(nil, parsed)
  end)
end

return M
