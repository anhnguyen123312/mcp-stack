.PHONY: help lint template install-staging install-production uninstall test package

# Variables
CHART_NAME := mcp-stack
NAMESPACE := p2pmmo-secrets
RELEASE_NAME := mcp-stack

help: ## Show this help message
	@echo "Usage: make [target]"
	@echo ""
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'

lint: ## Lint the Helm chart
	@echo "🔍 Linting Helm chart..."
	helm lint .

template-staging: ## Template the chart with staging values
	@echo "📝 Templating chart with staging values..."
	helm template $(RELEASE_NAME) . \
		-f values-staging.yaml \
		--namespace $(NAMESPACE)

template-production: ## Template the chart with production values
	@echo "📝 Templating chart with production values..."
	helm template $(RELEASE_NAME) . \
		-f values-production.yaml \
		--namespace $(NAMESPACE)

dry-run-staging: ## Dry run install with staging values
	@echo "🧪 Dry run install with staging values..."
	helm install $(RELEASE_NAME) . \
		-f values-staging.yaml \
		--namespace $(NAMESPACE) \
		--create-namespace \
		--dry-run \
		--debug

dry-run-production: ## Dry run install with production values
	@echo "🧪 Dry run install with production values..."
	helm install $(RELEASE_NAME) . \
		-f values-production.yaml \
		--namespace $(NAMESPACE) \
		--create-namespace \
		--dry-run \
		--debug

install-staging: ## Install the chart with staging values
	@echo "🚀 Installing Helm chart with staging values..."
	helm upgrade --install $(RELEASE_NAME) . \
		-f values-staging.yaml \
		--namespace $(NAMESPACE) \
		--create-namespace

install-production: ## Install the chart with production values
	@echo "🚀 Installing Helm chart with production values..."
	helm upgrade --install $(RELEASE_NAME) . \
		-f values-production.yaml \
		--namespace $(NAMESPACE) \
		--create-namespace

upgrade-staging: ## Upgrade the chart with staging values
	@echo "⬆️  Upgrading Helm chart with staging values..."
	helm upgrade $(RELEASE_NAME) . \
		-f values-staging.yaml \
		--namespace $(NAMESPACE)

upgrade-production: ## Upgrade the chart with production values
	@echo "⬆️  Upgrading Helm chart with production values..."
	helm upgrade $(RELEASE_NAME) . \
		-f values-production.yaml \
		--namespace $(NAMESPACE)

uninstall: ## Uninstall the Helm release
	@echo "🗑️  Uninstalling Helm release..."
	helm uninstall $(RELEASE_NAME) --namespace $(NAMESPACE)

status: ## Show the status of the Helm release
	@echo "📊 Helm release status..."
	helm status $(RELEASE_NAME) --namespace $(NAMESPACE)

list: ## List all Helm releases
	@echo "📋 Listing Helm releases..."
	helm list --namespace $(NAMESPACE)

get-values: ## Get the values of the installed release
	@echo "📄 Getting values of installed release..."
	helm get values $(RELEASE_NAME) --namespace $(NAMESPACE)

history: ## Show the history of the Helm release
	@echo "📜 Helm release history..."
	helm history $(RELEASE_NAME) --namespace $(NAMESPACE)

rollback: ## Rollback to the previous revision
	@echo "⏪ Rolling back to previous revision..."
	helm rollback $(RELEASE_NAME) --namespace $(NAMESPACE)

test: ## Run Helm tests
	@echo "🧪 Running Helm tests..."
	helm test $(RELEASE_NAME) --namespace $(NAMESPACE)

package: ## Package the Helm chart
	@echo "📦 Packaging Helm chart..."
	helm package .

# Kubernetes commands
k8s-pods: ## List all pods
	@echo "📦 Listing pods..."
	kubectl get pods -n $(NAMESPACE)

k8s-services: ## List all services
	@echo "🔌 Listing services..."
	kubectl get services -n $(NAMESPACE)

k8s-ingress: ## List all ingresses
	@echo "🌐 Listing ingresses..."
	kubectl get ingress -n $(NAMESPACE)

k8s-hpa: ## List all HPAs
	@echo "📈 Listing HPAs..."
	kubectl get hpa -n $(NAMESPACE)

k8s-pvc: ## List all PVCs
	@echo "💾 Listing PVCs..."
	kubectl get pvc -n $(NAMESPACE)

k8s-secrets: ## List all secrets
	@echo "🔐 Listing secrets..."
	kubectl get secrets -n $(NAMESPACE)

k8s-secretstores: ## List all secret stores
	@echo "🏪 Listing secret stores..."
	kubectl get secretstores -n $(NAMESPACE)

k8s-externalsecrets: ## List all external secrets
	@echo "🔑 Listing external secrets..."
	kubectl get externalsecrets -n $(NAMESPACE)

k8s-all: ## List all resources
	@echo "📋 Listing all resources..."
	kubectl get all,ingress,hpa,pvc,secrets,secretstores,externalsecrets -n $(NAMESPACE)

logs: ## Show logs for a specific service (usage: make logs SERVICE=api-service)
	@if [ -z "$(SERVICE)" ]; then \
		echo "❌ Error: SERVICE variable is required"; \
		echo "Usage: make logs SERVICE=api-service"; \
		exit 1; \
	fi
	@echo "📝 Showing logs for $(SERVICE)..."
	kubectl logs -f -n $(NAMESPACE) -l app.kubernetes.io/name=$(SERVICE)

describe: ## Describe a specific service (usage: make describe SERVICE=api-service)
	@if [ -z "$(SERVICE)" ]; then \
		echo "❌ Error: SERVICE variable is required"; \
		echo "Usage: make describe SERVICE=api-service"; \
		exit 1; \
	fi
	@echo "🔍 Describing $(SERVICE)..."
	kubectl describe deployment $(SERVICE) -n $(NAMESPACE)

port-forward: ## Port forward to a service (usage: make port-forward SERVICE=api-service PORT=8080)
	@if [ -z "$(SERVICE)" ]; then \
		echo "❌ Error: SERVICE variable is required"; \
		echo "Usage: make port-forward SERVICE=api-service PORT=8080"; \
		exit 1; \
	fi
	@if [ -z "$(PORT)" ]; then \
		echo "❌ Error: PORT variable is required"; \
		echo "Usage: make port-forward SERVICE=api-service PORT=8080"; \
		exit 1; \
	fi
	@echo "🔌 Port forwarding $(SERVICE):$(PORT)..."
	kubectl port-forward -n $(NAMESPACE) svc/$(SERVICE) $(PORT):$(PORT)

clean: ## Clean up generated files
	@echo "🧹 Cleaning up..."
	rm -rf *.tgz

verify-staging: ## Verify staging installation
	@echo "✅ Verifying staging installation..."
	@echo "\n📦 Checking deployments..."
	kubectl get deployments -n $(NAMESPACE)
	@echo "\n🔐 Checking secrets..."
	kubectl get externalsecrets -n $(NAMESPACE)
	@echo "\n🌐 Checking ingresses..."
	kubectl get ingress -n $(NAMESPACE)
	@echo "\n📊 Checking HPAs..."
	kubectl get hpa -n $(NAMESPACE)

verify-production: verify-staging ## Verify production installation (alias)
