# Migration Guide: services → mcp

Quick guide for updating to the new MCP-focused structure.

## Key Changes

### 1. Rename `services` to `mcp`

**Before:**
```yaml
services:
  my-server:
    enabled: true
```

**After:**
```yaml
mcp:
  my-server:
    enabled: true
```

### 2. Per-MCP Registry Override

**New feature:**
```yaml
global:
  image:
    registry: registry.example.com

mcp:
  asana-mcp:
    image:
      registry: ghcr.io  # Override global
      repository: mcp/asana
```

### 3. Global Default Port

**New:**
```yaml
global:
  defaultPort: 8000  # Used when mcp.port not specified

mcp:
  my-mcp:
    # port omitted, uses global.defaultPort
    image:
      repository: mcp/my-server
```

### 4. Updated Defaults

- Namespace: `p2pmmo-secrets` → `mcp-secrets`
- Domain: `p2pmmo.vn` → `example.com`
- Secret name: `infisical-credentials-trueprofit` → `infisical-credentials`
- Reflector: Removed

## Migration Steps

1. **Update values.yaml:**
   - Change `services:` to `mcp:`
   - Update namespace and domain
   - Remove reflector config

2. **Update secrets:**
   ```bash
   kubectl create namespace mcp-secrets
   kubectl create secret generic infisical-credentials \
     --from-literal=clientId=YOUR_ID \
     --from-literal=clientSecret=YOUR_SECRET \
     -n mcp-secrets
   ```

3. **Upgrade:**
   ```bash
   helm upgrade mcp-stack . \
     -f values-staging.yaml \
     -n mcp-secrets
   ```

## Full Example

**Before:**
```yaml
global:
  namespace: p2pmmo-secrets
  domain: p2pmmo.vn

services:
  my-mcp:
    enabled: true
    image:
      repository: mcp/server
    port: 8000
```

**After:**
```yaml
global:
  namespace: mcp-secrets
  domain: example.com
  defaultPort: 8000

mcp:
  my-mcp:
    enabled: true
    image:
      repository: mcp/server
      registry: ghcr.io  # New: per-MCP registry
    # port: omitted, uses global.defaultPort
```
