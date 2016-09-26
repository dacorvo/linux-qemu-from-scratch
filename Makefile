THIS_DIR   := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))
DNL_DIR=$(THIS_DIR)/dnl

NPROC := $(shell echo $$((2*$$(nproc))))

all:

define VERSION
$($(1)_MAJOR).$($1_MINOR).$($(1)_PATCH)
endef

# Crosstool-Ng

XTOOLS_MAJOR ?= 1
XTOOLS_MINOR ?= 22
XTOOLS_PATCH ?= 0

XTOOLS_VERSION := $(call VERSION,XTOOLS)
XTOOLS_URI ?= http://crosstool-ng.org/download/crosstool-ng

$(DNL_DIR)/crosstool-ng-$(XTOOLS_VERSION).tar.xz:
	mkdir -p $(DNL_DIR)
	wget $(XTOOLS_URI)/crosstool-ng-$(XTOOLS_VERSION).tar.xz -O $@

$(XTOOLS_DIR)/crosstool-ng: $(DNL_DIR)/crosstool-ng-$(XTOOLS_VERSION).tar.xz
	mkdir -p $(XTOOLS_DIR)
	tar xf $< -m -C $(XTOOLS_DIR)

XTOOLS_DIR ?= $(THIS_DIR)/x-tools
XTOOLS := $(XTOOLS_DIR)/bin/ct-ng

$(XTOOLS): $(XTOOLS_DIR)/crosstool-ng
	(cd $(XTOOLS_DIR)/crosstool-ng; \
		./configure --prefix=$(XTOOLS_DIR) && MAKELEVEL=0 $(MAKE) install)

# Toolchain

ARCH ?= arm
XTOOLS_PREFIX ?= arm-unknown-linux-uclibcgnueabi

CROSS_COMPILE := $(HOME)/x-tools/$(XTOOLS_PREFIX)/bin/$(XTOOLS_PREFIX)-

TOOLCHAIN_DIR ?= $(THIS_DIR)/toolchain/$(XTOOLS_PREFIX)

$(CROSS_COMPILE)gcc: $(XTOOLS)
	mkdir -p $(XTOOLS_DIR)/src
	mkdir -p $(TOOLCHAIN_DIR)
	$(XTOOLS) -C $(TOOLCHAIN_DIR) $(XTOOLS_PREFIX)
	sed -i 's/CT_LOCAL_TARBALLS_DIR=.*//' $(TOOLCHAIN_DIR)/.config
	echo "CT_LOCAL_TARBALLS_DIR=$(XTOOLS_DIR)/src" >> $(TOOLCHAIN_DIR)/.config
	$(XTOOLS) build -C $(TOOLCHAIN_DIR) -j$(NPROC)

# Kernel

LINUX_MAJOR ?=4
LINUX_MINOR ?=7
LINUX_PATCH ?=5

LINUX_VERSION := $(call VERSION,LINUX)
LINUX_URI ?= https://cdn.kernel.org/pub/linux/kernel

LINUX_DIR ?= $(THIS_DIR)/linux

LINUX_CONFIG ?= mainstone+initrd+sd_defconfig
	
$(DNL_DIR)/linux-$(LINUX_VERSION).tar.xz:
	mkdir -p $(DNL_DIR)
	wget $(LINUX_URI)/v$(LINUX_MAJOR).x/linux-$(LINUX_VERSION).tar.xz -O $@

$(LINUX_DIR)/linux-$(LINUX_VERSION): $(DNL_DIR)/linux-$(LINUX_VERSION).tar.xz
	mkdir -p $(LINUX_DIR)
	tar xf $< -m -C $(LINUX_DIR)

$(LINUX_DIR)/linux-$(LINUX_VERSION)/arch/$(ARCH)/configs/$(LINUX_CONFIG): \
	$(LINUX_DIR)/linux-$(LINUX_VERSION) \
	$(THIS_DIR)/$(LINUX_CONFIG)
	cp $(THIS_DIR)/$(LINUX_CONFIG) $@

$(LINUX_DIR)/build/.config: \
	$(LINUX_DIR)/linux-$(LINUX_VERSION)/arch/$(ARCH)/configs/$(LINUX_CONFIG)
	$(MAKE) -C $(LINUX_DIR)/linux-$(LINUX_VERSION) \
		ARCH=$(ARCH) \
		CROSS_COMPILE=$(CROSS_COMPILE) \
		KBUILD_DEFCONFIG=$(LINUX_CONFIG) \
		O=$(LINUX_DIR)/build defconfig

$(LINUX_DIR)/zImage: $(LINUX_DIR)/build/.config $(CROSS_COMPILE)gcc
	$(MAKE) -j$(NPROC) -C $(LINUX_DIR)/linux-$(LINUX_VERSION) \
		ARCH=arm \
		CROSS_COMPILE=$(CROSS_COMPILE) \
		O=$(LINUX_DIR)/build && cp $(LINUX_DIR)/build/arch/arm/boot/zImage $@

TARGET_CFLAGS ?= -march=armv5te -mtune=xscale -Wa,-mcpu=xscale

$(THIS_DIR)/tinyinit/initramfs $(THIS_DIR)/tinyinit/init.img: .FORCE
	$(MAKE) -C tinyinit CROSS_COMPILE=$(CROSS_COMPILE) \
		CFLAGS="$(CFLAGS) $(TARGET_CFLAGS)"

$(THIS_DIR)/mainstone-flash%.img:
	qemu-img create $@ 32M

all: $(LINUX_DIR)/zImage \
	 $(THIS_DIR)/tinyinit/initramfs \
	 $(THIS_DIR)/tinyinit/init.img \
	 $(THIS_DIR)/mainstone-flash0.img \
	 $(THIS_DIR)/mainstone-flash1.img

.FORCE:
