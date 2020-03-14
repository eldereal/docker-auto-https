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

if /auto-https/bin/has-certs.py; then
    echo "All domains has certificate"
else
    echo "Not all domain has certificate, apply for a new one"
    if ${CERTBOT} certonly --webroot --webroot-path /var/www/letsencrypt -d ${AUTOHTTPS_DOMAINS} -m ${AUTOHTTPS_EMAIL} --agree-tos; then
        echo "Apply certificate successful"
    else
        echo "Apply certificate failed"
        exit 1
    fi
fi

bash




