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

kernel: ## build linux kernel from scratch
	@echo "Building Kernel..."

	cd $(LINUX_DIR) && \
		$(MAKE) ARCH=$(ARCH) KBUILD_CC=$(KBUILD_CC) CC="$(CC)" defconfig

	cd $(LINUX_DIR) && \
		scripts/config -e WLAN -e WLAN_VENDOR_BROADCOM -m BRCMUTIL -m BRCMFMAC \
		-e BRCMFMAC_PROTO_BCDC -e BRCMFMAC_PROTO_MSGBUF -e BRCMFMAC_USB \
		-e WLAN_VENDOR_REALTEK -m RTW89 -m RTW89_CORE -m RTW89_PCI \
		-m RTW89_8825B -m RTW89_8852BE -m BINFMT_MISC \
		-d RELR 

	cd $(LINUX_DIR) && \
		scripts/kconfig/merge_config.sh .config rk3588_fragment.config

	cd $(LINUX_DIR) && \
		$(MAKE) KBUILD_IMAGE=arch/arm64/boot/Image CC="$(CC)"

	cp -rf $(LINUX_DIR)/arch/arm64/boot/Image $(SNAPSHOT_DIR)
	cp -rf $(LINUX_DIR)/vmlinux $(SNAPSHOT_DIR)/vmlinux-host
	cp -rf $(LINUX_DIR)/.config $(SNAPSHOT_DIR)/kernel.config

# devel:
# 	@echo "Building Development Kernel..."
# 	$(MAKE) -C $(LINUX_DIR) -j$(NPROC) KBUILD_IMAGE=arch/arm64/boot/Image
# 	cp -rf $(LINUX_DIR)/arch/arm64/boot/Image $(SNAPSHOT_DIR)
# 	cp -rf $(LINUX_DIR)/vmlinux $(SNAPSHOT_DIR)/vmlinux-host
# 	cp -rf $(LINUX_DIR)/.config $(SNAPSHOT_DIR)/kernel.config

# modules:
# 	@echo "Building Kernel Modules..."
# 	mkdir -p $(SNAPSHOT_DIR)/modules
# 	$(MAKE) -C $(LINUX_DIR) -j$(NPROC) modules
# 	$(MAKE) -C $(LINUX_DIR) -j$(NPROC) INSTALL_MOD_PATH=$(SNAPSHOT_DIR)/modules modules_install
# 	cp -rf $(LINUX_DIR)/arch/arm64/boot/Image $(SNAPSHOT_DIR)
# 	cp -rf $(LINUX_DIR)/.config $(SNAPSHOT_DIR)/kernel.config

# deb:
# 	@echo "Building Kernel Debian Package..."
# 	export CROSS_COMPILE="aarch64-none-elf-"
# 	$(MAKE) -C $(LINUX_DIR) defconfig
# 	$(LINUX_DIR)/scripts/config -e WLAN -e WLAN_VENDOR_BROADCOM -m BRCMUTIL -m BRCMFMAC \
# 		-e BRCMFMAC_PROTO_BCDC -e BRCMFMAC_PROTO_MSGBUF -e BRCMFMAC_USB \
# 		-e WLAN_VENDOR_REALTEK -m RTW89 -m RTW89_CORE -m RTW89_PCI \
# 		-m RTW89_8825B -m RTW89_8852BE -m BINFMT_MISC -d RELR
# 	$(LINUX_DIR)/scripts/kconfig/merge_config.sh .config rk3588_fragment.config
# 	$(MAKE) -C $(LINUX_DIR) -j$(NPROC) CROSS_COMPILE=$(CROSS_COMPILE) KBUILD_IMAGE=arch/arm64/boot/Image ARCH=arm64 deb-pkg
# 	cp -rf $(LINUX_DIR)/arch/arm64/boot/Image $(SNAPSHOT_DIR)
# 	cp -rf $(LINUX_DIR)/vmlinux $(SNAPSHOT_DIR)/vmlinux-host
# 	cp -rf $(LINUX_DIR)/.config $(SNAPSHOT_DIR)/kernel.config

# menuconfig:
# 	@echo "Launching Kernel Menuconfig..."
# 	$(MAKE) -C $(LINUX_DIR) menuconfig
# 	$(LINUX_DIR)/scripts/diffconfig .config.old .config

# clean:
# 	@echo "Cleaning Kernel Build..."
# 	$(MAKE) -C $(LINUX_DIR) clean
# 	$(MAKE) -C $(LINUX_DIR) mrproper
# 	rm -rf $(SNAPSHOT_DIR)/*
