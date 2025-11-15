#!/bin/bash
set -e

echo "Installing Prometheus and Grafana monitoring stack..."

# Create monitoring namespace
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

# Add Helm repos
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Install Prometheus
echo "Installing Prometheus..."
helm upgrade --install prometheus prometheus-community/prometheus \
  --namespace monitoring \
  --values prometheus-values.yaml \
  --wait

# Install Grafana
echo "Installing Grafana..."
helm upgrade --install grafana grafana/grafana \
  --namespace monitoring \
  --values grafana-values.yaml \
  --wait

echo "Monitoring stack installed successfully!"
echo ""
echo "To access Prometheus:"
echo "  kubectl port-forward -n monitoring svc/prometheus-server 9090:80"
echo "  Then visit: http://localhost:9090"
echo ""
echo "To access Grafana:"
echo "  kubectl get svc -n monitoring grafana"
echo "  Use the LoadBalancer external IP/DNS"
echo ""
echo "Grafana credentials:"
echo "  Username: admin"
echo "  Password: Run 'kubectl get secret -n monitoring grafana -o jsonpath=\"{.data.admin-password}\" | base64 --decode'"
