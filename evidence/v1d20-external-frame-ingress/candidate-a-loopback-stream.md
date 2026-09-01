# Candidate A: loopback framed stream

## Date, state, and authority

- Date: 2026-09-01 PDT.
- Machine state: accepted macOS 26.4.1 arm64 fixture; source worktrees were isolated from all unrelated work.
- Central basis/tree: `5597624bd50e5ef95ecd3af82ea1816ce4facd21` / `ec016bd3174345e32f1a6d47eb061820e7a1e9b9`.
- DrivenByMoss parent/tree: `663d719207ef58ec84b4d235c43211ec5da43605` / `c4e42825d069421a44b3241349de9a7c6453a3ad`.
- Local worktree/branch: `$HOME/Documents/ChatGPT/BitWig Standalone Push/DrivenByMoss-v1d20-a-loopback`, `research/v1d20-loopback-stream`.
- Final local research commit/tree: `4f00972355fcf7b5f0ead0fef3365b81850be12f` / `7202267e51d0f2613cea93d186b132a996ec14ec`.
- No candidate branch was pushed and no DrivenByMoss PR exists.

## Selected shape

Candidate A uses one `ServerSocket` bound to IPv4 `127.0.0.1` and configurable port `45291`, backlog `1`. One daemon receiver thread owns accept, authentication, header/payload reads, ingress validation, session tracking, and the staging array. It publishes only complete accepted messages into one fixed latest-publication array under a short `ReentrantLock` critical section.

The Push display thread uses `tryLock`, copies a newer complete publication into one fixed display-owned array, releases the lock, invokes the accepted V1D-1 raster writer, returns the exact same `IBitmap`, then enters the unchanged `PushUsbDisplay.send` path.

Construction-time activation is `-Dpushwig.v1d20ExternalIngress=true`. Port, private token-file path, and stale timeout are also construction-time properties. No property is polled per frame and no user-facing setting was added.

## Exact changed paths and final hashes

| Path | SHA-256 |
| --- | --- |
| `src/main/java/de/mossgrabers/controller/ableton/push/controller/Push2Display.java` | `f6b70d20700ab145531b85b638b0f70612fe46024489bb6ea1c58f1af191c1ad` |
| `src/main/java/de/mossgrabers/controller/ableton/push/controller/ExternalRasterPushFramePipeline.java` | `9e32e62b2b9340e27e4666f2bae881a0e0131da2ba0ab805458f954a99b250af` |
| `src/main/java/de/mossgrabers/controller/ableton/push/controller/ExternalRasterReceiver.java` | `4d451d8e22db0a8cd29fca8342bedc4d5f4ea141945c7a275a784b29f573a27f` |
| `src/main/java/de/mossgrabers/controller/ableton/push/controller/LatestExternalRasterFrameStore.java` | `cc658bc128ee5164a229b0650cc8cca608f87e89c29d8a7da46333d85f2297a6` |

`PushUsbDisplay.java`, `pom.xml`, and all other production source paths were untouched.

## Research iterations and restart correction

The first clean candidate iteration was:

- commit/tree: `e7b6308e885843d0d0fed5726894be404fe017e3` / `921b2f9ecd35c3fc2a07e35dce9995645e252503`;
- patch SHA-256: `762c9011ab54e02ce1a921b84162166f4d584bd024f0c8d30a86407d46395b85`;
- artifact: `14,386,473` bytes, SHA-256 `d2daf3e0a66e87d0eda60ecd9dfb3b1102b5c30c855b6bbfde66981e3f2a47b2`.

It passed correctness and live frame behavior, but a rapid Bitwig restart following the authenticated-idle shutdown hit `BindException: Address already in use`. The exact cause was candidate-owned `ServerSocket.setReuseAddress(false)`: no process or live socket owner remained, but the new construction did not recover from the post-close kernel state. Ingress failed closed to ordinary semantics, as designed, but the restart behavior was not acceptable.

The final iteration changed only the socket construction to enable address reuse before binding. A temporary Java 21 harness proved both required sides:

```text
SOCKET_REUSE_HARNESS PASS active_second_rejected=true immediate_rebind=true
```

- Harness source SHA-256: `c468b620d2eea11315f8689df85a6c6e8a68bfd3a16c3248eb4166a3706f105c`.
- Final commit/tree: `4f00972355fcf7b5f0ead0fef3365b81850be12f` / `7202267e51d0f2613cea93d186b132a996ec14ec`.
- Final patch SHA-256: `3bd908ba7ca6e5c92ca4275fbc18864d49eb35200b6636d8d42e5df83d4d6ada`.
- Final artifact: `14,386,473` bytes, SHA-256 `b7b3e98438292c86e79bcf284a18c156f7bfc6b86cb116e4ecdead26fa615464`.

An extracted comparison of the pre-fix and final artifacts found only `ExternalRasterReceiver.class` different. The exact final artifact then rebound the same port immediately after every live shutdown and passed all five blocking shutdown states itself.

## Source and bytecode proof

`git diff --check` passed. Source search found no HTTP, WebSocket, OSC frame transport, `ByteBuffer`, memory map, screen capture, platform capture type, or second USB owner. `javap -c -p` established:

- `Push2Display` reads the activation property only in construction;
- external mode forces current semantic redraw before each eligible send;
- `Push2Display.send` still calls one pipeline and one `PushUsbDisplay.send` under the existing shutdown/null guard;
- `ExternalRasterPushFramePipeline.process` performs only `tryAdopt`, one accepted V1D-1 `writeRasterRegion`, and same-reference return;
- the receiver thread never references `IRasterWritableBitmap`;
- `tryAdopt` uses `ReentrantLock.tryLock`, not `lock`;
- `LatestExternalRasterFrameStore.close` is a volatile close/epoch update and takes no lock;
- the only new thread construction is the single named daemon receiver;
- shutdown closes authority/client/server before the existing Push/USB shutdown executor waits for the bounded receiver join.

## Build and identities

The exact Java 21 build completed successfully in `17.389 s` at `2026-09-01T16:00:37-07:00`. Existing shade overlap/module warnings were unchanged and non-fatal.

Temporary, uncommitted test identities:

| Tool | SHA-256 |
| --- | --- |
| Python producer | `b19192e78ff225b85e1a6e40178939bb5e5c344bd4a9e9526696e95f095022aa` |
| Full correctness harness | `ed8a73fdbf5dc2e989331195719e64b5c42c2a6dae981aeda6596d7e4b653b3f` |
| Exact-final allocation harness | `78e98ae0d6acf8339134b8b9492cb7d035525ce6369d46316654da95a7030548` |
| Failure-latency harness | `44f51daaeb8ef28603dace7a8d99bdd839d49d69316f7cbff01e440fa207b61f` |
| Socket-reuse harness | `c468b620d2eea11315f8689df85a6c6e8a68bfd3a16c3248eb4166a3706f105c` |

The producer used Python `3.14.5` and only standard-library networking/packing.

## Commands and tools

Commands included basis/remotes/worktree readback; `git diff --check`; allowlist/forbidden-symbol `rg`; exact Java/Maven build; `javap`; deterministic Java/Python harnesses; artifact extraction and `diff -qr`; loopback `lsof`; and physical Bitwig/Push checks.

## What this proves

- Candidate A satisfies the required local-only, fixed-memory, complete-publication, latest-frame, nonblocking-display, same-bitmap, one-writer architecture.
- The restart defect was observed, bounded, corrected within Candidate A, and reproved offline and live rather than softened into uncertainty.
- Source custody is exact enough to propose a production slice without retaining the prototype itself.

## What this does not prove

- The local research commit is not a production review surface and must not be merged as-is.
- It does not establish a public producer SDK, service discovery subsystem, token broker, or capture adapter.
- It does not authorize multiple simultaneous producers or non-loopback access.
