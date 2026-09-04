# Runtime and source strategy

## Current decision

macOS remains Pushwig's active development fixture. The immediate runtime problem is not another capture backend; it is making the proven V1D-2 data plane available from an ordinary, fully usable Bitwig launch.

## Runtime sequence

```text
V5A on the Mac
    -> prove ordinary Bitwig activation + private producer rendezvous

later bounded Mac source slice
    -> select one product-valid source mode against that real ingress contract

Linux fixture later
    -> prove the selected common processing path and a concrete Linux source backend

Steam Deck / compact x86 later
    -> package proven software into a managed appliance
```

Windows is not a current product requirement.

## Ordinary-launch requirement

A product path starts when the user launches Bitwig normally through the operating system. It must not rely on a terminal-only executable invocation or JVM option environment injection to construct the Pushwig receiver.

The session must be fully visible and normally usable before process/listener evidence can count toward acceptance.

## Receiver and rendezvous ownership

The V1D-2 receiver is part of the DrivenByMoss Push display/controller lifetime. Its activation belongs with that owner, not with a future capture helper.

Subject to the V5A lifecycle audit, the runtime shape is:

```text
persistent user enablement
    -> Push controller instance starts
    -> create private session capability
    -> bind existing loopback receiver
    -> atomically publish nonsecret rendezvous
    -> producer connects/authenticates
    -> invalidate rendezvous and capability during shutdown
```

Required properties:

- exactly one receiver and one active rendezvous per owning controller instance;
- owner-only runtime directory and regular capability file;
- capability value absent from manifest, arguments, environment, logs, and evidence;
- no rendezvous publication before successful bind;
- stale prior-session files never confer current authority;
- normal shutdown and startup failure both remove/invalidate authority;
- external visual failure leaves controls, audio, and semantic display useful.

V5A may use a fixed/configured loopback port if that preserves the existing V1D-2 data plane. Dynamic discovery is useful only when it remains narrow and does not force a protocol rewrite.

## Source work after V5A

The rejected baseline remains continuous ScreenCaptureKit desktop-independent capture of the user's primary Bitwig window. The failed V5 AVFoundation whole-display crop is not a selected attached-mode source.

A later source slice must evaluate one materially distinct acquisition class at a time, identify its actual platform API, and prove source identity/usability before extracting portable abstractions. Cross-platform project branding is not proof of a shared source mechanism.

## Linux compatibility

A future selected frame-processing/media path must build and operate on Linux, with at least one concrete Linux source backend. Backend handles must not enter portable semantic, source, or presentation identity.

V5A does not implement or select Linux technology.

## Future managed appliance

A later appliance may run Bitwig in a controlled graphical workspace and expose:

```text
curated Push presentation
        +
full Bitwig desktop on another device
```

This may use Weston, gamescope, another compositor, PipeWire, X11, VNC/RDP/WebRTC, or another stack. None is selected before ordinary activation and source contracts are sound.

## Direct/generated sources

Not every Push experience must screen-capture Bitwig. Browser, analyzers, waveforms, and parameter graphs may use semantic, audio, or direct-rendered sources when they are more robust and useful. All still require a product-valid activation/delivery path or an explicitly different accepted owner.

## Decision rule

Trace real construction and ownership before selecting technology. Prove the first unproven cross-component dependency first. Performance, abstraction elegance, or green component tests never outrank ordinary product operation and exact recovery.
