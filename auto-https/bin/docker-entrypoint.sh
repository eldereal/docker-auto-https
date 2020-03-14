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

touch /var/log/letsencrypt/renewals.log
echo "0 0,12 * * * root python3 -c 'import random; import time; time.sleep(random.random() * 3600)' && /usr/local/bin/certbot-auto renew >> /var/log/letsencrypt/renewals.log" > /etc/crontab

if service cron start; then
    echo "Cron service started"
else
    echo "Cannot start cron service"
    exit 1
fi

tail -f /var/log/letsencrypt/renewals.log




