{{/* vim: set filetype=mustache: */}}

{{/* 
Determine the Pod annotations used in the controller 
*/}}
{{- define "env.fromSecret" }}
{{ $namespace := include "common.namespace" . }}
{{ $app := include "application.fullname" . }}
{{ if .Values.envFromSecret.enabled }}
{{ if .Values.envFromSecret.secretNames }}
{{- range $key := .Values.envFromSecret.secretNames }}
- extract:
    key: {{ $key | default $app }}
{{ end }}
{{ end }}
{{ end }}
{{- end }}

{{/* 
secret environment variables from a file
*/}}
{{- define "env.fromFile" }}
{{ $namespace := include "common.namespace" . }}
{{ $app := include "application.fullname" . }}
{{ if .Values.envFromFile.enabled }}
{{ if .Values.envFromFile.secretNames }}
{{- range $key := .Values.envFromFile.secretNames }}
- secretKey: {{ $key }}
  remoteRef:
    key: {{ $app }}
    property: {{ $key }}
{{ end }}
{{ end }}
{{ end }}
{{- end }}


{{/* 
Determine the Pod annotations used in the controller 
*/}}
{{- define "env.secret" }}
{{ $app := include "application.fullname" . }}
{{ if .Values.envFromSecret.enabled }}
- secretRef:
    name: {{ $app }}
{{ end }}
{{- end }}



{{/* 
Determine the Pod annotations used in the controller 
*/}}
{{- define "env.volumeMount" }}
{{ $app := include "application.fullname" . }}
{{- if .Values.envFromFile.enabled }}
{{ range $key := .Values.envFromFile.secretNames }}
- name: {{ $app }}
  mountPath: /app/{{ $key }}
  subPath: {{ $key  }}
  readOnly: true
{{ end }}
{{- end }}
{{- end }}


{{/* 
Determine the Pod annotations used in the controller 
*/}}
{{- define "env.volumes" }}
{{ $app := include "application.fullname" . }}
{{- if .Values.envFromFile.enabled }}
{{ range $key := .Values.envFromFile.secretNames }}
- name: {{ $app }}
  secret:
    secretName: {{ $app }}
    items:
      - key: {{ $key }}
        path: {{ $key }}
{{ end }}
{{- end }}
{{- end }}

{{/* 
Determine the Pod annotations used in the controller 
*/}}
{{- define "env.extraEnv" }}
{{ $app := include "application.fullname" . }}
{{- if .Values.extraEnv.enabled }}
{{- range $key, $value := .Values.extraEnv.values }}
- name: "{{- $key }}"
  value: "{{- $value }}"
{{- end }}
{{- end }}
{{- end }}


