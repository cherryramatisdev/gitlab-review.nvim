--- Payload Builder for gitlab-review
--- This module constructs payload data structures for GitLab API requests.
--- It handles building the `position` table required for single-line and multiline comments in merge requests.
---
--- WARNING: This module performs side effects by executing external shell commands
--- and making network requests to the GitLab API.

local M = {}

--- Build the position payload for GitLab API
--- @param mr_ctx table
--- @param start_ctx table
--- @param end_ctx table|nil Optional. If provided and different from start_ctx conceptually, builds multiline payload.
--- @return table position The position table for the GitLab API request.
function M.build_position(mr_ctx, start_ctx, end_ctx)
  local position = {
    position_type = "text",
    base_sha = mr_ctx.base_sha,
    start_sha = mr_ctx.start_sha,
    head_sha = mr_ctx.head_sha,
  }

  if not end_ctx or (start_ctx.old_line == end_ctx.old_line and start_ctx.new_line == end_ctx.new_line) then
    -- Single line comment
    position.old_path = start_ctx.old_path
    position.new_path = start_ctx.new_path
    position.old_line = start_ctx.old_line
    position.new_line = start_ctx.new_line
  else
    -- Multiline comment
    -- For multiline comments, the top-level old_line/new_line generally point to the end of the range.
    position.old_path = end_ctx.old_path or start_ctx.old_path
    position.new_path = end_ctx.new_path or start_ctx.new_path
    position.old_line = end_ctx.old_line
    position.new_line = end_ctx.new_line

    local function map_type(ctx_type)
      if ctx_type == "deletion" then
        return "old"
      end
      return "new"
    end

    position.line_range = {
      start = {
        type = map_type(start_ctx.type),
        old_line = start_ctx.old_line,
        new_line = start_ctx.new_line,
      },
      ["end"] = {
        type = map_type(end_ctx.type),
        old_line = end_ctx.old_line,
        new_line = end_ctx.new_line,
      }
    }
  end

  return position
end

return M
