TOP_DIR = ../..
MODULE_TOP_DIR = .
include $(TOP_DIR)/env.mk

CFLAGS_LOCAL += -I$(MODULE_TOP_DIR)/include -DCLOCK_MONOTONIC -DCLOCK_REALTIME
BUILD_TYPE = dynlib
BUILD_NAME = libevent
SUB_MOD =
SUB_DIR = $(SUB_MOD)

include $(TOP_DIR)/rule.mk
