# Monitoring Setup

This directory contains monitoring configuration files for the Trend App using Prometheus and Grafana.

## Current Status

**✅ Monitoring Already Installed on Jenkins EC2**

- Prometheus and Grafana are already running
- Grafana password: `abhi abhi`
- Username: `admin`

## Components

- **Prometheus**: Metrics collection and storage
- **Grafana**: Visualization and dashboards
- **Node Exporter**: System metrics from nodes
- **Kube State Metrics**: Kubernetes object metrics

## Accessing Your Monitoring

### Grafana

```bash
# Port forward from Jenkins EC2
kubectl port-forward -n monitoring svc/grafana 3000:80
```

**Access:**

- URL: http://localhost:3000
- Username: `admin`
- Password: `abhi abhi`

### Prometheus

```bash
# Port forward from Jenkins EC2
kubectl port-forward -n monitoring svc/prometheus-server 9090:80
```

Visit: http://localhost:9090

## Available Dashboards

1. **Kubernetes Cluster Monitoring** (ID: 7249)
2. **Kubernetes Pods** (ID: 6417)
3. **Node Exporter** (ID: 1860)
4. **Trend App Monitoring** (Custom)

## Configuration Files

- `prometheus-values.yaml`: Prometheus Helm chart configuration
- `grafana-values.yaml`: Grafana Helm chart configuration with custom dashboard
- `dashboards/kubernetes-cluster-dashboard.json`: Custom dashboard JSON

## Verification Commands

```bash
# Check monitoring components
kubectl get all -n monitoring

# Check Prometheus targets
kubectl port-forward -n monitoring svc/prometheus-server 9090:80
# Visit: http://localhost:9090/targets

# Check Grafana dashboards
kubectl port-forward -n monitoring svc/grafana 3000:80
# Visit: http://localhost:3000 (admin/abhi abhi)
```

## Troubleshooting

### Check Logs

```bash
kubectl logs -n monitoring deployment/prometheus-server
kubectl logs -n monitoring deployment/grafana
```

### Verify Targets

```bash
kubectl port-forward -n monitoring svc/prometheus-server 9090:80
# Visit http://localhost:9090/targets
```

## Security Notes

- Current password is `abhi abhi` - consider changing in production
- Use RBAC for Grafana user management
- Review network policies for monitoring traffic
