#!/usr/bin/env sh
#
power_off='⏻ Shutdown'
reboot='󰑓 Reboot'
lock=' Lock'
suspend='󰤄 Suspend'
log_out='󰍃 Log Out'

# If no argument is passed, output the menu choices for Rofi to display
if [ -z "$1" ]; then
    printf '%s\n%s\n%s\n%s\n%s\n' "$power_off" "$reboot" "$lock" "$suspend" "$log_out"
else
    # If an argument is passed, handle the action
    case "$1" in
        "$power_off")
            systemctl poweroff
            ;;
        "$reboot")
            systemctl reboot
            ;;
        "$lock")
            swaylock             
	    ;;

        "$suspend")
            mpc --quiet pause
            amixer set Master mute
            systemctl suspend
            ;;
        "$log_out")
            swaymsg exit
            ;;
    esac
fi
