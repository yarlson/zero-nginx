#!/bin/sh

set -eu

# Check required environment variables
for var in DOMAIN EMAIL PROXY_CONTAINER_NAME; do
    eval "value=\${$var}"
    if [ -z "$value" ]; then
        echo "$var environment variable is not set" >&2
        exit 1
    fi
done

# Check if proxy container is running
if ! docker ps | grep -q "$PROXY_CONTAINER_NAME"; then
    echo "Proxy container is not running. Exiting..." >&2
    exit 1
fi

while true; do
    sleep 1d
    if zero -d "$DOMAIN" -e "$EMAIL" -c /etc/nginx/ssl --renew; then
        echo "Certificate renewed. Restarting Nginx..."
        docker exec "$PROXY_CONTAINER_NAME" nginx -s reload
    else
        echo "No renewal needed or renewal failed."
    fi
done
