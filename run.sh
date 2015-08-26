#!/usr/bin/env bash

set -e

genpasswd() {
    export LC_CTYPE=C  # Quiet tr warnings
    local l=$1
    [ "$l" == "" ] && l=16
    cat /dev/urandom | tr -dc A-Za-z0-9_ | head -c ${l}
}

# Load environment file
ENV_FILE=${1-/tmp/env}
touch "${ENV_FILE}"
source "${ENV_FILE}"

# Sanity check
if [ -z "$APP_CODE" ]; then
    echo "Error: APP_CODE not set."
    exit 128
fi

# Database Variables
export DB_NAME=${DB_NAME:-$APP_CODE}
export DB_USER=${DB_USER:-$APP_CODE}
export DB_PASS=${DB_PASS:-$(genpasswd 12)}
export DB_HOST=${DB_HOST:-$MYSQL_PORT_3306_TCP_ADDR}

# TODO
#DEBUG= Staging / Development

# Wordpress Secure Salts
HASHS='AUTH_KEY SECURE_AUTH_KEY LOGGED_IN_KEY NONCE_KEY AUTH_SALT SECURE_AUTH_SALT LOGGED_IN_SALT NONCE_SALT'
for KEY in $HASHS; do
    VAL=$(eval echo \$$KEY)
    if [ -z "$VAL" ]; then
        export $KEY=$(genpasswd 64)
    fi
done

# Write out env file
printenv | sort > "${ENV_FILE}"

# Update MySQL
MYSQL="mysql --host=${DB_HOST} --user=root --password=$MYSQL_ENV_MYSQL_ROOT_PASSWORD"
echo "CREATE DATABASE IF NOT EXISTS ${DB_NAME};" | $MYSQL
echo "GRANT ALL ON ${DB_NAME}.* to ${DB_USER}@'%' IDENTIFIED BY '$DB_PASS';" | $MYSQL
echo "FLUSH PRIVILEGES;" | $MYSQL

echo ">> Wordpress Init Done."
