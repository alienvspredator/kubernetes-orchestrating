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
		  db_host: cockroachdb
		  db_port: '26257'
		  db_sslmode: disable
		  secret_manager: IN_MEMORY
	EOF
)

if [ -n "${ENABLE_FLUENT}" ]; then
	VALUES=$(
		cat <<-EOF
			${VALUES}
			  fluent_host: fluentd
			  fluent_port: '24231'
		EOF
	)
fi

if [ -n "${ENABLE_PROMETHEUS}" ]; then
	VALUES=$(
		cat <<-EOF
			${VALUES}
			  prometheus_port: '9090'
		EOF
	)
fi

echo $VALUES | tee ~/data/tgbot-values.yaml
