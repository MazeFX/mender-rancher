#!/bin/sh

echo "Creating /var/www/mendersoftware/cert/" >&2
mkdir -p /var/www/mendersoftware/cert/
echo "Creation succesfull" >&2

IFS="
"
for ENV_VAR in `env`; do
    ENV_VAR=`echo "$ENV_VAR" | sed -e 's,=.*,,'`
    echo $ENV_VAR | grep -q "_SECRET$" || continue
    SECRET_FILE=`echo "$ENV_VAR" | sed -e 's,_SECRET$,,g'`
    echo "Checking $ENV_VAR for $SECRET_FILE" >&2
    if [[ $SECRET_FILE == "MENDER_API_GATEWAY_CERT" ]]
    then
        echo "Creating $ENV_VAR in /var/www/mendersoftware/cert/cert.crt" >&2
        printenv $ENV_VAR > /var/www/mendersoftware/cert/cert.crt
        echo "Providing secrets for $ENV_VAR in /var/www/mendersoftware/cert/cert.crt" >&2
    else
        echo "$SECRET_FILE did not match" >&2
    fi
    if [[ $SECRET_FILE == "MENDER_API_GATEWAY_PRIV_KEY" ]]; then
        echo "Creating $ENV_VAR in /var/www/mendersoftware/cert/private.key" >&2
        printenv $ENV_VAR > /var/www/mendersoftware/cert/private.key
        echo "Providing secrets for $ENV_VAR in /var/www/mendersoftware/cert/private.key" >&2
    fi
done

