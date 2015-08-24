# vim: ft=make ts=3 sw=3 st=3 sts=3 sta noet tw=80 list

LVER=5.3
LREL=1
DLPATH=http://www.lua.org/ftp
DLCMD=curl
COSTUM=costums/lua-t.costum

LUASRC=lua-$(LVER).$(LREL).tar.gz

COMPDIR=$(CURDIR)/compile
PREFIX=$(CURDIR)/out
DLDIR=$(CURDIR)/download
LUAINC=$(PREFIX)/include

all: $(PREFIX)/bin/lua

include $(COSTUM)

CC=clang
LD=clang

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
		MYCFLAGS=" -g -fPIC " \
		linux

$(PREFIX)/bin/lua: $(COMPDIR)/$(LVER)/src/lua
	$(MAKE) -C $(COMPDIR)/$(LVER) CC=$(CC) LD=$(LD) \
		LVER=$(LVER) \
		INSTALL_TOP="$(PREFIX)" \
		install

costum: $(PREFIX)/bin/lua
	$(MAKE) CC=$(CC) LD=$(LD) \
		DLDIR=$(DLDIR) \
		DLCMD=$(DLCMD) \
		LVER=$(LVER) \
		MYCFLAGS=' -g' \
		LUAINC="$(LUAINC)" \
		PREFIX="$(PREFIX)" costumbuild
	$(MAKE) CC=$(CC) LD=$(LD) \
		DLDIR=$(DLDIR) \
		DLCMD=$(DLCMD) \
		LVER=$(LVER) \
		MYCFLAGS=' -g' \
		LUAINC="$(LUAINC)" \
		PREFIX="$(PREFIX)" costuminstall

clean:
	rm -rf $(COMPDIR)
	$(MAKE) CC=$(CC) LD=$(LD) \
		DLDIR=$(DLDIR) \
		DLCMD=$(DLCMD) \
		LVER=$(LVER) \
		MYCFLAGS=' -g' \
		LUAINC="$(LUAINC)" \
		PREFIX="$(PREFIX)" costumclean

remove: clean
	rm -rf $(PREFIX)

pristine: remove
	-rm -rf $(DLDIR)
