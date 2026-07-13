-- Extra autostart processes.
-- o.launch_on_start("my-service")

-- Populate workspaces on login. Placement is handled by the window rules
-- in hyprland.lua (WS2..WS10), so launch order does not matter here.

o.launch_on_start("kitty") -- WS2  terminal
o.launch_on_start("spotify") -- WS3
o.launch_on_start("thunderbird") -- WS4
o.launch_on_start("obsidian") -- WS9 (left 75%)
o.launch_on_start("chromium") -- WS10 browser
-- 1Password starts itself tray-only (--silent); startup.sh pops its WS6 window.

-- Web apps (omarchy-launch-webapp already runs through uwsm-app).
o.exec_on_start(o.launch_webapp("https://discord.com/app")) -- WS5
o.exec_on_start(o.launch_webapp("https://mantis.akaryon-services.com/")) -- WS7 (left 25%)
o.exec_on_start(o.launch_webapp("https://app.element.io/")) -- WS7 (right 75%)
o.exec_on_start(o.launch_webapp("https://web.whatsapp.com/")) -- WS8
o.exec_on_start(o.launch_webapp("https://app.todoist.com/app/today")) -- WS9 (right 25%)

-- Finalize: open 1Password window, wait for slow apps, land on WS2, then flip
-- placement from "silent" back to normal (waits for windows instead of guessing
-- a delay, so a slow app like Thunderbird can't steal the view afterwards).
o.exec_on_start("$HOME/.config/hypr/startup.sh")
