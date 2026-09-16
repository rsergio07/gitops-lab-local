#!/bin/bash

set -e

WORKFLOW_FILE=".github/workflows/ci.yml"

echo "[INFO] Cleaning up Phase 6 local artifacts..."

if [ -f "$WORKFLOW_FILE" ]; then
  rm -f "$WORKFLOW_FILE"
  echo "[SUCCESS] Removed $WORKFLOW_FILE"
fi

echo "[INFO] This only removes the local workflow file."
echo "To fully clean up, on GitHub:"
echo "  - Delete the demo-app package from your fork's Packages tab"
echo "  - Delete any workflow runs you no longer need from the Actions tab"

echo "[DONE] Cleanup completed"
