#!/bin/bash
# Build the multi‑stage image and compare sizes (Exercise 2)

set -euo pipefail

APP_DIR="$(dirname "$0")/../../examples/simple-app"
IMAGE_SINGLE="simple-app:0.1.0"
IMAGE_MULTI="simple-app:0.2.0"

cd "$APP_DIR"

if [ ! -f Dockerfile.multi ]; then
  echo "Dockerfile.multi not found in $APP_DIR"
  exit 1
fi

echo "Building multi‑stage image $IMAGE_MULTI..."
docker build -f Dockerfile.multi -t "$IMAGE_MULTI" .

echo "Image sizes:"
docker images "simple-app"

echo "To run the multi‑stage image:"
echo "docker run -d -p 8080:8080 --name simple-app-multi $IMAGE_MULTI"
