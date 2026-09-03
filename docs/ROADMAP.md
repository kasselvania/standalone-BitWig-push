# Roadmap

Pushwig's roadmap is organized around product capabilities, not every internal experiment.

## Done: working visual path on real Push hardware

The project has established:

- a narrow DrivenByMoss display-composition seam;
- reliable restoration of the current semantic Push display;
- a validated opaque-BGRA raster sink;
- bounded authenticated latest-frame ingress from a separate local process;
- a maintained macOS ScreenCaptureKit helper;
- live Bitwig pixels on a physical Push 3 Controller while controls, audio, and headphone output remain operational;
- a human-readable window-relative visual profile;
- unique/missing/ambiguous Bitwig-window selection;
- helper-local normalized cropping and aspect-preserving scaling;
- window move, supported resize, source-loss, and recreation handling;
- committed regression tests for stable crop, profile, selection, generation, protocol, and backpressure behavior.

Detailed historical experiments and measurements remain under `evidence/**` and the completed design dossiers.

## Accepted: V3 window-relative visual lens

[V3 / issue #45](https://github.com/kasselvania/standalone-BitWig-push/issues/45) removed the physical-display coordinate from normal profile use.

A profile can now select one intended Bitwig main window, define a normalized region inside it, and keep the visual source attached through ordinary move, supported resize, loss, and recreation. Missing or ambiguous sources fall back to current DrivenByMoss semantics. The V2 explicit-display mode remains available as a diagnostic/reference path.

The crop is applied explicitly inside the helper because ScreenCaptureKit does not honor `sourceRect` for single-window capture. A generated native quadrant fixture proved that materially different normalized crops select materially different source pixels.

See [`design/window-relative-visual-lens.md`](design/window-relative-visual-lens.md).

## Current design discussion: make the visual useful

The immediate question is no longer whether Pushwig can transport real pixels or follow the Bitwig window. It can.

The remaining limitation is that a normalized window region is still **device-unaware**. Bitwig can reflow Sampler, the device chain, and adjacent panels inside the same window while the outer capture remains technically correct.

Before selecting the next implementation milestone, decide the intended product experience:

- which information should appear on Push and in which controller modes;
- when a captured Bitwig view is valuable versus a purpose-built generated view;
- how DrivenByMoss selected-device and mode state should influence visual selection;
- how a visual should be switched, hidden, enlarged, or restored;
- how internal Bitwig regions should be located without showing the wrong content;
- what configuration should be automatic, profiled, or calibrated;
- what makes the feature pleasant to use rather than merely demonstrable.

Potential technical ingredients include Bitwig/DrivenByMoss semantics, bounded layout rules, user-authored profiles, calibration, confidence-checked pixel anchors, and direct project-owned visual renderers. None is selected as the next architecture merely by appearing in this list.

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

## Optional appliance work

A self-contained Linux host, battery, boot/recovery services, and wireless desktop management can package the same Pushwig software into a portable instrument. The Steam Deck is the first available appliance fixture; Framework/compact-x86 systems are possible later hosts.

## Optional internal-compute / connector research

Push's internal compute bay and CM11EB carrier remain a separate hardware research track. Useful outcomes include safe connector characterization, diagnostic hardware, and eventual evaluation of a native-bay compute installation.

These hardware tracks do not block the desktop visual/controller product.

## Release direction

A credible first public release should let another Push 3 + Bitwig user:

1. install the supported DrivenByMoss derivative and capture helper;
2. grant the required platform permission;
3. select or load a visual profile;
4. see useful Bitwig visuals on Push;
5. retain normal controls/audio when visuals disappear;
6. understand and reproduce the supported configuration from conventional docs and tests.
