# Launch bar on each monitor, tray on primary
polybar --list-monitors | while IFS=$'\n' read line; do
    monitor=$(echo $line | cut -d':' -f1)
    primary=$(echo $line | cut -d' ' -f3)
    echo $line
done

# polybar --list-monitors | while IFS=$'\n' read line; do
#   monitor=$(echo $line | ${pkgs.coreutils}/bin/cut -d':' -f1)
#   primary=$(echo $line | ${pkgs.coreutils}/bin/cut -d' ' -f3)
#   tray_position=$([ -n "$primary" ] && echo "right" || echo "none")
#   MONITOR=$monitor TRAY_POSITION=$tray_position polybar --reload top &
# done
