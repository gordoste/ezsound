This repo contains files related to the ezsound 6x8 isolated soundcard.

# CARD REQUIREMENTS:

1. Confirm that your `/boot/firmware/config.txt` contains `dtparam=i2c_arm=on`. When enabled properly, the file `/dev/i2c-1` will exist.
2. Ensure that you have a 6.12.x Linux kernel (using `uname -r`).

Everything should work automatically if the above requirements are met.

# UTILITIES:

* `reprobe.sh`: If the card did not have power when the Pi was booted, then it will not have been detected. This script can be run as root to scan for the card. Once it is detected, you can use it as normal.
* `runtests.sh`: This script shows examples of various things you can do with basic ALSA utilities. Use `runtests.sh -h` to get a list.

# OTHER FILES:

`Makefile`, `ezsound-6x8.conf`: It should never be necessary and is not recommended, but you can flash the card's EEPROM by running `make flash`. Note that this will run commands as root - make sure you understand what it is doing. You will need `cmake` installed on your system for this to work. 
