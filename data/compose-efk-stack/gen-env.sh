#!/usr/bin/env zsh

if [ -z "${TG_TOKEN}" ]; then
	echo "🛑 TG_TOKEN is not set!"
	exit 1
fi

(
	cat <<-EOF
		TG_TOKEN=${TG_TOKEN}
	EOF
) | tee .env
