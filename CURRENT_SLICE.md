# Current work

**Sampler contextual lens — foreground check blocked on notification continuity; official fixture restored.**

The maintainer subsequently authorized the [Sampler context interaction](docs/design/sampler-context-lens.md), approved its LED/presentation behavior, and physically confirmed the repaired live image with context return and normal controls/audio. The official extension was restored exactly afterward. This branch is development work, not accepted main or an end-user release.

The current explicit commission removes service-only code and qualifies an ordinary Terminal foreground command: no required window ID or duration, no acquisition outside current Sampler context, automatic current-window selection, visible state/failure reporting and clean stop. No installer, app bundle, LaunchAgent, permission change or DrivenByMoss edit is authorized. See [scope, historical note and evidence](visuals/sampler/README.md#foreground-utility--september-10). One focused physical session and exact official rollback must pass before the foreground commit is published. Do not open the final Sampler PR yet.

September 10 foreground result: 117 locator + 222 live generated checks passed. No-argument ordinary-Terminal startup, idle without FFmpeg, automatic physical Sampler entry/return and deliberate Ctrl-C worked. Normal played-note notifications suppress the image through the unchanged controller's blanket overlay rule; this is not a complete continuity pass. Locator refusals also occurred, without enough temporal evidence to assign their cause. The run stopped, the official extension was restored byte-exactly, and the maintainer confirmed official display/controls/audio/headphones and normal quit. Final process/session-file absence was verified at 23:35:06 UTC. Foreground work remains uncommitted pending the next bounded review; do not resume capture or edit DrivenByMoss under this slice.

## Preserve

- DrivenByMoss `pushwig/main`: `997158b0a4ddd932a0a985c8b74ffff1e631120f`.
- Tree: `dbf3dc8d4e6d6b95a654088f85b8a183584063b7`.
- Semantic/control behavior, current-semantic restoration, raster sink, V1D-2 receiver/protocol, sole Push USB writer.
- Accepted V5A ordinary-launch activation and private rendezvous.
- Published history and factual experiment records.
- The Sampler development controller head `93fb2a48d1e35dfeb69f902a44d8035a0b7db557` and approved LED/action/value presentation, without confusing that unmerged branch with accepted integration.

## Not part of this pass

Slice mode, device browsing, remote-to-image markers, arbitrary-device recognition, hidden-window capture, a generic device/source framework, Linux, and changes to protocol/raster/USB/MIDI/audio owners.

V2–V5B capture packages and speculative structures remain retired. This work does not resume [issue #57](https://github.com/kasselvania/standalone-BitWig-push/issues/57) or rehabilitate those experiments. No merge or unrelated housekeeping is authorized.

[Retirement boundary](docs/research/capture-experiments-retired.md).
