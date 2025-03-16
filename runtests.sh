#!/bin/bash

cardname="ezsound6x8"

while getopts "d:" opt; do
	case "$opt" in
		d)	opt_d="yes"; device="$OPTARG";;
		c)	cardname="$OPTARG";;
	esac
done

pbdevice="plughw:$cardname,1"
capdevice="plughw:$cardname,0"

if [ "$opt_d" = "yes" ]; then
	pbdevice=$device
	capdevice=$device
fi

echo "Using '$capdevice' for capture"
echo "Using '$pbdevice' for playback"

read -p "Press enter to start recording for 10 seconds"

arecord -Vstereo -d10 -D$capdevice -r96000 -c2 -fS32_LE sample.wav

if [ "$?" -ne 0 ]; then
	echo "Recording error... aborting"
	exit 1
fi
echo

read -p "Press enter to play back recorded file"

aplay -Vstereo -D$pbdevice -r96000 -c2 -fS32_LE sample.wav

if [ "$?" -ne 0 ]; then
	echo "Playback error... aborting"
	exit 2
fi
echo

exit 0
