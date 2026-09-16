#!/bin/bash

set -e

WORKFLOW_FILE=".github/workflows/ci.yml"

if [ ! -f "$WORKFLOW_FILE" ]; then
  echo "[ERROR] $WORKFLOW_FILE not found. Run Exercise 1 and 2 scripts first."
  exit 1
fi

echo "[INFO] Upgrading permissions and adding paths-ignore guard"
python3 - "$WORKFLOW_FILE" <<'PYEOF'
import sys
path = sys.argv[1]
with open(path) as f:
    content = f.read()
content = content.replace("  contents: read", "  contents: write")
content = content.replace(
    '    branches: ["**"]\n  pull_request:',
    '    branches: ["**"]\n    paths-ignore:\n      - "exercises/phase-4-gitops/demo-app/values.yaml"\n  pull_request:',
)
with open(path, "w") as f:
    f.write(content)
PYEOF

echo "[INFO] Appending update-chart job"
cat <<'EOF' >> "$WORKFLOW_FILE"

  update-chart:
    needs: build-and-push
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          ref: ${{ github.ref_name }}

      - name: Update image tag in values.yaml
        run: |
          sed -i "s/^  tag:.*/  tag: \"${{ github.sha }}\"/" exercises/phase-4-gitops/demo-app/values.yaml

      - name: Commit and push
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          git add exercises/phase-4-gitops/demo-app/values.yaml
          git diff --cached --quiet && echo "No changes to commit" || git commit -m "ci: bump demo-app image to ${{ github.sha }}"
          git push
EOF

echo "[SUCCESS] Wrote update-chart job to $WORKFLOW_FILE"
echo "[DONE] Now commit and push to trigger it:"
echo "  git add $WORKFLOW_FILE"
echo "  git commit -m 'Automate Helm chart image tag updates'"
echo "  git push origin <your-branch>"
