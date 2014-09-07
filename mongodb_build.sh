#!/bin/bash
VERSION='2.6.4'
BUILD_DATE=`date +%d%m%Y`
 
# Grab the source code.
git clone git://github.com/mongodb/mongo.git
cd mongo
git checkout $VERSION
 
# Build it with SSL enabled and mostly statically.
mkdir /tmp/installdir_mongo
scons install --64 --ssl --release --no-glibc-check --prefix=/tmp/installdir_mongo/usr/bin
cd /tmp/installdir_mongo

fpm -s dir -t deb -n mongodb -v ${VERSION}-git-tag-${BUILD_DATE} -C /tmp/installdir_mongo usr/bin
cp *.deb /vagrant_data/built_package
