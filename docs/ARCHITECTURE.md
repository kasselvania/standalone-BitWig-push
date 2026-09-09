# Architecture

## Product thesis

Pushwig combines semantic control/state from Bitwig and DrivenByMoss with optional visual information when graphics improve a Push task. The controller remains useful when the visual source is absent, unsupported, stale, or broken.

## Four separate planes

The architecture has four planes that must not be collapsed into one success claim.

### 1. Semantic/control plane

```text
Bitwig state
    -> DrivenByMoss controller model
    -> pads / encoders / transport / ordinary Push semantics
```

Bitwig owns DAW/audio. DrivenByMoss owns Push control semantics.

### 2. Frame data plane

```text
authenticated complete producer message
    -> bounded V1D-2 receiver
    -> fixed latest-frame publication
    -> nonblocking display-thread adoption
    -> accepted opaque-BGRA raster write
    -> current semantic composition
    -> one PushUsbDisplay.send
```

This plane is proven on physical Push hardware. It has one loopback receiver, no application frame FIFO, bounded storage, no source I/O on the display thread, and current-semantic fallback.

### 3. Activation/rendezvous plane

```text
ordinary Bitwig launch
    -> persisted Pushwig enablement read during configuration
    -> successful complete Push setup/startup
    -> display-owned activation
    -> private session capability and existing receiver bind
    -> atomically published nonsecret rendezvous
    -> producer discovery
```

Accepted in V5A on the Mac/Push 3 fixture. Display construction creates no ingress authority. The final setup-startup hook performs one activation, and shutdown prevents late activation. The default-Off preference is restart-scoped; no JVM option injection is used.

`Push2Display` owns receiver activation and shutdown. Its activation/rendezvous owner holds one lifetime lock, a fresh capability and current manifest. Only one ingress per user is supported. Producers discover that receiver; they do not create it.

See the [accepted activation design](design/ordinary-launch-ingress-activation.md) for exact runtime custody, publication ordering, cleanup and limitations.

### 4. Visual-source plane

```text
product-valid visual or generated source
    -> bounded crop / scale / opaque-BGRA production
    -> activation rendezvous
    -> V1D-2 data plane
```

The tested ScreenCaptureKit desktop-independent stream of the user's primary Bitwig window is not product-valid for ordinary attached use because macOS sharing UI obstructs normal window controls. The failed V5 slice did not select an alternative.

Therefore:

```text
accepted frame data plane + accepted ordinary activation
    != selected product capture source
```

V5A qualifies generated input, not a new capture backend. No subsequent implementation is authorized by this architecture document.

## Device-aware presentation

With activation accepted, source viability remains the prerequisite for the blocked Sampler page. The intended product model remains:

```text
context router
semantic context
experience profile
visual resolver
semantic camera
presentation composer
source backend
```

Existing track, mixer, session, transport, and performance screens remain ordinary DrivenByMoss by default.

## Attached and managed modes

### Attached

Use the user's ordinary Bitwig desktop. Activation and source mechanisms are eligible only when Bitwig remains visible, controllable, and cleanly recoverable.

### Managed

A future appliance may own a canonical Bitwig workspace and expose it independently to Pushwig and a remote full-desktop client. No compositor or remote stack is selected by V5A.

## Ownership invariants

- Bitwig owns DAW/audio.
- DrivenByMoss owns semantic Push behavior and final USB display transport.
- The DrivenByMoss/Push runtime owner controls receiver activation and session rendezvous lifetime.
- Producers own frame acquisition/generation and producer-local processing only.
- Capture/media backends never own MIDI, audio, controller state, or USB transport.
- Visual failures remove visual authority and return to current semantics.
- Platform-specific objects do not define portable semantic/device/presentation identity.
- A technically correct component does not establish a product path until ordinary launch, real interaction, shutdown, and rollback pass.

See [activation design](design/ordinary-launch-ingress-activation.md), [protocols](PROTOCOLS.md), and [device-aware presentation](design/device-aware-presentation-layer.md).
