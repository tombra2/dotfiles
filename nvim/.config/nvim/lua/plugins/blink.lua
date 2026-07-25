return {
  {
    "L3MON4D3/LuaSnip",
    keys = {},
    opts = function(_, opts)
      -- LazyVim lädt ~/.config/nvim/snippets nur via from_vscode (JSON).
      -- Für die .lua-Snippets in diesem Ordner brauchen wir den from_lua-Loader.
      require("luasnip.loaders.from_lua").lazy_load({
        paths = { vim.fn.stdpath("config") .. "/snippets" },
      })
      return opts
    end,
  },

  {
    "saghen/blink.cmp",
    opts = {
      enabled = function()
        return vim.bo.filetype ~= "markdown"
      end,
      keymap = {
        preset = "none",
        ["<C-Space>"] = { "show" },
        ["<CR>"] = { "accept", "fallback" },
        ["<C-p>"] = { "select_prev", "fallback" },
        ["<C-n>"] = { "select_next", "fallback" },
        ["<C-e>"] = { "hide", "fallback" },
      },
      appearance = {
        nerd_font_variant = "normal",
      },

      signature = { enabled = false },

      sources = {
        providers = {
          cmdline = { min_keyword_length = 2 },
        },
      },

      cmdline = { enabled = true },

      completion = {
        trigger = {
          show_on_keyword = true,
          show_on_trigger_character = true,
        },

        menu = {
          auto_show = true,
          border = "rounded",
          scrolloff = 1,
          scrollbar = false,
          draw = {
            padding = 1,
            gap = 1,
            columns = {
              { "kind_icon" },
              { "label", "label_description", gap = 1 },
              { "kind" },
              { "source_name" },
            },
          },
        },
        list = {
          selection = { preselect = true, auto_insert = false },
        },
        documentation = {
          auto_show = false,
          window = {
            border = "rounded",
            scrollbar = false,
            winhighlight = "Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,EndOfBuffer:BlinkCmpDoc",
          },
        },
      },
      fuzzy = {
        sorts = { "score", "sort_text" },
      },
    },
  },
}
