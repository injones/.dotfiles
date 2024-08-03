#!/bin/bash
echo "hello"
if xrandr --listmonitors | grep "2:" ; then
	source /home/happyduck/.screenlayout/three.sh
elif xrandr --listmonitors | grep "1:" ; then
	source /home/happyduck/.screenlayout/two.sh
else
	echo "Just one monitor"
fi

feh --bg-center /usr/share/backgrounds/earth-in-space.png
