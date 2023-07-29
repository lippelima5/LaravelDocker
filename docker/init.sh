#!/bin/bash

# Gere os certificados autoassinados caso não existam
if [ ! -f /etc/nginx/ssl/cert.pem ] || [ ! -f /etc/nginx/ssl/key.pem ]; then
    openssl req -x509 -newkey rsa:4096 -nodes -subj "/C=US/ST=California/L=San Francisco/O=Markware LTDA/CN=localhost" \
    -days 365 -keyout /etc/nginx/ssl/key.pem -out /etc/nginx/ssl/cert.pem
fi
