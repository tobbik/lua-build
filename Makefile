# vim: ft=make ts=3 sw=3 st=3 sts=3 sta noet tw=80 list

LVER=5.3
LREL=3
DLPATH=http://www.lua.org/ftp
DLCMD=curl
COSTUM=costums/lua-t.costum

LUASRC=lua-$(LVER).$(LREL).tar.gz

COMPDIR=$(CURDIR)/compile
PATCHDIR=$(CURDIR)/patches
PREFIX=$(CURDIR)/out
DLDIR=$(CURDIR)/download
LUAINC=$(PREFIX)/include

all: $(PREFIX)/bin/lua

include $(COSTUM)

MYCFLAGS= -g -O0

CC=clang
LD=clang

all: costuminstall

$(DLDIR):
	mkdir -p $(DLDIR)

$(DLDIR)/$(LUASRC): $(DLDIR)
	$(DLCMD) -o $(DLDIR)/$(LUASRC)   $(DLPATH)/$(LUASRC)

$(COMPDIR)/$(LVER)/src: $(DLDIR)/$(LUASRC)
	mkdir -p $(COMPDIR)/$(LVER)
	tar -xvzf $(DLDIR)/$(LUASRC) -C $(COMPDIR)/$(LVER) --strip-components=1
	patch -d $(COMPDIR)/$(LVER)/src/ -i $(CURDIR)/relocate-5.3.patch
	patch --strip 3 -d $(COMPDIR)/$(LVER)/src/ -i $(CURDIR)/relRequire-5.3.patch

$(COMPDIR)/$(LVER)/src/lua: $(COMPDIR)/$(LVER)/src
	$(MAKE) -C $(COMPDIR)/$(LVER) -j 4 CC=$(CC) LD=$(LD) \
		MYCFLAGS="$(MYCFLAGS)" \
		linux

$(PREFIX)/bin/lua: $(COMPDIR)/$(LVER)/src/lua
	$(MAKE) -C $(COMPDIR)/$(LVER) CC=$(CC) LD=$(LD) \
		LVER=$(LVER) \
		INSTALL_TOP=$(PREFIX) \
		install

costum: $(PREFIX)/bin/lua
	$(MAKE) CC=$(CC) LD=$(LD) \
		DLDIR=$(DLDIR) \
		DLCMD=$(DLCMD) \
		LVER=$(LVER) \
		MYCFLAGS="$(MYCFLAGS)" \
		LUAINC="$(LUAINC)" \
		PREFIX="$(PREFIX)" costuminstall

test: $(PREFIX)/bin/lua
	$(MAKE) CC=$(CC) LD=$(LD) \
		DLDIR=$(DLDIR) \
		DLCMD=$(DLCMD) \
		LVER=$(LVER) \
		MYCFLAGS="$(MYCFLAGS)" \
		LUAINC="$(LUAINC)" \
		PREFIX="$(PREFIX)" costumtest

clean:
	rm -rf $(COMPDIR)
	rm -rf $(PREFIX)
	rm $(PATCHDIR)/new.patch
	$(MAKE) CC=$(CC) LD=$(LD) \
		DLDIR=$(DLDIR) \
		DLCMD=$(DLCMD) \
		LVER=$(LVER) \
		MYCFLAGS="$(MYCFLAGS)" \
		LUAINC="$(LUAINC)" \
		PREFIX="$(PREFIX)" costumclean

pristine: remove
	$(MAKE) clean
	-rm -rf $(DLDIR)


$(PATCHDIR)/$(LVER): $(DLDIR)/$(LUASRC)
	mkdir -p $(PATCHDIR)/$(LVER)
	tar -xvzf $(DLDIR)/$(LUASRC) -C $(PATCHDIR)/$(LVER) --strip-components=1
	cp -avrp $(PATCHDIR)/$(LVER) $(PATCHDIR)/$(LVER).orig

patch: $(PATCHDIR)/$(LVER)
	diff -ruN patches/$(LVER).orig/src patches/$(LVER)/src > $(PATCHDIR)/new.patch
