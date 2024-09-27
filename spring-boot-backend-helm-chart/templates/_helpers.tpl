{{- define "spring-app.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "spring-app.labels" -}}
app.kubernetes.io/name: {{ include "spring-app.name" . }}
helm.sh/chart: {{ include "spring-app.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "spring-app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "spring-app.chart" -}}
{{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{- end -}}

{{- define "spring-app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "spring-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
