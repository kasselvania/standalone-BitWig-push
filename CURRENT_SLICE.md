# Current Slice: V1A — Identity Push Frame Pipeline

## Status

Ready to start from current `main` after V1A-0 merge commit `096a6d62ddc4511573ecdaa9d03071b52875c05c`.

## Primary claim

Insert the first project-owned frame-pipeline seam into the accepted DrivenByMoss Push display path without changing visible output or transport behavior.

For every eligible display send, the V1A production path must remain:

```text
complete semantic IBitmap
        -> synchronous identity PushFramePipeline
        -> the exact same IBitmap object
        -> unchanged PushUsbDisplay
        -> existing Push USB endpoint
```

V1A is the first functional source change. It proves the boundary only. It does **not** compose, copy, capture, queue, or reinterpret pixels.

## Accepted authorities and bases

### Central authority repository

```text
Repository: kasselvania/standalone-BitWig-push
Basis:      096a6d62ddc4511573ecdaa9d03071b52875c05c
Tree:       df4cac9f22eb67db15bd8dc7d67212667967123f
```

### DrivenByMoss implementation repository

```text
Repository:       kasselvania/DrivenByMoss
Immutable basis:  pushwig/upstream-26.4.1
Integration base: pushwig/main
Commit:           fd03245ab38fa5149c45934051d937ee9fda6d08
Tree:             edd2ad636b0aa1f39919f0ffd05c968015450075
```

Both fork branches currently point to the same accepted upstream commit. `pushwig/upstream-26.4.1` remains immutable. V1A is reviewed into `pushwig/main`.

Accepted artifact references:

```text
V1A-0 clean local-build SHA-256:
61ff21e5f21d96ee64bfe1b09c5971116f1f5075d5805bc015f0a168fe00b8f9

Official artifact SHA-256 to restore:
98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a
```

## Required branch and PR topology

### DrivenByMoss source work

Create a clean feature branch from `origin/pushwig/main`:

```text
pushwig/v1a-no-op-frame-pipeline
```

The source pull request must:

- be opened in `kasselvania/DrivenByMoss`;
- target `pushwig/main`, not `master` and not the immutable upstream-basis branch;
- contain one implementation commit;
- remain ordinary, non-draft, open, and unmerged for technical-lead review.

### Central evidence work

Create a clean central branch from the accepted central basis:

```text
codex/v1a-no-op-frame-pipeline-evidence
```

The central pull request must:

- contain only retained V1A evidence;
- reference the exact DrivenByMoss source PR/head/tree;
- include `Addresses #<active V1A issue>`;
- remain ordinary, non-draft, open, and unmerged.

Do not put DrivenByMoss source or generated extension binaries in the central repository.

## Authorized DrivenByMoss source envelope

Expected production paths are limited to:

```text
src/main/java/de/mossgrabers/controller/ableton/push/controller/Push2Display.java
src/main/java/de/mossgrabers/controller/ableton/push/controller/PushFramePipeline.java
src/main/java/de/mossgrabers/controller/ableton/push/controller/PassThroughPushFramePipeline.java
```

Equivalent naming may be proposed only if it follows established upstream conventions and does not widen the claim. Any additional production path requires explicit justification before editing.

`PushUsbDisplay.java` is **not** authorized for modification in V1A.

## Required implementation behavior

1. Introduce one synchronous frame-pipeline contract whose input and output type is `IBitmap`.
2. Introduce one allocation-free pass-through implementation, preferably a singleton.
3. The pass-through implementation must return the exact input object reference.
4. `Push2Display` must own the production pipeline instance.
5. The existing public construction path must select the pass-through implementation automatically.
6. The existing `Push2Display.send(IBitmap)` shutdown/null guard must remain semantically intact.
7. For an eligible send, `Push2Display` must invoke the pipeline exactly once and then invoke the existing `PushUsbDisplay.send` exactly once with the returned reference.
8. The pipeline must not:
   - retain the mutable bitmap after the call;
   - invoke `render` or `encode`;
   - copy pixels;
   - allocate a frame or buffer per send;
   - create a queue, thread, executor, timer, USB object, or platform-specific dependency.
9. Keep the extension version, controller IDs, product IDs, interface/endpoint matching, encoder, transport buffers, signal shaping, and transfer scheduling unchanged.
10. Do not introduce a `PushDisplayTransport` abstraction in this slice. Transport extraction is not needed to prove the identity seam.
11. Preserve upstream copyright and LGPL notices on modified/new source.

A package-private constructor seam for focused injection is allowed only when it remains narrow and does not create a second transport owner. Do not add a new public configuration surface merely for V1A.

## Required source and bytecode proof

Retain evidence from the exact proposed DrivenByMoss head:

1. Parent commit and tree are the accepted `pushwig/main` basis.
2. The PR has one commit and only the authorized source paths.
3. `git diff --check` passes and the worktree is clean.
4. A clean Java 21/Maven build succeeds using the V1A-0 environment.
5. `javap -c` or equivalent bytecode inspection proves the pass-through method returns its argument directly and performs no frame allocation.
6. A small temporary external harness may instantiate the final pass-through class with an `IBitmap` stub/proxy and assert reference identity. The harness must not become production source or require a POM/test-framework change.
7. Source/bytecode inspection proves `Push2Display.send` preserves the guard and performs one pipeline call followed by one USB-display send.
8. Search/diff evidence proves no new USB endpoint access, queue, executor, thread, or platform capture dependency was introduced.
9. Build the accepted base and V1A head under the same toolchain and compare extracted artifacts:
   - `PushUsbDisplay.class` must remain byte-identical;
   - unrelated classes/resources must remain byte-identical unless a build-system artifact is precisely characterized;
   - differences must be limited to the expected changed/new pipeline classes and normal archive metadata.

Do not add permanent per-frame logging, hashing, counters, profiling, or debug instrumentation to production source.

## Real-fixture acceptance

Use the accepted Mac + Bitwig 6.1 + Push 3 fixture.

1. Build the exact source PR head with the explicitly pinned Java 21 environment.
2. Hash and inspect the generated extension.
3. Stop Bitwig safely.
4. Move the official artifact intact outside every extension scan path.
5. Install the V1A artifact as the sole scanned DrivenByMoss extension.
6. Launch Bitwig and run the accepted eleven-row baseline:
   - connection;
   - notes;
   - pressure/MPE;
   - encoders;
   - transport;
   - coherent semantic display;
   - Push audio-device presence;
   - audible master output through Push headphones;
   - native-device selection;
   - compatible Expanded Device View open;
   - compatible Expanded Device View float/undock.
7. Confirm there is no intentional synthetic mark, crop, overlay, or visible pipeline behavior.
8. Quit Bitwig safely and restore the exact official artifact.
9. Reverify the official SHA-256 and exactly one scanned DrivenByMoss extension.
10. Relaunch sufficiently to confirm the official extension remains loadable.

A destructive cable-removal, forced-crash, endurance, or detailed latency test is not required in V1A. Normal shutdown/relaunch behavior must be retained. Quantitative composition performance begins when V1B introduces actual pixel work.

## Expected central evidence

Retain a structure equivalent to:

```text
evidence/v1a-identity-frame-pipeline/
├── README.md
├── source-topology.md
├── implementation-proof.md
├── build-artifact-comparison.md
├── install-rollback.md
└── manual-acceptance.md
```

Every file must state what it proves and what it does not prove.

Do not commit:

- official or derivative `.bwextension` files;
- raw proprietary screenshots or UI crops;
- account/license data;
- serial numbers, hardware UUIDs, hostnames, IP addresses, or unsanitized personal paths;
- temporary identity harness binaries or source;
- full private Bitwig logs.

## Explicit non-goals

- no visible overlay or synthetic pixel;
- no second `IBitmap.render` call;
- no raw pixel readback/copy/snapshot;
- no compositor implementation;
- no `PushDisplayTransport` abstraction;
- no `PushUsbDisplay` modification;
- no queue, worker, executor, timer, or latest-frame store;
- no IPC, shared memory, socket, or external frame ingress;
- no ScreenCaptureKit helper or Screen Recording permission;
- no window discovery, visual resolver, calibration, or pixel-anchor work;
- no POM dependency or permanent test-framework change;
- no version, extension-ID, controller-ID, or USB matcher change;
- no upstream-basis upgrade;
- no Push 2 hardware claim;
- no Steam Deck/Linux, yabridge, Monome, plugdata, battery, connector, or NUC work.

## Acceptance criteria

V1A is complete only when all of the following are true:

1. The source PR is based exactly on `pushwig/main` at `fd03245ab38fa5149c45934051d937ee9fda6d08` / tree `edd2ad636b0aa1f39919f0ffd05c968015450075`.
2. The source PR contains one implementation commit and only the authorized source envelope.
3. The identity pipeline returns the exact same `IBitmap` reference.
4. `Push2Display` calls the pipeline once and the unchanged USB display once inside the existing guard.
5. `PushUsbDisplay` and all USB/encoding/transfer behavior remain unchanged.
6. No per-frame allocation, bitmap retention, pixel copy, queue, thread, executor, or platform dependency is introduced.
7. The exact source head builds successfully under the accepted Java 21/Maven environment.
8. Base/head artifact and bytecode evidence bounds the implementation delta to the intended classes.
9. The V1A artifact loads as the sole scanned extension and the full real Push baseline passes.
10. The exact official artifact is restored and reverified.
11. The source PR and central evidence PR are open, non-draft, unmerged, and point to exact retained heads.
12. Both repositories and all relevant worktrees are clean and synchronized.

## Expected V1B handoff

V1B may begin only after V1A is reviewed and merged.

V1B will answer the next, separate question:

> How can project-owned pixels be composed over the persistent semantic bitmap without damaging or unpredictably clearing the existing image?

V1A must leave a lawful synchronous seam for that work without choosing the composition representation prematurely.

## Review standard

Do not accept V1A because the source diff looks trivial. The exact source head must build, the identity/object/call-order claims must be retained, the real Push baseline must pass with the derivative installed, and the official artifact must be restored exactly.
