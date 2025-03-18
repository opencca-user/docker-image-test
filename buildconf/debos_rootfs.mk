#!/usr/bin/make -f

# DEBOS_DIR
include env_x86.mk

OSPACK_IMAGE = $(DEBOS_DIR)/out/ospack-debian-arm64-trixie.tar.gz

.PHONY: debos clean

all: rk3588

$(OSPACK_IMAGE): debos

debos:
	cd $(DEBOS_DIR) && \
	mkdir -p out && \
    debos  --artifactdir=out -t architecture:arm64 opencca-ospack-debian.yaml

rk3588: $(OSPACK_IMAGE)
	cd $(DEBOS_DIR) && \
	debos  --artifactdir=out -t architecture:arm64 opencca-image-rockchip-rk3588.yaml

clean:
	rm -rf $(DEBOS_DIR)/out