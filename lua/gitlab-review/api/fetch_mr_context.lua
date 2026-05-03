--- Merge Request Context Fetcher for gitlab-review
--- This module fetches the current Merge Request context (project ID, IID, SHAs)
--- using the `glab mr view` CLI command via `vim.system`. It caches the result
--- per working directory to avoid redundant network calls.
---
--- WARNING: This module performs side effects by executing external shell commands
--- and making network requests to the GitLab API.

local M = {}

M.cache = {}

--- Fetches Merge Request context using `glab` CLI asynchronously
--- @param callback function Called with (err, context)
function M.fetch_mr_context(callback)
  local cwd = vim.fn.getcwd()

  -- Return cached context if available
  if M.cache[cwd] then
    vim.schedule(function()
      callback(nil, M.cache[cwd])
    end)
    return
  end

  vim.schedule(function()
    vim.notify("Fetching MR context...", vim.log.levels.INFO)
  end)

  -- Execute `glab mr view -F json`
  vim.system({ "glab", "mr", "view", "-F", "json" }, { text = true }, function(obj)
    if obj.code ~= 0 then
      local err_msg = "Failed to fetch MR context: " .. (obj.stderr or "Unknown error")
      vim.schedule(function()
        callback(err_msg, nil)
      end)
      return
    end

    local ok, parsed = pcall(vim.json.decode, obj.stdout)
    if not ok then
      vim.schedule(function()
        callback("Failed to parse glab JSON output", nil)
      end)
      return
    end

    local diff_refs = parsed.diff_refs or {}

    local context = {
      project_id = parsed.project_id,
      iid = parsed.iid,
      base_sha = diff_refs.base_sha,
      start_sha = diff_refs.start_sha,
      head_sha = diff_refs.head_sha,
    }

    M.cache[cwd] = context

    vim.schedule(function()
      callback(nil, context)
    end)
  end)
end

return M
