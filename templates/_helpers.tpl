{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "application.name" -}}
{{- if .Values.app.name }}
{{- default .Values.app.name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- default .Values.app.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "application.fullname" -}}
{{- if .Values.app.fullnameOverride }}
{{- .Values.app.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Values.app.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Allow the release namespace to be overridden for multi-namespace deployments in combined charts
*/}}
{{- define "common.namespace" -}}
{{- if .Values.namespaceOverride }}
{{- .Values.namespaceOverride }}
{{- else }}
{{- .Release.Namespace }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{ define "application.chart" }}
{{ printf "%s" .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{ end }}

{{/*
Define common labels to be used across the charts
*/}}
{{- define "common.labels" }}
app.kubernetes.io/name: {{ include "application.fullname" . }}
app.kubernetes.io/managed-by: Helm
app.kubernetes.io/instance: {{ include "application.fullname" . }}
app.kubernetes.io/part-of : {{ include "application.fullname" . }}
app.kubernetes.io/version: {{ .Chart.Version }}
helm.sh/chart: {{ .Values.app.name}}-{{ .Chart.Version }}
meta.helm.sh/release-namespace: {{ include "common.namespace" . }}
meta.helm.shv1.0.0/release-name: {{ .Values.app.name}}-{{ .Chart.Version }}
{{- if .Values.app.defaultLabels }}
{{- range $key, $value := .Values.application.defaultLabels }}
{{ $key }}: {{ $value | quote }}
{{- end }}
{{- end }}
{{ end }}

{{/*
Define common annotations to be used across the charts
*/}}


{{- define "common.annotations" }}
app.kubernetes.io/name: {{ include "application.name" . }}
helm.sh/chart: {{ .Values.app.name}}-{{ .Chart.Version }}
meta.helm.shv1.0.0/release-name: {{ .Values.app.name}}-{{ .Chart.Version }}
meta.helm.sh/release-namespace: {{ include "common.namespace" . }}
{{- if .Values.configReloader.enabled }}
reloader.stakater.com/auto: "true"
{{- end }}
{{- end }}

{{/*
Define annotations for ingress
*/}}
{{- define "ingress.annotations" }}
{{- if .Values.ingress.enabled }}
kubernetes.io/ingress.class: nginx
{{- range $key, $value := .Values.ingress.annotations }}
{{ $key }}: {{ $value | quote }}
{{- end }}
{{- end }}
{{- end }}

{{/*
/*{{- define "ingress.extraPath" }}
/*{{- with .Values.ingress.extraPath }}
/*{{- toYaml . }}
/*{{- end }}
/*{{- end }}
*/}}

/*
alb.ingress.kubernetes.io/tags: Environment={{ include "application.environment" . }},Project=application,Owner=devops
alb.ingress.kubernetes.io/load-balancer-name: {{ printf "application-%s" (include "application.environment" .) }}
*/

{{/*
Determine the Pod annotations used in the controller
*/}}
{{- define "common.podAnnotations" }}
  {{- if .Values.podAnnotations }}
    {{ tpl (toYaml .Values.podAnnotations) . | nindent 0 }}
  {{- end }}
{{- end }}

{{/*
Define common selector to be used across the charts
*/}}
{{- define "common.selectorLabels" -}}
app.kubernetes.io/name: {{ include "application.fullname" . }}
app.kubernetes.io/part-of : {{ include "application.fullname" . }}
{{- end }}


{{- define "application.image" -}}
{{- if .Values.image.repository }}
{{- .Values.image.repository }}
{{- else }}
{{- $registry := default "registry.gitlab.com/innovate-tech" .Values.image.registry -}}
{{- $group := default (include "application.fullname" .) .Values.image.group -}}
{{- if .Values.image.subgroup }}
{{- $group = printf "%s/%s" $group .Values.image.subgroup }}
{{- end -}}
{{- $tag := default "latest" .Values.image.tag -}}
{{- printf "%s/%s:%s" $registry $group $tag }}
{{- end }}
{{- end -}}


{{/*
environment
*/}}
{{- define "application.environment" -}}
{{- default "development" .Values.environment -}}
{{- end -}}

{{/*
find right domain for the environment
*/}}
{{- define "application.domain" -}}
{{- $root := default "test.com" .Values.root_domain -}}
{{- $subdomain := default (include "application.fullname" .) .Values.subdomain -}}
{{- $domains := dict "development" "test.com" -}}
{{- $environment := include "application.environment" . -}}
{{- printf "%s.%s" $subdomain (default (get $domains $environment) $root) -}}
{{- end -}}
