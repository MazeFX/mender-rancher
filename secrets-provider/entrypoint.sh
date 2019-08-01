#!/bin/sh

mkdir -p /var/www/mendersoftware/cert/

IFS="
"
for ENV_VAR in `env`; do
    ENV_VAR=`echo "$ENV_VAR" | sed -e 's,=.*,,'`
    echo $ENV_VAR | grep -q "_SECRET$" || continue
    SECRET_FILE=`echo "$ENV_VAR" | sed -e 's,_SECRET$,,g'`
    if [[ $ENV_VAR == *"_CERT"* ]]; then
        printenv $ENV_VAR > /var/www/mendersoftware/cert/cert.crt
        echo "Providing secrets for $ENV_VAR in /var/www/mendersoftware/cert/cert.crt"
    fi
    if [[ $ENV_VAR == *"_PRIV_KEY"* ]]; then
        printenv $ENV_VAR > /var/www/mendersoftware/cert/private.key
        echo "Providing secrets for $ENV_VAR in /var/www/mendersoftware/cert/private.key"
    fi
done

