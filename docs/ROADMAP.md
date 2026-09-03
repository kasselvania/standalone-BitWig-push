# Roadmap

Pushwig's roadmap is organized around product capabilities, not every internal experiment.

Execution authority lives in `CURRENT_SLICE.md` and the owning issue. This file provides orientation only.

## Accepted foundation

The project has established:

- a narrow DrivenByMoss display-composition seam;
- exact restoration of the current semantic Push display;
- a validated opaque-BGRA raster sink;
- bounded capability-authenticated latest-frame ingress;
- real host pixels displayed on a physical Push 3 while controls/audio remain operational;
- a maintained macOS capture helper;
- explicit helper-local cropping and aspect-preserving scaling;
- Bitwig-window movement/loss/recreation handling;
- committed regression tests for stable frame/profile/protocol/backpressure behavior.

These results answer the initial engineering question: real computer-hosted visuals can reach Push quickly, accurately and with bounded resource cost.

## Blocked: V4 Sampler device page

[V4 / issue #49](https://github.com/kasselvania/standalone-BitWig-push/issues/49) stopped before production implementation.

The current macOS primary-window ScreenCaptureKit source is not accepted for attached-desktop use because macOS sharing UI obstructs normal Bitwig window controls on the tested fixture.

The desired device-aware Sampler page remains a product goal. It does not resume until a viable source operating mode exists.

## Active: V5 managed Bitwig workspace

[V5 / issue #50](https://github.com/kasselvania/standalone-BitWig-push/issues/50) proves the source/runtime architecture originally intended for managed/appliance operation:

```text
one authoritative Bitwig session
        -> canonical managed graphical workspace
             +-> raw PipeWire frames -> Pushwig frame adapter -> V1D-2 -> Push
             +-> full remote desktop/input -> another device
```

V5 uses Weston and PipeWire as the first Linux reference implementation, not as permanent product dependencies.

Acceptance centers on:

- canonical workspace geometry independent of the remote client;
- raw compositor frames with bounded processing;
- independent remote desktop/input;
- restart/disconnect independence;
- cursor separation;
- actual frames through unchanged V1D-2;
- platform-neutral source descriptors.

See [`design/managed-visual-workspace.md`](design/managed-visual-workspace.md).

## After a viable managed source

The near product sequence remains:

1. reconsider the blocked Sampler device-page foundation against the viable source;
2. redesign the Browser as a results-first semantic experience;
3. add Sampler waveform/boundary and sliced task views after capability verification;
4. use Polymer as the first device-overview generalization test;
5. expand proven behavior families to other native devices;
6. improve attached-mode source coverage separately rather than constraining the managed appliance to the current Mac backend.

The device behavior catalog is [`design/native-device-behavior-matrix.md`](design/native-device-behavior-matrix.md).

## Stronger localization and interaction

As device-aware work resumes, improve:

- selected-device and parameter-binding semantic coordination;
- verified device boundaries and named visual regions;
- touch/edit/multi-touch semantic-camera behavior;
- layout variants and bounded calibration;
- confidence-checked semantic-seeded anchors where geometry is insufficient;
- direct generated waveform/analyzer sources where structured data is available;
- abstention rather than wrong visual locks.

## Usability and packaging

Before calling Pushwig an end-user release, improve:

- installation and first-run setup;
- profile/source management;
- helper/runtime/DrivenByMoss compatibility;
- diagnostics and recovery;
- release packaging and upgrade/rollback;
- contributor-facing build/test automation.

## Linux attached mode

Managed V5 is not the Linux attached-mode solution.

Later attached work may evaluate:

- X11/XComposite;
- XDG ScreenCast portal + PipeWire;
- compositor-specific capture where appropriate;
- dedicated/editor windows;
- direct/generated sources.

Attached backends must preserve ordinary desktop use.

## Track A appliance

The managed workspace becomes the software runtime for the portable appliance:

```text
Linux host + battery + Push
        +-> curated Push interface
        +-> full wireless Bitwig desktop
        +-> boot/recovery/shutdown services
```

The Steam Deck remains the first named appliance fixture. Framework/compact-x86 hosts remain alternatives.

## Track H internal compute

Push's internal compute bay and CM11EB carrier remain separate hardware research. They do not block the managed workspace, external USB appliance, or device-aware visual software.

## Release direction

A credible first public release should let a supported user:

1. install the supported DrivenByMoss derivative and runtime/source backend;
2. start a declared attached or managed operating mode;
3. see useful device/browser/direct information on Push in the right context;
4. retain normal controls/audio and semantic fallback when visuals disappear;
5. in managed/appliance mode, access the full Bitwig desktop from another device;
6. reproduce the supported configuration from conventional documentation and committed tests.
