#!/bin/bash

set -e

WORKFLOW_DIR=".github/workflows"
WORKFLOW_FILE="$WORKFLOW_DIR/ci.yml"

echo "[INFO] Writing basic validation workflow"
mkdir -p "$WORKFLOW_DIR"

cat <<'EOF' > "$WORKFLOW_FILE"
name: CI

on:
  push:
    branches: ["**"]
  pull_request:
    branches: [main]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Helm
        uses: azure/setup-helm@v4
        with:
          version: "v3.14.0"

      - name: Lint Helm chart
        run: helm lint exercises/phase-4-gitops/demo-app

      - name: Validate Kubernetes manifests
        run: |
          for f in kubernetes/manifests/*.yaml; do
            echo "Validating $f"
            python3 -c "import yaml, sys; list(yaml.safe_load_all(open(sys.argv[1])))" "$f"
          done
EOF

echo "[SUCCESS] Wrote $WORKFLOW_FILE"
echo "[DONE] Now commit and push to trigger it:"
echo "  git add $WORKFLOW_FILE"
echo "  git commit -m 'Add basic CI validation workflow'"
echo "  git push origin <your-branch>"
