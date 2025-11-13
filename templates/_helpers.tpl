{{- define "base-app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{- define "base-app.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else }}
{{- printf "%s-%s" .Release.Name (include "base-app.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end }}
{{- end }}

{{- define "base-app.labels" -}}
app.kubernetes.io/name: {{ include "base-app.name" . }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "base-app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "base-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "base-app.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "base-app.fullname" .) .Values.serviceAccount.name -}}
{{- else }}
{{- default "default" .Values.serviceAccount.name -}}
{{- end }}
{{- end }}

{{- define "base-app.image" -}}
{{- $global := .Values.global.image -}}
{{- $img := .image | default dict -}}
{{- $repository := default $global.repository $img.repository -}}
{{- $tag := default $global.tag $img.tag -}}
{{- $pullPolicy := default $global.pullPolicy $img.pullPolicy -}}
repository: {{ $repository | quote }}
tag: {{ $tag | quote }}
pullPolicy: {{ $pullPolicy | quote }}
{{- end }}
