-- Extra autostart processes.
-- o.launch_on_start("my-service")
o.launch_on_start("kitty") -- WS2  terminal
o.launch_on_start("spotify") -- WS3
o.launch_on_start("thunderbird") -- WS4
o.launch_on_start("obsidian") -- WS9 (left 75%)
o.launch_on_start("chromium") -- WS10 browser
o.launch_on_start("element-desktop") -- WS7 (right 75%)

o.exec_on_start(o.launch_webapp("https://discord.com/app")) -- WS5
o.exec_on_start(o.launch_webapp("https://mantis.akaryon-services.com/")) -- WS7 (left 25%)
o.exec_on_start(o.launch_webapp("https://web.whatsapp.com/")) -- WS8
o.exec_on_start("$HOME/.config/hypr/startup.sh")
