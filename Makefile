PREFIX      =$(HOME)
DEST_DIR    = $(PREFIX)/bin/paxperscientiam

TARGET_DIR  = dist
TARGET      = $(TARGET_DIR)/manifest

$(TARGET):manifest.bash
					test -d ${TARGET_DIR} || mkdir ${TARGET_DIR}
					$(info Building manifest ...)
					BUILD='GO' bash manifest.bash
					$(info done.)


.PHONY:install
install:$(TARGET)
					$(info Copying dist/manifest to ${DEST_DIR}.)
					mkdir -p $(DEST_DIR)
					cp $(TARGET) $(DEST_DIR)


.PHONY:uninstall
uninstall: $(DEST_DIR)/manifest
					$(eval TMP_DIR := $(shell mktemp -d))
					$(info Moving ${DEST_DIR} to the ${TMP_DIR}.)
					mv $(DEST_DIR) $(TMP_DIR)
