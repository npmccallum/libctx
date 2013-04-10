ACLOCAL_AMFLAGS = -I m4
SUBDIRS = . src

libctx.pc: libctx.pc.in Makefile
	$(SED) \
	-e 's,@VERSION\@,$(VERSION),g' \
	-e 's,@prefix\@,$(prefix),g' \
	-e 's,@exec_prefix\@,$(exec_prefix),g' \
	-e 's,@libdir\@,$(libdir),g' \
	-e 's,@includedir\@,$(includedir),g' \
	< $< > $@ || rm $@

pkgconfigdir = $(libdir)/pkgconfig
pkgconfig_DATA = libctx.pc

EXTRA_DIST = libctx.pc.in
CLEANFILES = libctx.pc