return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  opts = {
    formatters_by_ft = {

      -- Lua
      lua = { "stylua" },

      -- Web technologies
      javascript = { "biome" },
      typescript = { "biome" },
      javascriptreact = { "biome" },
      typescriptreact = { "biome" },
      json = { "biome" },
      jsonc = { "biome" },
      yaml = { "biome" },
      markdown = { "prettier" },
      html = { "biome" },
      css = { "biome" },
      scss = { "biome" },

      -- Python
      python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },

      -- PHP/Symfony
      php = { "php-cs-fixer" },
      twig = { "twig-cs-fixer" },

      cpp = { "clang-format" },
      -- Shell
      sh = { "shfmt" },
      bash = { "shfmt" },
      zsh = { "shfmt" },

      -- Java --
      java = { "google-java-format" },

      -- Additional file types (uncomment as needed)
      -- markdown = { "markdownlint" },
      -- yaml = { "yamllint" },
      -- toml = { "taplo" },
    },
  },
  init = function()
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
  end,
}
