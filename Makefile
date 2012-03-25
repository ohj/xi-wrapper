# Makefile for xi-wrapper

VERSION = 1
REVISION = 

# standard variables
bindir = $(exec_prefix)/bin
datadir = $(datarootdir)
datarootdir = $(prefix)/share
exec_prefix = $(prefix)
libdir = $(exec_prefix)/lib
prefix = /usr/local
sysconfdir = $(prefix)/etc

INSTALL = install
INSTALL_PROGRAM = $(INSTALL) -D -m0755
INSTALL_DATA = $(INSTALL) -D -m0644
INSTALL_DIR = $(INSTALL) -d

ifeq ($(V),1)
QUIET =
else
QUIET = @
endif

SRCS = \
	libusb.modulefile.in \
	usb-driver.modulefile.in \
	xi-config.in \
	xi-env.sh.in \
	xi-wrapper.in \

GENS := $(patsubst %.in,%,$(SRCS))

SYMLINKS = \
	bitgen \
	drc \
	fpga_editor \
	impact \
	ise \
	map \
	netgen \
	ngc2edif \
	ngdbuild \
	par \
	reportgen \
	timingan \
	trce \
	xst \

SUBST_VARS = $(QUIET)echo 'GEN     $@' ; \
	sed \
		-e 's:@bindir@:$(bindir):g' \
		-e 's:@datadir@:$(datadir):g' \
		-e 's:@datarootdir@:$(datarootdir):g' \
		-e 's:@exec_prefix@:$(exec_prefix):g' \
		-e 's:@libdir@:$(libdir):g' \
		-e 's:@prefix@:$(prefix):g' \
		-e 's:@sysconfdir@:$(sysconfdir):g' \
		$< > $@

.PRECIOUS: %.sh
%.sh: %.sh.in Makefile
	$(SUBST_VARS)

.PRECIOUS: %
%: %.in Makefile
	$(SUBST_VARS)

.PHONY: all
all: $(GENS)

.PHONY: install
install: all
	$(QUIET)echo 'INSTALL xi-config' ; \
	$(INSTALL_PROGRAM) xi-config $(DESTDIR)$(bindir)/xi-config
	$(QUIET)echo 'INSTALL xi-wrapper' ; \
	$(INSTALL_PROGRAM) xi-wrapper $(DESTDIR)$(bindir)/xi-wrapper
	$(QUIET)for f in $(SYMLINKS) ; do \
		echo "LN      $$f" ; \
		ln -sf xi-wrapper "$(DESTDIR)$(bindir)/$$f" ; \
	done
	$(QUIET)echo 'INSTALL hooks.d' ; \
	$(INSTALL_DIR) $(DESTDIR)$(datadir)/xi-wrapper/hooks.d

.PHONY: clean
clean:
	$(RM) $(GENS)

.PHONY: tarball
tarball:
	$(QUIET)echo 'TARBALL xi-wrapper-$(VERSION)$(REVISION).tar.gz' ; \
	git archive $(if $(QUIET),,-v) --format tar \
		--prefix xi-wrapper-$(VERSION)$(REVISION)/ HEAD | \
		gzip > xi-wrapper-$(VERSION)$(REVISION).tar.gz
