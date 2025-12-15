#!/bin/bash

set -e

CHART_NAME="demo-app"

echo "[INFO] Applying templating changes"

cat <<EOF > "$CHART_NAME/values.yaml"
replicaCount: 1

image:
  repository: demo-app
  tag: "1.0.0"
  pullPolicy: IfNotPresent

service:
  type: ClusterIP
  port: 80
  targetPort: 8080
EOF

echo "[SUCCESS] values.yaml updated"

echo "[INFO] Rendering templates..."
helm template "$CHART_NAME" "./$CHART_NAME" > rendered.yaml

echo "[SUCCESS] Templates rendered to rendered.yaml"

echo "[INFO] Linting chart..."
helm lint "./$CHART_NAME"

echo "[DONE] Exercise 2 completed"
