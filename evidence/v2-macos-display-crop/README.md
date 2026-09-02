# V2 production macOS display-crop visual lens

## Result

V2 is proven on the accepted Mac, Bitwig Studio, DrivenByMoss, and Push 3
fixture. The proposed helper captures one explicitly selected ScreenCaptureKit
display crop, applies a maximal fractional centered-cover mapping in screen
points, emits only an opaque
`560x160` BGRA raster, and publishes it through the unchanged V1D-2 receiver.
The physical Push showed useful live Bitwig Sampler pixels without disturbing
DrivenByMoss controls, semantic pixels outside the destination, or Push audio.

The production path is:

```text
explicit SCDisplay 5
    -> validated normalized crop 0.14,0.68,0.45,0.305
    -> maximal centered-cover source rect 480.2,984.1275,1543.5,441.0 points
    -> ScreenCaptureKit 560x160 opaque BGRA output
    -> accepted V1D-2 protocol v1 over IPv4 loopback with 250 ms write deadline
    -> accepted current-semantic redraw and raster writer
    -> unchanged DrivenByMoss PushUsbDisplay writer
```

The source is proposed in
[PR #43](https://github.com/kasselvania/standalone-BitWig-push/pull/43).
The helper source and this evidence remain unmerged pending review. The exact
official DrivenByMoss artifact was restored after the experiment.

## Date, machine state, and authority

- Evidence date: 2026-09-02 PDT.
- Machine state: macOS 26.4.1 build 25E253, Darwin 25.4.0, arm64 maintainer
  fixture; Bitwig Studio 6.1; DrivenByMoss 26.4.1; real Ableton Push 3; Push
  headphone audio route.
- Final ordinary state: Bitwig and its audio engine closed; helper stopped; no
  ingress listener; one scanned official `DrivenByMoss.bwextension`; no live
  capability file.
- Corrected central basis/tree:
  `7c15abaf55c0080b2f80971e845b4ee6f1bfcc46` /
  `730726784b57016714c0a44c8f0f8caf1c5b0141`.
- Accepted V1D-2 evidence commit/tree:
  `198b44a838009dac0df83464501004b6e6b59d9d` /
  `76d9f92ae8ec7369790b0b8dd325cd4a602e3dbb`.
- Source branch: `capture/v2-macos-display-crop-lens`.
- Source head/parent/tree:
  `03fb8c8824714e4bbefd7224848ca9cdad069088` /
  `7c15abaf55c0080b2f80971e845b4ee6f1bfcc46` /
  `f1f68bc6f0ba6527bb146a7ee93fd4333ffaf796`.
- DrivenByMoss integration commit/tree, unchanged:
  `7e3416a1bdddbcbeec4e35e6531652e1618723de` /
  `c8bc3f9e052e8f0b7b5dd256657697349d303740`.
- Proposed helper executable SHA-256:
  `9a81bb292cfa00588c4be0272abb11a2e223132feb8725aca6e2c6a808bf942a`.
- Exact tested derivative SHA-256:
  `3a05c8490f8947d82f80677982c1c52f71bba1b6e3b8dd37c94ce0246d0c7b48`.
- Restored official SHA-256:
  `98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a`.

## Headline evidence

- Source begins directly at the corrected authority basis and changes exactly
  eleven paths under `capture/macos/**`.
- The quarantined dedicated-window branch was neither merged nor
  cherry-picked and still has no pull request.
- Fifteen deterministic Swift tests and a separate 21-case runtime negative
  matrix passed with no capture or protocol publication on invalid input.
- The original signed V2 app binary produced both the public Screen Recording
  denial and later granted paths under bundle ID
  `com.kasselvania.pushwig.capture-helper`. The amended exact binary retained
  that stable identity and independently reported granted capture; the denial
  matrix was not repeated.
- The exact fixture selected display ID 5 at `3430x1447` ScreenCaptureKit
  points; it never selected by array position.
- Centered cover maps the requested source crop to
  `480.2,984.1275,1543.5,441.0` points and uniformly scales it by
  `0.362811791383...` into Push destination `400,0,560,160`, with no padding,
  GCD quantization, or independent-axis stretch.
- A deterministic `559x160` regression retained `>99.8%` of the ideal cover
  area instead of collapsing to the former `1118x320` GCD multiple.
- Every complete HELLO, FRAME, or CLEAR has one fixed 250 ms monotonic write
  deadline. Forty post-warmup stalled-reader runs failed closed and released a
  queued shutdown in at most `251.868/251.863` ms respectively.
- At 30 fps, 2,179 complete frames were sent over sequence 1 through 2,180,
  with one CLEAR and zero incomplete, format, dimension, alpha, full-display,
  wrong-destination, or helper-rejected delivered callbacks. Together with
  1,231 intentional guard suppressions, these account for all 3,410 delivered
  callbacks. ScreenCaptureKit exposes no count for callbacks it never
  delivered, so that upstream count remains unknown.
- The previously retained full run's accepted-sample processing measured
  p50/p95/max `1.141459/1.553917/2.523375` ms. Copy/map/normalize/send measured
  `0.172916/0.218208/0.709375` ms. RSS stayed at 39,008 KiB throughout the
  comparable interval.
- The exact amended helper independently retained 1,003 post-warmup frames:
  accepted-sample p50/p95/max was `1.851416/2.628583/4.628208` ms and normal
  loopback send was `0.079375/0.091916/0.489875` ms.
- The previously retained physical acceptance passed all 31 rows, including
  live Sampler changes, fixed-region confinement, guard loss/resume, permission fallback,
  helper exits, controls, display, audio, and normal Bitwig shutdown.
- A focused exact-amended-app smoke reran only live capture, proportions,
  guard CLEAR/recovery, and normal helper quit. All passed; the earlier 31-row
  result was not repeated.
- Final rollback restored exactly one official artifact at the accepted hash;
  the maintainer reconfirmed standard display, controls, audio/headphones, and
  absence of captured/generated pixels.

## Evidence map

- [source-topology.md](source-topology.md): bases, source custody, changed paths,
  source hashes, quarantine, and unchanged DrivenByMoss.
- [helper-build-and-identity.md](helper-build-and-identity.md): macOS toolchain,
  app bundle, signing, binary identity, tests, and stable TCC attribution.
- [display-selection-and-guard.md](display-selection-and-guard.md): exact display
  selection, dimension revalidation, source-validity guard, and the repaired
  AppKit event-loop defect.
- [crop-aspect-and-pixel-contract.md](crop-aspect-and-pixel-contract.md): crop,
  centered-cover math, format, stride, alpha, and protocol facts.
- [sampler-result.md](sampler-result.md): direct live Sampler observation and
  bounded photo-derived observations without retaining images.
- [permission-and-fallback.md](permission-and-fallback.md): public permission,
  loss/invalid states, CLEAR behavior, exits, and bounded limitations.
- [performance.md](performance.md): 15/30-fps timing, counters, CPU, RSS,
  buffers, queues, and thread topology.
- [real-fixture-and-rollback.md](real-fixture-and-rollback.md): installation,
  31-row acceptance, shutdown, and exact official rollback.
- [limitations-and-next-resolution.md](limitations-and-next-resolution.md): the
  deliberately fixed-coordinate fixture boundary and next bounded work.

## Commands and tools

Tools included `git`, `gh`, `rg`, `xcodebuild`, `xcrun swift`, SwiftPM,
`codesign`, `plutil`, `shasum -a 256`, `file`, `ps`, `lsof`, public
ScreenCaptureKit/CoreGraphics/CoreVideo/AppKit APIs, generated-pixel tests,
narrow aggregate logs, and direct physical maintainer observation. No captured
frame, screenshot, app bundle, binary, capability value, or full log is
committed.

## What this proves

- A stable-identity public macOS helper can carry useful live pixels from one
  explicit bounded display crop to the accepted Push raster destination through
  unchanged V1D-2 and its one existing Push USB writer.
- Aspect, pixel, guard, permission, bounded-resource, control/audio, and exact
  rollback claims hold on the accepted fixture.

## What this does not prove

- It does not locate Bitwig, Sampler, native-device panels, or plug-in windows.
- It does not track movement, resize, display changes, UI scale, or device-panel
  layout changes. A frontmost-Bitwig guard is application authority, not panel
  identity.
- It does not prove Push 2, another Mac/display topology, remote transport,
  endurance behavior, or a production installer/notarization path.
