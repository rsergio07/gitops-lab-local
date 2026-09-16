#!/bin/bash

set -e

CHART_DIR="exercises/phase-4-gitops/demo-app"
NAMESPACE="gitops-demo"

echo "[INFO] Writing stub_status ConfigMap"
cat <<EOF > "$CHART_DIR/templates/stub-status-configmap.yaml"
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-stub-status
  labels:
    app: demo-app
data:
  stub_status.conf: |
    server {
      listen 80;
      location /stub_status {
        stub_status on;
        allow 127.0.0.1;
        deny all;
      }
    }
EOF

echo "[SUCCESS] Wrote $CHART_DIR/templates/stub-status-configmap.yaml"
echo ""
echo "[INFO] Add this sidecar container to your deployment template's containers list:"
cat <<'EOF'
        - name: metrics-exporter
          image: nginx/nginx-prometheus-exporter:1.1.0
          args:
            - "--nginx.scrape-uri=http://localhost:80/stub_status"
          ports:
            - name: metrics
              containerPort: 9113
EOF

echo ""
echo "[INFO] Mount the ConfigMap into the nginx container and add the port to your Service, then run:"
echo "  helm upgrade demo-app $CHART_DIR -n $NAMESPACE"
echo ""
echo "[INFO] Writing ServiceMonitor"
cat <<EOF > servicemonitor.yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: demo-app
  namespace: monitoring
  labels:
    release: kube-prometheus
spec:
  selector:
    matchLabels:
      app: demo-app
  namespaceSelector:
    matchNames:
      - $NAMESPACE
  endpoints:
    - port: metrics
      interval: 15s
EOF

kubectl apply -f servicemonitor.yaml

echo "[DONE] Exercise 2 setup completed. Verify the target in the Prometheus UI under Status -> Targets."
