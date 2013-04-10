LDADD = libctx.la

AM_CFLAGS = \
    -Wall \
    -Wmissing-declarations \
    -Wmissing-prototypes \
    -Wnested-externs \
    -Wpointer-arith \
    -Wpointer-arith \
    -Wsign-compare \
    -Wchar-subscripts \
    -Wstrict-prototypes \
    -Wformat-security \
    -ffunction-sections \
    -fdata-sections

include_HEADERS = ctx.h
lib_LTLIBRARIES = libctx.la
check_PROGRAMS = test benchmark
TESTS = $(check_PROGRAMS)

libctx_la_SOURCES = ctx.c
libctx_la_LIBADD = $(IMPLEMENTATION)
libctx_la_DEPENDENCIES = $(IMPLEMENTATION)
libctx_la_LDFLAGS = $(AM_LDFLAGS) -version-info 0:0:0 \
                    -export-symbols-regex '^ctx_'
EXTRA_libctx_la_SOURCES = \
    gas-arm-aapcs.S \
    gas-mips-o32.S \
    gas-ppc-sysv.S \
    gas-sparc-sysv.S \
    gas-x86_32-sysv.S \
    gas-x86_64-sysv.S
