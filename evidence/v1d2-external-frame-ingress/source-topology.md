# Source topology and custody

## Date, state, and authority

- Date: 2026-09-01 PDT.
- Machine state: accepted macOS 26.4.1 arm64 fixture; Bitwig closed after exact
  official rollback.
- Central basis/tree:
  `fe8216fcadc9879bafa96acbb0f064f1d6625f4b` /
  `580786862a6f034aa111b60c4d434e64c44c7211`.
- DrivenByMoss basis/tree:
  `663d719207ef58ec84b4d235c43211ec5da43605` /
  `c4e42825d069421a44b3241349de9a7c6453a3ad`.
- Source PR/head/tree:
  <https://github.com/kasselvania/DrivenByMoss/pull/5> /
  `830b778b720a06f56de08861d27052228c82c63b` /
  `c8bc3f9e052e8f0b7b5dd256657697349d303740`.
- Source parent: `663d719207ef58ec84b4d235c43211ec5da43605`.
- Harness/producer/observer SHA-256:
  `007822786260f89a9c3d005b669162389843a4dad2fb3293c6c131762c32bd18` /
  `993cb0f4d14c0a909a629ac4063e6e1937cb50ca42075e9fbbd3f099253bacbb` /
  `2e6ff0f6e2236e0b6ad85a831ba3f8c18f3362263eeaba425749fb4cbf929eb4`.

## Repository topology

The production worktree was:

```text
$HOME/Documents/ChatGPT/BitWig Standalone Push/DrivenByMoss-v1d2
```

Remote roles were verified as:

```text
origin   git@github.com:kasselvania/DrivenByMoss.git
upstream https://github.com/git-moss/DrivenByMoss.git
```

`origin/pushwig/main` matched the accepted basis. The immutable
`origin/pushwig/upstream-26.4.1` remained
`fd03245ab38fa5149c45934051d937ee9fda6d08` with tree
`edd2ad636b0aa1f39919f0ffd05c968015450075`.

The feature branch is `pushwig/v1d2-external-frame-ingress`. It contains one
implementation commit with message `V1D-2: implement external latest-frame
ingress`; its parent is exactly the accepted integration commit. The remote
branch and PR head were read back at the same exact commit.

## Exact production paths and hashes

Only these paths changed:

| Path | Disposition | Source SHA-256 |
| --- | --- | --- |
| `src/main/java/de/mossgrabers/controller/ableton/push/controller/Push2Display.java` | modified | `7eb6a69d4a4932801db8d846dd3de0804dfae798ec186aa2195612727f03c79a` |
| `src/main/java/de/mossgrabers/controller/ableton/push/controller/ExternalRasterPushFramePipeline.java` | added | `d26a02588670936cdb49a715b70773204b5ce018bdd77b513570984619cf5a4a` |
| `src/main/java/de/mossgrabers/controller/ableton/push/controller/ExternalRasterReceiver.java` | added | `77d87554bd5a5087b6425d2cc1f980b6916996985c74a315842ff2396f8a9026` |
| `src/main/java/de/mossgrabers/controller/ableton/push/controller/LatestExternalRasterFrameStore.java` | added | `ff6d227b0cf044724e24350e3ace3ef0534861683a90fb48df4b854ea6b4fa1b` |

The source diff is 1,112 insertions and 6 deletions. `git diff --check` passed.
No POM, version, ID, USB, bitmap adapter, V1D-1 sink, earlier pipeline, or
authority/status file changed.

## Construction-time selection

`Push2Display` reads these Java system properties only during construction:

- `pushwig.externalRasterIngress`;
- `pushwig.externalRasterPort`;
- `pushwig.externalRasterTokenFile`;
- `pushwig.externalRasterStaleTimeoutMs`.

Selection precedence is external ingress, V1D-1 local raster, V1C vector, V1B
static overlay, then pass-through. Successfully constructed external mode sets
current-model semantic redraw. Requested external mode with invalid
configuration or bind failure emits one bounded error, starts no receiver,
selects pass-through semantics, disables continuous redraw, and does not fall
through to a lower diagnostic.

The existing guarded send remains one pipeline call followed by one
`PushUsbDisplay.send`. External shutdown begins before the final semantic
shutdown message; the existing shutdown executor performs the bounded join and
then the unchanged USB/superclass shutdown.

## New internal types

- `ExternalRasterReceiver`: package-private socket/parser/session owner; one
  thread; no bitmap, raster writer, display, or USB reference.
- `LatestExternalRasterFrameStore`: package-private fixed latest-publication
  owner; one lock; primitive metadata; authority epoch; no queue.
- `ExternalRasterPushFramePipeline`: package-private display-thread consumer;
  one fixed consumer array; no socket; at most one V1D-1 write; returns the
  exact input `IBitmap`.
- `LatestExternalRasterFrameStore.DisplayFrame`: one construction-time nested
  display metadata holder. It is not constructed per frame.

## Source and bytecode inspection

`javap -c -p` outputs had these SHA-256 values:

| Class | Disassembly SHA-256 |
| --- | --- |
| `Push2Display` | `8f981ceb6a9e48b71492d0e40526c1042b4d77f4f5538fec36b55ee8580248ff` |
| `ExternalRasterPushFramePipeline` | `75acc6f4e34726d6063cfbadc3b6fbfeeec98e3ace70c1746981611302b7d123` |
| `ExternalRasterReceiver` | `9c12e0bc83100900852e8a070c54a933addca59a7bc2c245c77a120f97a842cb` |
| `LatestExternalRasterFrameStore` | `c497f16f7906a0f13b0faf43e5a1297031f9bf59468be98faac60f373513c284` |

The disassembly proves construction-only property access and precedence; one
receiver-thread construction; explicit loopback bind with address reuse before
bind; fixed header/staging/publication/consumer arrays; fixed-header parsing;
no allocation from payload length; complete validation before publication;
store `tryLock` on display adoption; at-most-one raster write; exact input
bitmap return; and authority/socket close before bounded join and unchanged USB
shutdown.

Changed-source searches found no application frame queue, executor pool,
scheduled retry, mapped buffer, object stream, HTTP/WebSocket/OSC transport,
wildcard bind, receiver bitmap/raster/USB dependency, or pipeline socket
dependency.

## Commands and tools

Evidence came from `git fetch`, `git rev-parse`, `git worktree list`, `git
status`, `git diff --check`, `git diff --stat`, `git diff --name-only`, `rg`,
`shasum -a 256`, clean Maven builds, extracted archive comparison, `javap -c
-p`, `gh pr view`, and remote ref readback.

## Exact result

The source envelope, ancestry, remote branch, PR head, protected paths, and
bytecode shape all match the production contract. Source, base-build, and
observation worktrees were clean at handoff.

## What this proves

- Production V1D-2 is a one-commit, four-path change over the exact accepted
  integration basis.
- Receiver, store, display composition, existing send, and shutdown ownership
  are separated as authorized.
- The existing sole transport path remains the only Push display writer.

## What this does not prove

- Source/bytecode inspection alone does not prove physical output, malformed
  behavior, timing, or rollback; those are retained separately.
- It does not claim Push 2 hardware acceptance or authorize future capture,
  scaling, remote ingress, or public adapter APIs.
