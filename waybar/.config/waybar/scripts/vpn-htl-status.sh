#!/bin/bash
if nmcli connection show --active 2>/dev/null | grep -q "^HTL"; then
    echo '{"text": "󰌆", "tooltip": "HTL VPN: Verbunden\nKlick zum Trennen", "class": "active"}'
else
    echo '{"text": "󰌐", "tooltip": "HTL VPN: Getrennt\nKlick zum Verbinden", "class": "inactive"}'
fi
