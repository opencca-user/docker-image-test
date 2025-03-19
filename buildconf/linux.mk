#!/usr/bin/make -f
include env_aarch64.mk

export KDEB_PKGVERSION ?= 6.12.0 ## kernel deb package version
export LOCALVERSION ?= -opencca-wip ## kernel version suffix

EXIT_ON_DEVICE_TREE_VALIDATION := 0

.PHONY: build dt kernel devel modules deb menuconfig clean

build: dt kernel

dt: ## Build device tree for kernel
	@echo "Building Device Tree..."
	cd $(LINUX_DIR) && \
		$(MAKE) defconfig && \
		$(MAKE) dt_binding_check && \
		$(MAKE) dtbs

	cp -rf $(LINUX_DIR)/arch/arm64/boot/dts/rockchip/rk3588-rock-5b.dtb $(SNAPSHOT_DIR)/kernel-rk3588-rock-5b.dtb.prevalidation
	
	cd $(LINUX_DIR) && \
	$(MAKE) CHECK_DTBS=y rockchip/rk3588-rock-5b.dtb 2> dt-warnings.txt || true

	@if [ -s dt-warnings.txt ]; then \
		cat dt-warnings.txt; \
		@echo "====================================================="; \
		@echo "Device tree validation failed. Please fix the warnings."; \
		@echo "====================================================="; \
		if [ "$(EXIT_ON_DEVICE_TREE_VALIDATION)" = "1" ]; then exit 42; fi \
	fi

	-rm $(SNAPSHOT_DIR)/kernel-rk3588-rock-5b.dtb.prevalidation

	-cp -rf $(LINUX_DIR)/arch/arm64/boot/dts/rockchip/rk3588-rock-5b.dtb $(SNAPSHOT_DIR)/kernel-rk3588-rock-5b.dtb
	
	dtc -I dtb -O dts -o $(SNAPSHOT_DIR)/kernel-rk3588-rock-5b.dts $(SNAPSHOT_DIR)/kernel-rk3588-rock-5b.dtb > /dev/null 2>&1 &

KERNEL_KCONFIG := \
		scripts/config -e WLAN && \
		scripts/config -e WLAN_VENDOR_BROADCOM \
		scripts/config -m BRCMUTIL \
		scripts/config -m BRCMFMAC \
		scripts/config -e BRCMFMAC_PROTO_BCDC \
		scripts/config -e BRCMFMAC_PROTO_MSGBUF \
		scripts/config -e BRCMFMAC_USB \
		scripts/config -e WLAN_VENDOR_REALTEK \
		scripts/config -m RTW89 \
		scripts/config -m RTW89_CORE \
		scripts/config -m RTW89_PCI \
		scripts/config -m RTW89_8825B \
		scripts/config -m RTW89_8852BE \
		scripts/config -m BINFMT_MISC \
		scripts/config -d RELR 

kernel: ## build linux kernel from scratch
	@echo "Building Kernel..."

	cd $(LINUX_DIR) && \
		$(MAKE) ARCH=$(ARCH) KBUILD_CC=$(KBUILD_CC) CC="$(CC)" defconfig

	cd $(LINUX_DIR) && \
		$(KERNEL_KCONFIG)

	cd $(LINUX_DIR) && \
		scripts/kconfig/merge_config.sh .config rk3588_fragment.config

	cd $(LINUX_DIR) && \
		$(MAKE) KBUILD_IMAGE=arch/arm64/boot/Image"

	-cp -rf $(LINUX_DIR)/arch/arm64/boot/Image $(SNAPSHOT_DIR)
	-cp -rf $(LINUX_DIR)/vmlinux $(SNAPSHOT_DIR)/vmlinux-host
	-cp -rf $(LINUX_DIR)/.config $(SNAPSHOT_DIR)/kernel.config

devel: ## Build kernel without re-generating .config first
	@echo "Building Development Kernel..."

	cd $(LINUX_DIR) && \
		$(MAKE) ARCH=$(ARCH) KBUILD_CC=$(KBUILD_CC) CC="$(CC)" defconfig

	cd $(LINUX_DIR) && \
		$(KERNEL_KCONFIG)
	
	cd $(LINUX_DIR) && \
	$(MAKE) KBUILD_IMAGE=arch/arm64/boot/Image

	-cp -rf $(LINUX_DIR)/arch/arm64/boot/Image $(SNAPSHOT_DIR)
	-cp -rf $(LINUX_DIR)/vmlinux $(SNAPSHOT_DIR)/vmlinux-host
	-cp -rf $(LINUX_DIR)/.config $(SNAPSHOT_DIR)/kernel.config

modules: ## Build kernel moddules
	@echo "Building Kernel Modules..."

	cd $(LINUX_DIR) && $(MAKE) modules

	cd $(LINUX_DIR) && \
		$(MAKE) modules

	# $(MAKE) -C $(LINUX_DIR) -j$(NPROC) INSTALL_MOD_PATH=$(SNAPSHOT_DIR)/modules modules_install


deb: kernel ## Build kernel and package into .deb archive
	cd $(LINUX_DIR) && \
		$(MAKE) ARCH=$(ARCH) KBUILD_CC=$(KBUILD_CC) CC="$(CC)" defconfig

	cd $(LINUX_DIR) && \
		$(KERNEL_KCONFIG)

	cd $(LINUX_DIR) && \
		scripts/kconfig/merge_config.sh .config rk3588_fragment.config

	cd $(LINUX_DIR) && \
		$(MAKE) CROSS_COMPILE=$(CROSS_COMPILE) \
		KBUILD_IMAGE=arch/arm64/boot/Image \
		ARCH=$(ARCH) \
		deb-pkg
	
	# TODO: put deb somewhere
	# what about version?

menuconfig: ## Launch kernel menuconfig
	cd $(LINUX_DIR) && \
		$(MAKE) menuconfig

	cd $(LINUX_DIR) && \
		scripts/diffconfig .config.old .config

clean: ## Clean kernel build
	$(MAKE) -C $(LINUX_DIR) clean
	$(MAKE) -C $(LINUX_DIR) mrproper
