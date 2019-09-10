#!/bin/sh

echo "Making Directory" >&2
mkdir -p /var/www/mendersoftware/cert/

SOURCE="$CERT_LOCTION/$CERT_NAME"
TARGET="/var/www/mendersoftware/cert"

ln -s $SOURCE/fullchain.pem $TARGET/cert.crt
echo "Creating Link $SOURCE/fullchain.pem -> $TARGET/cert.crt" >&2

ln -s $SOURCE/privkey.pem $TARGET/private.key
echo "Creating Link $SOURCE/privkey.pem -> $TARGET/private.key" >&2

if [ -n "$ALLOWED_HOSTS" ]; then
    sed -i -e "s/[@]ALLOWED_HOSTS[@]/$ALLOWED_HOSTS/" /usr/local/openresty/nginx/conf/nginx.conf

    # generate ORIGIN whitelist
    hosts=$(echo $ALLOWED_HOSTS | sed 's/ \{1,\}/|/g' | sed 's/[.]\{1,\}/\\\\\\./g')
    sed -i -e "s/[@]ALLOWED_ORIGIN_HOSTS[@]/$hosts/" /usr/local/openresty/nginx/conf/nginx.conf
else
   echo "ALLOWED_HOSTS undefined, exiting"
   exit 1
fi

# Disabled by default
if [ -n "$CACHE_UI_BROWSER_PERIOD" ]; then
    sed -i -e "s/[@]CACHE_UI_BROWSER_PERIOD[@]/$CACHE_UI_BROWSER_PERIOD/" /usr/local/openresty/nginx/conf/nginx.conf
else
    sed -i -e "s/[@]CACHE_UI_BROWSER_PERIOD[@]/off/" /usr/local/openresty/nginx/conf/nginx.conf
fi

# Disabled by default
if [ -n "$CACHE_UI_SUCCESS_PERIOD" ]; then
    sed -i -e "s/[@]CACHE_UI_SUCCESS_PERIOD[@]/$CACHE_UI_SUCCESS_PERIOD/" /usr/local/openresty/nginx/conf/nginx.conf
else
    sed -i -e "s/[@]CACHE_UI_SUCCESS_PERIOD[@]/0s/" /usr/local/openresty/nginx/conf/nginx.conf
fi

# Disabled by default
if [ -n "$CACHE_UI_FAILUE_PERIOD" ]; then
    sed -i -e "s/[@]CACHE_UI_FAILURE_PERIOD[@]/$CACHE_UI_FAILURE_PERIOD/" /usr/local/openresty/nginx/conf/nginx.conf
else
    sed -i -e "s/[@]CACHE_UI_FAILURE_PERIOD[@]/0s/" /usr/local/openresty/nginx/conf/nginx.conf
fi

if [ -n "$HAVE_MULTITENANT" ]; then
    ln -sf /usr/local/openresty/nginx/conf/tenantadm.nginx.conf \
       /usr/local/openresty/nginx/conf/optional/endpoints/tenantadm.nginx.conf
fi

# Rate limits - disabled by default
if [ -n "$RATE_LIMIT_GLOBAL_RATE" ] && [ $RATE_LIMIT_GLOBAL_RATE -gt 0 ]; then
    sed -i -e "s/[@]RATE_LIMIT_GLOBAL_RATE[@]/${RATE_LIMIT_GLOBAL_RATE}r\/s/" /usr/local/openresty/nginx/conf/nginx.conf

    if [ -n "$RATE_LIMIT_GLOBAL_BURST" ] && [ $RATE_LIMIT_GLOBAL_BURST -gt 0 ]; then
        sed -i -e "s/[@]RATE_LIMIT_GLOBAL_BURST[@]/burst=$RATE_LIMIT_GLOBAL_BURST/" /usr/local/openresty/nginx/conf/nginx.conf
    else
        sed -i -e "s/[@]RATE_LIMIT_GLOBAL_BURST[@] //" /usr/local/openresty/nginx/conf/nginx.conf
    fi
else
    sed -i -e "/[@]RATE_LIMIT_GLOBAL_RATE[@]/d" /usr/local/openresty/nginx/conf/nginx.conf
    sed -i -e "/[@]RATE_LIMIT_GLOBAL_BURST[@]/d" /usr/local/openresty/nginx/conf/nginx.conf
    sed -i -e "/limit_req_status/d" /usr/local/openresty/nginx/conf/nginx.conf
fi

# Enabling access logs json format - disabled by default
if [ -n "$IS_LOGS_FORMAT_JSON" ] && [ "$IS_LOGS_FORMAT_JSON" = "true" ]; then
    sed -i -e "s/[@]LOGS_FORMAT[@]/access_log_json/g" /usr/local/openresty/nginx/conf/nginx.conf
else
    sed -i -e "s/[@]LOGS_FORMAT[@]/main/g" /usr/local/openresty/nginx/conf/nginx.conf
fi

# HTTP Strict Transport Security max-age - 2yrs by default
if [ -n "$HSTS_MAX_AGE" ]; then
    sed -i -e "s/[@]HSTS_MAX_AGE[@]/$HSTS_MAX_AGE/" /usr/local/openresty/nginx/conf/nginx.conf
else
    sed -i -e "s/[@]HSTS_MAX_AGE[@]/63072000/" /usr/local/openresty/nginx/conf/nginx.conf
fi

exec /usr/local/openresty/bin/openresty -g "daemon off;" $*
