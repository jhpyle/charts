{{- define "docassemble.commonEnvironment" -}}
        - name: ENVIRONMENT_TAKES_PRECEDENCE
          value: "true"
        - name: COLLECTSTATISTICS
          value: "true"
        - name: KUBERNETES
          value: "true"
        - name: DAHOSTNAME
          value: {{ .Values.daHostname }}
        - name: TIMEZONE
          value: {{ .Values.timeZone }}
{{- if .Values.locale }}
        - name: LOCALE
          value: {{ .Values.locale }}
{{- end }}
        - name: DAPYTHONVERSION
          value: "3"
{{- if .Values.inClusterMinio }}
        - name: S3ENABLE
          value: "true"
        - name: S3BUCKET
          value: "docassemble-bucket"
        - name: S3ACCESSKEY
          valueFrom:
            secretKeyRef:
              name: {{ .Release.Name }}-minio-creds-secret
              key: accesskey
        - name: S3SECRETACCESSKEY
          valueFrom:
            secretKeyRef:
              name: {{ .Release.Name }}-minio-creds-secret
              key: secretkey
        - name: S3ENDPOINTURL
          value: "http://{{ .Release.Name }}-minio:9000"
{{- else if .Values.s3.enable }}
        - name: S3ENABLE
          value: "true"
        - name: S3BUCKET
          value: "{{ .Values.s3.bucket }}"
  {{- if .Values.s3.region }}
        - name: S3REGION
          value: "{{ .Values.s3.region }}"
  {{- end }}
  {{- if .Values.s3.endpointURL }}
        - name: S3ENDPOINTURL
          value: "{{ .Values.s3.endpointURL }}"
  {{- end }}
{{- else if .Values.azure.enable }}
        - name: AZUREENABLE
          value: "true"
        - name: AZUREACCOUNTNAME
          value: "{{ .Values.azure.accountName }}"
        - name: AZURECONTAINER
          value: "{{ .Values.azure.container }}"
{{- end }}
{{- if .Values.inClusterPostgres }}
        - name: DBHOST
          value: "{{ .Release.Name }}-postgresql"
{{- else if .Values.db.host }}
        - name: DBHOST
          value: "{{ .Values.db.host }}"
{{- end }}
{{- if .Values.inClusterPostgres }}
        - name: DBNAME
          value: "{{ .Values.postgresql.auth.database }}"
        - name: DBUSER
          value: "{{ .Values.postgresql.auth.username }}"
        - name: DBPORT
          value: "{{ .Values.postgresql.primary.service.ports.postgresql }}"
{{- else }}
        - name: DBNAME
          value: "{{ .Values.db.name }}"
        - name: DBUSER
          value: "{{ .Values.db.user }}"
  {{- if .Values.db.port }}
        - name: DBPORT
          value: "{{ .Values.db.port }}"
  {{- end }}
{{- end }}
{{- if .Values.db.prefix }}
        - name: DBPREFIX
          value: "{{ .Values.db.prefix }}"
{{- end }}
{{- if .Values.db.tablePrefix }}
        - name: DBTABLEPREFIX
          value: "{{ .Values.db.tablePrefix }}"
{{- end }}
        - name: DBBACKUP
          value: "{{ .Values.db.backup }}"
        - name: USECLOUDURLS
          value: "false"
        - name: DAEXPOSEWEBSOCKETS
{{- if .Values.exposeWebsockets }}
          value: "true"
{{- else }}
          value: "false"
{{- end }}
        - name: BEHINDHTTPSLOADBALANCER
          value: "{{ .Values.usingSslTermination }}"
        - name: LOGSERVER
          value: "{{ .Release.Name }}-docassemble-backend-service"
        - name: RELEASENAME
          value: "{{ .Release.Name }}"
        - name: CHART_VERSION
          value: "{{ .Chart.Version }}"
        - name: DAALLOWUPDATES
          value: "{{ .Values.daAllowUpdates }}"
        - name: DASTABLEVERSION
          value: "{{ .Values.daStableVersion }}"
        - name: USEMINIO
  {{- if .Values.inClusterMinio }}
          value: "true"
  {{- else }}
          value: "false"
  {{- end }}
        - name: DASQLPING
  {{- if .Values.useSqlPing }}
          value: "true"
  {{- else }}
          value: "false"
  {{- end }}
{{- end -}}
{{- define "docassemble.formatImage" -}}
{{- $registryName := .imageRoot.registry -}}
{{- $repositoryName := .imageRoot.repository -}}
{{- $tag := .imageRoot.tag | toString -}}
{{- if .global }}
    {{- if .global.imageRegistry }}
     {{- $registryName = .global.imageRegistry -}}
    {{- end -}}
{{- end -}}
{{- if $registryName }}
{{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- else -}}
{{- printf "%s:%s" $repositoryName $tag -}}
{{- end -}}
{{- end -}}
{{- define "docassemble.postgresql.image" -}}
{{ include "docassemble.formatImage" (dict "imageRoot" .Values.postgresql.image "global" .Values.global) }}
{{- end -}}
{{- define "docassemble.minio.clientImage" -}}
{{ include "docassemble.formatImage" (dict "imageRoot" .Values.minio.clientImage "global" .Values.global) }}
{{- end -}}
{{- define "docassemble.bashImage" -}}
{{ include "docassemble.formatImage" (dict "imageRoot" .Values.bashImage "global" .Values.global) }}
{{- end -}}
{{- define "docassemble.redis.image" -}}
{{ include "docassemble.formatImage" (dict "imageRoot" .Values.redis.image "global" .Values.global) }}
{{- end -}}
{{- define "docassemble.rabbitmq.image" -}}
{{ include "docassemble.formatImage" (dict "imageRoot" .Values.rabbitmq.image "global" .Values.global) }}
{{- end -}}
{{- define "docassemble.daImage" -}}
{{ include "docassemble.formatImage" (dict "imageRoot" .Values.daImage "global" .Values.global) }}
{{- end -}}
{{- define "docassemble.aws-alb-ingress-controller" -}}
{{ include "docassemble.formatImage" (dict "imageRoot" .Values.albImage "global" .Values.global) }}
{{- end -}}
{{- define "docassemble.busyboxImage" -}}
{{ include "docassemble.formatImage" (dict "imageRoot" .Values.busyboxImage "global" .Values.global) }}
{{- end -}}
{{- define "docassemble.daMonitorImage" -}}
{{ include "docassemble.formatImage" (dict "imageRoot" .Values.daMonitorImage "global" .Values.global) }}
{{- end -}}
{{- define "docassemble.redisUrl" -}}
{{- if .Values.redis.auth.enabled -}}
{{- printf "redis://:%s@%s-daredis-master" .Values.redis.auth.password .Release.Name -}}
{{- else -}}
{{- printf "redis://%s-daredis-master" .Release.Name -}}
{{- end -}}
{{- end -}}
