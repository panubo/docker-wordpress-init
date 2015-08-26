#!/usr/bin/env bash

set -e

genpasswd() {
    export LC_CTYPE=C  # Quiet tr warnings
    local l=$1
    [ "$l" == "" ] && l=16
    cat /dev/urandom | tr -dc A-Za-z0-9_ | head -c ${l}
}

writeenv() {
    # write to env file
    echo "$1='$2'" >> "${ENV_FILE}"
}

# Load environment file
ENV_FILE=${1-/tmp/env}
touch "${ENV_FILE}"  # Create if not exist
source "${ENV_FILE}"
> "${ENV_FILE}"  # Zero it

# Sanity check
if [ -z "$APP_CODE" ]; then
    echo "Error: APP_CODE not set."
    exit 128
fi

# Database Variables
writeenv DB_NAME "${DB_NAME:-$APP_CODE}"
writeenv DB_USER "${DB_USER:-$APP_CODE}"
writeenv DB_PASS "${DB_PASS:-$(genpasswd 12)}"
writeenv DB_HOST "${DB_HOST:-$MYSQL_PORT_3306_TCP_ADDR}"

# Debug Setting
writeenv DEBUG "${DEBUG:-false}"

# Wordpress Secure Salts
HASHS='AUTH_KEY SECURE_AUTH_KEY LOGGED_IN_KEY NONCE_KEY AUTH_SALT SECURE_AUTH_SALT LOGGED_IN_SALT NONCE_SALT'
for KEY in $HASHS; do
    VAL=$(eval echo \$$KEY)
    if [ -z "$VAL" ]; then
        # write to env file
        writeenv "$KEY" "$(genpasswd 64)"
    fi
done

# Update MySQL
MYSQL="mysql --host=${DB_HOST} --user=root --password=$MYSQL_ENV_MYSQL_ROOT_PASSWORD"
echo "CREATE DATABASE IF NOT EXISTS ${DB_NAME};" | $MYSQL
echo "GRANT ALL ON ${DB_NAME}.* to ${DB_USER}@'%' IDENTIFIED BY '$DB_PASS';" | $MYSQL
echo "FLUSH PRIVILEGES;" | $MYSQL

echo ">> Wordpress Init Done."
