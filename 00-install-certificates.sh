#!/bin/sh
set -e

if [ -z "$DOMAIN" ]; then
    echo "DOMAIN environment variable is not set"
    exit 1
fi
if [ -z "$EMAIL" ]; then
    echo "EMAIL environment variable is not set"
    exit 1
fi

echo "Starting Zero to obtain/renew certificate..."
zero -d "$DOMAIN" -e "$EMAIL" -c /etc/nginx/ssl
echo "Certificate obtained/renewed successfully."

exit 0
