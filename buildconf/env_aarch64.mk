include env.mk

CCACHE = ccache
export CROSS_COMPILE=aarch64-none-linux-gnu-

export ARCH = arm64

export CC := ccache $(CROSS_COMPILE)gcc
export CXX="ccache ${CROSS_COMPILE}g++"
export LD="ccache ${CROSS_COMPILE}ld"
export KBUILD_CC="ccache ${CROSS_COMPILE}gcc"