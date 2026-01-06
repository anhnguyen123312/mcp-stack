# MCP Stack Helm Chart

A comprehensive Helm chart for deploying multiple Microservices Control Plane (MCP) services with integrated Infisical secret management, FluxCD GitOps support, and production-ready configurations.

## Features

- 🔐 **Infisical Secret Management**: Automatic secret synchronization from Infisical
- 📡 **MCP Server Support**: First-class support for deploying MCP servers with SSE (Server-Sent Events)
- 🐳 **Multi-Registry Support**: Each MCP can use a different container registry
- 🔌 **Global Default Port**: Configure default port for all MCP servers, override per-MCP
- 🚀 **FluxCD Ready**: Full GitOps integration with FluxCD
- 📊 **Horizontal Pod Autoscaling**: Per-service HPA configuration
- 🏥 **Health Checks**: Configurable liveness, readiness, and startup probes
- 💾 **Persistent Storage**: Dynamic PVC provisioning with custom storage classes
- 🌐 **Ingress Management**: Automatic ingress generation with TLS support
- 🎯 **Multi-Environment**: Built-in support for staging, production, and review environments
- 🔄 **Image Versioning**: Support for tags, digests, and semantic versioning
- 📦 **Resource Management**: Configurable resource requests and limits

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage Examples](#usage-examples)
- [MCP Server Deployment](#mcp-server-deployment)
- [FluxCD Integration](#fluxcd-integration)
- [Architecture](#architecture)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

## Prerequisites

- Kubernetes 1.23+
- Helm 3.8+
- External Secrets Operator (for Infisical integration)
- FluxCD (optional, for GitOps)
- Nginx Ingress Controller (or any ingress controller)
- cert-manager (for TLS certificates)

### Install External Secrets Operator

```bash
helm repo add external-secrets https://charts.external-secrets.io
helm install external-secrets \
  external-secrets/external-secrets \
  -n external-secrets-system \
  --create-namespace
```

### Setup Infisical Credentials

Create a secret with your Infisical credentials:

```bash
kubectl create secret generic infisical-credentials \
  --from-literal=clientId=YOUR_CLIENT_ID \
  --from-literal=clientSecret=YOUR_CLIENT_SECRET \
  -n mcp-secrets
```

## Installation

### Quick Start

```bash
# Add the Helm repository (if published)
helm repo add mcp-stack https://charts.p2pmmo.vn

# Install with default values (staging)
helm install mcp-stack mcp-stack/mcp-stack \
  -n mcp-secrets \
  --create-namespace

# Install for production
helm install mcp-stack mcp-stack/mcp-stack \
  -f values-production.yaml \
  -n mcp-secrets
```

### From Source

```bash
# Clone the repository
git clone https://github.com/example/helm-mcp-stack.git
cd helm-mcp-stack

# Install staging environment
helm install mcp-stack . \
  -f values-staging.yaml \
  -n mcp-secrets \
  --create-namespace

# Install production environment
helm install mcp-stack . \
  -f values-production.yaml \
  -n mcp-secrets
```

## Configuration

### Global Configuration

The chart provides extensive global configuration options:

```yaml
global:
  namespace: mcp-secrets        # Namespace for all resources
  domain: p2pmmo.vn               # Base domain for ingress
  environment: staging               # staging | production | review
  
  image:
    registry: registry.p2pmmo.vn  # Container registry
    pullPolicy: IfNotPresent         # Image pull policy
    pullSecrets:
      - name: docker-registry-secret
  
  versioning:
    strategy: tag                    # tag | digest | semver
  
  infisical:
    hostAPI: https://infisical.example.com
    projectSlug: my-project
    # ... see values.yaml for more options
  
  # Storage, ingress, probes, autoscaling defaults
  # ... see values.yaml for complete configuration
```

### Service Configuration

Each service can be configured individually:

```yaml
mcp:
  my-api:
    enabled: true
    
    # Image configuration
    image:
      repository: myapp/api
      tag: v1.0.0                    # or digest: sha256:...
      pullPolicy: IfNotPresent
    
    port: 8080
    replicas: 3
    
    # Autoscaling
    autoscaling:
      enabled: true
      minReplicas: 3
      maxReplicas: 20
      metrics:
        - type: Resource
          resource:
            name: cpu
            target:
              type: Utilization
              averageUtilization: 70
    
    # Health checks
    probes:
      liveness:
        enabled: true
        httpGet:
          path: /healthz
          port: 8080
        initialDelaySeconds: 30
        periodSeconds: 10
      
      readiness:
        enabled: true
        httpGet:
          path: /ready
          port: 8080
        initialDelaySeconds: 5
        periodSeconds: 5
    
    # Secret management
    secret:
      create: true
      store:
        secretsPath: /api
        environmentSlug: staging
      externalSecret:
        targetSecretName: api-secret
    
    # Environment variables
    env:
      envFrom:
        - secretRef:
            name: api-secret
      env:
        - name: NODE_ENV
          value: "production"
    
    # Persistence
    persistence:
      enabled: false
    
    # Service
    service:
      type: ClusterIP
      port: 80
      targetPort: 8080
    
    # Ingress
    ingress:
      enabled: true
      host: ""  # Auto-generated: mcp-my-api.staging.p2pmmo.vn
      path: /
      annotations:
        nginx.ingress.kubernetes.io/rate-limit: "1000"
    
    # Resources
    resources:
      requests:
        cpu: 200m
        memory: 256Mi
      limits:
        cpu: 1000m
        memory: 512Mi
```

## Usage Examples

### Example 1: MongoDB Service

```yaml
mcp:
  mongo:
    enabled: true
    
    image:
      repository: mongo
      tag: "7.0"
    
    port: 27017
    replicas: 1
    
    autoscaling:
      enabled: false  # Stateful services shouldn't autoscale
    
    probes:
      liveness:
        enabled: true
        tcpSocket:
          port: 27017
        initialDelaySeconds: 60
      
      readiness:
        enabled: true
        tcpSocket:
          port: 27017
    
    secret:
      create: true
      store:
        secretsPath: /mongo
      externalSecret:
        targetSecretName: mongo-secret
    
    env:
      envFrom:
        - secretRef:
            name: mongo-secret
    
    command: ["mongod"]
    args:
      - "--dbpath"
      - "/data/db"
      - "--bind_ip_all"
    
    persistence:
      enabled: true
      size: 50Gi
      storageClassName: premium-ssd
      mountPath: /data/db
    
    service:
      type: ClusterIP
      port: 27017
    
    ingress:
      enabled: false
    
    resources:
      requests:
        cpu: 1000m
        memory: 4Gi
      limits:
        cpu: 4000m
        memory: 16Gi
```

### Example 2: REST API with HPA

```yaml
mcp:
  api:
    enabled: true
    
    image:
      repository: myapp/api
      digest: sha256:abc123...  # Use digest in production
    
    port: 8080
    
    autoscaling:
      enabled: true
      minReplicas: 3
      maxReplicas: 50
      metrics:
        - type: Resource
          resource:
            name: cpu
            target:
              type: Utilization
              averageUtilization: 70
        - type: Resource
          resource:
            name: memory
            target:
              type: Utilization
              averageUtilization: 80
      behavior:
        scaleDown:
          stabilizationWindowSeconds: 300
          policies:
            - type: Percent
              value: 25
              periodSeconds: 60
        scaleUp:
          stabilizationWindowSeconds: 0
          policies:
            - type: Percent
              value: 50
              periodSeconds: 30
    
    probes:
      liveness:
        enabled: true
        httpGet:
          path: /healthz
          port: 8080
      readiness:
        enabled: true
        httpGet:
          path: /ready
          port: 8080
      startup:
        enabled: true
        httpGet:
          path: /startup
          port: 8080
        failureThreshold: 60
    
    secret:
      create: true
      store:
        secretsPath: /api
      externalSecret:
        targetSecretName: api-secret
    
    ingress:
      enabled: true
      annotations:
        nginx.ingress.kubernetes.io/rate-limit: "5000"
        nginx.ingress.kubernetes.io/cors-allow-origin: "*"
```

### Example 3: Shared Secret

```yaml
mcp:
  worker-1:
    enabled: true
    secret:
      create: false
      secretRef:
        name: shared-worker-secret
        namespace: mcp-secrets
    env:
      envFrom:
        - secretRef:
            name: shared-worker-secret
  
  worker-2:
    enabled: true
    secret:
      create: false
      secretRef:
        name: shared-worker-secret
        namespace: mcp-secrets
    env:
      envFrom:
        - secretRef:
            name: shared-worker-secret
```

## MCP Server Deployment

This chart has **first-class support for MCP (Model Context Protocol) servers** with SSE (Server-Sent Events).

### Quick Example: Deploy MCP Server

```yaml
mcp:
  my-mcp-server:
    enabled: true
    
    image:
      repository: mcp/custom-server
      tag: v1.0.0
    
    port: 8000
    
    # Health checks for MCP server
    probes:
      liveness:
        httpGet:
          path: /health
          port: 8000
      readiness:
        httpGet:
          path: /ready
          port: 8000
    
    # Secrets from Infisical
    secret:
      create: true
      store:
        secretsPath: /mcp-server
    
    # Service configuration
    service:
      type: ClusterIP
      port: 8000
    
    # 🔥 CRITICAL: Enable SSE support
    ingress:
      enabled: true
      sse: true  # This adds SSE-specific annotations
      path: /
```

### What `sse: true` Does

When you set `ingress.sse: true`, the chart automatically adds these critical annotations:

```yaml
nginx.ingress.kubernetes.io/proxy-buffering: "off"           # Disable buffering
nginx.ingress.kubernetes.io/proxy-read-timeout: "3600"       # 1 hour timeout
nginx.ingress.kubernetes.io/proxy-send-timeout: "3600"       # 1 hour timeout
nginx.ingress.kubernetes.io/proxy-http-version: "1.1"        # HTTP/1.1 for SSE
```

Without these, SSE connections will buffer, timeout, and fail.

### Testing SSE Connection

```bash
# Test your MCP server's SSE endpoint
curl -N -H "Accept: text/event-stream" \
  https://mcp-my-mcp-server.staging.p2pmmo.vn/sse

# Expected: streaming events, connection stays open
data: {"message": "connected"}

data: {"message": "heartbeat"}
```

### Multiple MCP Servers

```yaml
mcp:
  asana-mcp:
    enabled: true
    image:
      repository: mcp/asana
    port: 8000
    ingress:
      enabled: true
      sse: true
      host: mcp-asana.staging.p2pmmo.vn
  
  notion-mcp:
    enabled: true
    image:
      repository: mcp/notion
    port: 8000
    ingress:
      enabled: true
      sse: true
      host: mcp-notion.staging.p2pmmo.vn
```

📖 **For complete MCP server deployment guide, see [MCP_SERVER_GUIDE.md](MCP_SERVER_GUIDE.md)**

## FluxCD Integration

### Directory Structure

```
flux/
├── base/
│   └── helmrelease.yaml
├── staging/
│   ├── kustomization.yaml
│   └── values.yaml
└── production/
    ├── kustomization.yaml
    └── values.yaml
```

### Base HelmRelease

```yaml
# flux/base/helmrelease.yaml
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: mcp-stack
  namespace: flux-system
spec:
  interval: 5m
  chart:
    spec:
      chart: ./helm-mcp-stack
      sourceRef:
        kind: GitRepository
        name: infra-repo
        namespace: flux-system
  valuesFrom:
    - kind: ConfigMap
      name: mcp-stack-values
```

### Staging Kustomization

```yaml
# flux/staging/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../base/helmrelease.yaml
patches:
  - path: values.yaml
    target:
      kind: HelmRelease
      name: mcp-stack
```

```yaml
# flux/staging/values.yaml
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: mcp-stack
spec:
  values:
    global:
      environment: staging
      domain: p2pmmo.vn
      
      ingress:
        className: nginx-staging
      
      versioning:
        strategy: tag
    
    mcp:
      api:
        enabled: true
        image:
          tag: develop
        replicas: 1
        autoscaling:
          enabled: false
```

### Production Kustomization

```yaml
# flux/production/values.yaml
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: mcp-stack
spec:
  values:
    global:
      environment: production
      
      versioning:
        strategy: digest
      
      autoscaling:
        enabled: true
    
    mcp:
      api:
        enabled: true
        image:
          digest: sha256:abc123...
        autoscaling:
          enabled: true
          minReplicas: 5
          maxReplicas: 50
```

## Architecture

### Components

```
┌─────────────────────────────────────────────────────────┐
│                    FluxCD GitOps                        │
│  ┌───────────────────────────────────────────────────┐  │
│  │          HelmRelease (staging/production)         │  │
│  └─────────────────────┬─────────────────────────────┘  │
└────────────────────────┼────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│                   MCP Stack Helm Chart                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │ Deployment   │  │   Service    │  │   Ingress    │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │     PVC      │  │     HPA      │  │  ConfigMap   │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└────────────────────────┬────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│           External Secrets Operator                     │
│  ┌──────────────┐         ┌──────────────┐             │
│  │ SecretStore  │────────▶│ExternalSecret│             │
│  └──────────────┘         └──────┬───────┘             │
└─────────────────────────────────┼─────────────────────┘
                                   │
                                   ▼
                    ┌──────────────────────────┐
                    │   Infisical API          │
                    │  (Secret Management)     │
                    └──────────────────────────┘
```

### Ingress Pattern

```
Production:
  mcp-{service}.{domain}
  Example: mcp-api.p2pmmo.vn

Staging/Review:
  mcp-{service}.{environment}.{domain}
  Example: mcp-api.staging.p2pmmo.vn
```

### Secret Flow

1. **SecretStore** connects to Infisical with credentials
2. **ExternalSecret** defines which secrets to fetch
3. **Kubernetes Secret** is created/updated automatically
4. **Deployment** mounts the secret via envFrom or volumeMounts

## Troubleshooting

### Secrets Not Syncing

```bash
# Check SecretStore status
kubectl get secretstore -n mcp-secrets

# Check ExternalSecret status
kubectl get externalsecret -n mcp-secrets

# View ExternalSecret details
kubectl describe externalsecret <name> -n mcp-secrets

# Check External Secrets Operator logs
kubectl logs -n external-secrets-system \
  -l app.kubernetes.io/name=external-secrets
```

### Pods Not Starting

```bash
# Check pod status
kubectl get pods -n mcp-secrets

# View pod events
kubectl describe pod <pod-name> -n mcp-secrets

# Check pod logs
kubectl logs <pod-name> -n mcp-secrets

# Check if secrets exist
kubectl get secrets -n mcp-secrets
```

### HPA Not Scaling

```bash
# Check HPA status
kubectl get hpa -n mcp-secrets

# View HPA details
kubectl describe hpa <hpa-name> -n mcp-secrets

# Check metrics server
kubectl top nodes
kubectl top pods -n mcp-secrets

# Ensure metrics-server is running
kubectl get deployment metrics-server -n kube-system
```

### Ingress Not Working

```bash
# Check ingress status
kubectl get ingress -n mcp-secrets

# View ingress details
kubectl describe ingress <ingress-name> -n mcp-secrets

# Check ingress controller logs
kubectl logs -n ingress-nginx \
  -l app.kubernetes.io/name=ingress-nginx

# Check certificate status (if using TLS)
kubectl get certificate -n mcp-secrets
```

## Best Practices

### Image Versioning

- **Staging**: Use `tag: latest` or `tag: develop` for auto-deployment
- **Production**: Use `digest: sha256:...` for immutability and rollback safety
- Never use `latest` tag in production

### Health Checks

- **Liveness**: Loose thresholds, avoid killing healthy pods
- **Readiness**: Strict thresholds, quickly remove unhealthy pods from load balancer
- **Startup**: For slow-starting applications (>30 seconds)

### Autoscaling

- Enable HPA for stateless services
- Disable HPA for stateful services (databases)
- Set appropriate stabilization windows to prevent flapping
- Use multiple metrics (CPU + Memory) for better scaling decisions

### Secret Management

- Never commit secrets to Git
- Use Infisical for centralized secret management
- Create separate secrets per service when possible
- Use `secretRef` to share secrets between services if needed

### Resource Limits

- Always set resource requests for proper scheduling
- Set limits to prevent resource exhaustion
- Use different values for staging vs production
- Monitor actual usage and adjust accordingly

## Upgrading

```bash
# Check what will change
helm diff upgrade mcp-stack . \
  -f values-production.yaml \
  -n mcp-secrets

# Upgrade with new values
helm upgrade mcp-stack . \
  -f values-production.yaml \
  -n mcp-secrets

# Rollback if needed
helm rollback mcp-stack -n mcp-secrets
```

## Uninstall

```bash
# Uninstall the release
helm uninstall mcp-stack -n mcp-secrets

# Clean up PVCs (optional)
kubectl delete pvc -n mcp-secrets -l app.kubernetes.io/instance=mcp-stack

# Clean up namespace (optional)
kubectl delete namespace mcp-secrets
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `helm lint` and `helm template`
5. Submit a pull request

## License

Copyright © 2024 p2pmmo Vietnam

## Support

- Documentation: https://docs.p2pmmo.vn
- Issues: https://github.com/example/helm-mcp-stack/issues
- Email: devops@p2pmmo.vn
