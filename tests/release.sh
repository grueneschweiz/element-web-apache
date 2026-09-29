#!/usr/bin/env bash
set -euo pipefail

REPO_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
TEST_ROOT=$(mktemp -d)
trap 'rm -rf -- "$TEST_ROOT"' EXIT
export GITHUB_REPOSITORY=example/element-web-apache GITHUB_SHA=abc123
export FIXTURE_JSON=${TEST_ROOT}/upstream.json NOTES_COPY=${TEST_ROOT}/notes.md

jq -n --arg digest "sha256:$(printf 'a%.0s' {1..64})" \
    '{tag_name: "v1.12.29", body: "Changes in Element Web\n- Fixed icons", assets: [{name: "element-v1.12.29.tar.gz", digest: $digest}]}' \
    > "${FIXTURE_JSON}"

gh() {
    case "$1 $2" in
        'api repos/element-hq/element-web/releases/latest')
            cat "${FIXTURE_JSON}"
            ;;
        'release view')
            [[ ${RELEASE_EXISTS:-0} == 1 ]]
            ;;
        'release create')
            [[ $3 == element-web-v1.12.29 ]]
            while [[ $# -gt 0 ]]; do
                if [[ $1 == --notes-file ]]; then
                    cp -- "$2" "${NOTES_COPY}"
                    return
                fi
                shift
            done
            return 1
            ;;
        *) return 1 ;;
    esac
}
export -f gh

bash "${REPO_DIR}/scripts/publish-release.sh"
grep -q 'Changes in Element Web' "${NOTES_COPY}"
grep -q 'Fixed icons' "${NOTES_COPY}"
grep -q 'SHA-256: aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' "${NOTES_COPY}"
grep -q 'element-v1.12.29.tar.gz' "${NOTES_COPY}"

rm -- "${NOTES_COPY}"
RELEASE_EXISTS=1 bash "${REPO_DIR}/scripts/publish-release.sh"
[[ ! -e ${NOTES_COPY} ]]

jq '.assets = []' "${FIXTURE_JSON}" > "${TEST_ROOT}/invalid.json"
FIXTURE_JSON=${TEST_ROOT}/invalid.json bash "${REPO_DIR}/scripts/publish-release.sh" >/dev/null 2>&1 && exit 1
echo "Release checks passed"
