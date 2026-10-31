return {
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = { "BufReadPost", "BufNewFile" },
    main = "rainbow-delimiters.setup",
    opts = {
      -- Use yellow for every nesting level.
      highlight = { "RainbowDelimiterYellow" },
      -- Keep brackets visible over Tree-sitter and LSP semantic highlighting.
      priority = { [""] = 210 },
    },
  },
}
