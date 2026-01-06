# MCP Server Deployment Guide

Complete guide for deploying Model Context Protocol (MCP) servers using this Helm chart.

## 📡 MCP Server Connection Modes

MCP servers can operate in two modes:

### 1. SSE (Server-Sent Events) - HTTP Mode
- **Use case**: Remote connections, web-based integrations
- **Protocol**: HTTP with Server-Sent Events streaming
- **Port**: Typically 8000, 8080, or custom
- **Endpoint**: Usually `/sse` or `/mcp`
- **Examples**: Asana MCP, Figma MCP, Notion MCP

### 2. stdio Mode
- **Use case**: Local connections, subprocess communication
- **Protocol**: Standard input/output streams
- **Port**: None (no network exposure needed)
- **Not covered in this guide** (for Kubernetes deployment, use SSE mode)

## 🚀 Quick Start: Deploy MCP Server

### Basic MCP Server Configuration

```yaml
mcp:
  my-mcp-server:
    enabled: true
    
    image:
      repository: my-org/my-mcp-server
      tag: v1.0.0
    
    # MCP servers typically run on port 8000
    port: 8000
    
    replicas: 2
    
    # Enable autoscaling for production
    autoscaling:
      enabled: true
      minReplicas: 2
      maxReplicas: 10
    
    # Health checks
    probes:
      liveness:
        enabled: true
        httpGet:
          path: /health
          port: 8000
        initialDelaySeconds: 30
        periodSeconds: 10
      
      readiness:
        enabled: true
        httpGet:
          path: /health
          port: 8000
        initialDelaySeconds: 5
        periodSeconds: 5
    
    # Secrets from Infisical
    secret:
      create: true
      store:
        secretsPath: /mcp-server
      externalSecret:
        targetSecretName: mcp-server-secret
    
    # Environment variables
    env:
      envFrom:
        - secretRef:
            name: mcp-server-secret
      env:
        - name: MCP_SERVER_PORT
          value: "8000"
        - name: LOG_LEVEL
          value: "info"
    
    # Service configuration
    service:
      type: ClusterIP
      port: 8000
      targetPort: 8000
    
    # Ingress with SSE support
    ingress:
      enabled: true
      sse: true  # 🔥 CRITICAL: Enable SSE-specific annotations
      path: /
      annotations:
        nginx.ingress.kubernetes.io/backend-protocol: "HTTP"
    
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        cpu: 500m
        memory: 512Mi
```

## 🔑 Critical Configuration: SSE Support

### Why `sse: true` is Important

When `ingress.sse: true`, the chart automatically adds these annotations:

```yaml
nginx.ingress.kubernetes.io/proxy-buffering: "off"           # Disable buffering for streaming
nginx.ingress.kubernetes.io/proxy-read-timeout: "3600"       # 1 hour timeout
nginx.ingress.kubernetes.io/proxy-send-timeout: "3600"       # 1 hour timeout
nginx.ingress.kubernetes.io/proxy-http-version: "1.1"        # HTTP/1.1 for SSE
```

**Without these annotations**, SSE connections will:
- ❌ Buffer responses (breaking streaming)
- ❌ Timeout after 60 seconds
- ❌ Drop connections unexpectedly

### Testing SSE Endpoint

```bash
# Test SSE connection
curl -N -H "Accept: text/event-stream" \
  https://mcp-my-mcp-server.staging.p2pmmo.vn/sse

# Expected output: streaming events
data: {"message": "connected"}

data: {"message": "heartbeat"}

# Connection should stay open
```

## 📝 Real-World Examples

### Example 1: Custom MCP Server

```yaml
mcp:
  custom-mcp:
    enabled: true
    
    image:
      repository: mycompany/custom-mcp
      digest: sha256:abc123...  # Production: use digest
    
    port: 8000
    
    replicas: 3
    
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
    
    probes:
      liveness:
        httpGet:
          path: /health
          port: 8000
        initialDelaySeconds: 30
      
      readiness:
        httpGet:
          path: /ready
          port: 8000
      
      startup:
        httpGet:
          path: /health
          port: 8000
        failureThreshold: 30
    
    secret:
      create: true
      store:
        environmentSlug: production
        secretsPath: /custom-mcp
    
    env:
      envFrom:
        - secretRef:
            name: custom-mcp-secret
      env:
        - name: MCP_MODE
          value: "sse"
        - name: MCP_PORT
          value: "8000"
        - name: MCP_HOST
          value: "0.0.0.0"
    
    service:
      type: ClusterIP
      port: 8000
    
    ingress:
      enabled: true
      sse: true
      annotations:
        nginx.ingress.kubernetes.io/rate-limit: "100"
        nginx.ingress.kubernetes.io/cors-allow-origin: "*"
    
    resources:
      requests:
        cpu: 200m
        memory: 256Mi
      limits:
        cpu: 1000m
        memory: 1Gi
```

### Example 2: Database MCP Server (like MongoDB MCP)

```yaml
mcp:
  mongodb-mcp:
    enabled: true
    
    image:
      repository: mcp/mongodb
      tag: v1.0.0
    
    port: 8000
    
    replicas: 2
    
    probes:
      liveness:
        httpGet:
          path: /health
          port: 8000
      readiness:
        httpGet:
          path: /ready
          port: 8000
    
    # This MCP server needs MongoDB credentials
    secret:
      create: true
      store:
        secretsPath: /mongodb-mcp
        # Should contain: MONGODB_URI, API_KEY
    
    env:
      envFrom:
        - secretRef:
            name: mongodb-mcp-secret
      env:
        - name: MCP_SERVER_PORT
          value: "8000"
    
    service:
      type: ClusterIP
      port: 8000
    
    ingress:
      enabled: true
      sse: true  # Required for MCP
      path: /
```

### Example 3: Multiple MCP Servers (Different Services)

```yaml
mcp:
  # Asana MCP
  asana-mcp:
    enabled: true
    image:
      repository: mcp/asana
      tag: latest
    port: 8000
    ingress:
      enabled: true
      sse: true
      host: mcp-asana.staging.p2pmmo.vn
  
  # Notion MCP
  notion-mcp:
    enabled: true
    image:
      repository: mcp/notion
      tag: latest
    port: 8000
    ingress:
      enabled: true
      sse: true
      host: mcp-notion.staging.p2pmmo.vn
  
  # Custom Internal MCP
  internal-mcp:
    enabled: true
    image:
      repository: mycompany/internal-mcp
      tag: v1.0.0
    port: 8000
    ingress:
      enabled: true
      sse: true
      host: mcp-internal.staging.p2pmmo.vn
```

## 🔒 Security Considerations

### 1. API Key Authentication

Most MCP servers require API keys. Store them in Infisical:

```yaml
# In Infisical: /mcp-server path
API_KEY=your-secret-api-key
SERVICE_TOKEN=another-secret-token
```

Then reference in deployment:

```yaml
secret:
  create: true
  store:
    secretsPath: /mcp-server

env:
  envFrom:
    - secretRef:
        name: mcp-server-secret
```

### 2. Network Policies

Restrict which pods can access MCP servers:

```yaml
# Add to your cluster (not in this chart yet)
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: mcp-server-policy
spec:
  podSelector:
    matchLabels:
      app.kubernetes.io/name: mcp-server
  policyTypes:
    - Ingress
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              name: allowed-namespace
```

### 3. Rate Limiting

Protect MCP endpoints with rate limiting:

```yaml
ingress:
  enabled: true
  sse: true
  annotations:
    nginx.ingress.kubernetes.io/rate-limit: "100"  # 100 req/sec
    nginx.ingress.kubernetes.io/limit-rps: "10"    # 10 req/sec per IP
```

## 🐛 Troubleshooting

### SSE Connection Drops After 60 Seconds

**Problem**: SSE connection closes after default nginx timeout

**Solution**: Ensure `ingress.sse: true` is set:

```yaml
ingress:
  enabled: true
  sse: true  # This adds the necessary timeout annotations
```

### Buffering Issues

**Problem**: Events are buffered and arrive in batches

**Solution**: Verify proxy-buffering is off:

```bash
kubectl describe ingress mcp-server -n mcp-secrets | grep proxy-buffering
# Should show: nginx.ingress.kubernetes.io/proxy-buffering: off
```

### Connection Refused

**Problem**: Cannot connect to MCP server

**Solution**: Check pod and service:

```bash
# Check pod is running
kubectl get pods -n mcp-secrets -l app.kubernetes.io/name=mcp-server

# Check service endpoints
kubectl get endpoints mcp-server -n mcp-secrets

# Test from inside cluster
kubectl run -it --rm debug --image=alpine --restart=Never -- sh
apk add curl
curl http://mcp-server:8000/health
```

### Health Check Failures

**Problem**: Pods keep restarting due to failed health checks

**Solution**: Adjust probe settings:

```yaml
probes:
  liveness:
    initialDelaySeconds: 60  # Increase if startup is slow
    failureThreshold: 5      # Allow more failures
  
  startup:
    enabled: true
    failureThreshold: 30     # 30 * 10s = 5 minutes max startup
```

## 📊 Monitoring MCP Servers

### Recommended Metrics

Monitor these key metrics for MCP servers:

1. **Active SSE Connections**: Number of concurrent streaming connections
2. **Request Rate**: Requests per second
3. **Response Time**: P95, P99 latency
4. **Error Rate**: 4xx, 5xx errors
5. **CPU/Memory**: Resource utilization

### Example Prometheus Queries

```promql
# Active connections
sum(rate(nginx_ingress_controller_requests[5m])) by (exported_service)

# P95 response time
histogram_quantile(0.95, rate(nginx_ingress_controller_response_duration_seconds_bucket[5m]))

# Error rate
sum(rate(nginx_ingress_controller_requests{status=~"5.."}[5m])) by (exported_service)
```

## 🔄 Deployment Workflow

### Staging Deployment

```bash
# 1. Update values-staging.yaml with your MCP server config
# 2. Deploy
make install-staging

# 3. Verify
kubectl get pods -n mcp-secrets -l app.kubernetes.io/name=mcp-server
kubectl logs -f -n mcp-secrets -l app.kubernetes.io/name=mcp-server

# 4. Test SSE endpoint
curl -N -H "Accept: text/event-stream" \
  https://mcp-your-server.staging.p2pmmo.vn/sse
```

### Production Deployment

```bash
# 1. Use digest for immutable deployments
image:
  digest: sha256:abc123...

# 2. Deploy with production values
make install-production

# 3. Monitor
kubectl top pods -n mcp-secrets
make k8s-hpa
```

## 📚 Additional Resources

- [MCP Protocol Specification](https://spec.modelcontextprotocol.io/)
- [SSE Protocol](https://html.spec.whatwg.org/multipage/server-sent-events.html)
- [Nginx SSE Configuration](https://nginx.org/en/docs/http/ngx_http_proxy_module.html)
- [External Secrets Operator](https://external-secrets.io/)

## 🆘 Support

Having issues deploying MCP servers?

1. Check the [Troubleshooting](#troubleshooting) section
2. Review logs: `make logs SERVICE=mcp-server`
3. Open an issue with:
   - Your values.yaml config
   - Pod logs
   - Ingress description
   - Error messages

---

**Pro Tip**: Always test SSE connectivity after deployment:

```bash
# Should maintain open connection with streaming events
curl -N -H "Accept: text/event-stream" \
  https://your-mcp-server/sse
```
