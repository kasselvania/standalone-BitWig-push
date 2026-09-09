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

No capture implementation is currently maintained or selected. The V2–V5B helpers and their unimplemented resolver/camera/workspace structures are retired, not a framework that successor work must extend.

A future producer needs only to satisfy the existing authenticated frame and session contracts. The maintainer's requested FFmpeg-based video/composition direction has not yet been implemented or qualified. There is no claim of permanent API support, device recognition, or Linux compatibility.

[Historical experiments and retirement](research/capture-experiments-retired.md) retain findings without granting them architectural authority.

## Invariants

- Visual work never blocks musical controls or audio.
- Wrong, stale, partial or ambiguously sourced content is not current visual authority.
- Previous composed pixels are never semantic restoration authority.
- Source-specific OS handles stay outside DrivenByMoss and the wire contract.
- There is one final Push USB writer.
- A component test or past experiment is not a current product-usability claim.
