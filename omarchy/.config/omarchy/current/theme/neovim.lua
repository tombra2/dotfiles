return {
  {
    "bjarneo/aether.nvim",
    branch = "v3",
    name = "aether",
    priority = 1000,
    opts = {
      colors = {
        bg         = "#121212",
        dark_bg    = "#0e0e0e",
        darker_bg  = "#090909",
        lighter_bg = "#2a2a2a",

        fg         = "#ffffff",
        dark_fg    = "#bfbfbf",
        light_fg   = "#ffffff",
        bright_fg  = "#ffffff",
        muted      = "#9e9e9e",

        red        = "#fc3023",
        yellow     = "#fc3023",
        orange     = "#fc4f44",
        green      = "#b96564",
        cyan       = "#6a76cc",
        blue       = "#6479d2",
        purple     = "#af5ed8",
        brown      = "#972f29",

        bright_red    = "#ff523d",
        bright_yellow = "#ff523d",
        bright_green  = "#e78684",
        bright_cyan   = "#8d96ff",
        bright_blue   = "#879aff",
        bright_purple = "#dc79ff",

        accent               = "#6479d2",
        cursor               = "#ffffff",
        foreground           = "#ffffff",
        background           = "#121212",
        selection             = "#2a2a2a",
        selection_foreground = "#ffffff",
        selection_background = "#2a2a2a",
      },
    },
    -- set up hot reload
    config = function(_, opts)
      require("aether").setup(opts)
      vim.cmd.colorscheme("aether")
      require("aether.hotreload").setup()
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "aether",
    },
  },
}
