#!/usr/bin/env zsh

if [ -z "${TG_TOKEN}" ]; then
	echo "🛑 TG_TOKEN is not set!"
	exit 1
fi

(
	cat <<-EOF
		env:
		  tg_token: ${TG_TOKEN}
		  db_name: defaultdb
		  db_user: root
		  db_host: cockroachdb-0.cockroachdb
		  db_port: "26257"
		  db_sslmode: disable
		  secret_manager: IN_MEMORY
	EOF
) | tee ~/data/tgbot-values.yaml
