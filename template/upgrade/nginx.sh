#!/bin/bash

source versions
NGINX_MAIN_VERSION=1.11

function prepare_ndep() {
	cd ${OPENSHIFT_DATA_DIR}
	# download location to build libs
	mkdir build_nginx && cd build_nginx

	# download nginx

	wget -O nginx.tar.gz ${NGINX_LINK}nginx-${NGINX_VERSION}.tar.gz \
		&& mkdir nginx \
		&& tar zxf nginx.tar.gz -C nginx --strip-components=1

	# download pcre_library

	wget -O pcre.tar.gz ${PCRE_LINK}pcre-${PCRE_VERSION}.tar.gz \
		&& mkdir pcre \
		&& tar zxf pcre.tar.gz -C pcre --strip-components=1
	 
	# download openssl

	wget -O openssl.tar.gz ${OPENSSL_LINK}openssl-${OPENSSL_VERSION}.tar.gz \
		&& mkdir openssl \
		&& tar zxf openssl.tar.gz -C openssl --strip-components=1

	# download zlib library

	wget -O zlib.tar.gz ${ZLIB_LINK}${ZLIB_VERSION}zlib-${ZLIB_VERSION}.tar.gz \
		&& mkdir zlib \
		&& tar zxf zlib.tar.gz -C zlib --strip-components=1

	# download different nginx modules - ngx_http_auth_request_module, ngx_cache_purge, nginx-push-stream-module, ngx_http_geoip2_module 

	git clone https://github.com/PiotrSikora/ngx_http_auth_request_module.git \
		&& git clone https://github.com/wandenberg/nginx-push-stream-module.git \
		&& git clone https://github.com/leev/ngx_http_geoip2_module.git \
		&& git clone https://github.com/FRiCKLE/ngx_cache_purge.git	

	# compile and deploy location

	mkdir ${OPENSHIFT_DATA_DIR}deploy_nginx

	# compile pcre library

	cd ${OPENSHIFT_DATA_DIR}build_nginx/pcre \
		&& ./configure --prefix=${OPENSHIFT_DATA_DIR}deploy_nginx/pcre \
		&& make \
		&& make install
		
	# compile zlib library

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

	cd ${OPENSHIFT_SERVER_DIR}usr/bin \
	&& mv nginx nginx.old
}
	

function install_nginx() {
#configure nginx

	cd ${OPENSHIFT_DATA_DIR}build_nginx/nginx \
	&&  ./configure \
	--prefix=${OPENSHIFT_SERVER_DIR} \
	--with-cc-opt='-g -O2 -fstack-protector --param=ssp-buffer-size=4 -Wformat -Werror=format-security -D_FORTIFY_SOURCE=2' \
    	--with-ld-opt='-Wl,-Bsymbolic-functions -Wl,-z,relro' \
   	--sbin-path=${OPENSHIFT_SERVER_DIR}usr/bin/nginx \
    	--conf-path=${OPENSHIFT_SERVER_DIR}conf/nginx.conf \
	--http-log-path=${OPENSHIFT_SERVER_DIR}logs/access.log \
    	--error-log-path=${OPENSHIFT_SERVER_DIR}logs/error.log \
    	--http-client-body-temp-path=${OPENSHIFT_SERVER_DIR}temp/body \
    	--http-proxy-temp-path=${OPENSHIFT_SERVER_DIR}temp/proxy \
	--sbin-path=${OPENSHIFT_SERVER_DIR}usr/bin/nginx \
	--pid-path=${OPENSHIFT_SERVER_DIR}run/nginx.pid \
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
	if [ $? -eq 0 ]; then
		echo "NGINX has successfully been installed!"
		rm -rf ${OPENSHIFT_DATA_DIR}build_nginx \
		&& rm -rf ${OPENSHIFT_DATA_DIR}deploy_nginx \
		&& rm ${OPENSHIFT_SERVER_DIR}usr/bin/nginx.old
	else
		echo "The installation of NGINX has been interrupted!"
		mv ${OPENSHIFT_SERVER_DIR}usr/bin/nginx.old ${OPENSHIFT_SERVER_DIR}usr/bin/nginx
	fi
}


function update_metadata() {
# edit the manifest file with the latest nginx version 
cd ${OPENSHIFT_SERVER_DIR}metadata \
	&& rm -rf manifest.yml \
	&& touch manifest.yml \
	&& cat <<EOF >> manifest.yml
Name: server
Cartridge-Short-Name: SERVER
Display-Name: Web server
Version: "${NGINX_VERSION}"
Versions: ["${NGINX_VERSION}"]
Website: https://github.com/alexviean/openshift-test
Cartridge-Version: 0.0.5
Cartridge-Vendor: alexviean
Categories:
  - service
  - nginx
  - web_framework
Provides:
  - nginx-${NGINX_MAIN_VERSION}
  - nginx
  - nginx(version) = ${NGINX_VERSION}
Scaling:
  Min: 1
  Max: -1
Cart-Data:
  - Key: OPENSHIFT_NGINX_PORT
    Type: environment
    Description: "Internal port to which the web-framework binds to."
  - Key: OPENSHIFT_NGINX_IP
    Type: environment
    Description: "Internal IP to which the web-framework binds to."
Publishes:
  get-doc-root:
    Type: "FILESYSTEM:doc-root"
  publish-http-url:
    Type: "NET_TCP:httpd-proxy-info"
  publish-gear-endpoint:
    Type: "NET_TCP:gear-endpoint-info"
Subscribes:
  set-db-connection-info:
    Type: "ENV:NET_TCP:db:connection-info"
    Required: false
Group-Overrides:
  - components:
    - nginx-${NGINX_MAIN_VERSION}
    - web_proxy
Endpoints:
  - Private-IP-Name:   IP
    Private-Port-Name: PORT
    Private-Port:      8080
    Public-Port-Name:  PROXY_PORT
    Mappings:
      - Frontend:      ""
        Backend:       ""
        Options:       { websocket: true }
      - Frontend:      "/health"
        Backend:       ""
        Options:       { health: true }
Install-Build-Required: false

EOF
}