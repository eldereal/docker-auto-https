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

redirect = 'AUTOHTTPS_REDIRECT_HTTP' in os.environ and os.environ['AUTOHTTPS_REDIRECT_HTTP']

certname = domains[0]


httpConfTemplate = '''
server {{
    listen 80;
    server_name {hostname};
    location /.well-known/acme-challenge {{
        root /var/www/letsencrypt;
    }}
    location / {{
        {http_route};
    }}
}}
'''

httpsConfigTemplate = '''
server {{
    listen 443 ssl;
    server_name {hostname};
    ssl_certificate /etc/letsencrypt/live/{certname}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/{certname}/privkey.pem;
    include /auto-https/ssl-common-params.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
    location / {{
        proxy_pass http://{upstream};
    }}
}}
'''

if sys.argv[1] == 'http':
    confTemplate = httpConfTemplate
elif sys.argv[1] == 'https':
    confTemplate = httpsConfTemplate
else:
    raise Exception("Argument 1 must be 'http' or 'https'")

for i in range(len(domains)):
    if redirect:
        http_route = "return 301 https://$host$request_uri"
    else:
        http_route = "proxy_pass http://%s" % upstreams[i]
    conf = confTemplate.format(key="host%d" % i, hostname=domains[i], certname=certname, upstream=upstreams[i], http_route=http_route)
    print(conf)
