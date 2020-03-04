#!/bin/bash

# timezone
ln -sf /usr/share/zoneinfo/${TZ:-"Asia/Shanghai"} /etc/localtime
echo ${TZ:-"Asia/Shanghai"} > /etc/timezone

# sshd
if [ -n "${SSH_PASSWORD}" ];then
    mkdir -p /var/run/sshd
    echo root:${SSH_PASSWORD} | chpasswd
    sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
    /usr/sbin/sshd
fi


# set env  config to index.php
sed -i "s|\"refresh_token\"=>\"\"|\"refresh_token\"=>\"${REFRESH_TOKEN}\"|" /var/www/html/index.php
sed -i "s|\"client_id\"=>\"\"|\"client_id\"=>\"${CLIENT_ID}\"|" /var/www/html/index.php
sed -i "s|\"client_secret\"=>\"\"|\"client_secret\"=>\"${CLIENT_SECRET}\"|" /var/www/html/index.php
sed -i "s|'rewrite'=>false|'rewrite'=>${OPEN_REWRITE}|" /var/www/html/index.php
sed -i "s|'sitepath'=>''|'sitepath'=>'${SITE_PATH}'|" /var/www/html/index.php


# custom nginx config
if [ -f /etc/nginx/conf.d/nginx-custom.template.conf ];then
    cp -f /etc/nginx/conf.d/nginx-custom.template.conf /etc/nginx/conf.d/default.conf
    sed -i "s|SITE_PATH|${SITE_PATH}|" /etc/nginx/conf.d/default.conf
fi

sed -i "s|listen 80|listen ${PORT:-80}|" /etc/nginx/conf.d/nginx-custom.conf
chown -R www-data:www-data /var/www/html/config
php-fpm & nginx '-g daemon off;'