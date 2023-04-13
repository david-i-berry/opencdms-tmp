#!/bin/bash
# This script uses Certbot to generate SSL certificates in standalone mode.
# It assumes that Nginx is installed and configured on the same machine.
# The generated SSL files are copied to /etc/nginx/ssl/ and used to secure
# HTTPS connections to the specified domain.
# The script sets up a renewal cron job for the SSL certificates, which runs
# every 12 hours, and reloads Nginx to apply the renewed certificates.


DOMAIN=${DOMAIN:-api.opencdms.org}
EMAIL=${EMAIL:-info@opencdms.org}

certbot certonly --standalone -d $DOMAIN --email $EMAIL --agree-tos --no-eff-email
cp /etc/letsencrypt/live/$DOMAIN/fullchain.pem /etc/nginx/ssl/nginx.crt
cp /etc/letsencrypt/live/$DOMAIN/privkey.pem /etc/nginx/ssl/nginx.key

nginx -t
service nginx start

while true; do
    sleep 12h & wait -n ${!}
    certbot renew
    cp /etc/letsencrypt/live/$DOMAIN/fullchain.pem /etc/nginx/ssl/nginx.crt
    cp /etc/letsencrypt/live/$DOMAIN/privkey.pem /etc/nginx/ssl/nginx.key
    service nginx reload
done &

nginx -g "daemon off;"