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
	

cd ${OPENSHIFT_HOMEDIR}server/usr/bin \
&& mv nginx nginx.old
	

#configure nginx

cd ${OPENSHIFT_DATA_DIR}build_nginx/nginx \
&&  ./configure \
	--prefix=${OPENSHIFT_HOMEDIR}server/ \
	--with-cc-opt='-g -O2 -fstack-protector --param=ssp-buffer-size=4 -Wformat -Werror=format-security -D_FORTIFY_SOURCE=2' \
    	--with-ld-opt='-Wl,-Bsymbolic-functions -Wl,-z,relro' \
   	--sbin-path=${OPENSHIFT_HOMEDIR}server/usr/bin/nginx \
    	--conf-path=${OPENSHIFT_HOMEDIR}server/conf/nginx.conf \
	--http-log-path=${OPENSHIFT_HOMEDIR}server/logs/access.log \
    	--error-log-path=${OPENSHIFT_HOMEDIR}server/logs/error.log \
    	--http-client-body-temp-path=${OPENSHIFT_HOMEDIR}server/temp/body \
    	--http-proxy-temp-path=${OPENSHIFT_HOMEDIR}server/temp/proxy \
	--sbin-path=${OPENSHIFT_HOMEDIR}server/usr/bin/nginx \
	--pid-path=${OPENSHIFT_HOMEDIR}server/run/nginx.pid \
	--with-debug \
	--with-http_realip_module \
	--with-http_addition_module \
	--with-http_sub_module \
	--with-http_gunzip_module \
	--with-http_dav_module \
	--with-http_flv_module \
	--with-http_mp4_module  \
	--with-http_v2_module \
	--with-file-aio \
	--with-ipv6 \
	--with-http_stub_status_module \
	--with-http_secure_link_module \
	--with-http_random_index_module \
	--with-mail \
	--with-mail_ssl_module \
	--with-http_ssl_module \
	--with-openssl=${OPENSHIFT_DATA_DIR}build_nginx/openssl \
	--with-zlib=${OPENSHIFT_DATA_DIR}build_nginx/zlib \
	--with-http_gzip_static_module \
	--with-pcre=${OPENSHIFT_DATA_DIR}build_nginx/pcre \
	--add-module=${OPENSHIFT_DATA_DIR}build_nginx/ngx_http_auth_request_module \
	--add-module=${OPENSHIFT_DATA_DIR}build_nginx/nginx-push-stream-module \
	--add-module=${OPENSHIFT_DATA_DIR}build_nginx/ngx_cache_purge \
	&& make \
	&& make install	
	
	

#delete old version of nginx sbin file
#cd ${OPENSHIFT_HOMEDIR}server/usr/versions \
#	&& rm -rf 1.4.4