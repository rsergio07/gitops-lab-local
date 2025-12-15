#!/bin/bash

set -e

CHART_NAME="demo-app"

echo "[INFO] Initializing Helm chart: $CHART_NAME"

if [ -d "$CHART_NAME" ]; then
  echo "[WARNING] Chart directory already exists. Skipping creation."
else
  helm create "$CHART_NAME"
  echo "[SUCCESS] Helm chart created"
fi

sed -i '' 's/^version:.*/version: 0.1.0/' "$CHART_NAME/Chart.yaml"
sed -i '' 's/^appVersion:.*/appVersion: "1.0.0"/' "$CHART_NAME/Chart.yaml"

echo "[SUCCESS] Chart metadata updated"

echo "[INFO] Chart structure:"
tree "$CHART_NAME"

echo "[DONE] Exercise 1 completed"
