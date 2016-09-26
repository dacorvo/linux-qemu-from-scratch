qemu-system-arm -kernel linux/zImage -serial stdio -append console=ttyS0 -machine mainstone -pflash mainstone-flash0.img -pflash mainstone-flash1.img -initrd tinyinit/initramfs
