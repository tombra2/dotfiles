return {
  {
    "omacom/aether.nvim",
    branch = "v3",
    name = "aether",
    priority = 1000,
    opts = {
      -- JetBrains syntax roles, not Aether's default palette assignments.
      styles = {
        keywords = { italic = false },
        comments = { italic = false },
      },
      on_highlights = function(hl, c)
        local function set(groups, color, style)
          for _, group in ipairs(groups) do
            hl[group] = vim.tbl_extend("force", { fg = color }, style or {})
          end
        end
        set({
          "Keyword", "Conditional", "Repeat", "Exception", "Include",
          "StorageClass", "Statement", "Boolean",
          "@keyword", "@keyword.function", "@keyword.import",
          "@keyword.conditional", "@keyword.repeat", "@keyword.return",
          "@keyword.exception", "@keyword.storage", "@keyword.modifier",
          "@keyword.operator", "@type.builtin",
          "@lsp.type.keyword", "@lsp.type.modifier",
        }, c.orange)
        set({
          "Normal", "Identifier", "Type", "Structure", "Typedef",
          "Operator", "Delimiter",
          "@type", "@type.definition", "@constructor", "@module",
          "@variable", "@variable.parameter", "@variable.builtin",
          "@operator", "@punctuation.bracket", "@punctuation.delimiter",
          "@lsp.type.class", "@lsp.type.interface", "@lsp.type.enum",
          "@lsp.type.struct", "@lsp.type.type", "@lsp.type.namespace",
          "@lsp.type.variable", "@lsp.type.parameter",
        }, c.fg)
        -- Method calls are neutral; only declarations are blue.
        set({ "Function", "@function", "@function.method" }, c.blue)
        set({
          "@function.call", "@function.method.call", "@function.builtin",
          "@lsp.type.function", "@lsp.type.method",
        }, c.fg)
        set({
          "@lsp.typemod.function.declaration", "@lsp.typemod.method.declaration",
          "@lsp.typemod.function.definition", "@lsp.typemod.method.definition",
        }, c.blue)
        set({
          "Constant", "@constant", "@constant.builtin",
          "@property", "@variable.member", "@lsp.type.property",
          "@lsp.type.enumMember",
        }, c.magenta, { italic = true })
        set({ "String", "Character", "@string", "@character", "@character.printf" }, c.green)
        set({ "Number", "Float", "@number", "@number.float" }, c.cyan)
        set({ "@string.escape", "SpecialChar" }, c.orange)
        set({ "Comment", "@comment" }, c.muted)
        set({ "@comment.documentation", "@string.documentation" }, "#5f826b")
        set({ "PreProc", "@attribute", "@annotation", "@lsp.type.decorator" }, "#b3ae60")
        set({ "@lsp.type.typeParameter" }, "#16baac")
        hl.Normal.bg = c.bg
        hl.RainbowDelimiterYellow = { fg = c.bright_yellow }
        hl.RainbowDelimiterGreen = { fg = c.green }
        hl.RainbowDelimiterBlue = { fg = c.blue }
        hl.CursorLine = { bg = "#1f2024" }
        hl.LspInlayHint = { fg = "#868a91", bg = "#393b40" }
        -- Java-specific groups also override language-qualified defaults.
        for _, group in ipairs({
          "@keyword", "@keyword.import", "@keyword.modifier", "@keyword.return",
          "@type.builtin", "@type", "@constructor", "@module", "@variable",
          "@variable.member", "@variable.parameter", "@function",
          "@function.call", "@function.method", "@function.method.call",
          "@string", "@character.printf",
        }) do
          if hl[group] then
            hl[group .. ".java"] = vim.deepcopy(hl[group])
          end
        end
      end,
      colors = {
        bg = "#191a1c",
        dark_bg = "#191a1c",
        darker_bg = "#191a1c",
        lighter_bg = "#1f2024",

        fg = "#bcbec4",
        dark_fg = "#6f737a",
        light_fg = "#ced0d6",
        bright_fg = "#dfe1e5",
        muted = "#7a7e85",

        red = "#f75464",
        yellow = "#d5b778",
        orange = "#cf8e6d",
        green = "#6aab73",
        cyan = "#2aacb8",
        blue = "#56a8f5",
        magenta = "#c77dbb",
        brown = "#857042",

        bright_red = "#fa6675",
        bright_yellow = "#e0bb65",
        bright_green = "#73bd79",
        bright_cyan = "#42c3d4",
        bright_blue = "#57aaf7",
        bright_magenta = "#cf84cf",

        accent = "#548af7",
        cursor = "#dfe1e5",
        foreground = "#bcbec4",
        background = "#191a1c",
        selection = "#2b2d30",
        selection_foreground = "#dfe1e5",
        selection_background = "#2b2d30",
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "aether",
    },
  },
}
