#!/bin/bash

APP_UUID=$OPENSHIFT_APP_UUID
NGINX_MAIN_VERSION=1.11
source versions

cd ${OPENSHIFT_DATA_DIR}
# download location to build libs
mkdir build_nginx && cd build_nginx/

#download nginx
wget -O nginx.tar.gz ${NGINX_LINK}/nginx-${NGINX_VERSION}.tar.gz \
	&& mkdir nginx \
	&& tar zxf nginx.tar.gz -C nginx --strip-components=1

#download pcre_library
wget -O pcre.tar.gz ${PCRE_LINK}/pcre-${PCRE_VERSION}.tar.gz \
	&& mkdir pcre \
	&& tar zxf pcre.tar.gz -C pcre --strip-components=1
 
#download openssl
wget -O openssl.tar.gz ${OPENSSL_LINK}/openssl-${OPENSSL_VERSION}.tar.gz \
	&& mkdir openssl \
	&& tar zxf openssl.tar.gz -C openssl --strip-components=1

#download zlib library
wget -O zlib.tar.gz ${ZLIB_LINK}/${ZLIB_VERSION}/zlib-${ZLIB_VERSION}.tar.gz \
	&& mkdir zlib \
	&& tar zxf zlib.tar.gz -C zlib --strip-components=1

#download different nginx modules - ngx_http_auth_request_module, ngx_cache_purge, nginx-push-stream-module, ngx_http_geoip2_module 
git clone https://github.com/PiotrSikora/ngx_http_auth_request_module.git \
	&& git clone https://github.com/wandenberg/nginx-push-stream-module.git \
	&& git clone https://github.com/leev/ngx_http_geoip2_module.git \
	&& git clone https://github.com/FRiCKLE/ngx_cache_purge.git	



# compile and deploy location

cd ${OPENSHIFT_DATA_DIR} && mkdir deploy_nginx/

#compile pcre library
cd ${OPENSHIFT_DATA_DIR}build_nginx/pcre \
	&& ./configure --prefix=${OPENSHIFT_DATA_DIR}deploy_nginx/pcre \
	&& make \
	&& make install
	
#compile zlib library

cd ${OPENSHIFT_DATA_DIR}build_nginx/zlib \
	&& ./configure --prefix=${OPENSHIFT_DATA_DIR}deploy_nginx/zlib \
	&& make \
	&& make install
	

#compile openssl library
cd ${OPENSHIFT_DATA_DIR}build_nginx/openssl \
	&& ./config --prefix=${OPENSHIFT_DATA_DIR}deploy_nginx/openssl --openssldir=${OPENSHIFT_DATA_DIR}deploy_nginx/openssl \
	&& make depend \
	&& make \
	&& make install
	

cd ${OPENSHIFT_SERVER_DIR}/usr/bin \
&& mv nginx nginx.old
	

#configure nginx

cd ${OPENSHIFT_DATA_DIR} \
if [ ! -e ${OPENSHIFT_SERVER_DIR}usr/bin/php ]; then
	if [ -f php-${PHP_VERSION}.tar.gz ]; then
		echo "Found PHP source code, skip downloading."
	else
		echo "Downloading PHP source code"
		wget $PHP_MIRROR/php-${PHP_VERSION}.tar.gz && \
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
	--with-apxs2=$OPENSHIFT_DATA_DIR/httpd/bin/apxs \
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