--- Payload Validator for gitlab-review
--- This module provides validation functions for the context payload used to create MR comments.
--- It ensures that the start and end contexts of a multiline comment are valid and belong to the same file.
---
--- WARNING: This module performs side effects during the validation process.
local M = {}

--- Validate that start_ctx and end_ctx belong to the same file context.
--- @param start_ctx table
--- @param end_ctx table
--- @return boolean is_valid
--- @return string|nil error_message
function M.validate_multiline_context(start_ctx, end_ctx)
  if not start_ctx or not end_ctx then
    return false, "Invalid context: start or end context is missing."
  end

  if start_ctx.new_path ~= end_ctx.new_path then
    return false, "Cannot create a multiline comment spanning different files."
  end

  if start_ctx.old_path ~= end_ctx.old_path then
    return false, "Cannot create a multiline comment spanning different files."
  end

  return true, nil
end

return M
