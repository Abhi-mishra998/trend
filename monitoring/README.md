# Monitoring Setup

This directory contains the monitoring configuration for the Trend App using Prometheus and Grafana.

## Components

- **Prometheus**: Metrics collection and storage
- **Grafana**: Visualization and dashboards
- **Node Exporter**: System metrics from nodes
- **Kube State Metrics**: Kubernetes object metrics

## Installation

1. Ensure you have Helm and kubectl installed and configured for your cluster.

2. Run the installation script:
   ```bash
   cd monitoring
   chmod +x install-monitoring.sh
   export GRAFANA_ADMIN_PASSWORD="your-secure-password"
   ./install-monitoring.sh
   ```

## Accessing the Monitoring Stack

### Prometheus

```bash
kubectl port-forward -n monitoring svc/prometheus-server 9090:80
```

Visit: http://localhost:9090

### Grafana

```bash
kubectl get svc -n monitoring grafana -o wide
```

Use the LoadBalancer EXTERNAL-IP on port 80.

**Default Credentials:**

- Username: `admin`
- Password: The password you set in `GRAFANA_ADMIN_PASSWORD`

## Available Dashboards

1. **Kubernetes Cluster Monitoring** (ID: 7249)

   - Cluster-wide CPU and memory usage
   - Pod counts and status

2. **Kubernetes Pods** (ID: 6417)

   - Detailed pod metrics
   - Resource usage per pod

3. **Node Exporter** (ID: 1860)

   - System-level metrics from nodes
   - CPU, memory, disk, network stats

4. **Trend App Monitoring** (Custom)
   - Application-specific metrics
   - Response times, request rates
   - Pod resource usage
   - Application health status

## Metrics Collected

### Application Metrics (Trend App)

- HTTP request duration and rates
- Application response times (95th/50th percentiles)
- CPU and memory usage per pod
- Pod status and counts

### Infrastructure Metrics

- Node CPU, memory, disk, and network usage
- Kubernetes cluster health
- Pod lifecycle events
- Service discovery metrics

## Configuration Files

- `prometheus-values.yaml`: Prometheus Helm chart configuration
- `grafana-values.yaml`: Grafana Helm chart configuration with custom dashboard
- `install-monitoring.sh`: Automated installation script
- `dashboards/kubernetes-cluster-dashboard.json`: Custom dashboard JSON

## Troubleshooting

### Check Prometheus Targets

```bash
kubectl port-forward -n monitoring svc/prometheus-server 9090:80
```

Visit: http://localhost:9090/targets

### Check Grafana Logs

```bash
kubectl logs -n monitoring deployment/grafana
```

### Check Prometheus Logs

```bash
kubectl logs -n monitoring deployment/prometheus-server
```

### Verify Monitoring Namespace

```bash
kubectl get all -n monitoring
```

## Security Notes

- Change the default Grafana password in production
- Consider using ingress controllers for secure access
- Review network policies for monitoring traffic
- Use RBAC for Grafana user management

## Updating

To update the monitoring stack:

```bash
cd monitoring
./install-monitoring.sh
```

This will upgrade existing installations with the latest configurations.
