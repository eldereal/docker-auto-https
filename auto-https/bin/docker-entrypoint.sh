#!/bin/bash

rm -rf /etc/nginx/sites-enabled/default
mkdir -p /var/www/letsencrypt

if [ -z "$AUTOHTTPS_DOMAINS" ]; then
    echo "Environment variable AUTOHTTPS_DOMAINS is required"
fi
if [ -z "$AUTOHTTPS_UPSTREAMS" ]; then
    echo "Environment variable AUTOHTTPS_UPSTREAMS is required"
fi
if [ -z "$AUTOHTTPS_EMAIL" ]; then
    echo "Environment variable AUTOHTTPS_EMAIL is required"
fi
if [ -z "$AUTOHTTPS_STAGING" ]; then
    CERTBOT="certbot"
else
    CERTBOT="certbot --staging"
fi

if [ ! -f /etc/letsencrypt/ssl-dhparams.pem ]; then
    openssl dhparam -out /etc/letsencrypt/ssl-dhparams.pem 4096
fi

if /auto-https/bin/make-nginx-conf.py > /etc/nginx/sites-enabled/autohttps ; then
    echo "Nginx config generated"
else
    echo "Cannot generate nginx config"
    exit 1
fi

if service nginx start; then
    echo "Nginx service started"
else
    echo "Cannot start nginx service"
    exit 1
fi
echo "Update certificates:"
echo "    ${CERTBOT} certonly --webroot --webroot-path /var/www/letsencrypt -d ${AUTOHTTPS_DOMAINS} -m ${AUTOHTTPS_EMAIL} --agree-tos --no-eff-email --expand --noninteractive"
if ${CERTBOT} certonly --webroot --webroot-path /var/www/letsencrypt -d ${AUTOHTTPS_DOMAINS} -m ${AUTOHTTPS_EMAIL} --agree-tos --no-eff-email --expand --noninteractive; then
    echo "Update certificate successful"
else
    echo "Update certificate failed"
    exit 1
fi

bash




