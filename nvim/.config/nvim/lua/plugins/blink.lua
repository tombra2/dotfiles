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
        ["<CR>"] = {
          function(cmp)
            local is_markup = vim.tbl_contains({ "html", "twig" }, vim.bo.filetype)
            local guard = vim.b.blink_emmet_enter_guard
            local cursor = vim.api.nvim_win_get_cursor(0)

            if
              is_markup
              and guard
              and guard.row == cursor[1]
              and guard.col == cursor[2]
              and guard.changedtick == vim.api.nvim_buf_get_changedtick(0)
            then
              vim.b.blink_emmet_enter_guard = nil
              cmp.hide()
              vim.schedule(function()
                vim.api.nvim_feedkeys(vim.keycode("<CR>"), "n", false)
              end)
              return true
            end

            vim.b.blink_emmet_enter_guard = nil
            local item = cmp.get_selected_item()
            if not (is_markup and item) then
              return
            end

            local client = item.client_id and vim.lsp.get_client_by_id(item.client_id) or nil
            local is_emmet = (client and client.name == "emmet_language_server") or item.detail == "Emmet Abbreviation"
            if not is_emmet then
              return
            end

            local bufnr = vim.api.nvim_get_current_buf()
            return cmp.accept({
              callback = function()
                local accepted_at = vim.api.nvim_win_get_cursor(0)
                vim.b[bufnr].blink_emmet_enter_guard = {
                  row = accepted_at[1],
                  col = accepted_at[2],
                  changedtick = vim.api.nvim_buf_get_changedtick(bufnr),
                }
                cmp.hide()
              end,
            })
          end,
          "accept",
          "fallback",
        },
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
          selection = {
            preselect = function()
              local is_html = vim.tbl_contains({ "html", "twig" }, vim.bo.filetype)
              return not (is_html and require("luasnip").in_snippet())
            end,
            auto_insert = false,
          },
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
