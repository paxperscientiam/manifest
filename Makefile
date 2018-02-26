PREFIX      =$(HOME)
DEST_DIR    = $(PREFIX)/bin/paxperscientiam

TARGET      = dist/manifest

$(eval TMP_DIR := $(shell mktemp -d))

$(TARGET):manifest.bash
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
					$(info Moving ${DEST_DIR} to the ${TMP_DIR}.)
					mv $(DEST_DIR) $(TMP_DIR)
