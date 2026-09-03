# Roadmap

Pushwig's roadmap is organized around product capabilities, not every internal experiment.

Execution authority lives in `CURRENT_SLICE.md` and the owning issue. This file gives longer-term orientation only; it does not duplicate slice requirements.

## Done: working visual path on real Push hardware

The project has established:

- a narrow DrivenByMoss display-composition seam;
- reliable restoration of the current semantic Push display;
- a validated opaque-BGRA raster sink;
- bounded authenticated latest-frame ingress from a separate local process;
- a maintained macOS ScreenCaptureKit helper;
- live Bitwig pixels on a physical Push 3 Controller while controls, audio and headphone output remain operational;
- a human-readable window-relative visual profile;
- unique/missing/ambiguous Bitwig-window selection;
- helper-local normalized cropping and aspect-preserving scaling;
- window move, supported resize, source-loss and recreation handling;
- committed regression tests for stable crop, profile, selection, generation, protocol and backpressure behavior.

V3 proved that Pushwig can follow the Bitwig window and deliver real pixels. It also made the next limitation clear: a correct window-relative crop is not yet a device-aware instrument interface.

## Current phase: device-aware presentation

Pushwig now preserves existing controller screens that already work well and adds custom presentations only for supported objects and tasks.

The current operating vocabulary is:

```text
context router
semantic context
experience profile
visual resolver
semantic camera
presentation composer
platform capture backend
```

See [`design/device-aware-presentation-layer.md`](design/device-aware-presentation-layer.md). This model is not execution authority; the active issue controls the current implementation.

The first product sequence is:

1. **V4 Sampler device-page foundation** — one intentional hybrid native-device page with current encoder semantics, a tightly bounded visual, touch emphasis and exact fallback;
2. **Browser redesign** — results-first semantic browsing with clear filters, preview, commit and cancel;
3. **Sampler task views** — playback/loop boundaries and sliced workflows after capability verification;
4. **Polymer generalization** — prove that the device-overview model is not Sampler-specific;
5. **Broader native-device families** — analyzers, graphs, structures and note-flow devices using proven behavior families.

The active implementation is [V4 / issue #49](https://github.com/kasselvania/standalone-BitWig-push/issues/49).

The native-device inventory and priorities are in [`design/native-device-behavior-matrix.md`](design/native-device-behavior-matrix.md).

## Stronger localization and interaction

After the first complete device page proves what must be located and presented, improve:

- selected-device and parameter-binding semantic coordination;
- validated native-device boundaries and named control regions;
- touch/edit/multi-touch semantic-camera behavior;
- layout-variant handling and bounded calibration;
- confidence-checked semantic-seeded anchors where geometry is insufficient;
- direct generated waveform/analyzer sources where data is available;
- abstention rather than wrong visual locks.

## Usability and packaging

Before calling Pushwig an end-user release, improve:

- installation and first-run setup;
- configuration/profile management;
- helper and DrivenByMoss version compatibility;
- diagnostics and recovery that do not require reading evidence logs;
- release packaging and upgrade/rollback behavior;
- contributor-facing build/test automation.

## Linux and Steam Deck

Port the established contracts rather than redesigning them:

- prove Push control/audio/display on Linux;
- add a Linux visual-source backend appropriate to X11/Xwayland or Wayland/portal environments;
- characterize Flatpak boundaries;
- measure CPU/power on the Steam Deck fixture;
- preserve semantic fallback and one Push display writer.

The semantic context, device-experience and presentation models must remain platform-neutral even while macOS is the first capture implementation.

## Optional appliance work

A self-contained Linux host, battery, boot/recovery services and wireless desktop management can package the same Pushwig software into a portable instrument. The Steam Deck is the first available appliance fixture; Framework/compact-x86 systems are possible later hosts.

## Optional internal-compute / connector research

Push's internal compute bay and CM11EB carrier remain a separate hardware research track. Useful outcomes include safe connector characterization, diagnostic hardware and eventual evaluation of a native-bay compute installation.

These hardware tracks do not block the desktop visual/controller product.

## Release direction

A credible first public release should let another Push 3 + Bitwig user:

1. install the supported DrivenByMoss derivative and platform helper;
2. grant the required platform permission;
3. load a supported device or workflow experience;
4. see useful Bitwig-native and Push-specific information in the right controller context;
5. retain normal controls/audio and semantic fallback when visuals disappear;
6. understand and reproduce the supported configuration from conventional docs and tests.
