LVER=5.3
LREL=1
LUASRC=lua-$(LVER).$(LREL).tar.gz
DLPATH=http://www.lua.org/ftp

COMPDIR=$(CURDIR)/compile
OUTDIR=$(CURDIR)/out
SRCDIR=$(CURDIR)/sources
CC=clang
LD=clang

all: install

$(SRCDIR)/$(LUASRC):
	curl -o $(SRCDIR)/$(LUASRC)   $(DLPATH)/$(LUASRC) 

$(COMPDIR)/$(LVER)/src: $(SRCDIR)/$(LUASRC)
	mkdir -p $(COMPDIR)/$(LVER)
	tar -xvzf $(SRCDIR)/$(LUASRC) -C $(COMPDIR)/$(LVER) --strip-components=1
	patch -d $(COMPDIR)/$(LVER)/src/ -i $(SRCDIR)/lua-5.3_relocate.patch

$(COMPDIR)/$(LVER)/src/lua: $(COMPDIR)/$(LVER)/src
	cd $(COMPDIR)/$(LVER) ; \
		$(MAKE) -j 4 CC=$(CC) LD=$(LD) \
		MYCFLAGS=" -g -fPIC " \
		linux

$(TDIR)/t.so: $(COMPDIR)/$(LVER)/src
	cd $(TDIR) ; $(MAKE) -j 4 CC=$(CC) LD=$(LD) \
		LVER=$(LVER) \
		MYCFLAGS=' -g' \
		INCS="$(COMPDIR)/$(LVER)/src" t.so

install: $(COMPDIR)/$(LVER)/src/lua
	cd $(COMPDIR)/$(LVER) ; $(MAKE) CC=$(CC) LD=$(LD) \
		LVER=$(LVER) \
		INSTALL_TOP="$(OUTDIR)" \
		install
	cd $(TDIR) ; $(MAKE) CC=$(CC) LD=$(LD) \
		LVER=$(LVER) \
		MYCFLAGS=' -g' \
		INCS="$(COMPDIR)/$(LVER)/src" \
		PREFIX="$(OUTDIR)" install

clean:
	rm -rf $(COMPDIR)

remove: clean
	rm -rf $(OUTDIR)

pristine:
	rm $(SRCDIR)/$(LUASRC)
