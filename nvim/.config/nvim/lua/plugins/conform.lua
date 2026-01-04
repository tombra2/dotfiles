return {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    opts = {
        formatters_by_ft = {

            -- Lua
            lua = { "stylua" },

            -- Web technologies
            javascript = { "prettier" },
            typescript = { "prettier" },
            javascriptreact = { "prettier" },
            typescriptreact = { "prettier" },
            json = { "prettier" },
            jsonc = { "prettier" },
            yaml = { "prettier" },
            markdown = { "prettier" },
            html = { "prettier" },
            css = { "prettier" },
            scss = { "prettier" },

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
