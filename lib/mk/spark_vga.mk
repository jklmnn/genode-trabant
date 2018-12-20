
include $(REP_DIR)/lib/import/import-spark_vga.mk

INC_DIR += $(REP_DIR)/src/lib/spark_vga

SRC_ADB = vga.adb \
	  escape_dfa.adb

LIBS += ada

vpath %.adb $(REP_DIR)/src/lib/spark_vga
