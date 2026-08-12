#!/usr/bin/env bash

MPRIS_CTL=0
PLAYERCTL=1
MPRIS_CONTROLLER=""

# Symbols for display
declare -A labels=(
    ["play"]="󰐊 Play"
    ["pause"]="󰏤 Pause"
    ["play_pause"]="󰐎 Play/Pause"
    ["stop"]="󰓛 Stop"
    ["next"]="󰒭 Next"
    ["prev"]="󰒮 Previous"
    ["shuffle"]="󰒝 Shuffle"
)

options=(
    "play_pause"
    "prev"
    "next"
    "stop"
    "shuffle"
)

detect_controller() {
    if hash mpris-ctl 2>/dev/null; then
        MPRIS_CONTROLLER=$MPRIS_CTL
    elif hash playerctl 2>/dev/null; then
        MPRIS_CONTROLLER=$PLAYERCTL
    else
        echo "No mpris-ctl or playerctl in \$PATH."
        exit 1
    fi
}

get_players_mpris_ctl() {
    mpris-ctl --player active --player inactive list 2>/dev/null
}

get_players_playerctl() {
    playerctl -l 2>/dev/null
}

get_players() {
    if [[ "$MPRIS_CONTROLLER" == "$MPRIS_CTL" ]]; then
        get_players_mpris_ctl
    else
        get_players_playerctl
    fi
}

get_player_info_mpris_ctl() {
    local player="$1"
    local status
    local info
    
    status="$(mpris-ctl --player "$player" status)"
    if [[ "$status" == "Playing" ]]; then
        status="▶"
    else
        status="⏸"
    fi
    
    info="$(mpris-ctl --player "$player" info "%player_name - %track_name")"
    echo "$status $info"
}

get_player_info_playerctl() {
    local player="$1"
    local status
    local info
    
    status="$(playerctl -p "$player" status)"
    if [[ "$status" == "Playing" ]]; then
        status="▶"
    else
        status="⏸"
    fi
    
    info="$(playerctl -p "$player" metadata --format "{{playerName}} - {{title}}")"
    echo "$status $info"
}

get_player_info() {
    local player="$1"
    if [[ "$MPRIS_CONTROLLER" == "$MPRIS_CTL" ]]; then
        get_player_info_mpris_ctl "$player"
    else
        get_player_info_playerctl "$player"
    fi
}

select_player() {
    local players
    local player_list
    local selected
    
    players="$(get_players)"
    
    if [[ -z "$players" ]]; then
        rofi -e "No MPRIS players running."
        exit 1
    fi
    
    # Build player list with info
    player_list=""
    while IFS= read -r player; do
        info="$(get_player_info "$player")"
        player_list+="$info"$'\n'
    done <<< "$players"
    
    # Remove trailing newline to prevent empty option
    player_list="${player_list%$'\n'}"
    
    # Use rofi to select player
    selected="$(echo -e "$player_list" | rofi -dmenu -p "Select player: ")"
    
    if [[ -z "$selected" ]]; then
        exit 0
    fi
    
    # Extract player name from selection
    # Format is: "▶/⏸ playername\tartist - song"
    selected_player="$(echo "$selected" | awk '{print $2}' | cut -d$'\t' -f1)"
    
    echo "$selected_player"
}

show_options_simple() {
    local player="$1"
    local selected
    local options_display=""
    
    for option in "${options[@]}"; do
        options_display+="${labels[$option]}"$'\n'
    done
    
    # Remove trailing newline to prevent empty option
    options_display="${options_display%$'\n'}"
    
    # Use rofi to select option with increased line spacing
    selected="$(echo -e "$options_display" | rofi -dmenu -p "Select action: ")" 
    
    if [[ -z "$selected" ]]; then
        return
    fi
    
    # Find which option was selected by matching the label
    for option in "${options[@]}"; do
        if [[ "$selected" == "${labels[$option]}" ]]; then
            execute_option "$player" "$option"
            break
        fi
    done
}

execute_option() {
    local player="$1"
    local option="$2"
    
    if [[ "$MPRIS_CONTROLLER" == "$MPRIS_CTL" ]]; then
        execute_option_mpris_ctl "$player" "$option"
    else
        execute_option_playerctl "$player" "$option"
    fi
}

execute_option_mpris_ctl() {
    local player="$1"
    local option="$2"
    
    case "$option" in
        "play") mpris-ctl --player "$player" play ;;
        "pause") mpris-ctl --player "$player" pause ;;
        "play_pause") mpris-ctl --player "$player" pp ;;
        "stop") mpris-ctl --player "$player" stop ;;
        "next") mpris-ctl --player "$player" next ;;
        "prev") mpris-ctl --player "$player" prev ;;
        "shuffle") mpris-ctl --player "$player" shuffle ;;
    esac
}

execute_option_playerctl() {
    local player="$1"
    local option="$2"
    
    case "$option" in
        "play") playerctl -p "$player" play ;;
        "pause") playerctl -p "$player" pause ;;
        "play_pause") playerctl -p "$player" play-pause ;;
        "stop") playerctl -p "$player" stop ;;
        "next") playerctl -p "$player" next ;;
        "prev") playerctl -p "$player" previous ;;
        "shuffle") playerctl -p "$player" shuffle Toggle ;;
    esac
}

main() {
    detect_controller
    
    player="$(select_player)"
    [[ -z "$player" ]] && exit 0
    
    # Show options once and exit
    show_options_simple "$player"
    exit 0
}

main "$@"
