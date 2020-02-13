{{/* vim: set filetype=mustache: */}}
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
          value: {{ .Values.minio.defaultBucket.name }}
        - name: S3ACCESSKEY
          valueFrom:
            secretKeyRef:
              name: {{ .Release.Name }}-minio
              key: accesskey
        - name: S3SECRETACCESSKEY
          valueFrom:
            secretKeyRef:
              name: {{ .Release.Name }}-minio
              key: secretkey
        - name: S3ENDPOINTURL
          value: "http://{{ .Release.Name }}-minio:9000"
{{- else if .Values.s3.enable }}
        - name: S3ENABLE
          value: "true"
        - name: S3BUCKET
          value: "{{ .Values.s3.bucket }}"
  {{- if .Values.s3.accessKey }}
        - name: S3ACCESSKEY
          value: "{{ .Values.s3.accessKey }}"
  {{- end }}
  {{- if .Values.s3.secretKey }}
        - name: S3SECRETACCESSKEY
          value: "{{ .Values.s3.secretKey }}"
  {{- end }}
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
        - name: AZUREACCOUNTKEY
          value: "{{ .Values.azure.accountKey }}"
        - name: AZUREACCOUNTNAME
          value: "{{ .Values.azure.accountName }}"
        - name: AZURECONTAINER
          value: "{{ .Values.azure.container }}"
{{- end }}
{{- if .Values.inClusterPostgres }}
        - name: DBHOST
          value: "{{ .Release.Name }}-postgres-service"
{{- else if .Values.db.host }}
        - name: DBHOST
          value: "{{ .Values.db.host }}"
{{- end }}
        - name: DBNAME
          value: "{{ .Values.db.name }}"
        - name: DBUSER
          value: "{{ .Values.db.user }}"
        - name: DBPASSWORD
          value: "{{ .Values.db.password }}"
{{- if .Values.db.port }}
        - name: DBPORT
          value: "{{ .Values.db.port }}"
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
{{- if .Values.inClusterRedis }}
        - name: REDIS
          value: "redis://{{ .Release.Name }}-redis-service"
{{- else if .Values.redisURL }}
        - name: REDIS
          value: "{{ .Values.redisURL }}"
{{- end }}
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
{{- if .Values.inClusterRabbitMQ }}
        - name: RABBITMQ
          value: "pyamqp://user:{{ .Values.rabbitmq.rabbitmq.password }}@{{ .Release.Name }}-rabbitmq//"
{{- else if .Values.amqpURL }}
        - name: RABBITMQ
          value: "{{ .Values.amqpURL }}"
{{- end }}
        - name: LOGSERVER
          value: "{{ .Release.Name }}-docassemble-backend-service"
        - name: RELEASENAME
          value: "{{ .Release.Name }}"
        - name: CHART_VERSION
          value: "{{ .Chart.Version }}"
        - name: DAALLOWUPDATES
          value: "{{ .Values.daAllowUpdates }}"
{{- end -}}