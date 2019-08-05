#!/bin/sh

SOURCE="$CERT_LOCTION/$CERT_NAME"
TARGET="/var/www/mendersoftware/cert/"

ln $SOURCE/fullchain.pem $TARGET/cert.crt
echo "Creating Link $SOURCE/fullchain.pem -> $TARGET/cert.crt" >&2

ln $SOURCE/privkey.pem $TARGET/private.key
echo "Creating Link $SOURCE/privkey.pem -> $TARGET/private.key" >&2

exec /usr/local/openresty/bin/openresty -g "daemon off;" $*
