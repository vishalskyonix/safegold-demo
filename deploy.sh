#!/bin/bash
set -e

while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
    echo "Waiting for apt lock..."
    sleep 5
done

echo "Starting deployment..."

apt-get update -y
apt-get install -y nginx git

rm -rf /var/www/html/*
cd /tmp
rm -rf safegold-demo
git clone https://github.com/vishalskyonix/safegold-demo.git
mv /tmp/safegold-demo/index.html /var/www/html/

# Inject actual hostname into the page
sed -i "s/HOSTNAME/$(hostname)/g" /var/www/html/index.html

chmod 644 /var/www/html/index.html
systemctl reload nginx
echo "Deployed on $(hostname) at $(date)"
