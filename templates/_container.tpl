{{- define "application.container" }}
- name: {{ include "application.fullname" . }}
  {{- if .Values.container.command }}
  {{- with .Values.container.command }}
  command:
    - "/bin/sh"
    - "-c"
    - "{{ . }}"
  {{- end }}
  {{- end }}
  {{- if .Values.image.args }}
  args:
    {{- toYaml .Values.image.args | nindent 2 }}
  {{- end }}
  image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
  imagePullPolicy: {{ .Values.image.pullPolicy | default "Always" }}
  {{- if .Values.extraEnv.enabled }}
  env:
    {{ include "env.extraEnv" . | nindent 4 }}
  {{- end }}
  {{- if .Values.envFromSecret.enabled }}
  envFrom:
    {{ include "env.secret" . | nindent 4 }}
  {{- end }}
  {{- if .Values.envFromFile.enabled }}
  volumeMounts:
    {{ include "env.volumeMount" . | nindent 4  }}
  {{- end }}
  {{- with .Values.containerSecurityContext }}
  securityContext:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  ports:
    {{- range $key, $value := .Values.containerPort }}
    - containerPort: {{ $value }}
      name: {{ $key | default "http" }}
      protocol: {{ default "TCP" }}
    {{- end }}
  {{- if .Values.kubeProbe.enabled }}
  {{- with .Values.kubeProbe.liveness }}
  livenessProbe:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.kubeProbe.readiness }}
  readinessProbe:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.kubeProbe.statrupProbe }}
  startupProbe:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- end }}
  {{- with .Values.resource.value }}
  resources:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- end }}
