#!/usr/bin/python3

import os
import sys

if ('AUTOHTTPS_DOMAINS' not in os.environ) or ('AUTOHTTPS_UPSTREAMS' not in os.environ):
    raise Exception("AUTOHTTPS_DOMAINS, AUTOHTTPS_UPSTREAMS is required in env")

domains = os.environ['AUTOHTTPS_DOMAINS'].split(',')
upstreams = os.environ['AUTOHTTPS_UPSTREAMS'].split(',')

if len(domains) != len(upstreams):
    raise Exception("AUTOHTTPS_DOMAINS and AUTOHTTPS_UPSTREAMS must be comma separated and equal length")

for i in range(len(domains)):
    if (not domains[i]) or (not upstreams[i]):
        raise Exception("AUTOHTTPS_DOMAINS and AUTOHTTPS_UPSTREAMS cannot be empty")

confTemplate = '''
upstream {key} {{
    server {upstream};
}}
server {{
    listen 80;
    server_name {hostname};
    location /.well-known/acme-challenge {{
        root /var/www/letsencrypt;
    }}
    location * {{
        if ($host = {hostname}) {{
            return 404;
#            return 301 https://$host$request_uri;
        }}
    }}
}}
#server {{
#    listen 443 ssl;
#    server_name {hostname};
#    ssl_certificate /etc/letsencrypt/live/{hostname}/fullchain.pem;
#    ssl_certificate_key /etc/letsencrypt/live/{hostname}/privkey.pem;
#    include /etc/nginx/ssl-common-params.conf;
#    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
#}}
'''

for i in range(len(domains)):
    print(confTemplate.format(key="host%d"%i, hostname=domains[i], upstream=upstreams[i]))