PREFIX      =$(HOME)
DEST_DIR    = $(PREFIX)/bin/paxperscientiam

TARGET      = dist/manifest


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
					$(info Moving ${DEST_DIR} to the /tmp.)
					mv $(DEST_DIR) /tmp
