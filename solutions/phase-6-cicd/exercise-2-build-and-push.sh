#!/bin/bash

set -e

WORKFLOW_FILE=".github/workflows/ci.yml"

if [ ! -f "$WORKFLOW_FILE" ]; then
  echo "[ERROR] $WORKFLOW_FILE not found. Run Exercise 1's script first."
  exit 1
fi

echo "[INFO] Adding permissions block"
python3 - "$WORKFLOW_FILE" <<'PYEOF'
import sys
path = sys.argv[1]
with open(path) as f:
    content = f.read()
if "permissions:" not in content:
    content = content.replace(
        "on:",
        "permissions:\n  contents: read\n  packages: write\n\non:",
        1,
    )
with open(path, "w") as f:
    f.write(content)
PYEOF

echo "[INFO] Appending build-and-push job"
cat <<'EOF' >> "$WORKFLOW_FILE"

  build-and-push:
    needs: validate
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Log in to GitHub Container Registry
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build and push image
        uses: docker/build-push-action@v5
        with:
          context: examples/simple-app
          push: true
          tags: ghcr.io/${{ github.repository_owner }}/demo-app:${{ github.sha }}
EOF

echo "[SUCCESS] Wrote build-and-push job to $WORKFLOW_FILE"
echo "[DONE] Now commit and push to trigger it:"
echo "  git add $WORKFLOW_FILE"
echo "  git commit -m 'Build and push image to GHCR'"
echo "  git push origin <your-branch>"
