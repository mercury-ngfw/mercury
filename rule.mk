SRCS = $(wildcard *.c)
OBJS = $(SRCS:%.c=$(OBJ_DIR)/%.o)

CXXSRCS = $(wildcard *.cc)
CXXOBJS = $(CXXSRCS:%.cc=$(OBJ_DIR)/%.oo)

DBG_XML_PNMAE = $(XML_DEBUG:%_debug.xml=%)
CFG_XML_PNAME = $(XML_CONFIG:%.xml=%)

DBG_C_FILE = $(XML_DEBUG:%_debug.xml=%_debug.c)
DBG_H_FILE = $(XML_DEBUG:%_debug.xml=%_debug.h)
DBG_CLI_FILE = $(XML_DEBUG:%_debug.xml=%)

CFG_ENTITY_C_FILE = $(XML_CONFIG:%.xml=%_entity.c)
CFG_MGIIMPL_H_FILE = $(XML_CONFIG:%.xml=%_mgi_impl.h)
CFG_MGIIMPL_C_FILE = $(XML_CONFIG:%.xml=%_mgi_impl.c.tmp)
CFG_MGIEX_H_FILE = $(XML_CONFIG:%.xml=mgi_%_exchange.h)
CFG_MGIEX_C_FILE = $(XML_CONFIG:%.xml=mgi_%_exchange.c)
CFG_MGDCST_H_FILE = $(XML_CONFIG:%.xml=mgd_%_construct.h)
CFG_MGDCST_C_FILE = $(XML_CONFIG:%.xml=mgi_%_construct.c)
CFG_MGD_C_FILE = $(XML_CONFIG:%.xml=mgd_%.c)
CFG_MGD_H_FILE = $(XML_CONFIG:%.xml=mgd_%.h)
CFG_GENCFG_C_FILE = $(XML_CONFIG:%.xml=mgd_%_gencfg.c.tmp)

SUB_MOD_OBJS = $(SUB_MOD:%=$(OBJ_DIR)/_%.o)

ifeq ($(strip $(BUILD_TYPE)), obj)
TARGET_FILENAME = _$(BUILD_NAME).o
INSTALL_DIR = ../$(OBJ_DIR)
endif

ifeq ($(strip $(BUILD_TYPE)), lib)
TARGET_FILENAME = $(BUILD_NAME).a
INSTALL_DIR = $(GLOBAL_LIB_DIR)
endif

ifeq ($(strip $(BUILD_TYPE)), dynlib)
TARGET_FILENAME = $(BUILD_NAME).so
INSTALL_DIR = $(GLOBAL_DYNLIB_DIR)
endif

ifeq ($(strip $(BUILD_TYPE)), bin)
TARGET_FILENAME = $(BUILD_NAME)
INSTALL_DIR = $(GLOBAL_BIN_DIR)
endif

TARGET = $(OBJ_DIR)/$(TARGET_FILENAME)

CFLAGS_LOCAL += -I$(TOP_DIR)/src/include -I$(TOP_DIR)/src/share-include
ifeq ($(strip $(BUILD_TYPE)), dynlib)
CFLAGS_LOCAL += -fPIC
endif

ifeq ($(strip $(BUILD_TYPE)), bin)
LDFLAGS_PATH += -lrt -Wl,-rpath,/usr/local/lib
endif

# RULE
all: $(OBJ_DIR) make_sub $(TARGET) copy_target

prepare: prepare_debug prepare_cfg

prepare_debug: $(DBG_C_FILE)
	-@for sub in $(SUB_DIR) ; do make -C $$sub prepare_debug ; done

prepare_cfg: $(CFG_ENTITY_C_FILE)
	-@for sub in $(SUB_DIR) ; do make -C $$sub prepare_cfg ; done

%_debug.c: %_debug.xml
	$(TOP_DIR)/tool/convert/dbgconvert $< $(TOP_DIR)/src/mgmt/ cli_dbg_init.inc mgd_debug_entries_construct.inc $(XML_DEBUG_H_DIR)

%_entity.c: %.xml
	$(TOP_DIR)/tool/convert/mgiconvert $< mgd_entity_init.inc -d $(TOP_DIR)

clean_debug:
	-@for afile in $(DBG_C_FILE) ; do /bin/rm -f `basename $$afile`; done
ifeq (_$(strip $(XML_DEBUG_H_DIR))_, __)
	-@for afile in $(DBG_H_FILE) ; do /bin/rm -f `basename $$afile`; done
else
	-@for afile in $(DBG_H_FILE) ; do /bin/rm -f $(strip $(XML_DEBUG_H_DIR))/`basename $$afile`; done
endif
	-@for afile in $(DBG_CLI_FILE) ; do /bin/rm -f $(TOP_DIR)/src/mgmt/cli/cli_debug_`basename $$afile`.c; done
	-@for sub in $(SUB_DIR) ; do \
	make -C $$sub clean_debug ; \
	done

clean_cfg:
	-@for afile in $(CFG_ENTITY_C_FILE) ; do /bin/rm -f `basename $$afile`; done
	-@for afile in $(CFG_MGIIMPL_H_FILE) ; do /bin/rm -f `basename $$afile`; done
	-@for afile in $(CFG_MGIIMPL_C_FILE) ; do /bin/rm -f `basename $$afile`; done
	-@for afile in $(CFG_XML_PNAME) ; do \
		bname=`basename $$afile`; \
		/bin/rm -f $(TOP_DIR)/src/include/mgd/mgi_$$bname_exchange.h $(TOP_DIR)/src/include/mgd/mgd_$$bname_construct.h $(TOP_DIR)/src/include/mgd/mgd_$$bname.h; \
		/bin/rm -f $(TOP_DIR)/src/libmgmt/mgi_$$bname_exchange.c $(TOP_DIR)/src/libmgmt/mgd_$$bname_construct.c; \
		/bin/rm -f $(TOP_DIR)/src/mgmt/mgd/mgd_$$bname.c $(TOP_DIR)/src/mgmt/mgd/mgd_$$bname_gencfg.c.tmp $(TOP_DIR)/src/mgmt/mgd/mgd_$$bname_getdv.c.tmp; \
		done
	-@for sub in $(SUB_DIR) ; do make -C $$sub clean_cfg ; done

$(OBJ_DIR):
	-@mkdir $(OBJ_DIR)

$(OBJ_DIR)/%.o: %.c
	$(COMPILE)

$(OBJ_DIR)/%.oo: %.cc
	$(COMPILE_CXX)

$(OBJ_DIR)/%.d: %.c
	@-rm -f $@

ifeq ($(strip $(BUILD_TYPE)), obj)
$(TARGET): $(OBJS) $(CXXOBJS) $(SUB_MOD_OBJS)
	$(CC) $(CFLAGS_GLOBAL) $(CFLAGS_LOCAL) -nostdlib -r -o $(TARGET) $(OBJS) $(CXXOBJS) $(SUB_MOD_OBJS)
endif

ifeq ($(strip $(BUILD_TYPE)), bin)
$(TARGET): $(OBJ_DIR) $(OBJS) $(LIBS_LIST) $(CXXOBJS) $(SUB_MOD_OBJS)
	$(CC) $(OBJS) $(CXXOBJS) $(SUB_MOD_OBJS) $(LDFLAGS_PATH) $(LIBS_LIST) $(LDFLAGS_GLOBAL) -o $@
endif

ifeq ($(strip $(BUILD_TYPE)), lib)
$(TARGET): $(OBJS) $(CXXOBJS) $(SUB_MOD_OBJS)
	$(AR) rc $(TARGET) $(OBJS) $(CXXOBJS) $(SUB_MOD_OBJS)
endif

ifeq ($(strip $(BUILD_TYPE)), dynlib)
$(TARGET): $(SUB_DIR_MOD) $(OBJS) $(CXXOBJS)
	$(CC) -shared -o $(TARGET) $(OBJS) $(CXXOBJS) $(SUB_MOD_OBJS)
endif

copy_target:
ifneq (_$(strip $(INSTALL_DIR))_, __)
	/bin/cp -f -p $(TARGET) $(INSTALL_DIR)
endif

strip:
	-@for sub in $(SUB_DIR) ; do make -C $$sub strip; done
	$(STRIP) $(STRIP_FLAGS) $(TARGET)

make_sub:
	-@for sub in $(SUB_DIR) ; do make -C $$sub ; done

clean: clean_debug clean_cfg
ifneq (_$(strip $(INSTALL_DIR))_, __)
	-@rm -rf $(INSTALL_DIR)/$(TARGET_FILENAME)
endif
	-@rm -rf $(OBJ_DIR)
	-@for sub in $(SUB_DIR) ; do make -C $$sub clean ; done
