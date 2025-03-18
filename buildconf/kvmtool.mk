#!/usr/bin/make -f

# SNAPSHOT_DIR
# KVMTOOL_DIR
# CROSS_COMPILE
include env_aarch64.mk

DTC_REPO := https://git.kernel.org/pub/scm/utils/dtc/dtc.git
DTC_BRANCH := master
DTC_DIR= $(KVMTOOL_DIR)/dtc
LIBFDT_DIR=$(DTC_DIR)/libfdt

.PHONY: all clean dtc kvmtool copy-snapshot

all: dtc kvmtool

$(DTC_DIR):
	@echo "cloning dtc into $$(DTC_DIR)"
	git clone  -b $(DTC_BRANCH) $(DTC_REPO) $(DTC_DIR)

dtc: $(DTC_DIR)
	cd $(DTC_DIR) && make libfdt -j$(NPROC)

kvmtool: dtc ## build kvm tool
	cd $(KVMTOOL_DIR) && make ARCH=$(ARCH) LIBFDT_DIR=$(LIBFDT_DIR) \
		CROSS_COMPILE=$(CROSS_COMPILE) V=1 lkvm-static WERROR=0 -j$(NPROC)
	-cp $(KVMTOOL_DIR)/lkvm-static $(SNAPSHOT_DIR)/lkvm	

clean: ## clean kvmtool
	-cd $(KVMTOOL_DIR) && make clean
	-cd $(KVMTOOL_DIR) && git clean -fdx
	-cd $(DTC_DIR) && make clean
	-cd $(DTC_DIR) && git clean -fdx
