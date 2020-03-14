# auto-https

A simple HTTPS server which automatically manages certificates and proxy traffics to upstream.

This image is just a proxy server. To use it, serve something at anywhere you want.

For example, run `python -m SimpleHTTPServer` will serve static files in current folder at `http://localhost:8080`. If you just want to play, this is a good start.

## Simple usage

```bash
docker run -d \
    --net=host \
    -v PLACE_TO_STORE_HTTPS_CERTS:/etc/letsencrypt \
    -e AUTOHTTPS_DOMAINS=YOUR_DOMAIN \
    -e AUTOHTTPS_UPSTREAMS=localhost:8080 \
    -e AUTOHTTPS_EMAIL=YOUR_EMAIL \
    eldereal/auto-https
```

## In docker network

```
docker run -d \
    -p 80:80 -p 443:443 \
    -v PLACE_TO_STORE_HTTPS_CERTS:/etc/letsencrypt \
    -e AUTOHTTPS_DOMAINS=YOUR_DOMAIN \
    -e AUTOHTTPS_UPSTREAMS=UPSTREAM_HOST:PORT \
    -e AUTOHTTPS_EMAIL=YOUR_EMAIL \
    eldereal/auto-https
```

## Details

### Environments

* **AUTOHTTPS_DOMAINS**: [Required] Comma separated list to you domains. The first domain name will be the primary domain name. Shown on 
* **AUTOHTTPS_UPSTREAMS**: [Required] Comma separated list of upstream servers corresponding to each domain name. Must be same length with AUTOHTTPS_DOMAINS.
* **AUTOHTTPS_EMAIL**: [Required] Your email address to register on letsencrypt.org.
* **AUTOHTTPS_STAGING**: [Optional] If not empty, use staging servers of letsencrypt.org. This variable is useful to validate and debug.
* **AUTOHTTPS_REDIRECT_HTTP**: [Optional] If not empty, redirect all HTTP traffics to corresponding HTTPS endpoints.

### Exposed ports

* **80**: For HTTP service and ACME challenges, this port must be **publicly accessible as 80 port**. No other port is allowed. **All domains muse be resolved to address of this port**. Because certificate issuer will use this port to validate the authority of the domain names.
* **443**: For HTTPS service. This port is not required to be publicly accessible. You can keep it only visible to your private network.

### Volumes

* `/etc/letsencrypt`: Store your accounts, certificates, **private keys**, server configs.

  **It's very important to KEEP IT SAFELY**

  If you **lose data** in this volume, you cannot renew, revoke, delete previous certificated. You can still apply new certificates, but if you apply too many times in several days, you may be limited by letsencrypt.org.

  If the data is **leaked**, it means your private key is leaked. It is a **critical security problem**. Because others can use your private key to pretend to be yourself. They can make fake sites, and start Man In The Middle attack to your service. In this situation you should revoke your certificates immediately.