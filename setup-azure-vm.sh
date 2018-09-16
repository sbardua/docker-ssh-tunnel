#!/bin/bash

fqdn=$1
email=$2

apt-get update && apt-get -y upgrade

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

apt-get update

apt-get -y install docker-ce

curl -L https://github.com/docker/compose/releases/download/1.18.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

git clone https://github.com/evertramos/docker-compose-letsencrypt-nginx-proxy-companion.git /opt/docker-compose-letsencrypt-nginx-proxy-companion

cp /opt/docker-compose-letsencrypt-nginx-proxy-companion/.env.sample /opt/docker-compose-letsencrypt-nginx-proxy-companion/.env

mkdir -p /opt/nginx/data

sed -i 's+NGINX_FILES_PATH=/path/to/your/nginx/data+NGINX_FILES_PATH=/opt/nginx/data+g' /opt/docker-compose-letsencrypt-nginx-proxy-companion/.env

cd /opt/docker-compose-letsencrypt-nginx-proxy-companion && ./start.sh

cp /opt/tunnelingus/.env.sample /opt/tunnelingus/.env

sed -i "s+LETSENCRYPT_HOST=example.com+LETSENCRYPT_HOST=$fqdn+g" /opt/tunnelingus/.env

sed -i "s+LETSENCRYPT_EMAIL=you@example.com+LETSENCRYPT_EMAIL=$email+g" /opt/tunnelingus/.env

exit 0
