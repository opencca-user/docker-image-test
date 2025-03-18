#!/bin/make -f

include env_aarch64.mk

LOG ?= 10
DEBUG ?= 0
ENABLE_OPENCCA_PERF ?= 0

CLEAN_BUILD ?= 0

TFA_BUILD_TYPE := $(if $(filter 1,$(DEBUG)),debug,release)
RMM_BUILD_TYPE := $(if $(filter 1,$(DEBUG)),Debug,Release)

BL31_ELF ?= $(TFA_DIR)/build/rk3588/$(TFA_BUILD_TYPE)/bl31/bl31.elf
RMM_ELF ?= $(RMM_DIR)/build/$(RMM_BUILD_TYPE)/rmm.elf

MAKE ?= make -j$(NPROC)

.PHONY: all tfa rmm uboot clean

# Default: Build everything
all: tfa rmm uboot
build: all

clean: tfa-clean rmm-clean uboot-clean

tfa:
	@echo "Building TFA..."

	@if [ "$(CLEAN_BUILD)" = "1" ]; then \
		echo "Cleaning $(TFA_DIR)..."; \
		rm -rf $(TFA_DIR)/build; \
	fi

	cd $(TFA_DIR) && \
	$(MAKE) -j$(NPROC) \
		PLAT=rk3588 \
		ENABLE_OPENCCA=1 \
		ENABLE_RME=1 \
		DEBUG=$(DEBUG) \
		LOG_LEVEL=$(LOG) \
		ENABLE_PAUTH=0 \
		ENABLE_FEAT_DIT=0 \
		ENABLE_OPENCCA_PERF=$(ENABLE_OPENCCA_PERF) \
		RME_GPT_MAX_BLOCK=0
	
	cp -rf $(BL31_ELF) $(SNAPSHOT_DIR)

tfa-clean:
	-rm -r $(TFA_DIR)/build


RMM_CLEAN_FLAGS :=
ifeq ($(CLEAN_BUILD),1)
    RMM_CLEAN_FLAGS += --clean-first
endif

rmm: 
	@echo "Building RMM..."

	@if [ "$(CLEAN_BUILD)" = "1" ]; then \
		echo "Cleaning $(RMM_DIR)..."; \
		rm -rf $(RMM_DIR)/build; \
	fi

	cd $(RMM_DIR) && \
	cmake -S $(RMM_DIR)/ -B $(RMM_DIR)/build \
		-DRMM_CONFIG=rk3588_defcfg \
		-DLOG_LEVEL=$(LOG) \
		-DCMAKE_BUILD_TYPE=$(RMM_BUILD_TYPE) \
		-DENABLE_OPENCCA_PERF=$(ENABLE_OPENCCA_PERF) 
	 	
	cd $(RMM_DIR) && \
	cmake --build build $(RMM_CLEAN_FLAGS) -j$(NPROC)

	cp -rf $(RMM_ELF) $(SNAPSHOT_DIR)/tf-rmm.elf || true

rmm-clean:
	-rm -r $(RMM_DIR)/build	

UBOOT_CONFIG := $(UBOOT_DIR)/.config
UBOOT_FRAGMENT := $(UBOOT_DIR)/rk3588_fragment.config
UBOOT_BIN := idbloader.img u-boot.itb u-boot-rockchip.bin u-boot-rockchip-spi.bin u-boot

uboot:
	@echo "Building U-Boot..."

	# debug
	@export BINMAN_DEBUG=1
	@export BINMAN_VERBOSE=3

	cd $(UBOOT_DIR) && \
	$(MAKE) rock5b-rk3588_defconfig && \
	scripts/kconfig/merge_config.sh -r $(UBOOT_CONFIG) $(UBOOT_FRAGMENT)

	cd $(UBOOT_DIR) && \
	$(MAKE) -j$(NPROC) \
		ARCH=$(ARCH) \
		CROSS_COMPILE=$(CROSS_COMPILE) \
		ROCKCHIP_TPL=$(SNAPSHOT_DIR)/rk3588_ddr_lp4_2112MHz_lp5_2736MHz_v1.08.bin \
		BL31=$(SNAPSHOT_DIR)/bl31.elf \
		RMM=$(SNAPSHOT_DIR)/tf-rmm.elf 
	
	-cp -rf $(UBOOT_DIR)arch/arm/dts/rk3588-rock-5b.dtb \
		$(SNAPSHOT_DIR)/uboot-rk3588-rock-5b.dtb

	-dtc -I dtb -O dts -o $(SNAPSHOT_DIR)/uboot-rk3588-rock-5b.dts \
		$(SNAPSHOT_DIR)/uboot-rk3588-rock-5b.dtb &> /dev/null

	cd $(UBOOT_DIR) && cp -rf $(UBOOT_BIN) $(SNAPSHOT_DIR)

uboot-clean:
	cd $(UBOOT_DIR) && $(MAKE) distclean






