all: ezsound-6x8.eep $(dtbos)

ezsound-6x8.eep: eepmake ezsound-6x8.conf
	./eepmake ezsound-6x8.conf ezsound-6x8.eep

blank.eep:
	dd if=/dev/zero ibs=1k count=4 of=blank.eep

eepflash.sh eepmake:
	git clone https://github.com/raspberrypi/utils.git
	cmake -S utils/eeptools -B utils/eeptools
	$(MAKE) -C utils/eeptools
	cp utils/eeptools/eepmake .
	cp utils/eeptools/eepflash.sh .
	rm -rf utils

flash: eepflash.sh ezsound-6x8.eep
	sudo ./eepflash.sh -w -t=24c32 -f=ezsound-6x8.eep

erase: eepflash.sh blank.eep
	sudo ./eepflash.sh -w -t=24c32 -f=blank.eep

clean:
	rm -f eepmake eepflash.sh ezsound-6x8.eep blank.eep

.PHONY: clean flash erase
