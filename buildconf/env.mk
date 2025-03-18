ROOT_DIR ?= $(realpath ../../)

KVMTOOL_DIR ?= $(ROOT_DIR)/kvmtool
LINUX_DIR ?= $(ROOT_DIR)/linux
LINUX_GUEST_DIR ?=$(ROOT_DIR)/linux-guest
TFA_DIR ?= $(ROOT_DIR)/trusted-firmware-a
RMM_DIR ?= $(ROOT_DIR)/tf-rmm
DTC_DIR ?= $(ROOT_DIR)/dtc
UBOOT_DIR ?= $(ROOT_DIR)/u-boot
RKBIN_DIR ?= $(ROOT_DIR)/rkbin
ASSETS_DIR ?= $(ROOT_DIR)/opencca-assets
export SNAPSHOT_DIR ?= $(ROOT_DIR)/snapshot

DEBOS_DIR ?= $(ROOT_DIR)/debian-image-recipes

NPROC ?= $(shell nproc)
MAKEFLAGS += -j$(NPROC)
MAKE += $(MAKEFLAGS)


# Export all Makefile variables for bash
print-vars:  
	@awk -F ' \\?= | = ' '/^[A-Z0-9_-]+( \\?= | = )/ {print "export " $$1 "=" $$2}' $(MAKEFILE_LIST)

help: ## Print this help message
	@echo "Available make targets for $(firstword $(MAKEFILE_LIST)):"

	@# Print all targets with ## in help text
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z0-9_-]+:.*##/ \
		{printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	
	@echo ""
	@echo "Available variables for $(firstword $(MAKEFILE_LIST)):"
	@awk 'BEGIN {FS = " \\?= |##"} /^[A-Z0-9_-]+ \?= / \
		{printf "  \033[33m%-25s\033[0m %-5s \033[32m%s\033[0m \n", $$1, $$2, $$3}' $(MAKEFILE_LIST)

