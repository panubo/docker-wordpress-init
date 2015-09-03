#!/usr/bin/env bash

set -e

[ "$DEBUG" == 'true' ] && set -x

genpasswd() {
    export LC_CTYPE=C  # Quiet tr warnings
    local l=$1
    [ "$l" == "" ] && l=16
    tr -dc A-Za-z0-9_ < /dev/urandom | head -c ${l}
}

writeenv() {
    # write to env file
    echo "$1=$2" >> "${ENV_FILE}"
    export $1=$2
}

# Load environment file
ENV_FILE=${1-/output/environment}
touch "${ENV_FILE}"  # Create if not exist
source "${ENV_FILE}"
> "${ENV_FILE}"  # Zero it

# Sanity check
if [ -z "$APP_CODE" ]; then
    echo "Error: APP_CODE not set."
    exit 128
fi

# Database Variables
writeenv DB_NAME "$(echo ${DB_NAME:-$APP_CODE} | tr '-' '_' )"
writeenv DB_USER "$(echo ${DB_USER:-$APP_CODE} | tr '-' '_' )"
writeenv DB_PASS "${DB_PASS:-$(genpasswd 12)}"
writeenv DB_HOST "${MYSQL_PORT_3306_TCP_ADDR:-$DB_HOST}"

# Wordpress Secure Salts
HASHS='AUTH_KEY SECURE_AUTH_KEY LOGGED_IN_KEY NONCE_KEY AUTH_SALT SECURE_AUTH_SALT LOGGED_IN_SALT NONCE_SALT'
for KEY in $HASHS; do
    VAL=$(eval echo \$$KEY)
    writeenv "$KEY" "${VAL:-$(genpasswd 64)}"
done

# Update MySQL

while ! exec 6<>/dev/tcp/${DB_HOST}/3306; do
    echo "$(date) - waiting to connect to mysql at ${DB_HOST}:3306"
    sleep 1
done

MYSQL="mysql --host=${DB_HOST} --user=root --password=${MYSQL_ENV_MYSQL_ROOT_PASSWORD}"
echo "CREATE DATABASE IF NOT EXISTS ${DB_NAME};" | $MYSQL
echo "GRANT ALL ON ${DB_NAME}.* to ${DB_USER}@'%' IDENTIFIED BY '$DB_PASS';" | $MYSQL
echo "FLUSH PRIVILEGES;" | $MYSQL

echo ">> Wordpress Init Done."

if [ -n "$2" ] && [ "$2" == "--sleep" ]; then
    echo ">> sleeping"
    sleep infinity
fi