all:

initramfs: init
	echo $< | cpio -o --format=newc > $@

init.img: init
	rm -f $@
	qemu-img create $@ 128K
	sudo mkfs.ext2 $@
	sudo e2mkdir $@:sbin
	sudo e2cp -P 755 $< $< $@:sbin

init: main.c
	$(CROSS_COMPILE)gcc -static $(CFLAGS) $< -o $@

clean:
	rm -rf *.o init initramfs

all: initramfs init.img
