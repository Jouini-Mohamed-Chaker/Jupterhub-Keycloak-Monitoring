{{- define "keycloak-stack.postgresql.fullname" -}}
{{ .Release.Name }}-postgresql
{{- end -}}

{{- define "keycloak-stack.postgresql.serviceName" -}}
{{ include "keycloak-stack.postgresql.fullname" . }}
{{- end -}}

{{- define "keycloak-stack.postgresql.secretName" -}}
{{ include "keycloak-stack.postgresql.fullname" . }}-credentials
{{- end -}}