local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

ls.add_snippets("cpp", {
    s("ard", {
        t("// Copyright (c) "), i(1, "2026"), t(" "), i(2, "Thomas Brandner"), t({ "", "" }),
        t({ "#include <Arduino.h>", "", "" }),
        t({ "void setup() {", "  " }), i(3), t({ "", "}", "" }),
        t({ "", "void loop() {", "  " }), i(0), t({ "", "}" }),
    }),
})
