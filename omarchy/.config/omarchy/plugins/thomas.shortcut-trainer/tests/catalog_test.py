import importlib.util
import pathlib
import unittest

spec = importlib.util.spec_from_file_location("catalog", pathlib.Path(__file__).parents[1] / "catalog.py")
catalog = importlib.util.module_from_spec(spec)
spec.loader.exec_module(catalog)


class CatalogTests(unittest.TestCase):
    def test_ghostty_effective_bindings(self):
        tasks = catalog.ghostty_tasks("\n".join([
            "keybind = ctrl+==increase_font_size:1",
            "keybind = ctrl++=increase_font_size:1",
            "keybind = shift+enter=csi:13;2u",
            "keybind = ctrl+x=unbind",
        ]))
        self.assertEqual(len(tasks), 3)
        self.assertEqual(tasks[0]["label"], "Ctrl + =")
        self.assertEqual(tasks[1]["label"], "Ctrl + +")
        self.assertTrue(all(not t["trainable"] for t in tasks))
        self.assertIn("csi:13;2u", tasks[2]["description"])

    def test_herdr_prefix_variants_and_custom_command(self):
        tasks = catalog.herdr_tasks('''
[keys]
prefix = "ctrl+space"
split_vertical = "prefix+v"
switch_tab = ["prefix+1..9", "alt+1..9"]
focus_pane_up = ["ctrl+k", "ctrl+up"]
[[keys.command]]
key = "ctrl+f"
type = "popup"
command = "DO NOT EXECUTE THIS"
description = "<img src='https://invalid'>"
''')
        self.assertEqual(len(tasks), 23)
        self.assertEqual(tasks[1]["label"], "Ctrl + Space → V")
        self.assertEqual(len({t["id"] for t in tasks}), len(tasks))
        self.assertIn("<img", tasks[-1]["description"])
        self.assertNotIn("DO NOT EXECUTE", str(tasks))
        self.assertTrue(all(t["source"] == "herdr" for t in tasks))

    def test_unknown_prefix_is_not_guessed(self):
        self.assertEqual(catalog.herdr_tasks('[keys]\nnew_tab="prefix+n"'), [])

    def test_bash_defaults_are_explicit(self):
        tasks = catalog.bash_tasks()
        self.assertTrue(any(t["id"] == "bash:ctrl+a" for t in tasks))
        self.assertTrue(all("Emacs-Standard" in t["description"] for t in tasks))


if __name__ == "__main__":
    unittest.main()
