local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

local function filename()
  return vim.fn.expand("%:t:r")
end

local function namespace()
  local path = vim.fn.expand("%:.:h")
  local ns = path:match("src/(.*)")

  if not ns then
    return "App"
  end

  ns = ns:gsub("/", "\\")
  return "App\\" .. ns
end

ls.add_snippets("php", {
  -- public function
  s("pubf", {
    t("public function "),
    i(1, "name"),
    t("("),
    i(2),
    t("): "),
    i(3, "void"),
    t({ "", "{", "    " }),
    i(0),
    t({ "", "}" }),
  }),

  -- private function
  s("prif", {
    t("private function "),
    i(1, "name"),
    t("("),
    i(2),
    t("): "),
    i(3, "void"),
    t({ "", "{", "    " }),
    i(0),
    t({ "", "}" }),
  }),

  -- protected function
  s("prof", {
    t("protected function "),
    i(1, "name"),
    t("("),
    i(2),
    t("): "),
    i(3, "void"),
    t({ "", "{", "    " }),
    i(0),
    t({ "", "}" }),
  }),
  s("class", {
    t({ "<?php", "", "declare(strict_types=1);", "", "namespace " }),
    f(namespace),
    t({ ";", "", "class " }),
    t(filename()),
    t({ "", "{", "    " }),
    i(0),
    t({ "", "}" }),
  }),
})
