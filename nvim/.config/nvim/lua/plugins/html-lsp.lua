return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "biome",
        "emmet-language-server",
        "html-lsp",
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "html" } },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        html = {
          filetypes = { "html", "twig" },
          -- Biome/Conform is the single formatter for plain HTML.
          init_options = { provideFormatter = false },
        },
        emmet_language_server = {
          filetypes = {
            "css",
            "html",
            "javascriptreact",
            "less",
            "sass",
            "scss",
            "typescriptreact",
            "twig",
          },
          init_options = {
            includeLanguages = { twig = "html" },
            showExpandedAbbreviation = "always",
            showSuggestionsAsSnippets = true,
          },
        },
      },
    },
  },
}
