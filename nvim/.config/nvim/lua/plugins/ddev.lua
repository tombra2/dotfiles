-- DDEV-Integration: Keymaps (<leader>D…) + Status-Indikator in der Lualine.
-- Status wird asynchron geholt und gecacht, damit die Statusline nicht bei
-- jedem Redraw ein ddev-Kommando startet.

local M = { project = false, running = false, pending = false }

-- Sind wir in einem DDEV-Projekt? (.ddev/ irgendwo unterhalb von cwd)
function M.in_project()
  return vim.fn.isdirectory(".ddev") == 1
end

-- Status asynchron aktualisieren und Statusline neu zeichnen.
function M.refresh()
  M.project = M.in_project()
  if not M.project or vim.fn.executable("ddev") == 0 then
    M.running = false
    return
  end
  if M.pending then
    return
  end
  M.pending = true
  vim.system({ "ddev", "describe", "-j" }, { text = true }, function(out)
    M.pending = false
    local running = false
    if out.code == 0 then
      local ok, data = pcall(vim.json.decode, out.stdout)
      if ok and data and data.raw and data.raw.status == "running" then
        running = true
      end
    end
    M.running = running
    vim.schedule(function()
      vim.cmd("redrawstatus")
    end)
  end)
end

-- ddev-Kommando async ausführen, Ergebnis als Notify, danach Status refreshen.
function M.run(args)
  vim.notify("ddev " .. table.concat(args, " ") .. " …", vim.log.levels.INFO, { title = "DDEV" })
  vim.system(vim.list_extend({ "ddev" }, vim.deepcopy(args)), { text = true }, function(out)
    vim.schedule(function()
      if out.code == 0 then
        vim.notify("ddev " .. args[1] .. " ✓", vim.log.levels.INFO, { title = "DDEV" })
      else
        local msg = (out.stderr ~= "" and out.stderr) or out.stdout or "Fehler"
        vim.notify(msg, vim.log.levels.ERROR, { title = "DDEV" })
      end
      M.refresh()
    end)
  end)
end

-- ddev describe in einem (Floating-)Terminal anzeigen.
function M.describe()
  local ok, snacks = pcall(require, "snacks")
  if ok and snacks.terminal then
    snacks.terminal("ddev describe")
  else
    vim.cmd("botright new | terminal ddev describe")
  end
end

return {
  -- Keymaps + Which-Key-Gruppe
  {
    "folke/which-key.nvim",
    opts = function(_, opts)
      opts.spec = opts.spec or {}
      vim.list_extend(opts.spec, {
        { "<leader>k", group = "ddev", icon = "" },
        {
          "<leader>ks",
          function()
            M.run({ "start" })
          end,
          desc = "Start",
          icon = "",
        },
        {
          "<leader>kS",
          function()
            M.run({ "stop" })
          end,
          desc = "Stop",
          icon = "",
        },
        {
          "<leader>kr",
          function()
            M.run({ "restart" })
          end,
          desc = "Restart",
          icon = "",
        },
        {
          "<leader>kd",
          function()
            M.describe()
          end,
          desc = "Describe",
          icon = "",
        },
        {
          "<leader>kl",
          function()
            M.run({ "launch" })
          end,
          desc = "Launch",
          icon = "",
        },
        {
          "<leader>km",
          function()
            M.run({ "mailpit" })
          end,
          desc = "Mailpit",
          icon = "",
        },
      })
    end,
  },

  -- Status-Indikator in der Lualine
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      -- Status bei Start / Verzeichniswechsel / Fokus aktualisieren
      vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged", "FocusGained" }, {
        callback = function()
          M.refresh()
        end,
      })
      M.refresh()

      table.insert(opts.sections.lualine_x, 1, {
        function()
          return (M.running and "●" or "○") .. " ddev"
        end,
        cond = function()
          return M.project
        end,
        color = function()
          return { fg = M.running and "#a6e3a1" or "#f38ba8" }
        end,
      })
    end,
  },
}
