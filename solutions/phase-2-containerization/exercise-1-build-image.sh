#!/bin/bash
# Build and run the simple application container (Exercise 1)

set -euo pipefail

APP_DIR="$(dirname "$0")/../../examples/simple-app"
IMAGE_NAME="simple-app:0.1.0"

if [ ! -d "$APP_DIR" ]; then
  echo "Sample application directory not found at $APP_DIR"
  exit 1
fi

cd "$APP_DIR"
echo "Building image $IMAGE_NAME..."
docker build -t "$IMAGE_NAME" .

echo "Running container..."
docker run -d -p 8080:8080 --name simple-app "$IMAGE_NAME"
sleep 2

echo "Testing application..."
curl -s http://localhost:8080 || true

echo "Logs:"
docker logs simple-app

echo "To stop the container, run: docker rm -f simple-app"
