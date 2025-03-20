include env.mk

CCACHE = ccache
export CROSS_COMPILE=aarch64-none-linux-gnu-
export ARCH = arm64
export KBUILD_CC="/usr/bin/ccache ${CROSS_COMPILE}gcc"