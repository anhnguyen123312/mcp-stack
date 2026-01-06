# MCP Stack Helm Chart - Project Structure

## 📁 Complete File Structure

```
helm-mcp-stack/
├── Chart.yaml                          # Helm chart metadata
├── values.yaml                         # Default values (staging-like)
├── values-staging.yaml                 # Staging environment overrides
├── values-production.yaml              # Production environment overrides
├── README.md                           # Comprehensive documentation
├── QUICKSTART.md                       # Quick start guide
├── Makefile                            # Convenience commands
├── .helmignore                         # Files to ignore when packaging
├── .gitignore                          # Git ignore patterns
│
├── templates/                          # Kubernetes resource templates
│   ├── _helpers.tpl                   # Template helper functions
│   ├── NOTES.txt                      # Post-installation notes
│   ├── deployment.yaml                # Deployment template
│   ├── service.yaml                   # Service template
│   ├── ingress.yaml                   # Ingress template
│   ├── pvc.yaml                       # PersistentVolumeClaim template
│   ├── hpa.yaml                       # HorizontalPodAutoscaler template
│   ├── secret-store.yaml              # Infisical SecretStore template
│   └── external-secret.yaml           # Infisical ExternalSecret template
│
└── examples/
    └── flux/                          # FluxCD examples
        ├── base/
        │   └── helmrelease.yaml       # Base HelmRelease
        ├── staging/
        │   ├── kustomization.yaml     # Staging kustomization
        │   └── values.yaml            # Staging values override
        └── production/
            ├── kustomization.yaml     # Production kustomization
            └── values.yaml            # Production values override
```

## 📄 File Descriptions

### Core Files

#### `Chart.yaml`
Helm chart metadata including name, version, description, and maintainers.

#### `values.yaml`
Default configuration file with all available options. Includes:
- Global settings (namespace, domain, environment)
- Image configuration
- Infisical integration
- Health checks defaults
- HPA defaults
- Resource limits
- Example service configurations

#### `values-staging.yaml`
Staging environment overrides:
- Uses `tag` versioning strategy
- Lower resource limits
- Single replicas
- HPA disabled
- Debug logging enabled

#### `values-production.yaml`
Production environment overrides:
- Uses `digest` versioning strategy (immutable)
- Higher resource limits
- Multiple replicas
- HPA enabled
- Stricter health checks
- Info-level logging

### Templates

#### `templates/_helpers.tpl`
Helper functions for:
- Image path generation (tag/digest support)
- Ingress host generation
- Secret store naming
- Resource merging
- Probe configuration

#### `templates/deployment.yaml`
Creates Kubernetes Deployments for each enabled service with:
- Dynamic replica count (respects HPA)
- Health probes (liveness, readiness, startup)
- Resource limits
- Secret injection
- Volume mounts

#### `templates/service.yaml`
Creates Kubernetes Services for networking between pods.

#### `templates/ingress.yaml`
Creates Ingress resources for external access with:
- Auto-generated hostnames
- TLS support
- Custom annotations

#### `templates/hpa.yaml`
Creates HorizontalPodAutoscalers for services with autoscaling enabled.

#### `templates/pvc.yaml`
Creates PersistentVolumeClaims for stateful services.

#### `templates/secret-store.yaml`
Creates Infisical SecretStore resources for connecting to Infisical API.

#### `templates/external-secret.yaml`
Creates ExternalSecret resources to sync secrets from Infisical.

#### `templates/NOTES.txt`
Post-installation message showing:
- Deployed services
- Access URLs
- Useful kubectl commands

### Documentation

#### `README.md`
Comprehensive documentation covering:
- Features
- Prerequisites
- Installation instructions
- Configuration options
- Usage examples
- FluxCD integration
- Architecture diagrams
- Troubleshooting guide
- Best practices

#### `QUICKSTART.md`
Step-by-step quick start guide for getting up and running in 5 minutes.

### Development Tools

#### `Makefile`
Convenience commands for:
- Linting and testing
- Installing/upgrading
- Templating
- Kubernetes resource inspection
- Logs and debugging

#### `.helmignore`
Excludes files from Helm package:
- VCS directories
- IDE files
- Examples directory
- Documentation

#### `.gitignore`
Git ignore patterns for:
- Packaged charts
- IDE files
- Local testing files

### FluxCD Examples

#### `examples/flux/base/helmrelease.yaml`
Base HelmRelease template for FluxCD GitOps workflow.

#### `examples/flux/staging/`
Staging-specific FluxCD configuration with:
- Kustomization overlay
- Staging values override
- Environment-specific settings

#### `examples/flux/production/`
Production-specific FluxCD configuration with:
- Kustomization overlay
- Production values override
- High-availability settings

## 🎯 Key Features

### 1. Multi-Service Support
- Deploy multiple services from a single chart
- Each service is independently configurable
- Share common settings through global defaults

### 2. Secret Management
- Integrated Infisical support via External Secrets Operator
- Per-service secret configuration
- Support for secret sharing across services
- Automatic secret sync with configurable refresh intervals

### 3. Autoscaling
- Per-service HPA configuration
- Multi-metric support (CPU, memory, custom)
- Configurable scaling behavior
- Production-ready defaults

### 4. Health Checks
- Liveness probes (restart unhealthy pods)
- Readiness probes (remove from load balancer)
- Startup probes (for slow-starting apps)
- Support for HTTP, TCP, and exec probes

### 5. Image Versioning
- **Tag**: Use semantic versions or branch names
- **Digest**: Immutable images using SHA256
- **Semver**: Version constraints (future feature)

### 6. Multi-Environment
- Environment-specific value files
- Different configurations for staging/production
- Environment-aware ingress hostnames

### 7. Storage Management
- Dynamic PVC provisioning
- Custom storage classes per service
- Configurable access modes and sizes

### 8. Ingress Management
- Automatic hostname generation
- TLS certificate integration
- Rate limiting and CORS support
- Environment-based routing

### 9. GitOps Ready
- Full FluxCD integration
- Kustomize overlays for environments
- Automated deployments

### 10. Production Hardened
- Resource limits and requests
- Pod Disruption Budgets (can be added)
- Network Policies (can be added)
- Security contexts (can be added)

## 🔧 Customization Points

### Global Level
- Namespace and domain
- Image registry and pull secrets
- Infisical configuration
- Default resource limits
- Default health check settings
- Storage class defaults
- Ingress defaults

### Service Level
- Image (repository, tag/digest)
- Replicas and autoscaling
- Health probes
- Secret configuration
- Environment variables
- Persistence settings
- Resource limits
- Ingress configuration

## 📊 Resource Generation

For each enabled service, the chart generates:

1. **Always Created**
   - Deployment
   - Service

2. **Conditionally Created**
   - SecretStore (if `secret.create: true`)
   - ExternalSecret (if `secret.create: true`)
   - PersistentVolumeClaim (if `persistence.enabled: true`)
   - HorizontalPodAutoscaler (if `autoscaling.enabled: true`)
   - Ingress (if `ingress.enabled: true`)

## 🚀 Deployment Flow

### Using Helm Directly
1. Edit values file
2. Run `helm install` or `make install-staging`
3. Verify with `kubectl get all`

### Using FluxCD
1. Push changes to Git
2. FluxCD detects changes
3. Applies HelmRelease
4. Helm chart deployed automatically
5. Continuous reconciliation

## 📝 Configuration Hierarchy

```
Global Defaults
    ↓
Environment Overrides (values-staging.yaml / values-production.yaml)
    ↓
Service-Specific Configuration
    ↓
Runtime Values (from FluxCD or helm install --set)
```

## 🔐 Secret Flow

```
Infisical API
    ↓
SecretStore (connects to Infisical)
    ↓
ExternalSecret (fetches secrets)
    ↓
Kubernetes Secret (created automatically)
    ↓
Pod (mounts via envFrom or volumeMounts)
```

## 🌐 Ingress Pattern

```
Production:
  mcp-{service-name}.{domain}
  Example: mcp-api.p2pmmo.vn

Staging:
  mcp-{service-name}.{environment}.{domain}
  Example: mcp-api.staging.p2pmmo.vn

Review:
  mcp-{service-name}.review.{domain}
  Example: mcp-api.review.p2pmmo.vn
```

## 🎓 Best Practices Implemented

1. **Separation of Concerns**: Global settings vs service-specific
2. **DRY Principle**: Reusable templates and helpers
3. **Security First**: Secret management, resource limits
4. **Production Ready**: Health checks, HPA, monitoring labels
5. **GitOps Friendly**: Declarative configuration
6. **Multi-Environment**: Clear separation of concerns
7. **Observability**: Proper labels and annotations
8. **Scalability**: HPA and resource management
9. **Reliability**: Health checks and probes
10. **Maintainability**: Clear documentation and examples
