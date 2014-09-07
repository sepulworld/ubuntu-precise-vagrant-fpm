#!/bin/bash

#Build Variables
CHECKOUT='mono-3.8.0'
VERSION='3.8.0'
BUILD_DATE=`date +%d%m%Y`
BIT_LEVEL='64bit'

cd /vagrant_data/

# Check to see if checkout is in place on VM, handle either by fetch or clone
if [ -d "/vagrant_data/${CHECKOUT}-${BIT_LEVEL}" ]; then
        cd /vagrant_data/${CHECKOUT}-${BIT_LEVEL}
        git fetch
else
	cd /vagrant_data/
        git clone  --depth 0 git://github.com/mono/mono.git ${CHECKOUT}-${BIT_LEVEL} && cd ${CHECKOUT}-${BIT_LEVEL} && git checkout ${CHECKOUT}
fi


# Run build process for Mono
cd /vagrant_data/${CHECKOUT}-${BIT_LEVEL}
git submodule init
git submodule update --recursive
./autogen.sh --prefix=/usr/local
make get-monolite-latest

# Reference the current gmcs from monolite-latest
make EXTERNAL_MCS="${PWD}/mcs/class/lib/monolite/gmcs.exe"

make -j8
make -j8 check

rm -rf /tmp/installdir && mkdir -p /tmp/installdir
make install DESTDIR=/tmp/installdir && cd ..


# Build package with FPM
fpm --after-install /vagrant_data/built_package/mono-after-install -s dir -t deb -n mono -v ${VERSION}-git-tag-${BUILD_DATE} -C /tmp/installdir usr/local

dpkg -i mono_${VERSION}-git-tag-${BUILD_DATE}_amd64.deb

if (($? > 0 )); then
	echo "Mono package install verification failed!"
	exit 1
fi

#After mono install, proceed to build XSP web server package
if [ -d "/vagrant_data/xsp-${BIT_LEVEL}" ]; then
        cd /vagrant_data/xsp-${BIT_LEVEL}
        git fetch
else
        cd /vagrant_data/
        git clone --depth 0 git://github.com/mono/xsp.git xsp-${BIT_LEVEL}
fi


# Run build process for XSP
cd /vagrant_data/xsp-${BIT_LEVEL}
./autogen.sh --prefix=/usr/local
make get-monolite-latest
make EXTERNAL_MCS="${PWD}/mcs/class/lib/monolite/gmcs.exe"
make -j8
make -j8 check

rm -rf /tmp/installdir_xsp && mkdir -p /tmp/installdir_xsp
make install DESTDIR=/tmp/installdir_xsp && cd ..

fpm -s dir -t deb -n xsp -v ${VERSION}-git-master-${BUILD_DATE} -C /tmp/installdir_xsp usr/local

cp *.deb /vagrant_data/built_package

echo "Package build finished successfully"
