# Roadmap

Pushwig's roadmap is organized around product capabilities, not every internal experiment.

## Done: working visual path on real Push hardware

The project has already established:

- a narrow DrivenByMoss display-composition seam;
- reliable restoration of the current semantic Push display;
- a validated opaque-BGRA raster sink;
- bounded authenticated latest-frame ingress from a separate local process;
- a maintained macOS ScreenCaptureKit helper;
- live Bitwig Sampler pixels on a physical Push 3 Controller while controls, audio, and headphone output remain operational.

Detailed historical experiments and measurements remain under `evidence/**` and the completed slice dossiers.

## Next: adaptive Bitwig-window visual lens

Turn the fixed-layout V2 fixture into something usable in an ordinary desktop session:

- identify the Bitwig application window;
- define the visual crop relative to that window instead of the physical display;
- survive window move, resize, and recreation;
- load/save a visual profile;
- provide a straightforward launch/configuration path;
- keep the current semantic fallback and one-writer ownership model.

This should be delivered as one coherent product milestone rather than a chain of tiny research slices.

## Then: stronger visual localization

Once the window-relative lens works, improve how the desired device/panel region is found:

- use selected-device/layout semantics where Bitwig exposes them;
- add bounded calibration where necessary;
- benchmark semantic-seeded pixel anchors only where geometry/semantics are insufficient;
- prefer abstention to a wrong visual lock.

The detailed anchor-resolver document is a design hypothesis, not current product behavior.

## Usability and packaging

Before calling Pushwig an end-user release, improve:

- installation and first-run setup;
- configuration/profile management;
- helper/DrivenByMoss version compatibility;
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
