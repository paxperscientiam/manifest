PREFIX    =$(HOME)
DEST_DIR = $(PREFIX)/bin/paxperscientiam

# manifest:manifest.bash
# 					  $(info Building manifest ...)
# 					  BUILD=0 bash manifest.bash
# 					  $(info done.)


.PHONY:install
install:manifest
					$(info Copying dist/manifest to ${DEST_DIR}.)
					mkdir -p $(DEST_DIR)
					cp dist/manifest $(DEST_DIR)


.PHONY:uninstall
uninstall: $(DEST_DIR)/manifest
					  $(info Moving ${DEST_DIR} to the /tmp.)
					  mv $(DEST_DIR) /tmp
