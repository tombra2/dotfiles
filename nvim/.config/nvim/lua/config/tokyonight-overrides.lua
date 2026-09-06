-- TokyoNight "night" palette. Change values here to override the theme.
-- Every key below is available as c.<name> in highlights().
local M = {}

function M.colors(c)
  c.bg = "#282c34"
  c.bg_dark = "#21252b"
  c.bg_dark1 = "#181a1f"
  c.bg_highlight = "#2c313c"
  c.blue = "#61afef"
  c.blue0 = "#4d78cc"
  c.blue1 = "#56b6c2"
  c.blue2 = "#2b6f77"
  c.blue5 = "#56b6c2"
  c.blue6 = "#a5e8ef"
  c.blue7 = "#2c3043"
  c.comment = "#5c6370"
  c.cyan = "#56b6c2"
  c.dark3 = "#545862"
  c.dark5 = "#7f848e"
  c.fg = "#abb2bf"
  c.fg_dark = "#828997"
  c.fg_gutter = "#3b4048"
  c.green = "#98c379"
  c.green1 = "#5faf5f"
  c.green2 = "#43757a"
  c.magenta = "#c678dd"
  c.magenta2 = "#c24098"
  c.orange = "#d19a66"
  c.purple = "#c678dd"
  c.red = "#e06c75"
  c.red1 = "#be5046"
  c.teal = "#56b6c2"
  c.terminal_black = "#3f4451"
  c.yellow = "#e5c07b"
  c.git.add = "#98c379"
  c.git.change = "#e5c07b"
  c.git.delete = "#e06c75"
end

function M.highlights(hl, c)
  -- Add any Neovim or plugin highlight group here. Examples:
  -- hl.Normal = { fg = c.fg, bg = c.bg }
  -- hl.Comment = { fg = c.comment, italic = true }
  -- hl.CursorLineNr = { fg = c.cyan, bold = true }
  -- hl.Search = { fg = c.bg, bg = c.orange }
  -- hl.Visual = { bg = c.blue0 }
  -- hl.LineNr = { fg = c.fg_gutter }
  -- hl.StatusLine = { fg = c.fg_dark, bg = c.bg_dark }
end

return M
