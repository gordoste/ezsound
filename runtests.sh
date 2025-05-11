#!/bin/bash

default_cardname="ezsound6x8"

usage() {
	cat - <<EOF
$0: Run a variety of tests for the ezsound card

Usage: $0 [-h] [-c <cardname>] [-C <capturedev>] [-P <playbackdev>] testname ...

	-h:	Print help (this message)
	-c:	Specify the card name to use (default is $default_cardname)
	-C:	Specify ALSA device for capture
	-P:	Specify ALSA device for playback

Available tests:
	recplay:	Record 10 seconds of stereo audio and then play it back
EOF

	exit 0
}

cardname=$default_cardname

while getopts "hc:C:P:" opt; do
	case "$opt" in
		h)	usage;;
		c)	cardname="$OPTARG";;
		C)	opt_capdev="$OPTARG";;
		P)	opt_pbdev="$OPTARG";;
	esac
done

pbdevice="plughw:$cardname,1"
capdevice="plughw:$cardname,0"

if [ ! -z "$opt_capdev" ]; then
	capdevice=$opt_capdev
fi

if [ ! -z "$opt_pbdev" ]; then
	pbdevice=$opt_pbdev
fi

echo "Using '$capdevice' for capture"
echo "Using '$pbdevice' for playback"

do_recplay_test() {
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
}

for arg; do
	if [ "$arg" = "recplay" ]; then
		do_recplay_test
	fi
done

exit 0
