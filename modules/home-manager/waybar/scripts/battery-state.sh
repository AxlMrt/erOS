#!/usr/bin/env bash

set -euo pipefail

if [ -z "${DBUS_SESSION_BUS_ADDRESS:-}" ]; then
  export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
fi

# get the battery state from the udev rule
BATTERY_STATE=$1

if [ "$BATTERY_STATE" != "charging" ] && [ "$BATTERY_STATE" != "discharging" ]; then
  exit 0
fi

# get the battery percentage using upower (waybar dependency)
BAT_PATH=$(upower -e | grep BAT | head -n 1)
if [ -z "$BAT_PATH" ]; then
  exit 0
fi

BATTERY_LEVEL=$(upower -i "$BAT_PATH" | awk '/percentage:/ {print $2}' | tr -d '%')
if ! [[ "$BATTERY_LEVEL" =~ ^[0-9]+$ ]]; then
  exit 0
fi

# set the battery charging state and icon
case "$BATTERY_STATE" in
"charging")
  BATTERY_CHARGING="Charging"
  BATTERY_ICON="090-charging"
  ;;
"discharging")
  BATTERY_CHARGING="Discharging"
  BATTERY_ICON="090"
  ;;
esac

# send the notification
notify-send -a "state" "Battery ${BATTERY_CHARGING} (${BATTERY_LEVEL}%)" -u normal -i "battery-${BATTERY_ICON}" -r 9991
