{{/*
차트 이름
*/}}
{{- define "example-nestjs-api.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
전체 이름 생성 (release-name + chart-name)
*/}}
{{- define "example-nestjs-api.fullname" -}}
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
차트 라벨
*/}}
{{- define "example-nestjs-api.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
공통 라벨
*/}}
{{- define "example-nestjs-api.labels" -}}
helm.sh/chart: {{ include "example-nestjs-api.chart" . }}
{{ include "example-nestjs-api.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
셀렉터 라벨
*/}}
{{- define "example-nestjs-api.selectorLabels" -}}
app.kubernetes.io/name: {{ include "example-nestjs-api.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
