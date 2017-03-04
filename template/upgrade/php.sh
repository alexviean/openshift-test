#!/bin/bash

source versions

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
	./configure	--prefix=$${OPENSHIFT_SERVER_DIR}usr --disable-posix-threads
	
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
