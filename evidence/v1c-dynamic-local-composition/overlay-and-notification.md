# Overlay and notification evidence

## Date, machine state, and authority

- Evidence date: 2026-09-01 PDT.
- Machine state: exact Java harness, Bitwig Studio 6.1, and real Push 3 on the accepted macOS fixture.
- Actual central basis/tree: `4265dc7b6f1cabf2dcbad1b827d002bd9062cf4f` / `2af6b4757e5906ce74a3b52c5ee82323f5e32406`.
- DrivenByMoss basis/tree: `1ae0b74f383314d170a5960ca763bdf9c319e787` / `a81e5c4330b31f36845c25e98e322990d62f0c67`.
- Source PR/head/tree: [kasselvania/DrivenByMoss#3](https://github.com/kasselvania/DrivenByMoss/pull/3), `4b3326eddcf2d890de3baa10b93f6e80842d41e1`, tree `d03a372e2efcf41b22cef46501e08efbfb0c0036`.

## Overlay-only current-model retention

`ModelInfo` copies overlays but its equality/hash intentionally consider only components and notification. V1C therefore assigns every newly created `ModelInfo` before evaluating whether to render. The default hook remains false, while the dynamic Push hook forces current-model redraw.

The harness changed only overlay content while keeping ordinary semantic components equal:

```text
overlay changed pixels:          176
overlay-only update mismatches:  0
```

On the real Push, the maintainer entered Setup mode and exercised the Push 3 pad-curve display while generated visuals continued. The pad-curve graph and semantic display remained coherent.

## Notification lifecycle

The harness exercised notification appearance, active notification plus moving visuals, expiration, and restoration:

```text
notification changed pixels:               6,400
outside visual A notification mismatches:  0
outside visual B notification mismatches:  0
post-NONE notification mismatches:          0
notification lifecycle restoration:        0 mismatches
```

The decisive physical test avoided Push's hardware-owned volume page:

1. In the empty project, the maintainer pressed Clip.
2. The DrivenByMoss “Please select a clip” notification remained over the current Mix semantics while the local generated boxes continued moving.
3. The generated boxes did not interrupt or remove the notification.
4. After leaving Clip mode, the notification expired and the current Mix display returned normally.

The maintainer's direct observation was:

> the clip page hangs over the mix display boxes until that message has expired and then the mix display is fine. And it does that without any interruption to the floating boxes

This quotation is retained from the maintainer's acceptance response; it is not source-derived behavior.

## Master/Cue system mixer characterization

Pressing or conductively touching Push 3's Volume encoder invokes Push's own system mixer page. DrivenByMoss also maps the encoder press to a “Master Volume” / “Cue Volume” notification. During the dynamic run, the notification text remained stable while the representation behind it alternated between the ordinary controller display and the hardware-owned mixer page. Holding the knob down kept the system mixer page present.

After the exact official artifact was restored, the maintainer identified the same conductive-touch hardware page and concluded that it explained the earlier observation. This separates it from V1C's notification lifecycle:

- clean Clip notification path: stable and passed;
- Master/Cue encoder: pre-existing Push system-page interaction, not used as the compositor acceptance probe.

No production change was added to suppress or emulate Push's hardware-owned page.

## Commands and tools

Tools included exact source inspection of `ModelInfo`, `AbstractGraphicDisplay`, `SetupMode`, `ClipMode`, and the Push Master/Cue command; `javap`; the external harness; aggregate bitmap comparison; and direct physical Push interaction.

## What this proves

- Overlay-only state becomes the retained model used by forced redraw.
- Current notifications survive dynamic composition and restore current semantics on expiration.
- The generated local visual does not interrupt the tested DrivenByMoss Clip notification.
- The Master/Cue background alternation is bounded to a separate hardware-owned system page and was not mistaken for a V1C semantic-restoration failure.

## What this does not prove

- V1C does not claim ownership of or control over Push firmware/system pages.
- It does not repair or redesign the Master/Cue system-page interaction.
- It does not test every DrivenByMoss notification source.
