PREFIX = /usr/local

manifest: manifest.bash
					echo 'building manifest'
					BUILD=0 bash manifest.bash

# .PHONY: install
# install: manifest
#		mkdir -p $(DESTDIR)$(PREFIX)/bin
#		cp $< $(DESTDIR)$(PREFIX)/bin/manifest

# .PHONY: uninstall
# uninstall:
#		rm -f $(DESTDIR)$(PREFIX)/bin/manifest
