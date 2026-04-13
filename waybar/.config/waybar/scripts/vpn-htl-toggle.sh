#!/bin/bash
if nmcli connection show --active 2>/dev/null | grep -q "^HTL"; then
    nmcli connection down HTL
else
    nmcli connection up HTL
fi
pkill -RTMIN+11 waybar
