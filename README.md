First install prerequisites:

```
$ sudo apt-get install build-essentials qemu e2tools
```

Then fetch tools and build everything using the main Makefile:

```
$ make
```

Finally launch the two test scripts:

```
./boot_mainstone_initramfs.sh
```

or

```
./boot_mainstone_rootfs.sh
```
