--- UI for dealing with popup windows
--- This module provides functions that are specialized in mounting popup windows

local M = {}

---@class WindowOptions
---@field title string Title of the window
---@field on_submit? function(string[] lines, integer buf, integer win) Callback when ZZ is pressed. Receives a list of lines, buffer id and window id.
---@field initial_lines? string[] Optional lines to populate the buffer with
---@field width_ratio? number Ratio of window width to editor width. Default 0.6
---@field height_ratio? number Ratio of window height to editor height. Default 0.4
---@field start_in_insert_mode? boolean Whether to start in insert mode. Default true

---@param opts WindowOptions
function M.open_window(opts)
  opts = opts or {}

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf, scope = "local" })
  vim.api.nvim_set_option_value("filetype", "markdown", { buf = buf, scope = "local" })

  local width_ratio = opts.width_ratio or 0.6
  local height_ratio = opts.height_ratio or 0.4
  local width = math.floor(vim.o.columns * width_ratio)
  local height = math.floor(vim.o.lines * height_ratio)

  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local win_opts = {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = opts.title,
    title_pos = "center",
  }

  local win = vim.api.nvim_open_win(buf, true, win_opts)

  if opts.initial_lines then
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, opts.initial_lines)
  end

  local start_in_insert = opts.start_in_insert_mode
  if start_in_insert == nil then
    start_in_insert = true
  end

  if start_in_insert then
    vim.cmd("startinsert")
  end

  vim.keymap.set("n", "ZZ", function()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

    if opts.on_submit then
      opts.on_submit(lines, buf, win)
    end
  end, { buffer = buf, desc = "[gitlab-review] Submit popup" })

  vim.keymap.set("n", "ZQ", function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, desc = "[gitlab-review] Quit popup" })

  return buf, win
end

return M

