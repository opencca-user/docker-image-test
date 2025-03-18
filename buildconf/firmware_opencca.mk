#!/bin/make -f

include env_aarch64.mk


LOG ?= 10
DEBUG ?= 0
ENABLE_OPENCCA_PERF ?= 0
TARGET ?= rk3588
CLEAN_BUILD ?= 0

TFA_BUILD_TYPE := $(if $(filter 1,$(DEBUG)),debug,release)
RMM_BUILD_TYPE := $(if $(filter 1,$(DEBUG)),Debug,Release)

BL31_ELF ?= $(TFA_DIR)/build/rk3588/$(BUILD_TYPE)/bl31/bl31.elf
RMM_ELF ?= $(RMM_DIR)/build/$(BUILD_TYPE)/rmm.elf


RMM_FLAGS := -DRMM_CONFIG=rk3588_defcfg -DLOG_LEVEL=$(LOG) -DCMAKE_BUILD_TYPE=Release -DENABLE_OPENCCA_PERF=$(ENABLE_OPENCCA_PERF)

UBOOT_BINARIES := idbloader.img u-boot.itb u-boot-rockchip.bin u-boot-rockchip-spi.bin u-boot

.PHONY: all toolchain tfa rmm uboot clean

# Default: Build everything
all: toolchain tfa rmm uboot


tfa:
	@echo "Building TFA..."

	cd $(TFA_DIR) && \
	make -j$(NPROC) \
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

