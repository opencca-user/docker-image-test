#!/usr/bin/make -f
include env_aarch64.mk

# .ONESHELL:
SHELL := /bin/bash
# .SHELLFLAGS := -e

LOCALVERSION ?= -opencca-wip ## kernel version suffix

.PHONY: build
build: kernel ## see kernel

# ---------------
# Device tree
# ---------------

DEVICE_DTB := rockchip/rk3588-rock-5b.dtb
DEVICE_DTB_PATH := arch/arm64/boot/dts/$(DEVICE_DTB)
SNAPSHOT_DTB := $(SNAPSHOT_DIR)/kernel-rk3588-rock-5b.dtb
DEVICE_DTB_WARNINGS := dt-warnings.txt
DEVICE_TREE_IGNORE_WARNINGS ?=0

.PHONY: dt
.ONESHELL: dt
dt: kconfig ## Build device tree for kernel	
	cd $(LINUX_DIR)

    # Create device trees
	+$(MAKE) -C $(LINUX_DIR) dt_binding_check DTBS=$(DEVICE_DTB)
	+$(MAKE) -C $(LINUX_DIR) dtbs

	cd $(LINUX_DIR) && \
		cp -f $(DEVICE_DTB_PATH) $(SNAPSHOT_DTB).prevalidation
    
	cd $(LINUX_DIR) && \
		$(MAKE) -C $(LINUX_DIR) CHECK_DTBS=y $(DEVICE_DTB) 2> $(DEVICE_DTB_WARNINGS) || true

	if [ -s "$(DEVICE_DTB_WARNINGS)" ]; then
		cat "$(DEVICE_DTB_WARNINGS)" 
		echo "Warnings in device tree" 
	fi

	cd $(LINUX_DIR) && \
		rm -f $(SNAPSHOT_DTB).prevalidation && \
		cp -rf $(DEVICE_DTB_PATH) $(SNAPSHOT_DTB)

	dtc -I dtb -O dts -o $(SNAPSHOT_DTB) $(SNAPSHOT_DTB).txt > /dev/null 2>&1

# ---------------
# Kernel Build
# ---------------

KERNEL_CONFIG := $(LINUX_DIR)/.config
KERNEL_FRAGMENT := $(LINUX_DIR)/rk3588_fragment.config ## kconfig fragment
KERNEL_KCONFIG += \
		-e WLAN \
		-e WLAN_VENDOR_BROADCOM \
		-m BRCMUTIL \
		-m BRCMFMAC \
		-e BRCMFMAC_PROTO_BCDC \
		-e BRCMFMAC_PROTO_MSGBUF \
		-e BRCMFMAC_USB \
		-e WLAN_VENDOR_REALTEK \
		-m RTW89 \
		-m RTW89_CORE \
		-m RTW89_PCI \
		-m RTW89_8825B \
		-m RTW89_8852BE \
		-m BINFMT_MISC \
		-d RELR

.PHONY: kconfig
kconfig: $(KERNEL_FRAGMENT) ## Generate .config file	

    # generate .config
	+$(MAKE) -C $(LINUX_DIR) ARCH=$(ARCH) KBUILD_CC=$(KBUILD_CC) defconfig

    # apply rk3588 settings
	cd $(LINUX_DIR) && $(LINUX_DIR)/scripts/config $(KERNEL_KCONFIG)

    # apply fragment
	cd $(LINUX_DIR) && $(LINUX_DIR)/scripts/kconfig/merge_config.sh \
		$(KERNEL_CONFIG) \
		$(KERNEL_FRAGMENT)

	-cp -rf $(LINUX_DIR)/.config $(SNAPSHOT_DIR)/rk3588-kernel-config

.PHONY: kernel
kernel: kconfig ## build linux kernel
	@echo "Building kernel"
	+$(MAKE) -C $(LINUX_DIR) KBUILD_IMAGE="arch/arm64/boot/Image"

	-cp -rf $(LINUX_DIR)/arch/arm64/boot/Image $(SNAPSHOT_DIR)

.PHONY: devel
devel: ## Build kernel without re-generating .config first (devel)
	+$(MAKE) -C $(LINUX_DIR) KBUILD_IMAGE=arch/arm64/boot/Image

	-cp -rf $(LINUX_DIR)/arch/arm64/boot/Image $(SNAPSHOT_DIR)


# ---------------
# Debian package
# ---------------

BUILD_TIMESTAMP := $$(date +%Y-%m-%d_%H-%M-%S)
DEBIAN_RELEASE_DIR ?= $(LINUX_DIR)/../linux-release/$(BUILD_TIMESTAMP)_$(KERNEL_VERSION) ## output dir for deb build
KERNEL_VERSION = $(shell make -sC $(LINUX_DIR) kernelversion)$(LOCALVERSION)
KDEB_PKGVERSION ?= $(KERNEL_VERSION)


.PHONY: debian
debian: ## Build kernel and package into .deb archive (requires initial kconfig)
	+$(MAKE) -C $(LINUX_DIR) \
		CROSS_COMPILE=$(CROSS_COMPILE) \
		KBUILD_IMAGE=arch/arm64/boot/Image \
		ARCH=$(ARCH) \
		LOCALVERSION=$(LOCALVERSION) \
		KDEB_PKGVERSION=$(KDEB_PKGVERSION) \
		deb-pkg

    # XXX: deb-pkg creates *.deb files in parent
    # directory of linux dir. We move these to their own folder.
	mkdir -p $(DEBIAN_RELEASE_DIR)
	mv $(LINUX_DIR)/../linux-upstream* $(DEBIAN_RELEASE_DIR)
	mv $(LINUX_DIR)/../linux-*.deb $(DEBIAN_RELEASE_DIR)
	@echo "Files moved to $(DEBIAN_RELEASE_DIR)"
	ls -al $(DEBIAN_RELEASE_DIR)/

.PHONY: menuconfig
menuconfig: ## Launch kernel menuconfig
	cd $(LINUX_DIR) && \
		cp -f .config .config.pre-menuconfig

	cd $(LINUX_DIR) && \
		+$(MAKE) menuconfig

	cd $(LINUX_DIR) && \
		scripts/diffconfig .config.pre-menuconfig .config 

.PHONY: clean
clean: ## Clean kernel build
	+$(MAKE) -C $(LINUX_DIR) clean
	+$(MAKE) -C $(LINUX_DIR) mrproper
