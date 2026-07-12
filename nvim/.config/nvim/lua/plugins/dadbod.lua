return {
  "kristijanhusak/vim-dadbod-ui",
  init = function()
    -- Liest die DDEV-DB-Verbindung dynamisch aus, da sich der
    -- veröffentlichte Host-Port bei jedem `ddev start` ändern kann.
    -- Das Schema richtet sich nach dem DB-Typ (postgres / mariadb / mysql).
    local function ddev_db_url()
      -- Nur in einem DDEV-Projekt versuchen (sonst günstig überspringen).
      if vim.fn.executable("ddev") == 0 or vim.fn.isdirectory(".ddev") == 0 then
        return nil
      end

      local json = vim.fn.system({ "ddev", "describe", "-j" })
      if vim.v.shell_error ~= 0 then
        return nil
      end

      local ok, data = pcall(vim.json.decode, json)
      if not ok or type(data) ~= "table" then
        return nil
      end

      local db = data.raw and data.raw.dbinfo
      if not db or not db.published_port then
        return nil
      end

      -- DDEV-DB-Typ -> dadbod-URL-Schema
      local schemes = {
        postgres = "postgresql",
        postgresql = "postgresql",
        mariadb = "mysql",
        mysql = "mysql",
      }
      local scheme = schemes[db.database_type] or "postgresql"

      return string.format(
        "%s://%s:%s@127.0.0.1:%s/%s",
        scheme,
        db.username or "db",
        db.password or "db",
        db.published_port,
        db.dbname or "db"
      )
    end

    local url = ddev_db_url()
    if url then
      vim.g.dbs = {
        { name = "ddev", url = url },
      }
    end
  end,
}
