initramfs.cpio: initfs
	(cd $<;find . | cpio -o --format=newc > ../$@)

initfs: init ../busybox/_install
	mkdir -p $@
	cp $< $@
	(cd $@; \
		mkdir -p proc sys etc; \
		cp -r ../../busybox/_install/* .)

clean:
	rm -rf initfs initramfs.cpio
