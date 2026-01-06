# MCP Stack - Quick Start Guide

Get started with MCP Stack in 5 minutes! 🚀

## Prerequisites

```bash
# Check you have the required tools
kubectl version --client
helm version
```

## Step 1: Setup Infisical Credentials

Create a secret with your Infisical credentials:

```bash
kubectl create namespace mcp-secrets

kubectl create secret generic infisical-credentials \
  --from-literal=clientId=YOUR_CLIENT_ID \
  --from-literal=clientSecret=YOUR_CLIENT_SECRET \
  -n mcp-secrets
```

## Step 2: Install External Secrets Operator

```bash
helm repo add external-secrets https://charts.external-secrets.io
helm install external-secrets \
  external-secrets/external-secrets \
  -n external-secrets-system \
  --create-namespace
```

## Step 3: Configure Your Services

Edit `values-staging.yaml` or `values-production.yaml` to enable/configure your mcp:

```yaml
mcp:
  my-api:
    enabled: true  # Enable this service
    image:
      repository: myapp/api
      tag: v1.0.0
    port: 8080
    # ... other configurations
```

## Step 4: Deploy

### Option A: Using Helm Directly

```bash
# For staging
helm upgrade --install mcp-stack . \
  -f values-staging.yaml \
  -n mcp-secrets \
  --create-namespace

# For production
helm upgrade --install mcp-stack . \
  -f values-production.yaml \
  -n mcp-secrets \
  --create-namespace
```

### Option B: Using Makefile

```bash
# For staging
make install-staging

# For production
make install-production
```

### Option C: Using FluxCD

```bash
# Apply the FluxCD configuration
kubectl apply -k examples/flux/staging/

# Or for production
kubectl apply -k examples/flux/production/
```

## Step 5: Verify Deployment

```bash
# Check all resources
make k8s-all

# Or manually
kubectl get all,ingress,hpa,pvc,secrets -n mcp-secrets

# Check if secrets are synced
kubectl get externalsecrets -n mcp-secrets

# Check pods are running
kubectl get pods -n mcp-secrets
```

## Step 6: Access Your Services

```bash
# Get ingress URLs
kubectl get ingress -n mcp-secrets

# Access your service (example)
# Staging: https://mcp-my-api.staging.p2pmmo.vn
# Production: https://mcp-my-api.p2pmmo.vn
```

## Common Commands

```bash
# View logs
make logs SERVICE=api-service

# Port-forward to a service
make port-forward SERVICE=api-service PORT=8080

# Check HPA status
make k8s-hpa

# Upgrade deployment
make upgrade-staging

# Rollback
make rollback
```

## Troubleshooting

### Secrets Not Syncing

```bash
# Check SecretStore
kubectl describe secretstore -n mcp-secrets

# Check ExternalSecret
kubectl describe externalsecret -n mcp-secrets

# Check External Secrets Operator logs
kubectl logs -n external-secrets-system \
  -l app.kubernetes.io/name=external-secrets
```

### Pods Not Starting

```bash
# Check pod status
kubectl get pods -n mcp-secrets

# Describe pod
kubectl describe pod <pod-name> -n mcp-secrets

# View logs
kubectl logs <pod-name> -n mcp-secrets
```

### HPA Not Scaling

```bash
# Check HPA
kubectl describe hpa <hpa-name> -n mcp-secrets

# Check metrics server
kubectl top nodes
kubectl top pods -n mcp-secrets
```

## Next Steps

1. **Configure Custom Services**: Edit `values.yaml` to add your own services
2. **Setup Monitoring**: Integrate with Prometheus and Grafana
3. **Configure Alerts**: Setup PagerDuty or Slack alerts
4. **Enable Backups**: Configure backup strategies for stateful services
5. **Read Full Documentation**: Check [README.md](README.md) for detailed information

## Examples

### Simple API Service

```yaml
mcp:
  my-api:
    enabled: true
    image:
      repository: mycompany/my-api
      tag: v1.0.0
    port: 8080
    replicas: 3
    
    probes:
      liveness:
        enabled: true
        httpGet:
          path: /health
          port: 8080
    
    secret:
      create: true
      store:
        secretsPath: /my-api
    
    ingress:
      enabled: true
```

### Database Service

```yaml
mcp:
  postgres:
    enabled: true
    image:
      repository: postgres
      tag: "15"
    port: 5432
    replicas: 1
    
    autoscaling:
      enabled: false  # Don't autoscale databases
    
    persistence:
      enabled: true
      size: 50Gi
      storageClassName: premium-ssd
    
    secret:
      create: true
      store:
        secretsPath: /postgres
```

### Worker Service with HPA

```yaml
mcp:
  worker:
    enabled: true
    image:
      repository: mycompany/worker
      tag: latest
    port: 9090
    
    autoscaling:
      enabled: true
      minReplicas: 2
      maxReplicas: 20
      metrics:
        - type: Resource
          resource:
            name: cpu
            target:
              type: Utilization
              averageUtilization: 70
    
    secret:
      create: true
      store:
        secretsPath: /worker
```

## Support

- 📚 Documentation: [README.md](README.md)
- 🐛 Issues: https://github.com/example/helm-mcp-stack/issues
- 📧 Email: devops@p2pmmo.vn
