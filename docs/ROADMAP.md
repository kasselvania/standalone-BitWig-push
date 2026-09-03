# Roadmap

Pushwig's roadmap is organized around product capabilities, not every internal experiment.

Execution authority lives in `CURRENT_SLICE.md` and an owning issue. This file gives longer-term orientation only.

## Done: downstream visual path on real Push hardware

The project has established:

- a narrow DrivenByMoss display-composition seam;
- reliable restoration of the current semantic Push display;
- a validated opaque-BGRA raster sink;
- bounded authenticated latest-frame ingress from a separate local process;
- real Bitwig pixels on a physical Push 3 Controller while controls, audio, and headphone output remain operational;
- a maintained macOS ScreenCaptureKit helper;
- a human-readable window-relative visual profile;
- unique/missing/ambiguous Bitwig-window selection;
- helper-local normalized cropping and aspect-preserving scaling;
- window move, supported resize, source-loss, and recreation handling;
- committed regression tests for crop, profile, selection, generation, protocol, and backpressure behavior.

These results prove the **visual substrate**: pixels can be acquired and delivered quickly, accurately, and with bounded impact.

They do not prove that the current source is a usable end-user operating mode.

## Blocked: primary-window attached capture

On the tested macOS fixture, continuous desktop-independent capture of Bitwig's primary window places a macOS sharing badge over the normal window controls. The maintainer could not access normal minimize and full-screen controls while capture was active.

V4 stopped at this required preflight before any Sampler-page production source was written. The blocker is retained under [issue #49](https://github.com/kasselvania/standalone-BitWig-push/issues/49) and evidence commit `52f6f41f4fc7285d652453a3530b9764e0295cc5`.

The project will not waive this as a cosmetic limitation. A source mode that makes the host application materially worse to use is not the product foundation for a richer controller experience.

## Next decision: visual-source operating mode

Before resuming device-aware implementation, select and prove at least one viable source mode.

Candidate categories are:

1. **Attached desktop** — a supported source that preserves ordinary use of the primary Bitwig session.
2. **Managed/dedicated surface** — a controlled visual session, display, or window that does not obstruct the user's primary Bitwig UI.
3. **Direct/generated visuals** — render from controller semantics, sample/audio data, or analysis output without desktop capture.
4. **Hybrid** — direct/generated presentation by default, with captured native graphics only where the capture operating mode is acceptable.

No category is selected merely by appearing here.

## Device-aware presentation direction

The intended product model remains:

```text
context router
semantic context
experience profile
visual resolver
semantic camera
presentation composer
source backend
```

See [`design/device-aware-presentation-layer.md`](design/device-aware-presentation-layer.md) and the [`native-device-behavior-matrix.md`](design/native-device-behavior-matrix.md).

Once a viable source mode exists, the desired product order remains approximately:

- one complete Sampler Device-page experience;
- Browser redesign;
- Sampler playback/loop/slice task views;
- Polymer as the first generalization test;
- broader native-device behavior families.

That sequence is paused, not discarded.

## Usability and packaging

Before calling Pushwig an end-user release, improve:

- installation and first-run setup;
- source-mode and profile management;
- helper and DrivenByMoss version compatibility;
- diagnostics and recovery that do not require evidence logs;
- release packaging and upgrade/rollback behavior;
- contributor-facing build/test automation.

## Linux and Steam Deck

Port the proven downstream contracts rather than redesigning them:

- prove Push control/audio/display on Linux;
- evaluate X11/Xwayland and Wayland/portal source behavior;
- characterize Flatpak boundaries;
- measure CPU/power on the Steam Deck fixture;
- preserve semantic fallback and one Push display writer.

A managed Linux appliance may offer a different visual-source operating environment from attached macOS, but that must be proven rather than assumed.

## Optional appliance work

A self-contained Linux host, battery, boot/recovery services, and wireless desktop management can package Pushwig into a portable instrument. The Steam Deck is the first available appliance fixture; Framework/compact-x86 systems are possible later hosts.

## Optional internal-compute / connector research

Push's internal compute bay and CM11EB carrier remain a separate hardware research track. Useful outcomes include safe connector characterization, diagnostic hardware, and eventual evaluation of a native-bay compute installation.

These hardware tracks do not block the downstream visual/controller foundation, but a managed appliance may become one valid place to host a dedicated visual source.

## Release direction

A credible public release must let another Push 3 + Bitwig user:

1. install the supported controller extension and source/rendering components;
2. use Bitwig normally in the declared operating mode;
3. see useful information on Push in the correct controller context;
4. retain normal controls/audio and semantic fallback when visuals disappear;
5. understand the supported limitations from conventional docs and tests.
