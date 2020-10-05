#!/usr/bin/env zsh

if [ -z "${TG_TOKEN}" ]; then
	echo "🛑 TG_TOKEN is not set!"
	exit 1
fi

VALUES=$(
	cat <<-EOF
		env:
		  tg_token: ${TG_TOKEN}
		  db_name: defaultdb
		  db_user: root
		  db_host: cockroachdb-public
		  db_port: '26257'
		  db_sslmode: disable
		  secret_manager: IN_MEMORY
	EOF
)

FLUENT_HOST="''"

if [ -n "${ENABLE_FLUENT}" ]; then
	FLUENT_HOST=fluentd
fi

OBSERVABILITY_EXPORTER="''"

if [ -n "${ENABLE_PROMETHEUS}" ]; then
	OBSERVABILITY_EXPORTER=PROMETHEUS
fi

VALUES=$(
	cat <<-EOF
		${VALUES}
		  fluent_host: $FLUENT_HOST
		  fluent_port: '24231'
		  observability_exporter: $OBSERVABILITY_EXPORTER
	EOF
)

echo $VALUES | tee ~/data/tgbot-values.yaml
