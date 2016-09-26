CFLAGS="-march=arm5vte -mtune=xscale -Wa,-mcpu=xscale -lm" \
make -C $(pwd)/../busybox defconfig ARCH=arm CROSS_COMPILE=arm-unknown-linux-uclibcgnueabi- O=$(pwd)/busybox/
