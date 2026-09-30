#!/usr/bin/env bash
set -euo pipefail

# Create and configure this NetworkManager VPN profile in the desktop network
# settings. NetworkManager's secret agent handles credentials; none are stored
# in this script. The script never connects automatically.
VPN_CONNECTION="Schul-VPN"

case "${1:-status}" in
  up) nmcli connection up id "$VPN_CONNECTION" ;;
  down) nmcli connection down id "$VPN_CONNECTION" ;;
  status) nmcli -t -f NAME,TYPE connection show --active | awk -F: -v n="$VPN_CONNECTION" '$1 == n && $2 == "vpn" { print "up"; found=1 } END { if (!found) print "down" }' ;;
  *) echo "usage: $0 {up|down|status}" >&2; exit 2 ;;
esac
