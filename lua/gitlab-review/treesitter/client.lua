--- Treesitter Client for gitlab-review
--- This module provides utility functions for interacting with Neovim's treesitter API.
--- It handles getting the root node, finding nodes at specific rows, and finding ancestors of a specific type.
---
--- WARNING: This module performs side effects by invoking Neovim's treesitter parsing
--- and interacting with the buffer's state.

local M = {}

--- Get the root node of the treesitter tree for a given buffer and language
--- @param bufnr number
--- @param lang string
--- @return TSNode|nil
function M.get_root(bufnr, lang)
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr, lang)
  if not ok or not parser then return nil end

  local tree = parser:parse()[1]
  if not tree then return nil end

  return tree:root()
end

--- Get the named descendant at a specific row
--- @param root TSNode
--- @param row number
--- @return TSNode|nil
function M.get_node_at_row(root, row)
  return root:named_descendant_for_range(row, 0, row, 0)
end

--- Find the first ancestor of a node that matches a specific type
--- @param node TSNode|nil
--- @param node_type string|table<string, boolean>
--- @return TSNode|nil
function M.find_ancestor(node, node_type)
  local current = node
  local is_table = type(node_type) == "table"
  while current do
    local t = current:type()
    if is_table then
      if node_type[t] then
        return current
      end
    elseif t == node_type then
      return current
    end
    current = current:parent()
  end
  return nil
end

return M
