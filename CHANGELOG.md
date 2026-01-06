# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-07

### Added
- Initial release of MCP Stack Helm Chart
- **MCP Server Support**: Full support for deploying MCP servers with SSE (Server-Sent Events)
- **SSE Configuration**: Automatic SSE-specific annotations when `ingress.sse: true`
- **Per-MCP Registry Override**: Each MCP can specify its own container registry
- **Global Default Port**: Configure `global.defaultPort` for all MCP servers, override per-MCP
- Multi-service deployment support
- Infisical secret management integration via External Secrets Operator
- FluxCD GitOps support with example configurations
- Horizontal Pod Autoscaling (HPA) per service
- Comprehensive health checks (liveness, readiness, startup probes)
- Persistent storage support with dynamic PVC provisioning
- Ingress management with automatic hostname generation
- Multi-environment support (staging, production, review)
- Image versioning strategies (tag, digest, semver)
- Resource management with configurable limits and requests
- Complete documentation (README, QUICKSTART, PROJECT_STRUCTURE, MCP_SERVER_GUIDE, MIGRATION_GUIDE)
- Makefile with convenience commands
- Template helpers for DRY configuration
- Environment-specific value files (staging, production)
- Example service configurations (MongoDB, API, Redis, MCP Server)
- Post-installation NOTES with useful commands

### Changed
- **BREAKING**: Renamed top-level key from `services:` to `mcp:` for clarity
- **BREAKING**: Changed default namespace from `p2pmmo-secrets` to `mcp-secrets`
- **BREAKING**: Updated example domain from `p2pmmo.vn` to `example.com`
- **BREAKING**: Simplified Infisical secret name from `infisical-credentials-trueprofit` to `infisical-credentials`
- **BREAKING**: Removed Reflector support for cross-namespace secret sync

### Features
- 🔐 **Secret Management**: Automatic sync from Infisical
- 📡 **SSE Support**: Proper configuration for Server-Sent Events (MCP servers)
- 🐳 **Multi-Registry**: Per-MCP registry override support
- 🔌 **Default Port**: Global default port with per-MCP override
- 🚀 **Auto-scaling**: Per-service HPA with custom metrics
- 🏥 **Health Checks**: Configurable probes for all services
- 💾 **Storage**: Dynamic PVC with custom storage classes
- 🌐 **Ingress**: Auto-generated hostnames with TLS
- 🎯 **Multi-Env**: Built-in staging and production configs
- 🔄 **Versioning**: Support for tags, digests, and semver
- 📦 **GitOps**: Full FluxCD integration
- 🛡️ **Production Ready**: Resource limits, health checks, HPA

### Documentation
- Comprehensive README with examples
- Quick start guide (5 minutes to deploy)
- Project structure documentation
- **MCP Server deployment guide** with SSE configuration
- FluxCD integration examples
- Troubleshooting guide
- Best practices
- Makefile commands reference

### Templates
- Deployment with health checks and resource limits
- Service for internal networking
- Ingress with auto-hostname and TLS
- PersistentVolumeClaim for stateful services
- HorizontalPodAutoscaler for scalability
- SecretStore for Infisical connection
- ExternalSecret for secret synchronization
- Reusable template helpers

### Examples
- MongoDB stateful service
- REST API with HPA
- Redis cache service
- Worker service with queue-based scaling
- Shared secret configuration
- FluxCD base and environment overlays

## [Unreleased]

### Planned
- Support for StatefulSets
- Pod Disruption Budgets (PDB)
- Network Policies
- Security Contexts
- ServiceMonitor for Prometheus
- VPA (Vertical Pod Autoscaler) support
- Multi-container pod support
- Init containers support
- ConfigMap management
- KEDA integration for advanced autoscaling
- Multiple ingress per service
- Multiple volumes per service
- Istio/Service Mesh support
- Backup and restore procedures
- Migration guide from monolithic deployments

### Future Enhancements
- Web UI for configuration generation
- Helm chart repository hosting
- Integration tests
- Chart versioning automation
- OPA policies
- Cost optimization recommendations
- Performance benchmarking tools
