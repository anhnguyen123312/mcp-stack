# Contributing to MCP Stack Helm Chart

First off, thanks for taking the time to contribute! 🎉

The following is a set of guidelines for contributing to the MCP Stack Helm Chart. These are mostly guidelines, not rules. Use your best judgment, and feel free to propose changes to this document in a pull request.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Testing](#testing)
- [Pull Request Process](#pull-request-process)
- [Style Guidelines](#style-guidelines)

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code. Please report unacceptable behavior to devops@p2pmmo.vn.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues to avoid duplicates. When you are creating a bug report, please include as many details as possible:

- **Use a clear and descriptive title**
- **Describe the exact steps to reproduce the problem**
- **Provide specific examples** (values.yaml snippets, commands, etc.)
- **Describe the behavior you observed** and what behavior you expected
- **Include Helm and Kubernetes versions**

Example bug report:

```markdown
## Bug: HPA not scaling properly

**Environment:**
- Helm version: 3.12.0
- Kubernetes version: 1.27
- Chart version: 1.0.0

**Steps to reproduce:**
1. Install chart with `autoscaling.enabled: true`
2. Generate load on the service
3. HPA doesn't scale beyond minReplicas

**Expected behavior:**
HPA should scale up to maxReplicas based on CPU utilization

**Actual behavior:**
HPA remains at minReplicas even when CPU > 80%

**Configuration:**
```yaml
autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 10
```
```

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, please include:

- **Use a clear and descriptive title**
- **Provide a detailed description** of the suggested enhancement
- **Explain why this enhancement would be useful**
- **Provide examples** of how it would be used

### Contributing Code

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Make your changes**
4. **Test your changes** thoroughly
5. **Commit your changes** (`git commit -m 'Add amazing feature'`)
6. **Push to the branch** (`git push origin feature/amazing-feature`)
7. **Open a Pull Request**

## Development Setup

### Prerequisites

```bash
# Install required tools
brew install helm kubernetes-cli

# Or using package managers
# apt-get install helm kubectl
# yum install helm kubectl

# Verify installations
helm version
kubectl version --client
```

### Clone and Setup

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/helm-mcp-stack.git
cd helm-mcp-stack

# Add upstream remote
git remote add upstream https://github.com/example/helm-mcp-stack.git
```

### Local Development

```bash
# Lint the chart
make lint

# Template the chart to see generated YAML
make template-staging

# Test in a local cluster (minikube, kind, etc.)
make install-staging

# Make your changes, then test again
make upgrade-staging
```

## Testing

### Linting

```bash
# Run Helm lint
make lint

# Should output: "==> Linting ."
```

### Template Testing

```bash
# Test staging values
make template-staging > staging-output.yaml

# Test production values
make template-production > production-output.yaml

# Review the generated YAML
cat staging-output.yaml
```

### Dry Run

```bash
# Dry run installation
make dry-run-staging

# Check for any errors in the output
```

### Integration Testing

```bash
# Install in a test namespace
helm install test-release . \
  -f values-staging.yaml \
  -n test-mcp \
  --create-namespace

# Verify deployment
kubectl get all -n test-mcp

# Clean up
helm uninstall test-release -n test-mcp
kubectl delete namespace test-mcp
```

### Testing Checklist

Before submitting a PR, ensure:

- [ ] `make lint` passes without errors
- [ ] `make template-staging` generates valid YAML
- [ ] `make template-production` generates valid YAML
- [ ] Dry run succeeds for both environments
- [ ] Chart installs successfully in a test cluster
- [ ] All enabled services start successfully
- [ ] Secrets are properly synced from Infisical
- [ ] Ingress routes work correctly
- [ ] HPA scales as expected (if enabled)
- [ ] Health checks function properly
- [ ] Documentation is updated

## Pull Request Process

1. **Update Documentation**: Ensure README, QUICKSTART, or other docs are updated
2. **Update CHANGELOG**: Add your changes to the [Unreleased] section
3. **Test Thoroughly**: Follow the testing checklist above
4. **Keep PRs Focused**: One feature/fix per PR
5. **Write Clear Commit Messages**: Use conventional commits format
6. **Request Review**: Tag maintainers for review

### PR Template

```markdown
## Description
Brief description of the changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Linting passes
- [ ] Templates generate correctly
- [ ] Tested in staging environment
- [ ] Tested in production environment

## Checklist
- [ ] Documentation updated
- [ ] CHANGELOG updated
- [ ] Tests pass
- [ ] No breaking changes (or documented if necessary)

## Additional Notes
Any additional information reviewers should know
```

## Style Guidelines

### YAML Formatting

```yaml
# Use 2 spaces for indentation
global:
  namespace: example
  
# Add comments for complex configurations
services:
  api:
    # API service with HPA enabled
    enabled: true
    
# Group related settings
autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 10
```

### Template Formatting

```yaml
# Use consistent spacing in templates
{{- range $name, $service := .Values.services }}
{{- if $service.enabled }}
---
apiVersion: apps/v1
kind: Deployment
# ...
{{- end }}
{{- end }}
```

### Helper Function Naming

```go
// Use descriptive names with project prefix
{{- define "mcp.secretStoreName" -}}
{{- define "mcp.ingressHost" -}}
{{- define "mcp.image" -}}
```

### Documentation Style

```markdown
# Use clear headings
## Second Level
### Third Level

# Code blocks with language
```yaml
key: value
```

# Bullet points for lists
- Item 1
- Item 2

# Bold for emphasis
**Important**: This is important

# Links
[Link Text](URL)
```

### Git Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add support for StatefulSets
fix: correct HPA metrics configuration
docs: update README with new examples
refactor: simplify ingress template logic
test: add integration tests for secrets
chore: update dependencies
```

## Areas for Contribution

### High Priority
- [ ] Integration tests
- [ ] StatefulSet support
- [ ] Pod Disruption Budgets
- [ ] Network Policies
- [ ] Security Contexts

### Medium Priority
- [ ] ServiceMonitor for Prometheus
- [ ] VPA support
- [ ] Multi-container pods
- [ ] Init containers
- [ ] ConfigMap management

### Documentation
- [ ] Video tutorials
- [ ] Migration guides
- [ ] Architecture diagrams
- [ ] Best practices guides
- [ ] FAQ section

### Examples
- [ ] More service examples (PostgreSQL, RabbitMQ, etc.)
- [ ] Advanced HPA configurations
- [ ] Multi-region deployment
- [ ] Disaster recovery setup

## Questions?

Feel free to reach out:
- Create an issue for questions
- Email: devops@p2pmmo.vn
- Join our community discussions

## License

By contributing, you agree that your contributions will be licensed under the same license as the project.

---

Thank you for contributing to MCP Stack! 🚀
