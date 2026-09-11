# Architecture

## Accepted system

```text
Bitwig state -> DrivenByMoss semantic bitmap ------------------+
                                                             |
optional producer -> authenticated complete latest frame -----+
                                                             |
                                  current-semantic composition
                                                             |
                                  sole Push USB display writer
```

Bitwig owns DAW/audio. DrivenByMoss owns musical controls, semantic display state, composition and the final Push USB writer. No capture application owns those functions.

## Frame path

The accepted DrivenByMoss integration provides:

- synchronous current-semantic redraw before optional raster composition;
- validated opaque-BGRA writes, with no partial destination mutation on refusal;
- one bounded IPv4-loopback receiver and fixed latest-frame storage;
- nonblocking display-side adoption, with no source I/O on the display path;
- restoration to current semantics after CLEAR, staleness, disconnect or failure.

See [protocols](PROTOCOLS.md). This path is independent of how an external producer obtains or generates its pixels.

## Ordinary activation

```text
ordinary Bitwig launch
    -> persisted restart-scoped Pushwig enablement
    -> complete Push initialization and startup succeed
    -> display-owned ingress activation
    -> private capability + listener + current-session rendezvous
    -> producer discovery and authentication
```

Accepted in V5A. Display construction creates no ingress authority; shutdown prevents late activation and removes active session files. One ingress per user/runtime root is supported. A dormant owner.lock grants no authority.

The [activation design](design/ordinary-launch-ingress-activation.md) owns the implemented ordering and file/session contract. It is preserved unchanged by capture retirement.

## Video-source status

The V2–V5B helpers and their unimplemented resolver/camera/workspace structures are retired, not a framework that successor work must extend.

The current [Sampler lens development](design/sampler-context-lens.md) uses FFmpeg AVFoundation visible-screen acquisition, a Sampler-specific locator, uniform fit and the existing ingress. DrivenByMoss retains context eligibility, button actions, remote values, touch and final presentation. This is not hidden-window capture, arbitrary-device recognition, permanent API support or Linux compatibility.

Its foreground producer owns only its synchronous lifecycle and current image work; it has no service/status-file owner. It remains idle without eligible controller authority. Reusable mechanisms are justified by actual shared responsibilities; native-device categories, behavior families, Sampler-specific behavior and Browser workflow are distinct concerns, not a speculative class hierarchy.

[Historical experiments and retirement](research/capture-experiments-retired.md) retain findings without granting them architectural authority.

## Invariants

- Visual work never blocks musical controls or audio.
- Wrong, stale, partial or ambiguously sourced content is not current visual authority.
- Previous composed pixels are never semantic restoration authority.
- Source-specific OS handles stay outside DrivenByMoss and the wire contract.
- There is one final Push USB writer.
- A component test or past experiment is not a current product-usability claim.
