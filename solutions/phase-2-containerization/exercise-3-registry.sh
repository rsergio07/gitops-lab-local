#!/bin/bash
# Push and pull an image using a local registry (Exercise 3)

set -euo pipefail

IMAGE="simple-app:0.2.0"
TAGGED="localhost:5000/simple-app:0.2.0"

# Start the registry if not running
if ! docker ps | grep -q "registry"; then
  echo "Starting local registry..."
  docker run -d -p 5000:5000 --restart=always --name registry registry:2
else
  echo "Registry already running."
fi

echo "Tagging image $IMAGE as $TAGGED..."
docker tag "$IMAGE" "$TAGGED"

echo "Pushing image to registry..."
docker push "$TAGGED"

echo "Removing local images to simulate fresh environment..."
docker rmi "$IMAGE" "$TAGGED"

echo "Pulling image from registry..."
docker pull "$TAGGED"

echo "Run the pulled image:"
echo "docker run -d -p 8080:8080 --name simple-app-registry $TAGGED"
