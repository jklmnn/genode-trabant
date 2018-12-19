TARGET   = vga_terminal_drv
LIBS     = base ada
SRC_CC   = main.cc
SRC_ADB  = vga.adb escape_dfa.adb
INC_DIR += $(PRG_DIR) \
	   $(PRG_DIR)/libvga
