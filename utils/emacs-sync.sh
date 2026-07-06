#!/usr/bin/env sh

set -euo pipefail

TOKEN=""

request() {
    curl -H "Authorization: Bearer ${TOKEN}" -sSL \
         https://api.github.com/repos/radionoisee/ebuild/actions/"$1"
}

RAW=$(request runs/$(request workflows/build.yml/runs | jq -r .workflow_runs[0].id)/artifacts)

PS3="Which to download? "
select NAME in $(echo "${RAW}" | jq -r .artifacts[].name); do
    if [ -n "${NAME}" ]; then
        URL=$(echo "${RAW}" | jq -r ".artifacts[] | select(.name == \"${NAME}\") | .archive_download_url")
        break
    fi
done

curl -H "Authorization: Bearer ${TOKEN}" -fLo Emacs.tar.xz "${URL}"

unzip -o Emacs.tar.xz
tar -Jxf Emacs.tar.xz

xattr -rd com.apple.quarantine Emacs.app

rm -rf /Applications/Emacs.app
ditto Emacs.app /Applications/Emacs.app

rm -rf Emacs.tar.xz Emacs.app
