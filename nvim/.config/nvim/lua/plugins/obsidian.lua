return {
  "obsidian-nvim/obsidian.nvim",
  version = "*",
  lazy = true,
  ft = "markdown",
  -- Nur in deinen Vaults laden (Pfade anpassen):
  -- event = {
  --   "BufReadPre " .. vim.fn.expand("~") .. "/vaults/**.md",
  --   "BufNewFile " .. vim.fn.expand("~") .. "/vaults/**.md",
  -- },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "ibhagwan/fzf-lua", -- muss geladen sein, damit der Picker verfügbar ist
  },
  opts = {
    workspaces = {
      {
        name = "personal",
        path = "~/Documents",
      },
    },

    notes_subdir = "notes",
    new_notes_location = "notes_subdir",

    -- Neue Command-Syntax (`:Obsidian backlinks`); alte Aliase abschalten
    legacy_commands = false,

    -- Eindeutige IDs (Zettelkasten-Stil: timestamp + slug)
    note_id_func = function(title)
      local suffix = ""
      if title ~= nil then
        suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
      else
        for _ = 1, 4 do
          suffix = suffix .. string.char(math.random(65, 90))
        end
      end
      return tostring(os.time()) .. "-" .. suffix
    end,

    daily_notes = {
      folder = "dailies",
      date_format = "%Y-%m-%d",
      template = nil,
    },

    templates = {
      folder = "templates",
      date_format = "%Y-%m-%d",
      time_format = "%H:%M",
    },

    picker = {
      name = "fzf-lua", -- oder "telescope.nvim" / "mini.pick" / "snacks.pick"
    },

    ui = {
      enable = false, -- bei render-markdown.nvim auf false lassen, sonst Konflikt
    },

    -- Hinweis: completion (blink/nvim_cmp) und follow_url_func entfernt.
    -- Completion läuft jetzt über den eingebauten obsidian-ls LSP-Server,
    -- Links öffnet der Fork über vim.ui.open (nutzt xdg-open auf Linux).
  },
  keys = {
    { "<leader>on", "<cmd>Obsidian new<cr>", desc = "New note" },
    { "<leader>oo", "<cmd>Obsidian open<cr>", desc = "Open in Obsidian" },
    { "<leader>os", "<cmd>Obsidian search<cr>", desc = "Search notes" },
    { "<leader>od", "<cmd>Obsidian today<cr>", desc = "Daily note" },
    { "<leader>ob", "<cmd>Obsidian backlinks<cr>", desc = "Backlinks" },
    { "<leader>ot", "<cmd>Obsidian template<cr>", desc = "Insert template" },
    { "<leader>of", "<cmd>Obsidian follow_link<cr>", desc = "Follow link" },
    { "<leader>oq", "<cmd>Obsidian quick_switch<cr>", desc = "Quick switch" },
  },
}
