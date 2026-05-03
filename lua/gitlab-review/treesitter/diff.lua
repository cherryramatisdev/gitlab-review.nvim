--- Tree-sitter diff parser for gitlab-review
--- This module provides utilities for parsing and extracting information from diff files using Tree-sitter.
--- It handles extracting file paths, calculating precise line numbers for hunks, and retrieving diff context at a specific cursor row.
---
--- WARNING: This module performs side effects by interacting with Neovim's Tree-sitter API
--- and reading from Neovim buffers.
local client = require("gitlab-review.treesitter.client")

local M = {}

local function strip_prefix(path)
  -- Remove common git diff prefixes: a/, b/, c/ (commit), w/ (work tree), i/ (index), o/ (others)
  if path:match("^a/") or path:match("^b/") or path:match("^c/") or path:match("^w/") or path:match("^i/") or path:match("^o/") then
    return path:sub(3)
  end
  return path
end

--- Extract file paths from a diff block node
--- @param block_node TSNode
--- @param bufnr number
--- @return string|nil old_path, string|nil new_path
function M.get_file_paths(block_node, bufnr)
  local old_file_node, new_file_node
  for child in block_node:iter_children() do
    local t = child:type()
    if t == "old_file" then
      old_file_node = child
    elseif t == "new_file" then
      new_file_node = child
    end
  end

  local old_path, new_path
  if old_file_node then
    for child in old_file_node:iter_children() do
      if child:type() == "filename" then
        old_path = strip_prefix(vim.treesitter.get_node_text(child, bufnr))
      end
    end
  end
  if new_file_node then
    for child in new_file_node:iter_children() do
      if child:type() == "filename" then
        new_path = strip_prefix(vim.treesitter.get_node_text(child, bufnr))
      end
    end
  end

  if old_path == "/dev/null" then old_path = nil end
  if new_path == "/dev/null" then new_path = nil end

  return old_path, new_path
end

--- Get start lines from a diff hunk location node
--- @param location_node TSNode
--- @param bufnr number
--- @return number old_start, number new_start
function M.get_start_lines(location_node, bufnr)
  local old_start, new_start = 0, 0
  for child in location_node:iter_children() do
    if child:type() == "linerange" then
      local text = vim.treesitter.get_node_text(child, bufnr)
      if text:sub(1,1) == "-" then
        old_start = tonumber(text:match("%-(%d+)")) or 0
      elseif text:sub(1,1) == "+" then
        new_start = tonumber(text:match("%+(%d+)")) or 0
      end
    end
  end
  return old_start, new_start
end

--- Get exact line numbers for a specific change node inside a hunk
--- @param hunk_node TSNode
--- @param target_node TSNode
--- @param old_start number
--- @param new_start number
--- @return number old_line, number new_line
function M.calculate_line_numbers(hunk_node, target_node, old_start, new_start)
  local old_line = old_start
  local new_line = new_start

  local changes_node
  for child in hunk_node:iter_children() do
    if child:type() == "changes" then
      changes_node = child
      break
    end
  end

  if changes_node then
    for child in changes_node:iter_children() do
      if child == target_node then
        break
      end
      local t = child:type()
      if t == "context" then
        old_line = old_line + 1
        new_line = new_line + 1
      elseif t == "deletion" then
        old_line = old_line + 1
      elseif t == "addition" then
        new_line = new_line + 1
      end
    end
  end

  return old_line, new_line
end

--- Parse the buffer at the given cursor row to extract the diff context.
--- @param bufnr number The buffer number to parse
--- @param row number The 0-indexed cursor row
--- @return table|nil Context table with { old_path, new_path, old_line, new_line, type } or nil if invalid
function M.get_context_at_row(bufnr, row)
  local root = client.get_root(bufnr, "diff")
  if not root then return nil end

  local start_node = client.get_node_at_row(root, row)
  if not start_node then return nil end

  local current_node = client.find_ancestor(start_node, { addition = true, deletion = true, context = true })
  if not current_node then return nil end

  local node_type = current_node:type()

  local hunk_node = client.find_ancestor(current_node, "hunk")
  if not hunk_node then return nil end

  local block_node = client.find_ancestor(hunk_node, "block")
  if not block_node then return nil end

  local location_node
  for child in hunk_node:iter_children() do
    if child:type() == "location" then
      location_node = child
      break
    end
  end
  if not location_node then return nil end

  local old_path, new_path = M.get_file_paths(block_node, bufnr)
  local old_start, new_start = M.get_start_lines(location_node, bufnr)
  local old_line, new_line = M.calculate_line_numbers(hunk_node, current_node, old_start, new_start)

  local result = {
    old_path = old_path,
    new_path = new_path,
    type = node_type,
  }

  if node_type == "context" then
    result.old_line = old_line
    result.new_line = new_line
  elseif node_type == "addition" then
    result.new_line = new_line
  elseif node_type == "deletion" then
    result.old_line = old_line
  end

  return result
end

return M
