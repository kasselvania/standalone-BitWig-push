# Project tracks and success boundaries

## Purpose

Pushwig contains related but independent bodies of work. They share a Push/Bitwig contract, but they must not be collapsed into one linear definition of success.

The three primary tracks remain:

1. **Track V — universal visual/controller software**;
2. **Track A — all-in-one managed Bitwig appliance**;
3. **Track H — Push internal-connector/native-compute research**.

Optional ecosystem integrations may consume the software contracts without becoming prerequisites for the core project.

## Reference fixtures versus product requirements

Current fixture roles:

- **macOS development fixture** — first source/build/install/measurement environment; proved the downstream Push visual path and one concrete capture backend;
- **Linux managed-runtime fixture** — current V5 proof host for the canonical workspace, raw compositor frames, and full remote desktop;
- **Steam Deck appliance fixture** — later packaging/power/headless/portable acceptance host.

None is normative.

The Mac does not make Pushwig macOS-only. Weston/PipeWire do not make Weston or PipeWire permanent product requirements. The Steam Deck does not make SteamOS the only appliance host.

## Track V — universal visual/controller integration

This is the primary open-source software product.

Its claim is:

> A Push user can combine DrivenByMoss semantic control with useful live Bitwig/native-device/plug-in/direct visuals through declared source backends and operating modes without depending on one computer model, monitor arrangement, or appliance enclosure.

Track V has two operating classes.

### Attached mode

Bitwig remains in the user's existing desktop session.

A supported backend must coexist with normal host use. It must not require a project-owned desktop or materially obstruct normal application controls.

The accepted macOS ScreenCaptureKit primary-window path is currently an engineering/reference source, not an accepted attached product source on the tested fixture.

Attached mode remains a product goal and may use other capture backends, dedicated editor surfaces, direct/generated visuals, or future safer platform mechanisms.

### Managed mode

Pushwig controls the graphical workspace used by Bitwig.

Managed mode owns stable logical geometry and may expose:

- a raw frame stream for Pushwig;
- a full remote desktop/input path;
- deterministic layout/profile state;
- process supervision and recovery.

V5 is the first managed-source implementation proof.

## Track A — all-in-one appliance

Track A packages proven Track V software into a portable Bitwig instrument.

The intended appliance experience has **two interfaces to the same authoritative Bitwig session**:

```text
Push
    -> immediate musical control + curated task-specific visuals

another device
    -> complete Bitwig desktop + pointer/keyboard for deep editing
```

The remote client may be a laptop, tablet, or another suitable local/Tailscale client. Its view size must not redefine the canonical managed workspace geometry used by Pushwig.

The first appliance may use:

- Steam Deck or another Linux host;
- the existing angled base;
- battery power;
- Push's stock rear USB controller/audio path;
- managed graphical session and remote desktop;
- local service/recovery tooling.

Possible later hosts include Framework mainboards and compact x86 computers.

Track A does not require the internal compute bay.

## Track H — internal connector and native compute

Track H investigates Push's Intel NUC Compute Element / CM11EB carrier and possible native-bay final forms.

Independent results include:

- measured bay/carrier documentation;
- safe CM11EB diagnostic hardware;
- internal USB/mux/sideband characterization;
- used Compute Element bring-up;
- native-bay thermal, battery and power integration.

The direct external USB route remains first-class and may remain supported indefinitely.

## Optional ecosystem integrations

Adjacent work may include:

- Windows plug-in bridging;
- plugdata/Pure Data;
- Monome/serialosc;
- direct analyzers;
- device-specific visual sources;
- other controller integrations.

These projects may implement visual-source or semantic adapters but do not own Pushwig's roadmap.

## Current relationship between V5 and the tracks

V5 sits at the Track V / Track A boundary.

It proves a Track V managed visual-source contract using the runtime shape Track A will eventually need:

```text
one Bitwig session
        -> canonical managed workspace
             +-> raw frames -> Pushwig
             +-> full remote desktop/input
```

It intentionally does **not** solve:

- Steam Deck battery/power/boot packaging;
- gamescope or final compositor choice;
- device-aware Sampler presentation;
- Linux attached-mode portal capture;
- internal compute.

Those remain separate product capabilities.

## Valid stopping points

Each remains a legitimate project success:

1. **visual/controller extension:** useful supported device/browser/direct visuals on Push with safe fallback;
2. **managed-source runtime:** one canonical Bitwig workspace with raw frames and independent remote access;
3. **maintainer appliance:** Linux host + battery + Push + managed workspace + remote desktop;
4. **reproducible appliance:** documented Framework/compact-x86 or equivalent package others can reproduce;
5. **connector development platform:** public CM11EB diagnostic hardware and carrier findings;
6. **native-bay final form:** compute, battery and thermal system inside Push.

Later stopping points are larger integrations, not retroactive requirements for earlier ones.

## Repository boundary rule

This repository may coordinate the tracks while shared contracts are still forming. Split a track into its own repository when it develops a genuinely independent contributor community, release cadence, safety domain, or build system.

Possible future boundaries remain:

```text
pushwig-visual
pushwig-appliance
push3-cm11eb-devkit
```
