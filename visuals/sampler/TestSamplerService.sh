#!/bin/sh
set -eu
# Package preparation/refusal tests only: never invokes install/start/stop or launchctl.
sampler_source=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
sampler_binary=${1:?usage: TestSamplerService.sh exact-built-SamplerLive}
sampler_package=$(/usr/bin/mktemp -d /tmp/pushwig-service-test.XXXXXX)
cleanup() {
    /bin/rm -f "$sampler_package/SamplerLive" "$sampler_package/agent.plist" "$sampler_package/installation.plist"
    /bin/rmdir "$sampler_package"
}
trap cleanup EXIT
sh "$sampler_source/sampler-service.sh" prepare "$sampler_binary" "$sampler_package"
sh "$sampler_source/sampler-service.sh" verify "$sampler_package"
[ "$(/usr/bin/plutil -extract ProgramArguments raw -o - "$sampler_package/agent.plist")" = 1 ]
[ "$(/usr/bin/plutil -extract RunAtLoad raw -o - "$sampler_package/agent.plist")" = true ]
[ "$(/usr/bin/plutil -extract StandardOutPath raw -o - "$sampler_package/agent.plist")" = /dev/null ]
[ "$(/usr/bin/plutil -extract StandardErrorPath raw -o - "$sampler_package/agent.plist")" = /dev/null ]
if sh "$sampler_source/sampler-service.sh" prepare "$sampler_binary" "$sampler_package"; then exit 1; fi
/usr/bin/plutil -replace ProgramArguments.0 -string /tmp/wrong-program "$sampler_package/agent.plist"
if sh "$sampler_source/sampler-service.sh" verify "$sampler_package"; then exit 1; fi
echo "Sampler service package: 8 checks PASS; no installation, launchd or permission changes."
