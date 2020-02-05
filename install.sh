#!/bin/bash

mkdir /etc/certbot-renewed-copy

cp -v ./config.copy.cf /etc/certbot-renewed-copy/config.cf

cp -v ./certbot-renewed-copy.sh /usr/local/bin/

chmod +x /usr/local/bin/certbot-renewed-copy.sh

cp -v ./certbot-renewed-copy.service /etc/systemd/system/



mkdir /etc/certbot-post-renewal-reload
mkdir /etc/certbot-post-renewal-reload/last-reload

cp -v ./config.reload.cf /etc/certbot-post-renewal-reload/config.reload.cf
cp -v ./config.location.cf /etc/certbot-post-renewal-reload/config.location.cf

cp -v ./certbot-post-renewal-reload.sh /usr/local/bin/

chmod +x /usr/local/bin/certbot-post-renewal-reload.sh

cp -v ./certbot-post-renewal-reload.service /etc/systemd/system/



systemctl daemon-reload

systemctl enable certbot-renewed-copy.service
systemctl enable certbot-post-renewal-reload.service
