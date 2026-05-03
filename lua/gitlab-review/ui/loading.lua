--- UI for dealing with popup loading states
--- This module provides functions that are specialized in providing loading UX for popup windows.

local M = {}

--- Creates and starts a loading spinner animation on a window's title.
---@param win_id integer The Neovim window ID
---@param prefix string The text prefix to display before the spinner
---@return fun(fallback_title: string|nil)|nil stop_loading Cleanup function to stop the animation and optionally set a fallback title, or nil if timer creation fails
function M.set_loading_title(win_id, prefix)
  local frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
  local frame_idx = 1
  local uv = vim.uv or vim.loop
  local timer = uv.new_timer()

  assert(timer, "Failed to create timer for loading animation")

  timer:start(
    0,
    100,
    vim.schedule_wrap(function()
      if not vim.api.nvim_win_is_valid(win_id) then
        timer:stop()
        timer:close()
        return
      end

      local title = string.format(" %s %s ", prefix, frames[frame_idx])
      vim.api.nvim_win_set_config(win_id, { title = title })

      frame_idx = (frame_idx % #frames) + 1
    end)
  )

  local is_closed = false
  return function(fallback_title)
    if not is_closed then
      timer:stop()
      timer:close()
      is_closed = true
    end

    if fallback_title and vim.api.nvim_win_is_valid(win_id) then
      vim.schedule(function()
        if vim.api.nvim_win_is_valid(win_id) then
          vim.api.nvim_win_set_config(win_id, { title = fallback_title })
        end
      end)
    end
  end
end

return M

