#!/bin/bash

script=$(basename "$0")

if [ -z "$1" ] || [ "$1" = "-h" ]; then
    echo "使用方法: sudo $script [アプリケーション]"
    exit 0
fi

IFS=$'\n'

crucial=$(tput setaf 1)
normal=$(tput sgr0)

if [ ! -e "$1/Contents/Info.plist" ]; then
    echo " ! アプリケーションのplistが見つかりません"
    exit 1
fi

bundle=$(/usr/libexec/PlistBuddy -c "Print CFBundleIdentifier" "$1/Contents/Info.plist" 2>/dev/null)

if [ "$bundle" = "" ]; then
    echo " ! アプリケーションのバンドル識別子が見つかりません"
    exit 1
fi

app=$(basename "$1" .app)

echo " * 実行中のプロセスを確認中"
sleep 1

processes=($(pgrep -afil "$app" | grep -v "$script"))

if [ ${#processes[@]} -gt 0 ]; then
    printf "%s\n" "${processes[@]}"
    printf "$crucial%s$normal" " ! 実行中のプロセスを終了しますか？(yまたはn): "
    read -r answer
    if [ "$answer" = "y" ]; then
        echo " * プロセスを終了しています"
        sleep 1
        for process in "${processes[@]}"; do
            kill "$(echo "$process" | awk '{print $1}')" 2>/dev/null
        done
    fi
fi

echo " * Bill of Materialログをデスクトップに保存中"
sleep 1

paths=()
paths+=($(find /private/var/db/receipts -iname "*$app*.bom" -maxdepth 1 -prune 2>/dev/null))
paths+=($(find /private/var/db/receipts -iname "*$bundle*.bom" -maxdepth 1 -prune 2>/dev/null))

if [ ${#paths[@]} -gt 0 ]; then
    mkdir -p "$HOME/Desktop/$app"
    for path in "${paths[@]}"; do
        lsbom -f -l -s -p f "$path" > "$HOME/Desktop/$app/$(basename "$path").log"
    done
fi

echo " * アプリケーションデータを検索中"
sleep 1

locations=(
    "$HOME/Library"
    "$HOME/Library/Application Scripts"
    "$HOME/Library/Application Support"
    "$HOME/Library/Application Support/CrashReporter"
    "$HOME/Library/Containers"
    "$HOME/Library/Caches"
    "$HOME/Library/HTTPStorages"
    "$HOME/Library/Group Containers"
    "$HOME/Library/Internet Plug-Ins"
    "$HOME/Library/LaunchAgents"
    "$HOME/Library/Logs"
    "$HOME/Library/Preferences"
    "$HOME/Library/Preferences/ByHost"
    "$HOME/Library/Saved Application State"
    "$HOME/Library/WebKit"
    "/Library"
    "/Library/Application Support"
    "/Library/Application Support/CrashReporter"
    "/Library/Caches"
    "/Library/Extensions"
    "/Library/Internet Plug-Ins"
    "/Library/LaunchAgents"
    "/Library/LaunchDaemons"
    "/Library/Logs"
    "/Library/Preferences"
    "/Library/PrivilegedHelperTools"
    "/private/var/db/receipts"
    "/usr/local/bin"
    "/usr/local/etc"
    "/usr/local/opt"
    "/usr/local/sbin"
    "/usr/local/share"
    "/usr/local/var"
    "$(getconf DARWIN_USER_CACHE_DIR | sed "s/\/$//")"
    "$(getconf DARWIN_USER_TEMP_DIR | sed "s/\/$//")"
)

paths=("$1")

for location in "${locations[@]}"; do
    paths+=($(find "$location" -iname "*$app*" -or -iname "*$bundle*" -maxdepth 1 -prune 2>/dev/null))
done

paths=($(printf "%s\n" "${paths[@]}" | sort -u))
printf "%s\n" "${paths[@]}"

printf "$crucial%s$normal" " ! アプリケーションデータをゴミ箱に移動しますか？(yまたはn): "
read -r answer
if [ "$answer" = "y" ]; then
    echo " * アプリケーションデータをゴミ箱に移動しています"
    sleep 1
    files=$(printf ", POSIX file \"%s\" as alias" "${paths[@]}" | awk '{print substr($0,3)}')
    osascript -e "tell application \"Finder\" to delete { $files }" >/dev/null
    echo " * 完了しました"
fi
