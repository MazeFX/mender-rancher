FROM mendersoftware/api-gateway:2.0.0

RUN mkdir /usr/local/openresty/nginx/conf.d

COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY nginx-ssl.conf /usr/local/openresty/nginx/conf.d/nginx-ssl.conf

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
