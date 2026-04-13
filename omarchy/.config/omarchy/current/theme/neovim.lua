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

        red        = "#c26252",
        yellow     = "#cd5d34",
        orange     = "#cb7a6c",
        green      = "#d0642b",
        cyan       = "#7775d2",
        blue       = "#7675d2",
        purple     = "#c25bc3",
        brown      = "#7a4941",

        bright_red    = "#f1836e",
        bright_yellow = "#fd7e48",
        bright_green  = "#e27941",
        bright_cyan   = "#9c95ff",
        bright_blue   = "#9b95ff",
        bright_purple = "#f176f9",

        accent               = "#7675d2",
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
