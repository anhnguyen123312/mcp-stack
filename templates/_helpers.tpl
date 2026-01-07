{{/*
Expand the name of the chart.
*/}}
{{- define "mcp.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "mcp.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "mcp.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "mcp.labels" -}}
helm.sh/chart: {{ include "mcp.chart" . }}
{{ include "mcp.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
environment: {{ .Values.global.environment }}
{{- end }}

{{/*
Selector labels for a specific service
*/}}
{{- define "mcp.selectorLabels" -}}
app.kubernetes.io/name: {{ .name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Generate full image path
Supports tag, digest, and per-mcp registry override
*/}}
{{- define "mcp.image" -}}
{{- $global := .global -}}
{{- $mcp := .mcp -}}
{{- $registry := default $global.image.registry $mcp.image.registry -}}
{{- $repository := $mcp.image.repository -}}
{{- if $mcp.image.digest }}
  {{- printf "%s/%s@%s" $registry $repository $mcp.image.digest -}}
{{- else if $mcp.image.tag }}
  {{- printf "%s/%s:%s" $registry $repository $mcp.image.tag -}}
{{- else }}
  {{- printf "%s/%s:latest" $registry $repository -}}
{{- end }}
{{- end }}

{{/*
Generate ingress host
Pattern: mcp-<name>.<env>.<domain> or mcp-<name>.<domain> for production
*/}}
{{- define "mcp.ingressHost" -}}
{{- $name := .name -}}
{{- $mcp := .mcp -}}
{{- $env := .global.environment -}}
{{- $domain := .global.domain -}}
{{- if $mcp.ingress.host }}
  {{- $mcp.ingress.host -}}
{{- else if eq $env "production" }}
  {{- printf "mcp-%s.%s" $name $domain -}}
{{- else }}
  {{- printf "mcp-%s.%s.%s" $name $env $domain -}}
{{- end }}
{{- end }}

{{/*
Generate secret store name
*/}}
{{- define "mcp.secretStoreName" -}}
{{- if and .mcp.secret .mcp.secret.store .mcp.secret.store.name }}
  {{- .mcp.secret.store.name -}}
{{- else }}
  {{- printf "infisical-store-%s" .name -}}
{{- end }}
{{- end }}

{{/*
Generate external secret name
*/}}
{{- define "mcp.externalSecretName" -}}
{{- if and .mcp.secret .mcp.secret.externalSecret .mcp.secret.externalSecret.name }}
  {{- .mcp.secret.externalSecret.name -}}
{{- else }}
  {{- printf "external-secret-%s" .name -}}
{{- end }}
{{- end }}

{{/*
Generate environment slug for Infisical
*/}}
{{- define "mcp.environmentSlug" -}}
{{- if and .mcp.secret .mcp.secret.store .mcp.secret.store.environmentSlug }}
  {{- .mcp.secret.store.environmentSlug -}}
{{- else }}
  {{- .global.environment -}}
{{- end }}
{{- end }}

{{/*
Merge probe configuration with defaults
*/}}
{{- define "mcp.probe" -}}
{{- $default := .default -}}
{{- $override := .override -}}
{{- if $override.enabled }}
{{- if $override.httpGet }}
httpGet:
  path: {{ $override.httpGet.path }}
  port: {{ $override.httpGet.port }}
  {{- with $override.httpGet.scheme }}
  scheme: {{ . }}
  {{- end }}
  {{- with $override.httpGet.httpHeaders }}
  httpHeaders:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- else if $override.tcpSocket }}
tcpSocket:
  port: {{ $override.tcpSocket.port }}
{{- else if $override.exec }}
exec:
  command:
    {{- toYaml $override.exec.command | nindent 4 }}
{{- end }}
initialDelaySeconds: {{ default $default.initialDelaySeconds $override.initialDelaySeconds }}
periodSeconds: {{ default $default.periodSeconds $override.periodSeconds }}
timeoutSeconds: {{ default $default.timeoutSeconds $override.timeoutSeconds }}
successThreshold: {{ default $default.successThreshold $override.successThreshold }}
failureThreshold: {{ default $default.failureThreshold $override.failureThreshold }}
{{- end }}
{{- end }}

{{/*
Generate storage class name
*/}}
{{- define "mcp.storageClassName" -}}
{{- if .mcp.persistence.storageClassName }}
  {{- .mcp.persistence.storageClassName -}}
{{- else }}
  {{- .global.storage.className -}}
{{- end }}
{{- end }}

{{/*
Generate ingress class name
*/}}
{{- define "mcp.ingressClassName" -}}
{{- if .mcp.ingress.className }}
  {{- .mcp.ingress.className -}}
{{- else }}
  {{- .global.ingress.className -}}
{{- end }}
{{- end }}

{{/*
Merge resources with defaults
*/}}
{{- define "mcp.resources" -}}
{{- $global := .global.resources -}}
{{- $mcp := .mcp.resources -}}
{{- if $mcp }}
requests:
  cpu: {{ default $global.requests.cpu $mcp.requests.cpu }}
  memory: {{ default $global.requests.memory $mcp.requests.memory }}
limits:
  cpu: {{ default $global.limits.cpu $mcp.limits.cpu }}
  memory: {{ default $global.limits.memory $mcp.limits.memory }}
{{- else }}
{{- toYaml $global }}
{{- end }}
{{- end }}

{{/*
Check if service should create secrets
*/}}
{{- define "mcp.shouldCreateSecret" -}}
{{- if and .mcp (kindIs "map" .mcp) .mcp.secret (kindIs "map" .mcp.secret) .mcp.secret.create }}
  {{- true -}}
{{- else }}
  {{- false -}}
{{- end }}
{{- end }}

{{/*
Get image pull policy
*/}}
{{- define "mcp.imagePullPolicy" -}}
{{- if .mcp.image.pullPolicy }}
  {{- .mcp.image.pullPolicy -}}
{{- else }}
  {{- .global.image.pullPolicy -}}
{{- end }}
{{- end }}

{{/*
Get port (use mcp.port if defined, otherwise use global.defaultPort)
*/}}
{{- define "mcp.port" -}}
{{- if .mcp.port }}
  {{- .mcp.port -}}
{{- else }}
  {{- .global.defaultPort -}}
{{- end }}
{{- end }}
