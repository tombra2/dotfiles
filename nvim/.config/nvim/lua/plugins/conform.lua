return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "djlint", "google-java-format", "xmlformatter" })
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

        -- Web technologies
        javascript = { "biome" },
        typescript = { "biome" },
        javascriptreact = { "biome" },
        typescriptreact = { "biome" },
        json = { "biome" },
        jsonc = { "biome" },
        css = { "biome" },
        html = { "biome_html" },
        -- Biome does not support these yet: markdown, scss

        -- YAML (yamlfmt keeps comments intact, unlike prettier)
        yaml = { "yamlfmt" },
        ["yaml.docker-compose"] = { "yamlfmt" },
        ["yaml.gitlab"] = { "yamlfmt" },
        ["yaml.github-actions"] = { "yamlfmt" },

        -- Python
        python = { "isort", "black" },

        -- PHP/Symfony
        php = { "php-cs-fixer" },
        -- Normalize Twig first, then format its HTML in Symfony's layout style.
        twig = { "twig-cs-fixer", "twig_html" },

        -- Shell
        sh = { "shfmt" },
        bash = { "shfmt" },

        -- Java and XML
        java = { "palantir-java-format" },
        xml = { "xmlformatter" },

        -- Additional file types (uncomment as needed)
        -- markdown = { "markdownlint" },
        -- toml = { "taplo" },
      },
      formatters = {
        yamlfmt = {
          args = function(_, ctx)
            local ft = vim.bo[ctx.buf].filetype
            local is_symfony = ctx.filename:find("/config/", 1, true)
              and vim.fs.root(ctx.filename, { "symfony.lock" }) ~= nil
            local indent = (ft == "yaml.gitlab" or is_symfony) and 4 or 2

            return {
              "-formatter",
              "indent=" .. indent,
              "-formatter",
              "retain_line_breaks_single=true",
              "-formatter",
              "trim_trailing_whitespace=true",
              "-formatter",
              "eof_newline=true",
              "-",
            }
          end,
        },
        biome_html = {
          command = vim.fn.stdpath("config") .. "/bin/twig-html-format",
          args = function()
            return { "--biome", vim.fn.exepath("biome"), vim.fn.exepath("djlint"), "$FILENAME" }
          end,
          stdin = true,
        },
        twig_html = {
          command = vim.fn.stdpath("config") .. "/bin/twig-html-format",
          args = function()
            return { vim.fn.exepath("djlint") }
          end,
          stdin = true,
        },
        php_cs_fixer = {
          prepend_args = { "--using-cache=no" },
        },
        -- Stop Xdebug from trying to attach to the short-lived CLI call on save.
        ["twig-cs-fixer"] = {
          env = { XDEBUG_MODE = "off" },
        },
      },
    },
  },
}
