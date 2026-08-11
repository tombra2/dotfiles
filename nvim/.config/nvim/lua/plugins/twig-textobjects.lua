local function twig_blocks(ai_type)
  if vim.bo.filetype ~= "twig" then
    return {}
  end

  local ok, parser = pcall(vim.treesitter.get_parser, 0, "twig")
  if not ok or not parser then
    return {}
  end

  local query = vim.treesitter.query.parse("twig", "(statement_directive) @directive")
  local tree = parser:parse()[1]
  local stack = {}
  local blocks = {}
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  for _, node in query:iter_captures(tree:root(), 0, 0, -1) do
    local text = vim.treesitter.get_node_text(node, 0)
    local directive = text:match("^%{%%%-?%s*(%a+)")
    local start_row, start_col, end_row, end_col = node:range()

    if directive == "block" then
      table.insert(stack, {
        start_row = start_row,
        start_col = start_col,
        end_row = end_row,
        end_col = end_col,
      })
    elseif directive == "endblock" and #stack > 0 then
      local opening = table.remove(stack)

      if ai_type == "a" then
        table.insert(blocks, {
          from = { line = opening.start_row + 1, col = opening.start_col + 1 },
          to = { line = end_row + 1, col = end_col },
        })
      else
        local from = { line = opening.end_row + 1, col = opening.end_col + 1 }
        local to = { line = start_row + 1, col = start_col }

        if from.line < to.line and lines[from.line]:sub(from.col):match("^%s*$") then
          from = { line = from.line + 1, col = 1 }
        end
        if to.line > from.line and lines[to.line]:sub(1, to.col):match("^%s*$") then
          to = { line = to.line - 1, col = #lines[to.line - 1] }
        end

        if from.line < to.line or (from.line == to.line and from.col <= to.col) then
          table.insert(blocks, { from = from, to = to })
        else
          table.insert(blocks, { from = from })
        end
      end
    end
  end

  return blocks
end

return {
  "nvim-mini/mini.ai",
  opts = function(_, opts)
    opts.custom_textobjects = opts.custom_textobjects or {}
    opts.custom_textobjects.B = twig_blocks
  end,
}
