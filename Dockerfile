FROM ubuntu:bionic


RUN apt-get update && \
    apt-get -y install software-properties-common && \
    add-apt-repository -y ppa:certbot/certbot && \
    apt-get install -y certbot nginx python-certbot-nginx

COPY ./auto-https /auto-https

RUN chmod +x /auto-https/bin/*

ENTRYPOINT [ "/auto-https/bin/docker-entrypoint.sh" ]
