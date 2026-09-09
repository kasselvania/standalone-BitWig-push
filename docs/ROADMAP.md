# Roadmap

This is product orientation. The owning issue and `CURRENT_SLICE.md` control active work.

## Proven foundation

Pushwig has established on physical Push hardware:

- a narrow DrivenByMoss composition seam;
- current-semantic restoration;
- a validated opaque-BGRA raster sink;
- bounded authenticated latest-frame ingress;
- real Bitwig pixel delivery at useful cadence and low CPU/RSS;
- preserved pads, encoders, transport, Push audio, and headphones;
- ordinary-launch activation, private current-session producer discovery, clean shutdown/fresh restart, and exact official rollback.

## Completed: V5A ordinary ingress activation

V5A delivered one operational result:

```text
ordinary Bitwig launch
    -> supported persisted Pushwig enablement
    -> successful Push startup
    -> existing V1D-2 receiver + private session rendezvous
    -> generated frame on physical Push
    -> semantic fallback + clean shutdown/restart/rollback
```

See the [accepted design](design/ordinary-launch-ingress-activation.md) and [final evidence](../evidence/v5a-ordinary-ingress-activation/README.md). V5A changed activation/rendezvous ownership only and selected no capture backend. Its temporary recovery ladder has ended.

The earlier V5 frame-source bakeoff is closed as failed/superseded. Closed, unmerged PR #52 is not a selected implementation.

## Remaining product direction

1. Prove a product-valid Mac source mode, beginning with actual source identity and ordinary attached-use behavior rather than a generic portability layer.
2. Resume the first Sampler hybrid device page only after source viability.
3. Redesign Browser as a results-first semantic experience.
4. Add Sampler waveform/boundary/sliced views after capability verification.
5. Generalize proven behavior families to Polymer, analyzers, graph devices, structures, and note-flow devices.

This is direction, not execution authority. The current bounded experiment and its candidate status are linked from [`../CURRENT_SLICE.md`](../CURRENT_SLICE.md). A candidate under test is not an accepted capture backend.

## Portability

After one real source and common processing path are accepted:

- implement and prove its Linux source backend on a general Linux fixture;
- preserve backend-neutral semantic/frame/presentation contracts;
- later adapt to Steam Deck/appliance constraints;
- retain attached and managed operating modes as separate product forms.

Do not extract portability solely from a Mac pixel transform while acquisition remains unresolved. macOS remains the working fixture; completing V5A does not move development to Linux or Steam Deck.

## Appliance

A later managed appliance combines a Linux host, battery, boot/recovery, Push over USB, and full Bitwig desktop access from another device. The compositor and remote stack remain unselected.

## Release direction

A first credible release lets another Push 3 + Bitwig user install supported components, enable Pushwig through a supported UI/lifecycle, launch Bitwig normally, retain controls/audio, understand source limits, and recover cleanly when visuals are unavailable.
