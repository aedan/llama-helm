{{/*
Expand the chart name.
*/}}
{{- define "llama-cpp.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Fully qualified app name — capped at 63 chars (DNS label limit).
*/}}
{{- define "llama-cpp.fullname" -}}
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
Chart label: <name>-<version>.
*/}}
{{- define "llama-cpp.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels applied to every resource.
*/}}
{{- define "llama-cpp.labels" -}}
helm.sh/chart: {{ include "llama-cpp.chart" . }}
{{ include "llama-cpp.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels (used in matchLabels + Service selectors).
*/}}
{{- define "llama-cpp.selectorLabels" -}}
app.kubernetes.io/name: {{ include "llama-cpp.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Image tag: explicit tag value, falling back to Chart.AppVersion.
*/}}
{{- define "llama-cpp.imageTag" -}}
{{- .Values.image.tag | default .Chart.AppVersion }}
{{- end }}

{{/*
Full image reference.
*/}}
{{- define "llama-cpp.image" -}}
{{- printf "%s:%s" .Values.image.repository (include "llama-cpp.imageTag" .) }}
{{- end }}

{{/*
Secret name (external or chart-managed).
*/}}
{{- define "llama-cpp.secretName" -}}
{{- printf "%s-credentials" (include "llama-cpp.fullname" .) }}
{{- end }}

{{/*
ServiceAccount name used by the coordinator to list pods.
*/}}
{{- define "llama-cpp.serviceAccountName" -}}
{{- printf "%s-coordinator" (include "llama-cpp.fullname" .) }}
{{- end }}
