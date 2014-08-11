#!/bin/bash

#Build Variables
CHECKOUT='mono-3.4.0'
VERSION='3.4.0'
BUILD_DATE='08102014'
BIT_LEVEL='64bit'


echo '#!/bin/bash' > /root/mono-link-update.sh
echo "unlink /usr/local/bin/mono" >> /root/mono-link-update.sh
echo "ln -s /usr/local/bin/mono-sgen /usr/local/bin/mono" >> /root/mono-link-update.sh

cd /vagrant_data/ && git clone git://github.com/mono/mono.git ${CHECKOUT}-${BIT_LEVEL} && cd ${CHECKOUT}-${BIT_LEVEL} && git checkout ${CHECKOUT}
./autogen.sh --prefix=/usr/local
make
make check
rm -rf /tmp/installdir && mkdir -p /tmp/installdir
make install DESTDIR=/tmp/installdir && cd ..
fpm --after-install /root/mono-link-update.sh -s dir -t deb -n mono -v ${VERSION}-git-tag-${BUILD_DATE} -C /tmp/installdir usr/local
cp *.deb /vagrant_data/built_package
