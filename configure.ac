AC_PREREQ(2.60)
AC_INIT([libctx], [0.1], [nathaniel@themccallums.org],
        [libctx], [http://www.github.com/npmccallum/libctx])
AC_CONFIG_AUX_DIR([build-aux])
AC_CONFIG_MACRO_DIR([m4])
AC_PREFIX_DEFAULT([/usr])
AC_USE_SYSTEM_EXTENSIONS
AC_CANONICAL_SYSTEM
AC_SYS_LARGEFILE
AC_PROG_CC_STDC
AC_PROG_LIBTOOL
AC_PROG_SED

AM_INIT_AUTOMAKE([check-news foreign 1.11 -Wall -Wno-portability silent-rules tar-pax no-dist-gzip dist-xz subdir-objects])
AM_SILENT_RULES([yes])
AM_PROG_CC_C_O
AM_PROG_AS

LT_INIT([disable-static pic-only])

dnl Check for pointer size
AC_CHECK_SIZEOF([void *])
case $ac_cv_sizeof_void_p in
  4) BITS=32; AC_DEFINE([CTX_32BIT]);; 
  8) BITS=64; AC_DEFINE([CTX_64BIT]);;
  *) AC_MSG_ERROR([invalid size ($ac_cv_sizeof_void_p)]);;
esac

dnl Check for architecture
AC_MSG_CHECKING([compatibility ($target_cpu)])
case $target_cpu in
         arm*) IMPLEMENTATION=gas-arm-aapcs.lo;;
        mips*) IMPLEMENTATION=gas-mips-o32.lo;;
     powerpc*) IMPLEMENTATION=gas-ppc-sysv.lo;;
       sparc*) IMPLEMENTATION=gas-sparc-sysv.lo;;
  i?86|x86_64) IMPLEMENTATION=gas-x86_$BITS-sysv.lo;;
            *) AC_MSG_ERROR([not found]);;
esac
AC_MSG_RESULT([$IMPLEMENTATION])
AC_SUBST(IMPLEMENTATION)

AC_CONFIG_FILES(Makefile src/Makefile)
AC_OUTPUT
AC_MSG_RESULT([
        $PACKAGE $VERSION
        ========

        prefix:                 ${prefix}
        libdir:                 ${libdir}
        includedir:             ${includedir}
        localstatedir:          ${localstatedir}

        compiler:               ${CC}
        cflags:                 ${CFLAGS}
        ldflags:                ${LDFLAGS}
        
        host:                   ${host}
        build:                  ${build}
        target:                 ${target}
])