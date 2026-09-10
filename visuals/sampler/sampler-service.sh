#!/bin/sh
set -eu
# One per-user producer. No sudo, Bitwig launch, settings mutation or permission reset.
sampler_source=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
sampler_uid=$(/usr/bin/id -u)
sampler_label=com.kasselvania.pushwig.sampler
sampler_root="$HOME/.pushwig/sampler-producer-v1"
sampler_plist="$HOME/Library/LaunchAgents/$sampler_label.plist"
sampler_job="gui/$sampler_uid/$sampler_label"
fail() { echo "$*" >&2; exit 1; }
private_dir() {
    if [ ! -e "$1" ] && [ ! -L "$1" ]; then /bin/mkdir -m 700 "$1"; fi
    [ -d "$1" ] && [ ! -L "$1" ] && [ "$(/usr/bin/stat -f '%u:%Lp' "$1")" = "$sampler_uid:700" ] || fail "Unsafe producer directory: $1"
}
hash() { /usr/bin/shasum -a 256 "$1" | /usr/bin/awk '{print $1}'; }
field() { /usr/bin/plutil -extract "$2" raw -o - "$1"; }
verify() {
    sampler_package=$1
    for sampler_file in SamplerLive agent.plist installation.plist; do
        [ -f "$sampler_package/$sampler_file" ] && [ ! -L "$sampler_package/$sampler_file" ] || fail "Missing/unsafe package member: $sampler_file"
    done
    [ "$(field "$sampler_package/installation.plist" Label)" = "$sampler_label" ] || fail "Wrong installation identity"
    [ "$(hash "$sampler_package/SamplerLive")" = "$(field "$sampler_package/installation.plist" ExecutableSHA256)" ] || fail "Executable changed since preparation"
    [ "$(hash "$sampler_package/agent.plist")" = "$(field "$sampler_package/installation.plist" AgentSHA256)" ] || fail "Agent changed since preparation"
    [ "$(field "$sampler_package/agent.plist" Label)" = "$sampler_label" ] || fail "Wrong agent identity"
    [ "$(field "$sampler_package/agent.plist" ProgramArguments)" = 1 ] || fail "Unexpected producer arguments"
    [ "$(field "$sampler_package/agent.plist" ProgramArguments.0)" = "$sampler_root/SamplerLive" ] || fail "Package prepared for a different installation path"
}
case ${1:-help} in
verify)
    [ "$#" -eq 2 ] || fail "usage: sampler-service.sh verify prepared-directory"
    verify "$2"
    echo "Package identity verified; nothing installed or started."
    ;;
prepare)
    [ "$#" -eq 3 ] || fail "usage: sampler-service.sh prepare exact-built-SamplerLive existing-output-directory"
    sampler_binary=$2; sampler_stage=$3
    [ -f "$sampler_binary" ] && [ ! -L "$sampler_binary" ] && [ -x "$sampler_binary" ] || fail "Expected the exact built executable"
    [ -d "$sampler_stage" ] && [ ! -L "$sampler_stage" ] || fail "Expected an existing staging directory"
    for sampler_file in SamplerLive agent.plist installation.plist; do
        [ ! -e "$sampler_stage/$sampler_file" ] && [ ! -L "$sampler_stage/$sampler_file" ] || fail "Refusing to overwrite staging material"
    done
    /usr/bin/install -m 700 "$sampler_binary" "$sampler_stage/SamplerLive"
    /usr/bin/install -m 600 "$sampler_source/sampler-agent.plist" "$sampler_stage/agent.plist"
    /usr/bin/plutil -insert ProgramArguments.0 -string "$sampler_root/SamplerLive" "$sampler_stage/agent.plist"
    /usr/bin/plutil -create xml1 "$sampler_stage/installation.plist"
    /bin/chmod 600 "$sampler_stage/installation.plist"
    /usr/bin/plutil -insert Label -string "$sampler_label" "$sampler_stage/installation.plist"
    /usr/bin/plutil -insert ExecutableSHA256 -string "$(hash "$sampler_stage/SamplerLive")" "$sampler_stage/installation.plist"
    /usr/bin/plutil -insert AgentSHA256 -string "$(hash "$sampler_stage/agent.plist")" "$sampler_stage/installation.plist"
    verify "$sampler_stage"
    echo "Prepared only; nothing installed or started."
    ;;
install)
    [ "$#" -eq 2 ] || fail "usage: sampler-service.sh install prepared-directory"
    verify "$2"
    [ ! -e "$sampler_plist" ] && [ ! -L "$sampler_plist" ] || fail "Existing agent preserved; this installer never overwrites it"
    private_dir "$HOME/.pushwig"; private_dir "$sampler_root"
    for sampler_file in SamplerLive agent.plist installation.plist; do
        [ ! -e "$sampler_root/$sampler_file" ] && [ ! -L "$sampler_root/$sampler_file" ] || fail "Existing installation preserved; stop and inspect it before replacing"
    done
    [ -d "$HOME/Library" ] && [ ! -L "$HOME/Library" ] || fail "User Library is unavailable"
    if [ ! -e "$HOME/Library/LaunchAgents" ]; then /bin/mkdir -m 700 "$HOME/Library/LaunchAgents"; fi
    [ -d "$HOME/Library/LaunchAgents" ] && [ ! -L "$HOME/Library/LaunchAgents" ] || fail "Unsafe LaunchAgents directory"
    [ "$(/usr/bin/stat -f '%u' "$HOME/Library/LaunchAgents")" = "$sampler_uid" ] || fail "LaunchAgents is not current-owner"
    /usr/bin/install -m 700 "$2/SamplerLive" "$sampler_root/SamplerLive"
    /usr/bin/install -m 600 "$2/agent.plist" "$sampler_root/agent.plist"
    /usr/bin/install -m 600 "$2/installation.plist" "$sampler_root/installation.plist"
    /usr/bin/install -m 600 "$2/agent.plist" "$sampler_plist"
    verify "$sampler_root"
    # Installation is deliberately stopped, including at subsequent login, until explicit start.
    /bin/launchctl disable "$sampler_job"
    echo "Installed but disabled. Use sampler-service.sh start when ready."
    ;;
start)
    verify "$sampler_root"
    /usr/bin/cmp -s "$sampler_root/agent.plist" "$sampler_plist" || fail "Installed launch agent differs; refusing start"
    /bin/launchctl enable "$sampler_job"
    if /bin/launchctl print "$sampler_job" >/dev/null 2>&1; then
        /bin/launchctl kickstart "$sampler_job"
    else
        /bin/launchctl bootstrap "gui/$sampler_uid" "$sampler_plist"
    fi
    echo "Started. The producer waits for ordinary Bitwig/Sampler context; it does not launch Bitwig."
    ;;
stop)
    /bin/launchctl disable "$sampler_job"
    if /bin/launchctl print "$sampler_job" >/dev/null 2>&1; then /bin/launchctl bootout "$sampler_job"; fi
    echo "Stopped and disabled at login. No extension, project, session files or permission settings changed."
    ;;
status)
    if /bin/launchctl print "$sampler_job" >/dev/null 2>&1; then
        /bin/launchctl print "$sampler_job" | /usr/bin/awk '/state =|pid =|last exit code =/ {print}'
    else echo "Producer service not loaded."; fi
    if [ -f "$sampler_root/status.json" ] && [ ! -L "$sampler_root/status.json" ] && [ "$(/usr/bin/stat -f '%z' "$sampler_root/status.json")" -le 16384 ]; then
        /usr/bin/plutil -p "$sampler_root/status.json"
        echo "Snapshot only: check observedAt and live service PID; a retained status is not live authority."
    fi
    ;;
*) echo "usage: sampler-service.sh prepare built-executable staging-directory | verify prepared-directory | install prepared-directory | start | stop | status" ;;
esac
