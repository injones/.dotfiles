killall -q polybar
# https://github.com/polybar/polybar/issues/763#issuecomment-1664691901
polybar --list-monitors | while IFS=$'\n' read line; do
    monitor=$(echo $line | cut -d':' -f1)
    primary=$(echo $line | cut -d' ' -f3)
    tray_position=$([ -n "$primary" ] && echo "right" || echo "none")
    MONITOR=$monitor TRAY_POSITION=$tray_position polybar --reload example &
done
