ROOT_DIR ?= $(realpath ../../)

KVMTOOL_DIR ?= $(ROOT_DIR)/kvmtool
LINUX_DIR ?= $(ROOT_DIR)/linux
LINUX_GUEST_DIR ?=$(ROOT_DIR)/linux-guest
TFA_DIR= ?=$(ROOT_DIR)/trusted-firmware-a
RMM_DIR= ?=$(ROOT_DIR)/tf-rmm
DTC_DIR ?= $(ROOT_DIR)/dtc
UBOOT_DIR ?= $(ROOT_DIR)/u-boot
RKBIN_DIR ?= $(ROOT_DIR)/rkbin
export SNAPSHOT_DIR ?= $(ROOT_DIR)/snapshot

DEBOS_DIR ?= $(ROOT_DIR)/debian-image-recipes

NPROC ?= $(shell nproc)

