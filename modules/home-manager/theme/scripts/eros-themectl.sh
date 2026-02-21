set -euo pipefail

xdg_config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
xdg_state_home="${XDG_STATE_HOME:-$HOME/.local/state}"
active_root="$xdg_config_home/eros/active"
state_root="$xdg_state_home/eros/theme"
current_theme_file="$state_root/current-theme"

default_theme=@DEFAULT_THEME@

mkdir -p "$active_root" "$state_root"

theme_path() {
  case "$1" in
@THEME_CASES@
    *) return 1 ;;
  esac
}

list_themes() {
  cat @THEME_LIST_FILE@
}

get_theme() {
  if [ -s "$current_theme_file" ]; then
    cat "$current_theme_file"
  else
    echo "$default_theme"
  fi
}

set_theme_file() {
  printf '%s\n' "$1" > "$current_theme_file"
}

next_theme() {
  local current="$1"
  local names
  local idx=0
  local total
  names="$(list_themes)"
  total="$(printf '%s\n' "$names" | sed '/^$/d' | wc -l | tr -d ' ')"
  if [ "$total" -le 0 ]; then
    echo "$default_theme"
    return
  fi

  idx="$(printf '%s\n' "$names" | sed '/^$/d' | nl -v 0 -w 1 -s ':' | grep ":$current$" | cut -d: -f1 || true)"
  if ! printf '%s' "$idx" | grep -Eq '^[0-9]+$'; then
    idx=0
  fi
  idx=$(( (idx + 1) % total ))
  printf '%s\n' "$names" | sed '/^$/d' | sed -n "$((idx + 1))p"
}

ensure_swww() {
  if ! command -v swww >/dev/null 2>&1 || ! command -v swww-daemon >/dev/null 2>&1; then
    return 1
  fi
  if ! swww query >/dev/null 2>&1; then
    swww-daemon >/dev/null 2>&1 &
    disown || true
    for _ in $(seq 1 30); do
      if swww query >/dev/null 2>&1; then
        break
      fi
      sleep 0.1
    done
  fi
}

set_wallpaper_by_mode() {
  local theme="$1"
  local mode="$2"
  local theme_dir
  local list_file
  local index_file
  local default_wallpaper
  local count
  local index=0
  local wallpaper

  theme_dir="$(theme_path "$theme")"
  list_file="$theme_dir/wallpapers.txt"
  index_file="$state_root/wallpaper-index-$theme"
  default_wallpaper="$(cat "$theme_dir/default-wallpaper.txt")"

  if [ ! -s "$list_file" ]; then
    return 0
  fi

  count="$(wc -l < "$list_file" | tr -d ' ')"
  if [ "$count" -le 0 ]; then
    return 0
  fi

  if [ -f "$index_file" ]; then
    index="$(cat "$index_file")"
  fi
  if ! printf '%s' "$index" | grep -Eq '^[0-9]+$'; then
    index=0
  fi
  if [ "$index" -ge "$count" ]; then
    index=$((index % count))
  fi

  if [ "$mode" = "next" ]; then
    index=$(( (index + 1) % count ))
  elif [ "$mode" = "default" ]; then
    if [ -n "$default_wallpaper" ]; then
      local i=0
      while IFS= read -r line; do
        if [ "$line" = "$default_wallpaper" ]; then
          index="$i"
          break
        fi
        i=$((i + 1))
      done < "$list_file"
    else
      index=0
    fi
  fi

  printf '%s\n' "$index" > "$index_file"
  wallpaper="$(sed -n "$((index + 1))p" "$list_file")"
  if [ -z "$wallpaper" ] || [ ! -f "$wallpaper" ]; then
    return 0
  fi

  ensure_swww || return 0
  swww img "$wallpaper" --resize crop
}

apply_theme_artifacts() {
  local theme="$1"
  local reload="$2"
  local theme_dir
  theme_dir="$(theme_path "$theme")"

  ln -sfn "$theme_dir" "$active_root/theme"

  if [ -f "$active_root/theme/settings.env" ]; then
    # shellcheck disable=SC1090
    . "$active_root/theme/settings.env"
  fi

  if command -v gsettings >/dev/null 2>&1; then
    gsettings set org.gnome.desktop.interface gtk-theme "$EROS_GTK_THEME" >/dev/null 2>&1 || true
    gsettings set org.gnome.desktop.interface icon-theme "$EROS_ICON_THEME" >/dev/null 2>&1 || true
    gsettings set org.gnome.desktop.interface cursor-theme "$EROS_CURSOR_THEME" >/dev/null 2>&1 || true
    gsettings set org.gnome.desktop.interface cursor-size "$EROS_CURSOR_SIZE" >/dev/null 2>&1 || true
    if [ "$EROS_THEME_KIND" = "dark" ]; then
      gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' >/dev/null 2>&1 || true
    else
      gsettings set org.gnome.desktop.interface color-scheme 'prefer-light' >/dev/null 2>&1 || true
    fi
  fi

  mkdir -p "$HOME/.icons/default"
  cat > "$HOME/.icons/default/index.theme" <<EOF
[Icon Theme]
Inherits=$EROS_CURSOR_THEME
EOF

  if command -v kitty >/dev/null 2>&1; then
    kitty @ set-colors -a -c "$active_root/theme/kitty.conf" >/dev/null 2>&1 || true
  fi

  if [ "$reload" = "1" ]; then
    if ! command -v systemctl >/dev/null 2>&1 || ! systemctl --user restart waybar.service >/dev/null 2>&1; then
      pkill -x waybar >/dev/null 2>&1 || true
      sleep 0.05
      @WAYBAR_BIN@ >/dev/null 2>&1 &
      disown || true
    fi

    hyprctl reload >/dev/null 2>&1 || true

    pkill -x swaync >/dev/null 2>&1 || true
    swaync >/dev/null 2>&1 &
    disown || true
  fi
}

cmd="${1:-help}"
case "$cmd" in
  init)
    theme="$(get_theme)"
    if ! theme_path "$theme" >/dev/null 2>&1; then
      theme="$default_theme"
      set_theme_file "$theme"
    fi
    apply_theme_artifacts "$theme" 0
    set_wallpaper_by_mode "$theme" current
    ;;

  list)
    list_themes
    ;;

  get)
    get_theme
    ;;

  set)
    theme="${2:-}"
    if [ -z "$theme" ]; then
      echo "usage: eros-themectl set <theme>" >&2
      exit 1
    fi
    if ! theme_path "$theme" >/dev/null 2>&1; then
      echo "unknown theme: $theme" >&2
      exit 1
    fi
    set_theme_file "$theme"
    apply_theme_artifacts "$theme" 1
    set_wallpaper_by_mode "$theme" default
    ;;

  next)
    current="$(get_theme)"
    theme="$(next_theme "$current")"
    set_theme_file "$theme"
    apply_theme_artifacts "$theme" 1
    set_wallpaper_by_mode "$theme" default
    ;;

  apply)
    theme="$(get_theme)"
    apply_theme_artifacts "$theme" 1
    set_wallpaper_by_mode "$theme" current
    ;;

  wallpaper)
    sub="${2:-next}"
    theme="$(get_theme)"
    case "$sub" in
      next|current|default) set_wallpaper_by_mode "$theme" "$sub" ;;
      *)
        echo "usage: eros-themectl wallpaper [next|current|default]" >&2
        exit 1
        ;;
    esac
    ;;

  menu-theme)
    selection=""
    if command -v rofi >/dev/null 2>&1; then
      selection="$(list_themes | rofi -dmenu -i -p 'Theme' -theme "$active_root/theme/rofi.rasi")"
    else
      echo "rofi not available" >&2
      exit 1
    fi
    if [ -n "$selection" ]; then
      "$0" set "$selection"
    fi
    ;;

  status-theme)
    theme="$(get_theme)"
    echo "{\"text\":\"󰔎\",\"tooltip\":\"Active theme: $theme\"}"
    ;;

  status-wallpaper)
    echo "{\"text\":\"󰸉\",\"tooltip\":\"Next wallpaper\"}"
    ;;

  *)
    cat <<'EOF'
usage: eros-themectl <command>
  init
  list
  get
  set <theme>
  next
  apply
  wallpaper [next|current|default]
  menu-theme
  status-theme
  status-wallpaper
EOF
    ;;
esac
