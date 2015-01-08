SUDO =

PLATFORM ?= X64
RELEASE ?= 0

#Tool
CC = gcc
CPP = g++
STRIP = strip
AR = ar
TR = tr

#Global Compile Flags
CFLAGS_GLOBAL = -fno-strict-aliasing -g -W -Wall -Werror -Wno-pointer-sign -Wno-unused-parameter -D$(PLATFORM)=1
LDFLAGS_GLOBAL =
ASFLAGS_GLOBAL =

#Local Compile Flags
CFLAGS_LOCAL =
LDFLAGS_LOCAL =
ASFLAGS_LOCAL =

#Macros
OBJ_DIR = OBJ-$(PLATFORM)
GLOBAL_PRELIB_DIR = $(TOP_DIR)/build/lib/
GLOBAL_DYNLIB_DIR = $(TOP_DIR)/build/dynlib
GLOBAL_LIB_DIR = $(TOP_DIR)/build/lib
GLOBAL_BIN_DIR = $(TOP_DIR)/build/bin
LDFLAGS_PATH += -L$(GLOBAL_PRELIB_DIR) -L$(GLOBAL_DYNLIB_DIR) -L$(GLOBAL_LIB_DIR)

#Basic Rule Action
COMPILE = $(CC) $(CFLAGS_GLOBAL) $(CFLAGS_LOCAL) -MD -c -o $@ $<
COMPILE_CXX = $(CPP) $(CFLAGS_GLOBAL) $(CFLAGS_LOCAL) -MD -c -o $@ $<
ASSEMBLE = $(CC) $(ASFLAGS_GLOBAL) $(ASFLAGS_LOCAL) -MD -c -o $@ $<

ifeq ($(RELEASE), 1)
CFLAGS_GLOBAL += -O2 -DFLOW_MCHECK=1 -DMEM_NO_STAT=1 -DLICENSE_CHECK=1 -DSHELL_PASSWORD=1
else
CFLAGS_GLOBAL += -DBUILD_DEBUG=1
endif
