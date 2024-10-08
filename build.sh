#!/bin/bash

# Set variables
IMAGE_NAME="yarlson/zero-nginx"
VERSION="1.27-alpine3.19-zero0.1.1"

# Enable Docker BuildKit
export DOCKER_BUILDKIT=1

# Build for amd64
docker build --platform linux/amd64 -t ${IMAGE_NAME}:${VERSION}-amd64 .

# Build for arm64
docker build --platform linux/arm64 -t ${IMAGE_NAME}:${VERSION}-arm64 .

# Push the images
docker push ${IMAGE_NAME}:${VERSION}-amd64
docker push ${IMAGE_NAME}:${VERSION}-arm64

# Create and push the manifest
docker manifest create ${IMAGE_NAME}:${VERSION} \
    ${IMAGE_NAME}:${VERSION}-amd64 \
    ${IMAGE_NAME}:${VERSION}-arm64

docker manifest annotate ${IMAGE_NAME}:${VERSION} \
    ${IMAGE_NAME}:${VERSION}-amd64 --os linux --arch amd64

docker manifest annotate ${IMAGE_NAME}:${VERSION} \
    ${IMAGE_NAME}:${VERSION}-arm64 --os linux --arch arm64

docker manifest push ${IMAGE_NAME}:${VERSION}

# Tag and push as latest
docker manifest create ${IMAGE_NAME}:latest \
    ${IMAGE_NAME}:${VERSION}-amd64 \
    ${IMAGE_NAME}:${VERSION}-arm64

docker manifest annotate ${IMAGE_NAME}:latest \
    ${IMAGE_NAME}:${VERSION}-amd64 --os linux --arch amd64

docker manifest annotate ${IMAGE_NAME}:latest \
    ${IMAGE_NAME}:${VERSION}-arm64 --os linux --arch arm64

docker manifest push ${IMAGE_NAME}:latest

echo "Multi-architecture build and push completed successfully!"
