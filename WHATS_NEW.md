# What's New in v1.0

## 🎉 Major Updates

### 1. ️ `services:` → `mcp:`
Chart is now MCP-focused. Top-level key renamed for clarity.

```yaml
# Before
services:
  my-server: ...

# After  
mcp:
  my-server: ...
```

### 2. 🐳 Per-MCP Registry Override
Each MCP can use a different container registry!

```yaml
global:
  image:
    registry: registry.example.com

mcp:
  github-mcp:
    image:
      registry: ghcr.io  # Use GitHub Container Registry
      repository: mcp/github
  
  internal-mcp:
    image:
      registry: registry.internal.example.com  # Internal registry
      repository: mcp/internal
  
  docker-mcp:
    image:
      registry: docker.io  # Docker Hub
      repository: redis
```

### 3. 🔌 Global Default Port
Set default port once, override when needed.

```yaml
global:
  defaultPort: 8000  # Default for all MCPs

mcp:
  standard-mcp:
    # No port specified, uses global.defaultPort (8000)
    image:
      repository: mcp/standard
  
  custom-mcp:
    port: 9090  # Override global default
    image:
      repository: mcp/custom
```

### 4. 📡 Full SSE Support
First-class support for MCP servers with Server-Sent Events.

```yaml
mcp:
  asana-mcp:
    ingress:
      enabled: true
      sse: true  # Auto-adds SSE annotations
```

Automatically adds:
- `proxy-buffering: off`
- `proxy-read-timeout: 3600`
- `proxy-http-version: 1.1`

### 5. 🔒 Simplified Setup
- Namespace: `mcp-secrets` (cleaner)
- Domain: `example.com` (generic examples)
- Secret: `infisical-credentials` (simpler name)
- Reflector: Removed (unnecessary complexity)

## 📚 New Documentation

- **MIGRATION_GUIDE.md** - Upgrade from v0.9 to v1.0
- **MCP_SERVER_GUIDE.md** - Complete MCP deployment guide
- **WHATS_NEW.md** - This file!

## 🚀 Quick Start

### Setup
```bash
kubectl create namespace mcp-secrets

kubectl create secret generic infisical-credentials \
  --from-literal=clientId=YOUR_ID \
  --from-literal=clientSecret=YOUR_SECRET \
  -n mcp-secrets
```

### Deploy
```yaml
# values.yaml
global:
  namespace: mcp-secrets
  domain: example.com
  defaultPort: 8000
  
  image:
    registry: registry.example.com

mcp:
  asana-mcp:
    enabled: true
    image:
      repository: mcp/asana
      registry: ghcr.io  # Per-MCP registry
    # port: omitted, uses global.defaultPort
    
    ingress:
      enabled: true
      sse: true  # SSE support
```

```bash
helm install mcp-stack . \
  -f values.yaml \
  -n mcp-secrets \
  --create-namespace
```

## 💡 Key Benefits

✅ **Cleaner config** - `mcp:` is more descriptive than `services:`  
✅ **Multi-registry** - Mix public/private/internal registries  
✅ **Default port** - Less repetition in configs  
✅ **SSE-ready** - Proper MCP server support out of the box  
✅ **Simpler names** - Generic examples, easier to adapt  

## 🔄 Migration

See [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md) for detailed upgrade steps.

**TL;DR:**
1. Change `services:` to `mcp:`
2. Update namespace to `mcp-secrets`
3. Update secret name to `infisical-credentials`
4. Remove reflector config
5. Deploy!

## 📖 Learn More

- [README.md](README.md) - Complete documentation
- [QUICKSTART.md](QUICKSTART.md) - 5-minute setup
- [MCP_SERVER_GUIDE.md](MCP_SERVER_GUIDE.md) - MCP deployment guide
- [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md) - Upgrade guide

## 🎯 Example: Complete Setup

```yaml
global:
  namespace: mcp-secrets
  domain: example.com
  defaultPort: 8000
  
  image:
    registry: registry.example.com

mcp:
  # From GitHub Container Registry
  github-mcp:
    enabled: true
    image:
      registry: ghcr.io
      repository: modelcontextprotocol/github
    ingress:
      enabled: true
      sse: true
  
  # From internal registry, custom port
  internal-mcp:
    enabled: true
    port: 9000
    image:
      registry: registry.internal.example.com
      repository: mcp/internal
    ingress:
      enabled: true
      sse: true
  
  # From Docker Hub
  redis:
    enabled: true
    port: 6379
    image:
      registry: docker.io
      repository: library/redis
      tag: 7-alpine
    ingress:
      enabled: false
```

Happy deploying! 🚀
