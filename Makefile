# vim: ft=make ts=3 sw=3 st=3 sts=3 sta noet tw=80 list

LVER=5.3
LREL=1
DLPATH=http://www.lua.org/ftp
DLCMD=curl

include Makefile.inc

CC=clang
LD=clang


$(COMPDIR)/$(LVER)/src: $(SRCDIR)/$(LUASRC)
	mkdir -p $(COMPDIR)/$(LVER)
	tar -xvzf $(SRCDIR)/$(LUASRC) -C $(COMPDIR)/$(LVER) --strip-components=1
	patch -d $(COMPDIR)/$(LVER)/src/ -i $(CURDIR)/relocate-5.3.patch

$(COMPDIR)/$(LVER)/src/lua: $(COMPDIR)/$(LVER)/src
	$(MAKE) -C $(COMPDIR)/$(LVER) -j 4 CC=$(CC) LD=$(LD) \
		MYCFLAGS=" -g -fPIC " \
		linux

$(TDIR)/t.so: $(COMPDIR)/$(LVER)/src
	$(MAKE) -C $(TDIR) -j 4 CC=$(CC) LD=$(LD) \
		LVER=$(LVER) \
		MYCFLAGS=' -g' \
		INCS="$(COMPDIR)/$(LVER)/src" t.so

install: $(COMPDIR)/$(LVER)/src/lua
	$(MAKE) -C $(COMPDIR)/$(LVER) CC=$(CC) LD=$(LD) \
		LVER=$(LVER) \
		INSTALL_TOP="$(OUTDIR)" \
		install
	$(MAKE) -C $(TDIR) CC=$(CC) LD=$(LD) \
		LVER=$(LVER) \
		MYCFLAGS=' -g' \
		INCS="$(COMPDIR)/$(LVER)/src" \
		PREFIX="$(OUTDIR)" install

clean:
	rm -rf $(COMPDIR)

remove: clean
	rm -rf $(OUTDIR)

pristine: remove
	-rm -rf $(SRCDIR)
