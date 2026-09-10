# Pushwig

**Optional visual frames alongside DrivenByMoss control on Ableton Push 3.**

Pushwig's proven foundation is a narrow DrivenByMoss integration: receive complete authenticated visual frames, compose them with the current semantic display, and retain one Push USB writer. Bitwig remains responsible for DAW/audio; DrivenByMoss remains responsible for musical controls and the normal Push interface.

This is experimental software, not an end-user release. Pushwig does not run Bitwig on AbletonOS or modify Push firmware.

## Accepted foundation

- Current-semantic redraw and exact restoration when visuals clear, expire, disconnect, or fail.
- Validated opaque-BGRA raster composition.
- Bounded authenticated latest-frame ingress, without a historical frame queue.
- Ordinary Bitwig launch with a default-Off, restart-scoped Pushwig setting and private current-session rendezvous.
- Physical Push display/control/audio acceptance and exact official-artifact rollback.

The implementation is in [kasselvania/DrivenByMoss](https://github.com/kasselvania/DrivenByMoss), integration branch `pushwig/main`. See the [integration guide](docs/integrations/drivenbymoss.md), [activation guide](docs/design/ordinary-launch-ingress-activation.md), and [protocol](docs/PROTOCOLS.md).

## Capture experiments retired

The V2–V5B capture experiments are no longer maintained production tooling or architectural prerequisites. The macOS capture package, its tests/profiles/build scripts, and the associated unimplemented capture/presentation designs have been removed from the current tree. Published source and experimental findings remain available in Git history and retained evidence.

There is no supported end-user capture application. The subsequent [Sampler contextual lens](docs/design/sampler-context-lens.md) is an explicitly commissioned, narrow FFmpeg implementation—not a continuation of the retired capture framework. Its repaired live layout passed a focused physical check; ordinary daily-use startup is now being qualified. [Build/run instructions and evidence](visuals/sampler/README.md).

See [the retirement boundary and history](docs/research/capture-experiments-retired.md). Earlier successful pixel-delivery experiments do not establish a usable capture product.

## Development

Start with [Architecture](docs/ARCHITECTURE.md), [Development](docs/DEVELOPMENT.md), [Testing](docs/TESTING.md), and [Contributing](CONTRIBUTING.md). [CURRENT_SLICE.md](CURRENT_SLICE.md) records the current development work and its acceptance boundary.

The central repository holds project contracts, documentation and historical evidence. The DrivenByMoss fork holds the accepted runtime and its tests. Historical evidence is not required onboarding and does not impose retired helpers or workflows on new work.

## Independence

Pushwig is independent and is not affiliated with or endorsed by Ableton, Bitwig, Apple, Valve, Intel, Framework Computer, or the DrivenByMoss project.
