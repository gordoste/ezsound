#!/bin/bash

default_cardname="ezsound6x8"

usage() {
	cat - <<EOF
$0: Run a variety of tests for the ezsound card

Usage: $0 [-h] [-c <cardname>] [-C <capturedev>] [-P <playbackdev>] testname ...

	-h:	Print help (this message)
	-c:	Specify the card name to use (default is $default_cardname)
	-C:	Specify ALSA device for capture (default is plughw:<CARDNAME>,1)
	-P:	Specify ALSA device for playback (default is plughw:<CARDNAME>,0>

Available tests:
	recplay:	Record 10 seconds of stereo audio and then play it back
	record:		Record 60 seconds of 6-channel audio to recordtest.wav
	playback:	Loop a short 8-channel audio sample 60 times on the playback device
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

exec_cmd() {
	quiet=$1
	shift
	cmd="$*"
	if [ "$quiet" -ne "0" ]; then
		echo $cmd
	fi
	eval $cmd
	return $?
}

do_recplay_test() {
	read -p "Press enter to start recording for 10 seconds"

	exec_cmd 1 arecord -Vstereo -d10 -D$capdevice -r96000 -c2 -fS32_LE sample.wav
	if [ "$?" -ne "0" ]; then
		echo Error encountered... aborting
		exit 1
	fi

	echo

	read -p "Press enter to play back recorded file"

	exec_cmd 1 aplay -Vstereo -D$pbdevice -r96000 -c2 -fS32_LE sample.wav
	if [ "$?" -ne "0" ]; then
		echo Error encountered... aborting
		exit 1
	fi

	echo
}

for arg; do
	if [ "$arg" = "recplay" ]; then
		do_recplay_test
	fi
	if [ "$arg" = "record" ]; then
		exec_cmd 0 "arecord -D$capdevice -c6 -r96000 -fS32_LE -d60 recordtest.wav"
		if [ "$?" -ne "0" ]; then
			echo Error in command: "$cmd"
			exit 1
		fi
	fi
	if [ "$arg" = "playback" ]; then
		bunzip2 nums_8ch_96k.wav.bz2
		for i in 0 1 2 3 4 5; do
			for j in 0 1 2 3 4 5 6 7 8 9; do
				echo $i$j/60...
				exec_cmd 0 "aplay -D$pbdevice -r96000 -c8 nums_8ch_96k.wav >/dev/null 2>&1"
				if [ "$?" -ne "0" ]; then
					echo Error in command: "$cmd"
					bzip2 nums_8ch_96k.wav
					exit 1
				fi
			done
		done
		bzip2 nums_8ch_96k.wav
	fi
done

exit 0
