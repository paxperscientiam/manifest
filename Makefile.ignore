PREFIX = /usr/local

.PHONY: install
install: manifest
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	cp $< $(DESTDIR)$(PREFIX)/bin/manifest

.PHONY: uninstall
uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/manifest
