EXTRA_CFLAGS="-march=armv5te -mtune=xscale -Wa,-mcpu=xscale" \
LIBRARIES="-lm" \
make -C $(pwd)/../busybox ARCH=arm CROSS_COMPILE=arm-unknown-linux-uclibcgnueabi- O=$(pwd)/busybox/ install -j16
