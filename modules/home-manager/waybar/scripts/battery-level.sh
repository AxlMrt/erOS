#!/usr/bin/env bash

set -euo pipefail

theme_env="$HOME/.config/eros/active/theme/colors.env"
if [ -f "$theme_env" ]; then
  # shellcheck disable=SC1090
  . "$theme_env"
fi

warn_color="${EROS_COLOR_WARNING}"

if [ -z "${DBUS_SESSION_BUS_ADDRESS:-}" ]; then
  export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
fi

# battery levels
WARNING_LEVEL=20
CRITICAL_LEVEL=10

# get the battery state and percentage using upower (waybar dependency)
BAT_PATH=$(upower -e | grep BAT | head -n 1)
if [ -z "$BAT_PATH" ]; then
  exit 0
fi

BATTERY_STATE=$(upower -i "$BAT_PATH" | awk '/state:/ {print $2}')
BATTERY_LEVEL=$(upower -i "$BAT_PATH" | awk '/percentage:/ {print $2}' | tr -d '%')
if ! [[ "$BATTERY_LEVEL" =~ ^[0-9]+$ ]]; then
  exit 0
fi

# prevent multiple notifications
FILE_FULL=/tmp/battery-full
FILE_WARNING=/tmp/battery-warning
FILE_CRITICAL=/tmp/battery-critical

# remove the files if the battery is no longer in that state
if [ "$BATTERY_STATE" == "discharging" ]; then
  rm -f "$FILE_FULL"
elif [ "$BATTERY_STATE" == "charging" ]; then
  rm -f "$FILE_WARNING" "$FILE_CRITICAL"
fi

# if the battery is full and is plugged in
if [ "$BATTERY_LEVEL" -eq 100 ] && [ "$BATTERY_STATE" == "fully-charged" ] && [ ! -f $FILE_FULL ]; then
  notify-send -a "state" "Battery Charged (${BATTERY_LEVEL}%)" "You might want to unplug your PC." -i "battery-full" -r 9991
  touch "$FILE_FULL"

# if the battery is low and is discharging
elif [ "$BATTERY_LEVEL" -le $WARNING_LEVEL ] && [ "$BATTERY_STATE" == "discharging" ] && [ ! -f $FILE_WARNING ]; then
  notify-send -a "state" "Battery Low (${BATTERY_LEVEL}%)" "You might want to plug in your PC." -u critical -i "battery-caution" -r 9991 -h "string:fgcolor:${warn_color}" -h "string:frcolor:${warn_color}"
  touch "$FILE_WARNING"

# if the battery is critical and is discharging
elif [ "$BATTERY_LEVEL" -le $CRITICAL_LEVEL ] && [ "$BATTERY_STATE" == "discharging" ] && [ ! -f $FILE_CRITICAL ]; then
  notify-send -a "state" "Battery Critical (${BATTERY_LEVEL}%)" "Plug in your PC now." -u critical -i "battery-empty" -r 9991
  touch "$FILE_CRITICAL"
fi
