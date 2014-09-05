#!/bin/bash

#Build Variables
CHECKOUT='mono-3.8.0'
VERSION='3.8.0'
BUILD_DATE='09042014'
BIT_LEVEL='64bit'

cd /vagrant_data/

# Check to see if checkout is in place on VM, handle either by fetch or clone
if [ -d "/vagrant_data/${CHECKOUT}-${BIT_LEVEL}" ]; then
        cd /vagrant_data/${CHECKOUT}-${BIT_LEVEL}
        git fetch
else
        git clone  --depth 0 git://github.com/mono/mono.git ${CHECKOUT}-${BIT_LEVEL} && cd ${CHECKOUT}-${BIT_LEVEL} && git checkout ${CHECKOUT}
fi

# Run build process
git submodule init
git submodule update --recursive
./autogen.sh --prefix=/usr/local

# We don't have mono installed, so lets bootstrap the compiler
make get-monolite-latest

# Reference the current gmcs from monolite-latest
make EXTERNAL_MCS="${PWD}/mcs/class/lib/monolite/gmcs.exe"

# Compile mono
make -j8

# Run checks
make -j8 check

rm -rf /tmp/installdir && mkdir -p /tmp/installdir
make install DESTDIR=/tmp/installdir && cd ..

# Build package with FPM
fpm --after-install /vagrant_data/built_package/mono-after-install -s dir -t deb -n mono -v ${VERSION}-git-tag-${BUILD_DATE} -C /tmp/installdir usr/local
cp *.deb /vagrant_data/built_package
