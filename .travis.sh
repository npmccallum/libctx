#!/bin/bash -ex

CORE="automake autoconf libtool make curl $CC"

case "$1" in
  multiarch/debian-*|multiarch/ubuntu-*)
    apt-get update
    apt-get -y install $CORE build-essential
    ;;

  multiarch/fedora:*)
    [ "$CC" == "clang" ] && rt=compiler-rt
    dnf -y install $CORE $rt
    ;;

  multiarch/centos:*)
    yum -y install $CORE gcc
    ;;
esac

autoreconf -if

if ! CFLAGS=-coverage LDFLAGS=-lgcov ./configure --prefix=/usr; then
  cat ./config.log
  exit 1
fi

make -j8 -k check V=1 TESTS=

if ! make -j8 check; then
  cat ./test-suite.log
  exit 1
fi

bash <(curl -s https://codecov.io/bash)
