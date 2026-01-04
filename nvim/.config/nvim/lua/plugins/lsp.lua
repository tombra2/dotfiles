return {
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                html = {
                    filetypes = {
                        "html",
                        "twig",
                        "javascriptreact",
                        "typescriptreact",
                        "jsx",
                        "tsx"
                    },
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
                }
            },
        },
    },
}
