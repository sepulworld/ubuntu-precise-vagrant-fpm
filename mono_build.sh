#!/bin/bash

#Build Variables
CHECKOUT='mono-3.4.0'
VERSION='3.4.0'
BUILD_DATE='08122014'
BIT_LEVEL='64bit'

cd /vagrant_data/ && git clone git://github.com/mono/mono.git ${CHECKOUT}-${BIT_LEVEL} && cd ${CHECKOUT}-${BIT_LEVEL} && git checkout ${CHECKOUT}
./autogen.sh --prefix=/usr/local
make
make check
rm -rf /tmp/installdir && mkdir -p /tmp/installdir
make install DESTDIR=/tmp/installdir && cd ..
fpm --after-install /vagrant_data/built_package/mono-after-install -s dir -t deb -n mono -v ${VERSION}-git-tag-${BUILD_DATE} -C /tmp/installdir usr/local
cp *.deb /vagrant_data/built_package
