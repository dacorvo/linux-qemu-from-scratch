qemu-system-arm -kernel linux/zImage -serial stdio -append "console=ttyS0 root=/dev/mmcblk0" -machine mainstone -pflash mainstone-flash0.img -pflash mainstone-flash1.img -sd tinyinit/init.img
