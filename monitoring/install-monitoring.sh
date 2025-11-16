#!/bin/bash
set -e

echo "🚀 Installing Prometheus and Grafana monitoring stack..."

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl not found. Please install kubectl first."
    exit 1
fi

# Check if helm is available
if ! command -v helm &> /dev/null; then
    echo "❌ helm not found. Please install Helm first."
    exit 1
fi

# Create monitoring namespace
echo "📁 Creating monitoring namespace..."
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

# Add Helm repos
echo "📦 Adding Helm repositories..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts --force-update
helm repo add grafana https://grafana.github.io/helm-charts --force-update
helm repo update

# Set Grafana admin password if not provided
if [ -z "$GRAFANA_ADMIN_PASSWORD" ]; then
    GRAFANA_ADMIN_PASSWORD="admin123"  # Default password, change in production!
    echo "⚠️  Using default Grafana password: $GRAFANA_ADMIN_PASSWORD"
    echo "   Please change this in production!"
fi

# Install Prometheus
echo "📊 Installing Prometheus..."
helm upgrade --install prometheus prometheus-community/prometheus \
  --namespace monitoring \
  --values prometheus-values.yaml \
  --set server.global.scrape_interval=15s \
  --wait \
  --timeout=600s

# Install Grafana
echo "📈 Installing Grafana..."
helm upgrade --install grafana grafana/grafana \
  --namespace monitoring \
  --values grafana-values.yaml \
  --set adminPassword="$GRAFANA_ADMIN_PASSWORD" \
  --wait \
  --timeout=600s

echo "✅ Monitoring stack installed successfully!"
echo ""
echo "🔗 Access URLs:"
echo ""
echo "Prometheus:"
echo "  kubectl port-forward -n monitoring svc/prometheus-server 9090:80"
echo "  Visit: http://localhost:9090"
echo ""
echo "Grafana:"
echo "  kubectl get svc -n monitoring grafana -o wide"
echo "  Use the LoadBalancer EXTERNAL-IP"
echo ""
echo "Grafana Credentials:"
echo "  Username: admin"
echo "  Password: $GRAFANA_ADMIN_PASSWORD"
echo ""
echo "📊 Available Dashboards:"
echo "  - Kubernetes Cluster Monitoring"
echo "  - Kubernetes Pods"
echo "  - Node Exporter"
echo "  - Trend App Monitoring (custom)"
echo ""
echo "🔍 To check monitoring targets:"
echo "  kubectl port-forward -n monitoring svc/prometheus-server 9090:80"
echo "  Visit: http://localhost:9090/targets"
echo ""
echo "📈 To check Grafana dashboards:"
echo "  Get Grafana URL from: kubectl get svc -n monitoring grafana"
echo "  Login with admin/$GRAFANA_ADMIN_PASSWORD"
