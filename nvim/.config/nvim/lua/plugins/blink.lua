local copilot = require "lazyvim.plugins.extras.ai.copilot"
return {
    {
        "saghen/blink.compat",
        -- use the latest release, via version = '*', if you also use the latest release for blink.cmp
        version = "*",
        -- lazy.nvim will automatically load the plugin when it's required by blink.cmp
        lazy = true,
        -- make sure to set opts so that lazy.nvim calls blink.compat's setup
        opts = {},
    },
    {
        "L3MON4D3/LuaSnip",
        -- follow latest release.
        version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
        -- install jsregexp (optional!).
        build = "make install_jsregexp",
    },
    {
        "saghen/blink.cmp",
        dependencies = {
            "rafamadriz/friendly-snippets",
            "thomas-hiron/cmp-symfony",
            "giuxtaposition/blink-cmp-copilot",
            "Jezda1337/cmp_bootstrap"
        },
        version = "*",
        config = function()
            require("blink.cmp").setup({
                snippets = { preset = "luasnip" },
                signature = { enabled = false },
                appearance = {
                    use_nvim_cmp_as_default = false,
                    nerd_font_variant = "normal",
                },
                sources = {
                    default = {
                        "lsp",
                        "path",
                        "buffer",
                        "copilot",
                        "snippets",
                        "symfony_routes",
                        "twig",
                        "twig_constans",
                        "twig_templates",
                        "bootstrap",
                    },
                    providers = {
                        bootstrap = {
                            name = "cmp_bootstrap",
                            module = "blink.compat.source",
                            score_offset = 95,
                        },
                        copilot = {
                            name = "copilot",
                            module = "blink-cmp-copilot",
                            score_offset = 100,
                            async = true,

                        },
                        symfony_routes = {
                            name = "symfony_routes",
                            module = "blink.compat.source",
                            score_offset = 99,
                        },
                        twig = {
                            name = "twig",
                            module = "blink.compat.source",
                            score_offset = 99,
                        },
                        twig_constans = {
                            name = "twig_constans",
                            module = "blink.compat.source",
                            score_offset = 99,
                        },
                        translation = {
                            name = "translation",
                            module = "blink.compat.source",
                            score_offset = 99,
                        },
                        twig_templates = {
                            name = "twig_templates",
                            module = "blink.compat.source",
                            score_offset = 99,
                        },

                        buffer = {
                            name = "Buffer",
                            enabled = true,
                            max_items = 4,
                            module = "blink.cmp.sources.buffer",
                            min_keyword_length = 4,
                            score_offset = 66,
                        },
                        path = {
                            name = "Path",
                            module = "blink.cmp.sources.path",
                            score_offset = 71,
                            min_keyword_length = 4,
                            fallbacks = { "snippets", "buffer" },
                            opts = {
                                trailing_slash = false,
                                label_trailing_slash = true,
                                get_cwd = function(context)
                                    return vim.fn.expand(("#%d:p:h"):format(context.bufnr))
                                end,
                                show_hidden_files_by_default = true,
                            },
                        },
                        lsp = {
                            name = "lsp",
                            enabled = true,
                            module = "blink.cmp.sources.lsp",
                            score_offset = 96,
                        },

                        cmdline = {
                            min_keyword_length = 3,
                        },
                    },
                },
                keymap = {
                    preset = "enter",
                },
                cmdline = {
                    enabled = false,
                    completion = { menu = { auto_show = true } },
                    keymap = {
                        ["<CR>"] = { "accept_and_enter", "fallback" },
                    },
                },
                completion = {
                    list = {
                        selection = { preselect = true, auto_insert = true },
                    },
                    trigger = {
                        show_on_blocked_trigger_characters = { "", "\n", "\t" },
                    },
                    menu = {
                        border = "rounded",
                        scrolloff = 2,
                        scrollbar = false,
                        draw = {
                            columns = {
                                { "kind_icon" },
                                { "label",    gap = 1 },
                                { "kind",     gap = 1 },
                            },
                            components = {
                                kind_icon = {
                                    text = function(ctx)
                                        if vim.tbl_contains({ "Path" }, ctx.source_name) then
                                            local mini_icon, _ =
                                                require("mini.icons").get_icon(ctx.item.data.type, ctx.label)
                                            if mini_icon then
                                                return mini_icon .. ctx.icon_gap
                                            end
                                        end

                                        local icon = require("lspkind").symbolic(ctx.kind, { mode = "symbol" })
                                        return icon .. ctx.icon_gap
                                    end,

                                    -- Optionally, use the highlight groups from mini.icons
                                    -- You can also add the same function for `kind.highlight` if you want to
                                    -- keep the highlight groups in sync with the icons.
                                    highlight = function(ctx)
                                        if vim.tbl_contains({ "Path" }, ctx.source_name) then
                                            local mini_icon, mini_hl =
                                                require("mini.icons").get_icon(ctx.item.data.type, ctx.label)
                                            if mini_icon then
                                                return mini_hl
                                            end
                                        end
                                        return ctx.kind_hl
                                    end,
                                },
                                kind = {
                                    -- Optional, use highlights from mini.icons
                                    highlight = function(ctx)
                                        if vim.tbl_contains({ "Path" }, ctx.source_name) then
                                            local mini_icon, mini_hl =
                                                require("mini.icons").get_icon(ctx.item.data.type, ctx.label)
                                            if mini_icon then
                                                return mini_hl
                                            end
                                        end
                                        return ctx.kind_hl
                                    end,
                                },
                            },
                        },
                    },
                    documentation = {
                        window = {
                            border = "rounded",
                            scrollbar = false,
                        },
                        auto_show = false,
                        auto_show_delay_ms = 501,
                    },
                },
            })

            require("luasnip.loaders.from_vscode").lazy_load()
            require("luasnip.loaders.from_lua").lazy_load({
                paths = "~/.config/nvim/lua/snippets",
            })
        end,
    },
}
