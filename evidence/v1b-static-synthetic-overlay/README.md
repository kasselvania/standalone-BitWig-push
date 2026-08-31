# V1B static synthetic overlay evidence

## Date and machine state

- Evidence date: 2026-08-31 PDT.
- Machine state: accepted macOS 26.4.1 arm64 reference fixture, Bitwig Studio 6.1, DrivenByMoss 26.4.1, and a physically connected Ableton Push 3 Controller.
- Central basis: `a13faef08ac8bb75a9e32f7ff7d4bc07fcd41c6e`, tree `c06009f822fee7bf36096739e7be6589f0b9ae34`.
- DrivenByMoss integration basis: `033ccef8c64f08e8d8d41fa90d48fa06b326a1a1`, tree `9aec7429ff093addee001a62a5a07309708fd592`.
- Source PR/head/tree: [kasselvania/DrivenByMoss#2](https://github.com/kasselvania/DrivenByMoss/pull/2), `a2e0341b7bccfa4e6b13614f4adffc2235f785f4`, tree `a81e5c4330b31f36845c25e98e322990d62f0c67`.

## Exact result

V1B passed on the accepted Mac fixture.

- With the startup property absent, the exact V1B artifact selected `PassThroughPushFramePipeline.INSTANCE`, displayed no synthetic mark, and passed all 14 property-off rows.
- With `-Dpushwig.syntheticOverlay=true`, the same artifact selected `SyntheticOverlayPushFramePipeline.INSTANCE`, invoked one synchronous render callback, returned the same `IBitmap`, displayed the fixed pink/white mark, and passed all 24 enabled rows.
- Temporary observation instrumentation derived from the exact source head measured a 960x160 frame, 1,529 changed pixels inside the declared 96x16 target, and zero changed pixels outside it.
- Actual 1,000-call measurements were below the provisional review band both off and on.
- A final property-off restart removed the mark and restored the ordinary semantic display without hot switching.
- The exact official artifact was restored at SHA-256 `98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a`, remained the sole scanned DrivenByMoss extension, and was physically confirmed loadable.

No compositor, external frame, copy, queue, transport abstraction, IPC, capture code, platform type, user setting, or functional `PushUsbDisplay` change entered the source head.

## Evidence map

- `source-topology.md` — exact fork, branch, commit, tree, two-path envelope, and PR topology.
- `activation-and-rendering.md` — startup property delivery, selection bytecode, same-reference renderer behavior, harness, and single-writer proof.
- `pixel-preservation.md` — temporary before/after encode method, hashes, mismatch counts, colors, and repeated-send observation.
- `performance.md` — exact measurement method, samples, latency percentiles, allocation sites, and real audio/control/display observations.
- `build-artifact-comparison.md` — Java/Maven builds, artifact hashes, manifests, and extracted payload comparison.
- `install-rollback.md` — safe installation, off/on/off launches, exact rollback, and restored official loadability.
- `manual-acceptance.md` — all direct property-off, property-on, recovery, and official-restoration results.

## Commands and tools

The retained result used `git`, `gh`, `java`, `javac`, Maven, `javap`, `shasum -a 256`, `stat`, `file`, `unzip`, `diff`, `cmp`, `find`, exact-name `pgrep`, Bitwig's actual executable, narrowly filtered current-run logs, a temporary external Java harness, temporary uncommitted observation instrumentation, and direct maintainer interaction with the real Push. The exact command shapes and results are recorded in the topic files.

## What this proves

- The default remains the accepted identity path.
- The enabled path adds a bounded synchronous diagnostic drawing to the complete semantic bitmap and returns the exact same object.
- The existing USB transport and sole writer remain unchanged.
- The enabled drawing preserves every observed pixel outside its declared bounds.
- Real controls, display, audio, semantic updates, restart removal, normal shutdown, and exact official rollback all passed.

## What this does not prove and unresolved questions

- No Push 2 hardware acceptance is claimed; Push 2 only shares the preserved source path.
- The new pipeline has no per-call allocation bytecode, but existing `BitmapImpl.render` retains a capturing callback call site and an explicit `new GraphicsContextImpl` allocation site. A heap profiler was not used, so JVM escape-analysis effects remain unresolved and are deferred beyond V1B.
- The timing record is a bounded 1,000-call fixture measurement, not an endurance, forced-crash, cable-removal, or cross-platform benchmark.
- Seven target pixels already matched their final synthetic values, so they did not count as byte changes; target hashes and color samples prove the target result instead of assuming all 1,536 pixels must differ.
- V1B does not prove damage restoration, runtime hot switching, external visual ingress, or final compositor architecture.
