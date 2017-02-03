# vim: ft=make ts=3 sw=3 st=3 sts=3 sta noet tw=80 list

LVER=5.3
LREL=4
LRL=$(LVER).$(LREL)
DLPATH=http://www.lua.org/ftp
DLCMD=curl
COSTUM=costums/lua-t.costum

LUASRC=lua-$(LRL).tar.gz

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
	-rm -rf $(COMPDIR)
	-rm -rf $(PREFIX)
	-rm $(PATCHDIR)/new.patch
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


$(PATCHDIR)/$(LRL): $(DLDIR)/$(LUASRC)
	mkdir -p $(PATCHDIR)/$(LRL)
	tar -xvzf $(DLDIR)/$(LUASRC) -C $(PATCHDIR)/$(LRL) --strip-components=1
	cp -avrp $(PATCHDIR)/$(LRL) $(PATCHDIR)/$(LRL).orig

patch: $(PATCHDIR)/$(LRL)
	diff -ruN patches/$(LRL).orig/src patches/$(LRL)/src > $(PATCHDIR)/new.patch
