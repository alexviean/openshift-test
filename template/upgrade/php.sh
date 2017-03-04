#!/bin/bash

APP_UUID=$OPENSHIFT_APP_UUID
NGINX_MAIN_VERSION=1.11
source versions

## INSTALL ZLIB

	cd ${OPENSHIFT_DATA_DIR}
	if [ ! -e dependencies/include/zlib.h ]; then
		if [ ! -e zlib-${ZLIB_VERSION}.tar.gz ]; then
		wget ${ZLIB_LINK}/${ZLIB_VERSION}/zlib-${ZLIB_VERSION}.tar.gz
		fi
	rm -rf zlib-$ZLIB_VERSION
	tar -zxf zlib-$ZLIB_VERSION.tar.gz
	cd zlib-$ZLIB_VERSION
	chmod +x configure
	./configure --prefix=$OPENSHIFT_RUNTIME_DIR/dependencies/
	make && make install
		if [ $? -eq 0 ]; then
			echo "ZLIB has successfully been installed!"
			rm -rf $OPENSHIFT_RUNTIME_DIR/zlib-*
		else
			echo "The installation of ZLIB has been interrupted."
		fi
	else
		echo "ZLIB has already been installed!"
	fi

### INSTALL RE2C

	cd ${OPENSHIFT_DATA_DIR}
	if [ ! -e dependencies/bin/re2c ]; then
		if [ ! -e re2c-${RE2C_VERSION}.tar.gz ]; then
		wget $RE2C_LINK/${RE2C_VERSION}/re2c-${RE2C_VERSION}.tar.gz
		fi
	rm -rf re2c-$RE2C_VERSION
	tar -zxf re2c-${RE2C_VERSION}.tar.gz
	cd re2c-$RE2C_VERSION
	./configure --prefix=$OPENSHIFT_RUNTIME_DIR/dependencies/
	make install
		if [ $? -eq 0 ]; then
			echo "RE2C has successfully been installed!"
			rm -rf $OPENSHIFT_RUNTIME_DIR/re2c-*
		else
			echo "The installation of RE2C has been interrupted."
		fi
	else
		echo "RE2C has already been installed!"
	fi

### INSTALL BISON

	cd ${OPENSHIFT_DATA_DIR}
	if [ ! -e dependencies/bin/bison ]; then
		if [ ! -e bison-${BISON_VERSION}.tar.gz ]; then
		wget $BISON_LINK/bison-${BISON_VERSION}.tar.gz
		fi
	rm -rf bison-${BISON_VERSION}
	tar -zxf bison-${BISON_VERSION}.tar.gz
	cd bison-${BISON_VERSION}
	./configure --prefix=$OPENSHIFT_RUNTIME_DIR/dependencies/
	make install
		if [ $? -eq 0 ]; then
			echo "BISON has successfully been installed!"
			rm -rf $OPENSHIFT_RUNTIME_DIR/bison-*
		else
			echo "The installation of BISON has been interrupted."
		fi
	else
		echo "BISON has already been installed!"
	fi

### INSTALL MCRYPT

	cd ${OPENSHIFT_DATA_DIR}
	if [ ! -e dependencies/lib/libmcrypt ]; then
		if [ ! -e libmcrypt-$MCRYPT_VERSION.tar.gz ]; then
		wget $MCRYPT_LINK/$MCRYPT_VERSION/libmcrypt-$MCRYPT_VERSION.tar.gz
		fi
	rm -rf libmcrypt-$MCRYPT_VERSION
	tar -zxf libmcrypt-$MCRYPT_VERSION.tar.gz
	cd libmcrypt-$MCRYPT_VERSION
	./configure \
	--prefix=$OPENSHIFT_RUNTIME_DIR/dependencies/ \
	--disable-posix-threads
	make install
		if [ $? -eq 0 ]; then
			echo "MCRYPT has successfully been installed!"
			rm -rf $OPENSHIFT_RUNTIME_DIR/libmcrypt-*
		else
			echo "The installation of MCRYPT has been interrupted."
		fi
	else
		echo "MCRYPT has already been installed!"
	fi

### INSTALL LIBTOOL

	cd ${OPENSHIFT_DATA_DIR}
	if [ ! -e dependencies/bin/libtool ]; then
		if [ ! -e libtool-${LIBTOOL_VERSION}.tar.gz ]; then
		wget $LIBTOOL_LINK/libtool-${LIBTOOL_VERSION}.tar.gz
		fi
	rm -rf libtool-${LIBTOOL_VERSION}
	tar -zxf libtool-${LIBTOOL_VERSION}.tar.gz
	cd libtool-${LIBTOOL_VERSION}
	./configure --prefix=$OPENSHIFT_RUNTIME_DIR/dependencies/
	make install
		if [ $? -eq 0 ]; then
			echo "LIBTOOL has successfully been installed!"
			rm -rf $OPENSHIFT_RUNTIME_DIR/libtool-*
		else
			echo "The installation of LIBTOOL has been interrupted."
		fi
	else
		echo "LIBTOOL has already been installed!"
	fi
	

#configure nginx

cd ${OPENSHIFT_DATA_DIR} \
if [ ! -e ${OPENSHIFT_SERVER_DIR}usr/bin/php ]; then
	if [ -f php-${PHP_VERSION}.tar.gz ]; then
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
	--prefix=$OPENSHIFT_DATA_DIR/php/ \
	--with-config-file-path=$OPENSHIFT_DATA_DIR/php/etc \
	--with-mcrypt=$OPENSHIFT_RUNTIME_DIR/dependencies \
	--with-zlib=$OPENSHIFT_RUNTIME_DIR/dependencies \
	--with-icu-dir=$OPENSHIFT_RUNTIME_DIR/dependencies \
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
	
	

#delete old version of nginx sbin file
#cd ${OPENSHIFT_SERVER_DIR}/usr/versions \
#	&& rm -rf 1.4.4