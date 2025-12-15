#!/bin/bash
# Phase 2 cleanup script
#
# This script removes containers and images created during the Phase 2 exercises.

set -euo pipefail

echo "Stopping and removing containers..."
docker rm -f simple-app simple-app-multi simple-app-registry registry 2>/dev/null || true

echo "Removing images..."
docker rmi simple-app:0.1.0 simple-app:0.2.0 localhost:5000/simple-app:0.2.0 2>/dev/null || true

echo "Cleanup complete."
