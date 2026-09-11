#!/bin/sh
set -eu
# Build/test outside the checkout. Uses installed FFmpeg libraries; installs nothing.
sampler_source=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
sampler_output=${1:?usage: build-live.sh existing-output-directory}
test -d "$sampler_output"
xcrun clang -O2 -Wall -Wextra -Werror -I/opt/homebrew/include \
    -c "$sampler_source/SamplerFit.c" -o "$sampler_output/SamplerFit.o"
xcrun clang -O2 -Wall -Wextra -Werror -c "$sampler_source/SamplerHost.c" -o "$sampler_output/SamplerHost.o"
for sampler_program in SamplerLive TestSamplerLive TestSamplerLocator TestSamplerHandoff
do
    if [ "$sampler_program" = TestSamplerLocator ]; then
        xcrun swiftc -module-cache-path "$sampler_output/ModuleCache" -O "$sampler_source/SamplerLocator.swift" "$sampler_source/TestSamplerLocator.swift" -o "$sampler_output/$sampler_program"
    elif [ "$sampler_program" = TestSamplerHandoff ]; then
        xcrun swiftc -module-cache-path "$sampler_output/ModuleCache" -O -warnings-as-errors "$sampler_source/FFmpegSamplerStream.swift" \
            "$sampler_source/TestSamplerHandoff.swift" -o "$sampler_output/$sampler_program"
    elif [ "$sampler_program" = TestSamplerLive ]; then
        xcrun swiftc -module-cache-path "$sampler_output/ModuleCache" -O -warnings-as-errors -D SAMPLER_TEST -import-objc-header "$sampler_source/SamplerBridge.h" \
            "$sampler_source/SamplerLocator.swift" "$sampler_source/FFmpegSamplerStream.swift" \
            "$sampler_source/SamplerProcess.swift" \
            "$sampler_source/SamplerConnection.swift" "$sampler_source/SamplerLive.swift" "$sampler_source/TestSamplerLive.swift" "$sampler_source/TestSamplerRuntime.swift" \
            "$sampler_output/SamplerFit.o" "$sampler_output/SamplerHost.o" -L/opt/homebrew/lib -lswscale -lavutil -o "$sampler_output/$sampler_program"
    else
        xcrun swiftc -module-cache-path "$sampler_output/ModuleCache" -O -warnings-as-errors -import-objc-header "$sampler_source/SamplerBridge.h" \
            "$sampler_source/SamplerLocator.swift" "$sampler_source/FFmpegSamplerStream.swift" \
            "$sampler_source/SamplerProcess.swift" \
            "$sampler_source/SamplerConnection.swift" "$sampler_source/SamplerLive.swift" \
            "$sampler_output/SamplerFit.o" "$sampler_output/SamplerHost.o" -L/opt/homebrew/lib -lswscale -lavutil -o "$sampler_output/$sampler_program"
    fi
done
"$sampler_output/TestSamplerLocator"
"$sampler_output/TestSamplerLive"
shasum -a 256 "$sampler_output/SamplerLive"
