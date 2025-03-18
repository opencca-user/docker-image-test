include env.mk

export CROSS_COMPILE = aarch64-none-linux-gnu-
export ARCH = arm64
export CC = $(CROSS_COMPILE)gcc

