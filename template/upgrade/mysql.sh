#!/bin/bash
source ${OPENSHIFT_REPO_DIR}upgrade/versions

# Download
function get_extract() {
if [ ! -f ${OPENSHIFT_DATA_DIR}tmp.tgz ]; then
	curl -L -o ${OPENSHIFT_DATA_DIR}tmp.tgz ${MYSQL_LINK}mysql-${MYSQL_VERSION}-linux-glibc2.5-x86_64.tar.gz
fi

# Create bin directory if necessary
mkdir -p ${OPENSHIFT_SERVER_DIR}usr/data

# Copy just the mecessary files
tar -xvzf ${OPENSHIFT_DATA_DIR}tmp.tgz --strip-components=1 -C ${OPENSHIFT_SERVER_DIR}usr mysql-${MYSQL_VERSION}-linux-glibc2.5-x86_64/bin/{mysql,mysqld,mysqld_safe,my_print_defaults,resolveip}
tar -xvzf ${OPENSHIFT_DATA_DIR}tmp.tgz --strip-components=1 -C ${OPENSHIFT_SERVER_DIR}usr mysql-${MYSQL_VERSION}-linux-glibc2.5-x86_64/share
tar -xvzf ${OPENSHIFT_DATA_DIR}tmp.tgz --strip-components=2 -C ${OPENSHIFT_SERVER_DIR}usr/bin mysql-${MYSQL_VERSION}-linux-glibc2.5-x86_64/scripts/mysql_install_db
tar -xvzf ${OPENSHIFT_DATA_DIR}tmp.tgz --strip-components=2 -C ${OPENSHIFT_SERVER_DIR}usr mysql-${MYSQL_VERSION}-linux-glibc2.5-x86_64/support-files/my-default.cnf
}

## Create config file
function config_file() {
echo "
[mysqld_safe]
ledir = ${OPENSHIFT_SERVER_DIR}usr/bin

[mysqld]
explicit-defaults-for-timestamp
port=3307
socket=${OPENSHIFT_TMP_DIR}mysql.sock
basedir=${OPENSHIFT_SERVER_DIR}usr
datadir=${OPENSHIFT_SERVER_DIR}usr/data
tmpdir=${OPENSHIFT_TMP_DIR}
pid-file=${OPENSHIFT_SERVER_DIR}run/mysql.pid
log-error=${OPENSHIFT_SERVER_DIR}logs/mysql.log
" > ${OPENSHIFT_SERVER_DIR}usr/etc/my.cnf
}

# Create internal database
function internal_data() {
cd ${OPENSHIFT_SERVER_DIR}usr
./bin/mysql_install_db \
  --defaults-file=${OPENSHIFT_SERVER_DIR}usr/etc/my.cnf \
  --datadir=${OPENSHIFT_SERVER_DIR}usr/data
}

# Remove temporary tools
function clean_up() {
	# Remove downloaded archive
	rm ${OPENSHIFT_DATA_DIR}tmp.tgz
	
	# Strip symbols from mysqld, reducing file size by more than 80%
	strip ${OPENSHIFT_SERVER_DIR}usr/bin/*

	rm ${OPENSHIFT_SERVER_DIR}usr/bin/{mysql_install_db,resolveip}
	rm ${OPENSHIFT_SERVER_DIR}usr/{my-default.cnf,my-new.cnf}
}

# Add DB_HOST and DB_PORT environment variables
function add_port() {
#if [ -z "$OPENSHIFT_MYSQL_PROXY_PORT" ]; then
  # Since $OPENSHIFT_MYSQL_PROXY_PORT is missing, cartridge must be running in the main gear
  echo "${OPENSHIFT_SERVER_IP}" > ${OPENSHIFT_SERVER_DIR}/env/DB_HOST
  echo "3306" > ${OPENSHIFT_SERVER_DIR}/env/DB_PORT
#else
#  # Found $OPENSHIFT_MYSQL_PROXY_PORT, the cartridge is running in a separate gear
#  echo "$OPENSHIFT_GEAR_DNS" > ${OPENSHIFT_SERVER_DIR}/env/DB_HOST
#  echo "$OPENSHIFT_MYSQL_DB_PROXY_PORT" > ${OPENSHIFT_SERVER_DIR}/env/DB_PORT
#fi
}

function start_mysql(){
	cd ${OPENSHIFT_SERVER_DIR}usr
	./bin/mysqld_safe --defaults-file=./etc/my.cnf &
}

function client_results() {
# Output result
client_result "MySQL ${MYSQL_VERSION} has been installed."
client_result "The initial root password will be set to 'root', make sure to change it!"
client_result "Use \$DB_HOST and \$DB_PORT environment variables to connect your application."
}