#!/bin/bash

source versions

function install_dephp() {

### INSTALL ICU

	cd ${OPENSHIFT_DATA_DIR}
	if [ ! -e icu4c/lib/icu ]; then
		if [ ! -e icu4c-${ICU_VERSION[1]}-src.tgz ]; then
		wget $ICU_LINK/${ICU_VERSION[0]}/icu4c-${ICU_VERSION[1]}-src.tgz
		fi
	rm -rf icu
	tar -zxf icu4c-${ICU_VERSION[1]}-src.tgz
	cd icu/source/
	chmod +x runConfigureICU configure install-sh
	./configure --prefix=${OPENSHIFT_SERVER_DIR}usr
	make && make install
		if [ $? -eq 0 ]; then
			echo "ICU has successfully been installed!"
			rm -rf $OPENSHIFT_DATA_DIR/icu*
		else
			echo "The installation of ICU has been interrupted."
		fi
	else
		echo "ICU has already been installed!"
	fi

## INSTALL ZLIB

	cd ${OPENSHIFT_DATA_DIR}
	if [ ! -e zlib/include/zlib.h ]; then
		if [ ! -e zlib-${ZLIB_VERSION}.tar.gz ]; then
		wget ${ZLIB_LINK}/${ZLIB_VERSION}/zlib-${ZLIB_VERSION}.tar.gz
		fi
	rm -rf zlib-$ZLIB_VERSION
	tar -zxf zlib-$ZLIB_VERSION.tar.gz
	cd zlib-$ZLIB_VERSION
	chmod +x configure
	./configure --prefix=${OPENSHIFT_SERVER_DIR}usr
	make && make install
		if [ $? -eq 0 ]; then
			echo "ZLIB has successfully been installed!"
			rm -rf $OPENSHIFT_DATA_DIR/zlib-*
		else
			echo "The installation of ZLIB has been interrupted."
		fi
	else
		echo "ZLIB has already been installed!"
	fi

### INSTALL RE2C

	cd ${OPENSHIFT_DATA_DIR}
	if [ ! -e re2c/bin/re2c ]; then
		if [ ! -e re2c-${RE2C_VERSION}.tar.gz ]; then
		wget $RE2C_LINK/${RE2C_VERSION}/re2c-${RE2C_VERSION}.tar.gz
		fi
	rm -rf re2c-$RE2C_VERSION
	tar -zxf re2c-${RE2C_VERSION}.tar.gz
	cd re2c-$RE2C_VERSION
	./configure --prefix=${OPENSHIFT_SERVER_DIR}usr
	make install
		if [ $? -eq 0 ]; then
			echo "RE2C has successfully been installed!"
			rm -rf $OPENSHIFT_DATA_DIR/re2c-*
		else
			echo "The installation of RE2C has been interrupted."
		fi
	else
		echo "RE2C has already been installed!"
	fi

### INSTALL BISON

	cd ${OPENSHIFT_DATA_DIR}
	if [ ! -e bison/bin/bison ]; then
		if [ ! -e bison-${BISON_VERSION}.tar.gz ]; then
		wget $BISON_LINK/bison-${BISON_VERSION}.tar.gz
		fi
	rm -rf bison-${BISON_VERSION}
	tar -zxf bison-${BISON_VERSION}.tar.gz
	cd bison-${BISON_VERSION}
	./configure --prefix=${OPENSHIFT_SERVER_DIR}usr
	make install
		if [ $? -eq 0 ]; then
			echo "BISON has successfully been installed!"
			rm -rf $OPENSHIFT_DATA_DIR/bison-*
		else
			echo "The installation of BISON has been interrupted."
		fi
	else
		echo "BISON has already been installed!"
	fi

### INSTALL MCRYPT

	cd ${OPENSHIFT_DATA_DIR}
	if [ ! -e libmcrypt/lib/libmcrypt ]; then
		if [ ! -e libmcrypt-$MCRYPT_VERSION.tar.gz ]; then
		wget $MCRYPT_LINK/$MCRYPT_VERSION/libmcrypt-$MCRYPT_VERSION.tar.gz
		fi
	rm -rf libmcrypt-$MCRYPT_VERSION
	tar -zxf libmcrypt-$MCRYPT_VERSION.tar.gz
	cd libmcrypt-$MCRYPT_VERSION
	./configure	--prefix=${OPENSHIFT_SERVER_DIR}usr --disable-posix-threads
	
	make install
		if [ $? -eq 0 ]; then
			echo "MCRYPT has successfully been installed!"
			rm -rf $OPENSHIFT_DATA_DIR/libmcrypt-*
		else
			echo "The installation of MCRYPT has been interrupted."
		fi
	else
		echo "MCRYPT has already been installed!"
	fi

### INSTALL LIBTOOL

	cd ${OPENSHIFT_DATA_DIR}
	if [ ! -e libtool/bin/libtool ]; then
		if [ ! -e libtool-${LIBTOOL_VERSION}.tar.gz ]; then
		wget $LIBTOOL_LINK/libtool-${LIBTOOL_VERSION}.tar.gz
		fi
	rm -rf libtool-${LIBTOOL_VERSION}
	tar -zxf libtool-${LIBTOOL_VERSION}.tar.gz
	cd libtool-${LIBTOOL_VERSION}
	./configure --prefix=${OPENSHIFT_SERVER_DIR}usr
	make install
		if [ $? -eq 0 ]; then
			echo "LIBTOOL has successfully been installed!"
			rm -rf $OPENSHIFT_DATA_DIR/libtool-*
		else
			echo "The installation of LIBTOOL has been interrupted."
		fi
	else
		echo "LIBTOOL has already been installed!"
	fi
}


function install_php() {
	cd ${OPENSHIFT_DATA_DIR}
	if [ ! -e ${OPENSHIFT_SERVER_DIR}usr/bin/php ]; then
		if [ -f php-${PHP_VERSION}.tar.gz ]; then
			echo "Found PHP source code, skip downloading."
		else
			echo "Downloading PHP source code"
			wget $PHP_LINK/php-${PHP_VERSION}.tar.gz && \
			if [ $? -ne 0 ]; then
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
}

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
	to_strip=('nginx' 'php' 'php-cgi' 'phpdbg')

	cd ${OPENSHIFT_SERVER_DIR}usr
	rm -rf var share man include php
	
	for l in "${del_lib[@]}"; do
		rm ${OPENSHIFT_SERVER_DIR}usr/bin/$l
	done

	for s in "${del_sbin[@]}"; do
		rm ${OPENSHIFT_SERVER_DIR}usr/sbin/$s
	done

	strip ${OPENSHIFT_SERVER_DIR}usr/sbin/php-fpm
	
	for t in "${to_strip[@]}"; do
		rm ${OPENSHIFT_SERVER_DIR}usr/sbin/$t
	done

}