#!/bin/bash

source versions

cd ${OPENSHIFT_DATA_DIR}
if [ ! -e ${OPENSHIFT_SERVER_DIR}usr/bin/php ]; then
	if [ -e php-${PHP_VERSION}.tar.gz ]; then
		echo "Found PHP source code, skip downloading."
	else
		echo "Downloading PHP source code"
		wget $PHP_LINK/php-${PHP_VERSION}.tar.gz && \
	  if [ $? != 0 ]; then
		echo "ERROR! CANNOT DOWNLOAD php-${PHP_VERSION}"
		return 1
	  fi
	fi

	tar -zxf php-$PHP_VERSION.tar.gz
	cd php-${PHP_VERSION}
		
	[ ! -f Makefile ] && \
	./configure \
	--prefix=${OPENSHIFT_SERVER_DIR}usr \
	--with-config-file-path=${OPENSHIFT_SERVER_DIR}usr/etc \
	--with-mcrypt=${OPENSHIFT_SERVER_DIR}usr \
	--with-zlib=${OPENSHIFT_SERVER_DIR}usr \
	--with-icu-dir=${OPENSHIFT_SERVER_DIR}usr \
	--with-layout=PHP --disable-fileinfo --disable-debug --with-curl --with-mhash --with-pgsql --with-mysqli --with-pdo-mysql --with-pdo-pgsql --with-openssl --with-xmlrpc --with-xsl \
	--with-bz2 --with-gettext --with-readline --with-kerberos --with-gd --with-jpeg-dir --with-png-dir --with-png-dir --with-xpm-dir --with-freetype-dir --without-pear \
	--enable-gd-native-ttf --enable-fpm --enable-cli --enable-inline-optimization --enable-exif --enable-wddx --enable-zip --enable-bcmath --enable-calendar --enable-ftp \
	--enable-mbstring --enable-soap --enable-sockets --enable-shmop --enable-dba --enable-sysvsem --enable-sysvshm --enable-sysvmsg --enable-intl --enable-opcache --enable-maintainer-zts
	make
	make install
	if [ $? -eq 0 ]; then
		echo "PHP has successfully been installed!"
		rm -rf $OPENSHIFT_DATA_DIR/php-*
	else
		echo "The installation of PHP has been interrupted!"
	fi
else
	echo "PHP has already been installed!"
fi

function loadup_settings() {
	if [[ ( -f "${OPENSHIFT_REPO_DIR}php.ini.erb" ) && ( -e "${OPENSHIFT_SERVER_DIR}usr/etc") ]]; then
	oo-erb ${OPENSHIFT_REPO_DIR}php.ini.erb > ${OPENSHIFT_SERVER_DIR}usr/etc/php.ini
	fi

	if [[ ( -f "${OPENSHIFT_REPO_DIR}www.conf.erb" ) && ( -e "${OPENSHIFT_SERVER_DIR}usr/etc/php-fpm.d" )]]; then
	oo-erb ${OPENSHIFT_REPO_DIR}www.conf.erb > ${OPENSHIFT_SERVER_DIR}usr/etc/php-fpm.d/www.conf
	fi

	if [[ ( -f "${OPENSHIFT_REPO_DIR}php-fpm.conf.erb" ) && ( -e "${OPENSHIFT_SERVER_DIR}usr/etc" )]]; then
	oo-erb ${OPENSHIFT_REPO_DIR}php-fpm.conf.erb > ${OPENSHIFT_SERVER_DIR}usr/etc/php-fpm.conf
	fi
}

function cleanup() {
	del_lib=('bison' 'gencnval' 'icuinfo' 'makeconv' 'yacc' 'derb' 'gendict' 'libmcrypt-config' 'pkgdata' 'genbrk' 'genrb' 'libtool' 're2c' 'gencfu' 'icu-config' 'libtoolize' 'uconv')
	del_sbin=('genccode' 'gencmn' 'gennorm2' 'gensprep' 'icupkg')

	cd ${OPENSHIFT_SERVER_DIR}usr
	rm -rf var share man include php
	
	for l in "${del_lib[@]}"; do
		rm ${OPENSHIFT_SERVER_DIR}usr/bin/$l
	done

	for s in "${del_sbin[@]}"; do
		rm ${OPENSHIFT_SERVER_DIR}usr/sbin/$s
	done

	strip ${OPENSHIFT_SERVER_DIR}usr/bin/*
	strip ${OPENSHIFT_SERVER_DIR}usr/sbin/*
}

loadup_settings
cleanup