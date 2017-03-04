#!/bin/bash

APP_UUID=$OPENSHIFT_APP_UUID
NGINX_VERSION=1.11.10
NGINX_MAIN_VERSION=1.11
# download location to build libs
mkdir build_nginx && cd build_nginx/

#download nginx
wget -O nginx.tar.gz http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
	&& mkdir nginx \
	&& tar zxf nginx.tar.gz -C nginx --strip-components=1

#download pcre_library
wget -O pcre.tar.gz ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.40.tar.gz \
	&& mkdir pcre \
	&& tar zxf pcre.tar.gz -C pcre --strip-components=1


#download zlib library
wget -O zlib.tar.gz http://zlib.net/zlib-1.2.11.tar.gz \
	&& mkdir zlib \
	&& tar zxf zlib.tar.gz -C zlib --strip-components=1

 
#download openssl
wget -O openssl.tar.gz https://www.openssl.org/source/openssl-1.0.2k.tar.gz \
	&& mkdir openssl \
	&& tar zxf openssl.tar.gz -C openssl --strip-components=1
	

#download different nginx modules - ngx_http_auth_request_module, ngx_cache_purge, nginx-push-stream-module, ngx_http_geoip2_module 
git clone https://github.com/PiotrSikora/ngx_http_auth_request_module.git \
	&& git clone https://github.com/wandenberg/nginx-push-stream-module.git \
	&& git clone https://github.com/leev/ngx_http_geoip2_module.git \
	&& git clone https://github.com/FRiCKLE/ngx_cache_purge.git	



# compile and deploy location

cd /var/lib/openshift/${APP_UUID}/app-root/data && mkdir deploy_nginx/

#compile pcre library
cd /var/lib/openshift/${APP_UUID}/app-root/data/build_nginx/pcre \
	&& ./configure --prefix=/var/lib/openshift/${APP_UUID}/app-root/data/deploy_nginx/pcre \
	&& make \
	&& make install
	
#compile zlib library

cd /var/lib/openshift/${APP_UUID}/app-root/data/build_nginx/zlib \
	&& ./configure --prefix=/var/lib/openshift/${APP_UUID}/app-root/data/deploy_nginx/zlib \
	&& make \
	&& make install
	

#compile openssl library
cd /var/lib/openshift/${APP_UUID}/app-root/data/build_nginx/openssl \
	&& ./config --prefix=/var/lib/openshift/${APP_UUID}/app-root/data/deploy_nginx/openssl --openssldir=/var/lib/openshift/${APP_UUID}/app-root/data/deploy_nginx/openssl \
	&& make depend \
	&& make \
	&& make install
	

	

#configure nginx

cd /var/lib/openshift/${APP_UUID}/app-root/data/build_nginx/nginx \
&&  ./configure \
	--prefix=/var/lib/openshift/${APP_UUID}/nginx/ \
	--with-cc-opt='-g -O2 -fstack-protector --param=ssp-buffer-size=4 -Wformat -Werror=format-security -D_FORTIFY_SOURCE=2' \
    	--with-ld-opt='-Wl,-Bsymbolic-functions -Wl,-z,relro' \
   	--sbin-path=/var/lib/openshift/${APP_UUID}/nginx/usr/versions/${NGINX_VERSION}/bin/nginx \
    	--conf-path=/var/lib/openshift/${APP_UUID}/nginx/conf/nginx.conf \
	--http-log-path=/var/lib/openshift/${APP_UUID}/nginx/logs/access.log \
    	--error-log-path=/var/lib/openshift/${APP_UUID}/nginx/logs/error.log \
    	--http-client-body-temp-path=/var/lib/openshift/${APP_UUID}/nginx/temp/body \
    	--http-proxy-temp-path=/var/lib/openshift/${APP_UUID}/nginx/temp/proxy \
	--user=www \
	--sbin-path=/var/lib/openshift/${APP_UUID}/nginx/usr/versions/${NGINX_VERSION}/bin/nginx \
	--pid-path=/var/lib/openshift/${APP_UUID}/nginx/run/nginx.pid \
	--group=www \
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
	--with-openssl=/var/lib/openshift/${APP_UUID}/app-root/data/build_nginx/openssl \
	--with-zlib=/var/lib/openshift/${APP_UUID}/app-root/data/build_nginx/zlib \
	--with-http_gzip_static_module \
	--with-pcre=/var/lib/openshift/${APP_UUID}/app-root/data/build_nginx/pcre \
	--without-http_autoindex_module \
	--add-module=/var/lib/openshift/${APP_UUID}/app-root/data/build_nginx/ngx_http_auth_request_module \
	--add-module=/var/lib/openshift/${APP_UUID}/app-root/data/build_nginx/nginx-push-stream-module \
	--add-module=/var/lib/openshift/${APP_UUID}/app-root/data/build_nginx/ngx_cache_purge \
	&& make \
	&& make install	
	
	

#delete old version of nginx sbin file
cd /var/lib/openshift/${APP_UUID}/nginx/usr/versions \
	&& rm -rf 1.4.4
	

#edit the manifest file with the latest nginx version 
cd /var/lib/openshift/${APP_UUID}/nginx/metadata \
	&& rm -rf manifest.yml \
	&& touch manifest.yml \
	&& cat <<EOF >> manifest.yml
Name: nginx
Cartridge-Short-Name: NGINX
Display-Name: Nginx
Version: "${NGINX_VERSION}"
Versions: ["${NGINX_VERSION}"]
Website: https://github.com/alexviean/openshift-upgradable-nginx
Cartridge-Version: 0.0.3
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




	
