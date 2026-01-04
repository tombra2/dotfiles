return {
    "monaqa/dial.nvim",
    opts = function(_, opts)
        local augend = require("dial.augend")

        local logic_states = augend.constant.new({
            elements = { "LOW", "HIGH" },
            word = true,
            cyclic = true,
        })

        local pin_modes = augend.constant.new({
            elements = { "INPUT", "OUTPUT" },
            word = true,
            cyclic = true,
        })
        local wochentage = augend.constant.new({
            elements = { "Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag", "Sonntag" },
            word = true,
            cyclic = true,
        })

        table.insert(opts.groups.default, logic_states)
        table.insert(opts.groups.default, wochentage)
        table.insert(opts.groups.default, pin_modes)
    end,
}
