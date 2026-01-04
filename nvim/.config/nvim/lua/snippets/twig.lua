local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

return {
	s(
		"tr",
		fmt("{{{{ '{}' | trans }}}}", {
			i(1, "translation.key"),
		})
	),

	s(
		"trd",
		fmt("{{{{ '{}'|trans({{}}, '{}') }}}}", {
			i(1, "translation.key"),
			i(2, "domain"),
		})
	),
}
