#!/bin/sh

set -eu

DOCKER_API_VERSION="v1.41"
DOCKER_SOCKET="/var/run/docker.sock"

# Function to make Docker API calls
docker_api_call() {
    curl -s --unix-socket "$DOCKER_SOCKET" "http:/v$DOCKER_API_VERSION/$1"
}

# Check required environment variables
for var in DOMAIN EMAIL PROXY_CONTAINER_NAME; do
    eval "value=\${$var}"
    if [ -z "$value" ]; then
        echo "$var environment variable is not set" >&2
        exit 1
    fi
done

# Get container ID for running containers filtered by name
container_id=$(curl -s --unix-socket "$DOCKER_SOCKET" \
    "http:/v$DOCKER_API_VERSION/containers/json?all=false&filters=%7B%22name%22%3A%5B%22$PROXY_CONTAINER_NAME%22%5D%7D" | \
    grep -oP '"Id":"\K[^"]+')

if [ -z "$container_id" ]; then
    echo "Proxy container '$PROXY_CONTAINER_NAME' is not running. Exiting..." >&2
    exit 1
fi

while true; do
    sleep 1d
    if zero -d "$DOMAIN" -e "$EMAIL" -c /etc/nginx/ssl --renew; then
        echo "Certificate renewed. Restarting Nginx..."
        # Restart Nginx inside the container
        curl -s --unix-socket "$DOCKER_SOCKET" -X POST \
            -H "Content-Type: application/json" \
            -d '{"Cmd":["nginx", "-s", "reload"],"AttachStdout":true,"AttachStderr":true}' \
            "http:/v$DOCKER_API_VERSION/containers/$container_id/exec"
    else
        echo "No renewal needed or renewal failed."
    fi
done
