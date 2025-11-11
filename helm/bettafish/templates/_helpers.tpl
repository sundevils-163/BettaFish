{{- define "bettafish.name" -}}
{{- default .Chart.Name .Values.global.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "bettafish.fullname" -}}
{{- if .Values.global.fullnameOverride -}}
{{- .Values.global.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- include "bettafish.name" . -}}
{{- end -}}
{{- end -}}

{{- define "bettafish.labels" -}}
app.kubernetes.io/name: {{ include "bettafish.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
app.kubernetes.io/part-of: bettafish
{{- end -}}


