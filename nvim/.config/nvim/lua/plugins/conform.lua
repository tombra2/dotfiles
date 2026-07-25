return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "google-java-format", "xmlformatter" })
    end,
  },

  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    opts = {
      formatters_by_ft = {
        -- Lua
        lua = { "stylua" },

        -- Web technologies (Biome — see note below for unsupported types)
        javascript = { "biome" },
        typescript = { "biome" },
        javascriptreact = { "biome" },
        typescriptreact = { "biome" },
        json = { "biome" },
        jsonc = { "biome" },
        css = { "biome" },
        -- Biome does not support these; no formatter installed yet:
        -- markdown, html, scss

        -- YAML (yamlfmt keeps comments intact, unlike prettier)
        yaml = { "yamlfmt" },
        ["yaml.docker-compose"] = { "yamlfmt" },
        ["yaml.gitlab"] = { "yamlfmt" },

        -- Python
        python = { "isort", "black" },

        -- PHP/Symfony
        php = { "php-cs-fixer" },
        -- twig-cs-fixer fixes Twig coding standard, then djlint reflows/indents
        -- the surrounding HTML (Biome can't parse Twig templates).
        twig = { "twig-cs-fixer", "djlint" },

        -- Shell
        sh = { "shfmt" },
        bash = { "shfmt" },

        -- Java and XML
        java = { "google-java-format" },
        xml = { "xmlformatter" },

        -- Additional file types (uncomment as needed)
        -- markdown = { "markdownlint" },
        -- toml = { "taplo" },
      },
      formatters = {
        php_cs_fixer = {
          prepend_args = { "--using-cache=no" },
        },
        -- Twig syntax is Jinja/Django-like; reflow the HTML with that profile.
        djlint = {
          prepend_args = { "--profile", "django" },
        },
        -- Stop Xdebug from trying to attach to the short-lived CLI call on save.
        ["twig-cs-fixer"] = {
          env = { XDEBUG_MODE = "off" },
        },
      },
    },
    init = function()
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
  },
}
