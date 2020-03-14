rm -rf /etc/nginx/sites-enabled/default && \
mkdir -p /var/www/letsencrypt && \
/auto-https/bin/make-nginx-conf.py > /etc/nginx/sites-enabled/autohttps && \
service nginx start && \
bash