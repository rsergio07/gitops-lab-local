#!/bin/bash

set -e

CHART_NAME="demo-app"
REPO_DIR="$HOME/helm-repo"
REPO_NAME="demo-repo"
PORT=8080

echo "[INFO] Packaging Helm chart"

helm package "$CHART_NAME"

mkdir -p "$REPO_DIR"
mv "$CHART_NAME"-*.tgz "$REPO_DIR"

cd "$REPO_DIR"
helm repo index . --merge index.yaml 2>/dev/null || helm repo index .

echo "[SUCCESS] Helm repository indexed"

echo "[INFO] Starting local Helm repo server on port $PORT"
echo "Press CTRL+C to stop the server"

python3 -m http.server "$PORT"
