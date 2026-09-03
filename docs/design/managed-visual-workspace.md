# Future managed visual workspace

## Status

This is a **future Track A/runtime design**, not the active V5 implementation and not a selected Weston/PipeWire architecture.

The active source work is the Mac-first [portable frame-source bakeoff](portable-frame-source-bakeoff.md). V5 must first determine which capture/media substrate is product-usable on macOS and can continue to Linux.

## Product purpose

A future self-contained Pushwig appliance still needs one authoritative Bitwig session with two different projections:

```text
one canonical Bitwig workspace
        +-> curated Push presentation
        +-> full remote desktop and input from another device
```

The remote client should view/control the canonical workspace without defining its geometry. Disconnecting or resizing a viewer should not stop Bitwig or redefine Pushwig's visual source.

## Candidate managed form

A Linux appliance may eventually use Weston, gamescope, another compositor, Xwayland, PipeWire, VNC/RDP/WebRTC, or another stack. No compositor, media transport, or remote protocol is selected by this document.

The eventual managed implementation should prove:

- stable canonical geometry;
- normal Bitwig main, child, and editor windows;
- independent raw-frame and remote-access consumers;
- pointer usable remotely but separable from Push visuals;
- restart/failure domains that do not unnecessarily stop music/control;
- remote-client size independent of source identity;
- safe process supervision, project retention, and shutdown.

## Relationship to attached mode

Managed mode is valuable for Steam Deck, Framework, compact-x86, headless operation, remote-only workflows, and deterministic tests. It must not be imposed on ordinary desktop users.

Attached mode remains a first-class Track V goal and currently depends on selecting a product-usable frame source.

## Portable boundary

Managed backends may use Linux-specific compositor, PipeWire, X11, Wayland, DRM, VNC, or RDP objects internally. Those objects must not define portable semantic, device, presentation, or raw-frame identity.

This document remains a destination for later appliance design. It is not authority to jump from one failed macOS source directly to a Linux implementation.
