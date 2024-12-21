#!/bin/sh

# Admin helpers for the self-hosted pastebin KV namespace.
# Usage: scripts/kv.sh [list|hist|curl-delete]

set -e
set -u

script_dir=$(cd "$(dirname "$0")" && pwd)
repo_root=$(dirname "${script_dir}")
cd "${repo_root}" || exit 1

deploy_url="${PB_DOMAIN:-https://komj.uk}"
binding=PB
action="${1:-list}"

list_pastes() {
	pnpm exec wrangler kv key list --binding "${binding}"
}

case "${action}" in
list | list-pastes)
	list_pastes
	;;
hist | pb_hist)
	list_json=$(list_pastes)
	printf '%s\n' "${list_json}" | jq -r '.[] | "\(.name):\(.metadata.passwd)"'
	;;
curl-delete)
	list_json=$(list_pastes)
	printf '%s\n' "${list_json}" | jq -r --arg url "${deploy_url}" '.[] | "curl -XDELETE \($url)/\(.name):\(.metadata.passwd)"'
	;;
*)
	printf 'Usage: %s [list|hist|curl-delete]\n' "$0" >&2
	exit 2
	;;
esac
