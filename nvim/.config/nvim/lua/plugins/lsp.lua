return {
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                lua_ls = {
                },
                html = {
                    filetypes = {
                        "html",
                        "twig",
                        "javascriptreact",
                        "typescriptreact",
                        "jsx",
                        "tsx"
                    },
                    settings = {
                        suggest = {
                            html5 = true,
                        }
                    }
                },
                emmet_ls = {
                    filetypes = {
                        "html",
                        "twig",
                        "javascriptreact",
                        "typescriptreact",
                        "jsx",
                        "tsx"
                    }
                },
                phpactor = {
                    init_options = {
                        ["language_server_phpstan.enabled"] = true,
                        ["language_server_psalm.enabled"] = true,
                        ["language_server_php_cs_fixer.enabled"] = false,
                    },
                }

            },
        },
    },
}
