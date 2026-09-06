return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    local theme = require("lualine.themes.auto")
    for _, mode in pairs(theme) do
      if mode.c then
        mode.c.bg = nil
      end
    end
    opts.options.theme = theme
  end,
}
