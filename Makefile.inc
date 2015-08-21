# vim: ft=make ts=3 sw=3 st=3 sts=3 sta noet tw=80 list
LUASRC=lua-$(LVER).$(LREL).tar.gz

COMPDIR=$(CURDIR)/compile
OUTDIR=$(CURDIR)/out
SRCDIR=$(CURDIR)/src

all: install

$(SRCDIR):
	mkdir -p $(SRCDIR)

$(SRCDIR)/$(LUASRC): $(SRCDIR)
	$(DLCMD) -o $(SRCDIR)/$(LUASRC)   $(DLPATH)/$(LUASRC) 

