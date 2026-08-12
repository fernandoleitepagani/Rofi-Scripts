#!/usr/bin/env bash
#
# rofi-sysinfo.sh
#

# --- CONFIGURATION ---
# Define your terminal here. Needed to open TUI apps like nmtui and wiremix.
# Example: TERMINAL="alacritty" or TERMINAL="kitty"
TERMINAL="foot" 

# --- MAIN MENU ITEMS ---
wifi='󰤨 WiFi'
user=' User'
bluetooth=' Bluetooth'
power_mode='󰐥 Power-Mode'
kernel='󰌽 Kernel'
uptime_o='󰥔 Uptime'
packages='󰏓 Packages'
audio='󰕾 Audio'

# --- SUB-MENU ITEMS ---
wifi_info='󰤨 Show WiFi Info'
wifi_open='󰤨 Open nmtui'

bt_info=' Show Bluetooth Info'
bt_open=' Open blueman-manager'

audio_info='󰕾 Show Audio Info'
audio_open='󰕾 Open wiremix'

notify() {
    # $1 = title, $2 = body
    notify-send -a "sysinfo" "$1" "$2"
}

get_wifi() {
    if ! command -v nmcli >/dev/null 2>&1; then
        notify "WiFi" "nmcli not found."
        return
    fi

    local info
    info="$(nmcli -t -f active,ssid,signal dev wifi 2>/dev/null | awk -F: '$1=="yes"{print $2"\t"$3; exit}')"

    if [ -z "$info" ]; then
        notify "WiFi" "Not connected."
        return
    fi

    local ssid="${info%%$'\t'*}"
    local signal="${info##*$'\t'}"
    notify "WiFi" "Connected to: ${ssid}"$'\n'"Signal strength: ${signal}%"
}

get_user() {
    notify "User" "$(whoami)@$(hostname)"
}

get_bluetooth() {
    if ! command -v bluetoothctl >/dev/null 2>&1; then
        notify "Bluetooth" "bluetoothctl not found."
        return
    fi

    local powered
    powered="$(bluetoothctl show 2>/dev/null | awk -F': ' '/Powered/{print $2}')"

    if [ "$powered" != "yes" ]; then
        notify "Bluetooth" "Off"
        return
    fi

    local connected=""
    while read -r _ mac name; do
        [ -z "$mac" ] && continue
        if bluetoothctl info "$mac" 2>/dev/null | grep -q "Connected: yes"; then
            connected="$name"
            break
        fi
    done < <(bluetoothctl devices 2>/dev/null)

    if [ -n "$connected" ]; then
        notify "Bluetooth" "On - Connected to: ${connected}"
    else
        notify "Bluetooth" "On - No device connected."
    fi
}

get_power_mode() {
    if ! command -v busctl >/dev/null 2>&1; then
        notify "Power Mode" "busctl not found (systemd missing?)."
        return
    fi

    local raw
    raw="$(busctl --json=short get-property net.hadess.PowerProfiles \
        /net/hadess/PowerProfiles net.hadess.PowerProfiles ActiveProfile 2>/dev/null)"

    if [ -z "$raw" ]; then
        notify "Power Mode" "power-profiles-daemon (or tuned-ppd) not running."
        return
    fi

    local profile
    profile="$(echo "$raw" | sed -n 's/.*"data":"\([^"]*\)".*/\1/p')"
    notify "Power Mode" "${profile:-Unknown}"
}

get_kernel() {
    notify "Kernel" "$(uname -r)"
}

get_uptime() {
    notify "Uptime" "$(uptime -p)"
}

get_packages() {
    local count=""
    if command -v rpm >/dev/null 2>&1; then
        count="$(rpm -qa | wc -l) packages (rpm)"
    elif command -v pacman >/dev/null 2>&1; then
        count="$(pacman -Qq | wc -l) packages (pacman)"
    elif command -v dpkg >/dev/null 2>&1; then
        count="$(dpkg -l | grep -c '^ii') packages (dpkg)"
    else
        count="No supported package manager found."
    fi

    if command -v flatpak >/dev/null 2>&1; then
        count="${count}"$'\n'"$(flatpak list --app 2>/dev/null | wc -l) flatpaks"
    fi

    notify "Packages" "$count"
}

get_audio() {
    if command -v wpctl >/dev/null 2>&1; then
        # PipeWire (WirePlumber) logic
        local vol_info="$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)"
        local vol_level="$(echo "$vol_info" | awk '{printf "%.0f%%", $2 * 100}')"
        local muted=""
        if echo "$vol_info" | grep -q "MUTED"; then
            muted=" (Muted)"
        fi
        
        local sink_name="$(wpctl inspect @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk -F '"' '/node.description/ {print $2}')"
        
        notify "Audio" "Output: ${sink_name:-Unknown}\nVolume: ${vol_level}${muted}"

    elif command -v pactl >/dev/null 2>&1; then
        # PulseAudio logic
        local default_sink="$(pactl get-default-sink 2>/dev/null)"
        local vol="$(pactl get-sink-volume "$default_sink" 2>/dev/null | awk -F'/' '/Volume:/ {print $2}' | tr -d ' %' | head -n 1)"
        local muted="$(pactl get-sink-mute "$default_sink" 2>/dev/null | awk '{print $2}')"
        local sink_name="$(pactl list sinks 2>/dev/null | grep -A 15 "Name: $default_sink" | grep "Description:" | cut -d':' -f2 | xargs)"
        
        local mute_str=""
        [ "$muted" = "yes" ] && mute_str=" (Muted)"
        
        notify "Audio" "Output: ${sink_name:-Unknown}\nVolume: ${vol}%${mute_str}"
    else
        notify "Audio" "Neither wpctl nor pactl found."
    fi
}

# If no argument is passed, output the main menu choices for Rofi to display
if [ -z "$1" ]; then
    printf '%s\n' "$wifi"  "$bluetooth" "$audio" "$power_mode" "$user" "$uptime_o" "$kernel" "$packages"
else
    # If an argument is passed, handle the action or draw the sub-menu
    case "$1" in
        # --- Main Menu to Sub-Menu routing ---
        "$wifi")        printf '%s\n' "$wifi_info" "$wifi_open" ;;
        "$bluetooth")   printf '%s\n' "$bt_info" "$bt_open" ;;
        "$audio")       printf '%s\n' "$audio_info" "$audio_open" ;;
        
        # --- Immediate Main Menu actions ---
        "$user")        get_user ;;
        "$power_mode")  get_power_mode ;;
	"$kernel")      get_kernel ;;
	"$uptime_o")    get_uptime ;;
	"$packages")    get_packages ;;
	# --- Sub-Menu Actions ---
	"$wifi_info")   get_wifi ;;
	"$wifi_open")   $TERMINAL -a floating_nmtui nmtui>/dev/null 2>&1 & ;;

	"$bt_info")     get_bluetooth ;;
	"$bt_open")     blueman-manager >/dev/null 2>&1 & ;;

	"$audio_info")  get_audio ;;
	"$audio_open")  $TERMINAL -a floating_wiremix wiremix >/dev/null 2>&1 & ;;
    esac
fi
