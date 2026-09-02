# V3 Bitwig window-relative visual lens evidence

Date: 2026-09-02

## Result and repair gate

The repaired V3 production path no longer relies on
`SCStreamConfiguration.sourceRect` to crop a desktop-independent single-window
stream. ScreenCaptureKit supplies one bounded full-window pixel buffer. The
helper computes the normalized crop in that buffer, applies one uniform
centered-cover scale through Core Image, normalizes alpha, and renders directly
into the existing reusable protocol output buffer.

A native four-quadrant ScreenCaptureKit fixture proves that two non-overlapping
profile crops select different expected source pixels. Committed tests and an
exact packaged-helper run prove the crop, stride, resize, storage, protocol, and
performance contracts. Focused observation on the real Push then confirmed the
normal Sampler crop, a deliberately distant upper-right crop, clean restoration,
move, supported resize, source loss/recovery, musical controls, and audio. The
exact official DrivenByMoss artifact was restored and physically confirmed.

The resize result retains an important product limitation rather than hiding
it: the normalized window crop remained current, stable, and proportionally
correct, but Bitwig reflowed Sampler outside the useful crop. V3 attaches a
raster region to the Bitwig window; it does not identify or anchor to an
internal Bitwig device. The maintainer considers that screen-crop approach too
hacky for the eventual product, and the technical lead must select any later
device-aware design.

## Authority, machine state, and commands

- Central basis commit/tree:
  `acf9625317cd828496ab86bad05e22024957d68a` /
  `6ba9018910d6a6ef7ae856f8248a1c94828d696e`.
- Repaired V3 implementation commit/tree:
  `0c9606bc030e7655acf98c8c4f05ce30426d7f95` /
  `79342057c48b1bb3dcb8be30792273131de5d94d`.
- Branch: `capture/v3-window-relative-lens`.
- Implementation-path SHA-256 manifest:
  `14ae4b5cb5b627269a74042ea99a5fe84b9247ba704fc8c8f1e387ae441f72ef`.
- DrivenByMoss integration commit/tree remained
  `7e3416a1bdddbcbeec4e35e6531652e1618723de` /
  `c8bc3f9e052e8f0b7b5dd256657697349d303740`; its source worktree was clean and
  no DrivenByMoss source changed.
- macOS 26.4.1 build 25E253, Apple silicon, Bitwig Studio 6.1 revision
  `94a90411037fa337883222813b7372a3ace9dbd7`, Ableton Push 3 Controller.
- Current safe checkpoint: ordinary Bitwig is running with no helper, listener,
  or test properties; the temporary capability is removed and exactly one
  scanned DrivenByMoss extension is present at the official SHA-256.

Commands and tools included `git status/rev-parse/diff`, `xcrun swift-format`,
`xcrun swift test`, `build-app.sh`, `swiftc`, `plutil`, `codesign`, `shasum`,
`ps`, `lsof`, a bounded generated-window receiver, ScreenCaptureKit public APIs,
Core Image, and the packaged helper's fixed-capacity metrics. Temporary fixture
source, receiver source, capabilities, and generated pixels are not committed.

## Why the original proof was insufficient

Production used `SCContentFilter(desktopIndependentWindow:)` and assigned the
profile crop to `SCStreamConfiguration.sourceRect`. Apple documents that
`sourceRect` is not referenced when capturing a single window. The previous
fixture proved desktop-independent Bitwig capture and its lifecycle, but did
not compare outputs from two materially different profile crops. It therefore
could not establish that profile normalization controlled the selected pixels.

The repaired ownership path is:

```text
desktop-independent full-window ScreenCaptureKit frame
        -> crop normalized against actual source-buffer dimensions
        -> top-left profile crop translated to Core Image coordinates
        -> edge-clamped maximal centered-cover source
        -> one uniform Lanczos scale
        -> existing reusable opaque-BGRA destination buffer
        -> unchanged V1D-2 protocol and DrivenByMoss path
```

`sourceRect` and `destinationRect` are left unset in window mode. V2
explicit-display mode retains its accepted display-filter `sourceRect` path.

## Generated native conformance proof

A temporary ad-hoc AppKit application created one borderless 800x600-point
window owned by `com.kasselvania.pushwig.crop-conformance-fixture`. Its content
was four unmistakable solid quadrants in top-left row order: red, green, blue,
and yellow. The exact packaged production helper captured the real
ScreenCaptureKit window twice, through a temporary protocol-v1 receiver:

- A: normalized top-left crop `(0,0,0.5,0.5)`;
- B: normalized bottom-right crop `(0.5,0.5,0.5,0.5)`;
- both: destination `0,0,560,160`, centered-cover, 30 fps.

ScreenCaptureKit delivered 1600x1200 BGRA buffers with 6,400-byte row stride
and point scale 2. The window/filter content rect was
`120,727,800,600` points. The repaired helper read back:

| Crop | Window-local effective points | Effective pixel crop |
| --- | --- | --- |
| A | `0,92.857143,400,114.285714` | `0,185.714286,800,228.571429` |
| B | `400,392.857143,400,114.285714` | `800,785.714286,800,228.571429` |

The one-frame outputs were:

| Result | A | B |
| --- | ---: | ---: |
| SHA-256 | `b3fa2a22f98162b353b43120cf8f6e13c8cd543788f92142c78ff2284be8de42` | `643891cc8bea0c665a15c05983e484fcdad952dd27caaa05013e469f3592830f` |
| Exact expected-color pixels | 87,920 red | 87,920 yellow |
| Other fixture-quadrant pixels | 0 | 0 |
| Opaque-alpha failures | 0 | 0 |
| Unique BGRA colors | 4 | 4 |

Each 89,600-pixel output contained the 87,920 expected solid pixels plus three
560-pixel Lanczos edge rows derived only from that same selected color. Neither
contained any marker/color from the other three quadrants, and neither was a
scaled miniature of the full window. A then B produced different hashes, and a
second independent A/B run reproduced both exact hashes.

Temporary-input identities were:

| Material | SHA-256 |
| --- | --- |
| Quadrant fixture Swift source | `5b104e61cc2e933d900a37f31fab64ba4c41be60a885ab293a72cdafc164cc5f` |
| Fixture executable | `fe929d527af49faf3203b465c428ad5af7c3aa3adc43011ca07d2f4eac01b36e` |
| Fixture plist | `6645c314fd246551b65c01625e2351aa88ea26ff2b9f9e8e8685d8dc86ce0924` |
| A profile | `f8779ab243ed554de558523a8ea91f98c4aa7e98b7100756054bd10fd5fb8589` |
| B profile | `b58dae43d397966d3438c6bc45272d64386809457a805e59401d4ffc8a9a7ecd` |
| Protocol receiver | `1174f56829bc6a33e0d978e61468d9c5fc5dd5209b43f90d3bb33b4bce2dc6d2` |

The temporary capability and generated frames were deleted; none is retained
in Git. This proof establishes the actual packaged ScreenCaptureKit path, not
only pure geometry.

## Point, pixel, stride, scale, and storage contract

Profile coordinates are normalized in top-left window-content order.
`SCContentFilter.contentRect` and `SCWindow.frame` describe points. The helper
requests native backing resolution when within bounds, then uniformly bounds
the full-window stream to at most 2560x1600 and 4,096,000 pixels. Integer stream
dimensions define the observed X/Y point-to-output-pixel ratios; no assumption
that every fixture always remains at the nominal backing scale is made.

For the unattended repaired Bitwig run:

| Fact | Value |
| --- | --- |
| Window ID / generation | `14942` / `1` |
| Window and filter content rect | `715,283,1979,967` points |
| ScreenCaptureKit point scale | `2.0` |
| Full-window capture | `2560x1250` pixels, stride `10,240` |
| Actual point-to-buffer scale | `1.293583 x 1.292658` |
| Normalized profile | `0.14,0.68,0.45,0.305` |
| Requested crop | `992.060,940.560,890.550,294.935` points |
| Effective centered-cover crop | `992.060000,960.806071,890.550000,254.442857` points |
| Window-local effective crop | `277.060,677.806,890.550,254.443` points |
| Helper-local pixel crop | `358.400000,876.053571,1152.000000,329.142857` |
| Destination | `400,0,560,160`, stride `2,240`, 358,400 bytes |

`WindowFramePlan` recomputes crop geometry from actual CVPixelBuffer dimensions.
It flips only Y when translating top-left profile rows to Core Image's
lower-left image coordinates. Core Image respects CVPixelBuffer row stride,
clamps the selected crop before interpolation, and applies
`CILanczosScaleTransform` with aspect ratio 1 and one uniform scale. The final
in-place alpha pass sets every destination alpha byte to `0xFF`.

ScreenCaptureKit owns its bounded queue-depth-2 source buffers. Project-owned
fixed storage is one 358,400-byte protocol output array and one reusable
`CIContext`. Rendering targets that array directly; no destination-sized array,
frame FIFO, second callback queue, or extra worker is created per frame. Core
Image retains its own bounded framework-managed internals; this evidence does
not claim zero framework allocation. Stable RSS and fixed topology demonstrate
no unbounded growth or application backlog.

## Deterministic validation and V2 regression

From `capture/macos`, against the repaired implementation tree:

```text
xcrun swift-format lint --recursive --strict Sources Tests
xcrun swift test --scratch-path /tmp/<fresh-directory>
```

Strict format lint passed. A fresh-scratch Swift 6.3.1 build executed 36 tests
with zero failures: 21 V3 tests and all 15 V2/protocol regressions. The new
coverage includes actual generated-region pixels for non-overlapping crops,
padded source stride, crop bounds, uniform centered-cover scaling, opaque alpha,
resize recomputation, absence of other-quadrant/full-window leakage, and a
stable destination-array address across 32 renders.

V2 explicit-display configuration remains available and cannot be mixed with
profile mode. Protocol v1, its 250 ms complete-message deadline, sequence and
capability rules, one serial output queue, one reusable output buffer, and the
sole DrivenByMoss USB writer remain unchanged.

## Packaged app identity

The clean external release build and the installed/tested helper were identical:

| Fact | Value |
| --- | --- |
| Bundle ID | `com.kasselvania.pushwig.capture-helper` |
| Executable SHA-256 | `3643470c44f9f8a86b5a77d0e786e434ab9d44e1494a3c9349ac0ea837b02b8f` |
| `Info.plist` SHA-256 | `2b01780f17aedee57c9d9c0b5946de3ce612f52873f9100cd079a9839604332f` |
| `CodeResources` SHA-256 | `6686de10a28a2fe11b36cbb86dcbacc827cfc4ea116b4dabf1845e5aee629e9b` |
| Path-independent sorted app-file manifest SHA-256 | `8a5f21f84c6de0d1aa05338b3ba19b4325f7f7cb86eb23a8e49f67ba8f39b68d` |
| CDHash | `7d59fdcc7b0a30126601b89edfd3ea069effc224` |
| Signature | valid strict ad-hoc; no Team ID claim |

The build used `capture/macos/scripts/build-app.sh` with external build and app
directories. `plutil` and `codesign --verify --deep --strict` passed. No build
product is tracked.

## Repaired 30-fps performance

The exact packaged helper ran against the exact accepted DrivenByMoss receiver
and real Bitwig window. After 100 warmup frames it retained 1,898 complete
frames over 69.910 seconds (28.565 observed fps).

| Interval | p50 | p95 | Maximum |
| --- | ---: | ---: | ---: |
| Callback interval | 34.841 ms | 36.684 ms | 42.420 ms |
| SCK frame delivery to callback | 0.545 ms | 0.944 ms | 6.797 ms |
| Pixel-buffer lock/access | 0.334 ms | 1.197 ms | 2.161 ms |
| Helper crop setup | 0.032 ms | 0.066 ms | 0.358 ms |
| Helper crop + Lanczos render | 1.191 ms | 1.570 ms | 8.423 ms |
| Opaque-alpha normalization | 0.015 ms | 0.016 ms | 0.098 ms |
| Loopback socket send | 0.087 ms | 0.111 ms | 0.430 ms |
| Crop/map/normalize/send | 1.720 ms | 2.725 ms | 9.092 ms |
| Complete accepted sample to send | 1.758 ms | 2.763 ms | 9.130 ms |

The 30-fps request is an upper target; callback cadence and project processing
remain separate facts. Fifty one-second `ps` observations reported 7.99%
average CPU, 12.0% maximum, and RSS 58,528 -> 58,496 KiB (58,576 KiB peak;
58,048 KiB minimum). The run had zero incomplete samples, invalid pixel
buffers, pixel-format/dimension/stride/alpha mismatches, protocol or stream
failures, wrong-destination/full-display publications, stale-generation
callbacks, or frames after authority loss. It sent 1,998 frames and one normal
shutdown CLEAR. Topology read back one capture output, ScreenCaptureKit queue
depth 2, one project serial output queue, one reusable output buffer, and zero
application frame queues.

This run proves the repaired full-window/crop/scale path remains comfortably
inside one 30-fps interval and does not exhibit unbounded memory growth. It does
not substitute for direct observation of which pixels appeared on Push.

## Focused repaired-helper physical result

The focused fixture used the exact packaged helper and one Bitwig window,
`15018`. With the maintained profile crop `(0.14,0.68,0.45,0.305)`, the
maintainer directly confirmed a useful live Sampler/device-chain region with
correct proportions, fixed destination, and no whole-window miniature.

The same executable was then restarted with a temporary profile whose only
material visual change was normalized crop `(0.50,0.05,0.45,0.305)` (SHA-256
`6033d64c0970478a1ca73967290c99ed2cd78ab338830d378693c126c9ea6540`).
The helper read back a different pixel crop,
`1280.000000,88.553571,1152.000000,329.142857`, and the maintainer saw a
clearly different upper-right Bitwig region, correctly proportioned and confined
to the same Push destination. It was neither Sampler nor a miniature of the
whole window. Restarting the maintained profile restored the original Sampler
crop with no leftover upper-right pixels. This is the direct physical proof that
profile normalization controls actual selected pixels.

The Bitwig window was moved substantially. Runtime readback recorded ten global
position changes while ignoring position as identity; the maintained crop stayed
attached to current Bitwig content, never switched to desktop or another app,
and retained correct proportions and normal controls/audio.

The window was then resized through supported dimensions. The helper revoked
and replaced bounded capture generations, recomputed the helper pixel crop, and
settled at a 2087x1085-point window with a 2560x1330 full-window buffer and
pixel crop `358.400000,942.653571,1152.000000,329.142857`. The maintainer
confirmed the capture returned stable, pixels were correctly proportioned,
Bitwig data was current, and controls remained normal. Sampler itself was no
longer properly framed because Bitwig moved/reflowed it inside the window. That
is a failing product-quality device anchor but not a failure of the explicit V3
normalized-window crop contract; no device-aware anchor is claimed or added.

Stopping the helper sent one CLEAR and produced clean DrivenByMoss semantic
fallback. Restarting the exact helper and maintained profile restored current
Bitwig pixels with no stale image, tearing, or residue. In the longer move/resize
run, runtime custody reported five capture generations, zero stale-generation
callbacks, zero frames after authority loss, zero wrong-destination/full-display
publications, and no protocol/stream failure. Two delivered callbacks were
classified idle during stream replacement and were not published.

The maintainer finally confirmed all of: pads produce notes, pressure/MPE,
encoders, transport, Push as Bitwig's audio device, audible headphones, and no
whole-window miniature, tearing, stale frame, or unrelated-application pixels.
The earlier full V3 fixture additionally remains evidence for occlusion and a
new Bitwig window instance; the repair did not alter window selection or
generation ownership. Ambiguity remains deterministic rather than physically
manufactured.

## Installation and exact rollback

Before the unattended repaired-path run, the official artifact at
`$HOME/Documents/Bitwig Studio/Extensions/DrivenByMoss.bwextension` matched
SHA-256 `98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a`.
It was moved intact outside every scan path. The unchanged accepted derivative
was installed as the sole scanned artifact at SHA-256
`31be44969abf97da8c09aa389056b30363f57532cde2c8cdab2978fd89a9a3cd`.
Bitwig's startup log proved that the external-ingress properties were present,
and the repaired packaged helper established one authenticated loopback
connection.

After the focused run the helper stopped normally and sent one CLEAR. Bitwig and
its audio engine ended, the capability and temporary alternate profile were
removed, the listener was absent, the derivative was moved outside scan paths,
and the untouched official artifact was restored. Readback found exactly one
scanned DrivenByMoss artifact at SHA-256
`98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a`.

Ordinary Bitwig was relaunched with no `JAVA_TOOL_OPTIONS` and no listener on
port 45291. The maintainer physically confirmed standard DrivenByMoss display
with no captured pixels, working pads/encoders/transport, Push audio available,
and audible headphone output. The ordinary environment remains on the official
artifact.

## Repaired implementation path hashes

SHA-256 values are of the exact file blobs in the repaired implementation
commit. The manifest above is the SHA-256 of these sorted `<hash><two
spaces><path>` lines.

| Path | SHA-256 |
| --- | --- |
| `README.md` | `d17969d55b86f047be986c590200ffa8a966c35574aae3ca91fea88767bb71ab` |
| `capture/macos/Package.swift` | `4bdfee8134b526776dc4808119a57992c291a2d61a72d1a7cb20298b24a9c025` |
| `capture/macos/Profiles/bitwig-device-chain.json` | `0425cb7b04b28ffecd23b711988f37b2112a84935aeb90c15d1380bbf94cc2f9` |
| `capture/macos/Resources/Info.plist` | `2b01780f17aedee57c9d9c0b5946de3ce612f52873f9100cd079a9839604332f` |
| `capture/macos/Sources/PushwigCaptureHelper/AspectMapping.swift` | `00454b8b38909e0b7946aa0601ff087d1a987763bef4412d02c2fe01b9b4a077` |
| `capture/macos/Sources/PushwigCaptureHelper/CaptureConfiguration.swift` | `62795049f2e6c5b34a5fa4077aae208f711fcc6c7c5f2aba45badea3f3c06195` |
| `capture/macos/Sources/PushwigCaptureHelper/DisplayCropCapture.swift` | `1c991400d7e4c2640092423d15fbaf6dfef4a7f9b228d6a9df5a3d043a02dee8` |
| `capture/macos/Sources/PushwigCaptureHelper/VisualProfile.swift` | `81f365cd5341ccf859e375611af0feff2b2fe1351609497832f407d2884b5294` |
| `capture/macos/Sources/PushwigCaptureHelper/WindowCaptureApplication.swift` | `1ea82ee503ba06ce61a464020b39ab1c31d030c12762d6a0fe1596793b80d263` |
| `capture/macos/Sources/PushwigCaptureHelper/WindowDiscovery.swift` | `cf117503ca46704d38f74c9cc87edb1cab85a26f61fb6c4144a7611e9cb70d20` |
| `capture/macos/Sources/PushwigCaptureHelper/WindowFrameProcessor.swift` | `667bbc2cf00d01f054cf66733a8d21d246b0a0ab9cb45043289153842a4d5752` |
| `capture/macos/Sources/PushwigCaptureHelper/WindowRelativeCapture.swift` | `65cfab18a6ef06ca573dd021b845f11bb588f9ea12262f511c60c443cb4913dc` |
| `capture/macos/Sources/PushwigCaptureHelper/main.swift` | `b505a85cb782f71ba9ebdf87b834ad025402ffb69a451fd5b3f0312e6930396a` |
| `capture/macos/Tests/PushwigCaptureHelperTests/PushwigCaptureHelperTests.swift` | `3a8863203b9958fe2a01fd85deb8f209c21075a2ef7f7d533ca22f5c77e31c62` |
| `capture/macos/Tests/PushwigCaptureHelperTests/V3WindowRelativeTests.swift` | `3d9bf580c9b03ad13c9603e9cd00af923dfca409c3de05b9d050d6620e5c2834` |
| `docs/DEVELOPMENT.md` | `6d26b15db2c2258644a1025f5899af53fe2125ea5097da4047bc703e8eed64e2` |
| `docs/TESTING.md` | `41700f02a53c8615dc55ecaa6c5f4c6455e6ba22f6666363235d4f4562fca1aa` |
| `docs/design/window-relative-visual-lens.md` | `c7e662e9499ab3d8c3a07ca6e4d2d8b2fc61af5a78f3ecf50db8fd8769ab58ff` |

## What this proves and does not prove

The repaired deterministic, native-conformance, and direct physical evidence
proves that the schema-v1 normalized crop controls actual pixels through a
documented single-window production path. It proves bounded full-window
acquisition, stride-safe Core Image crop/scale, opaque BGRA output, reused
destination storage, preserved V2 mode and protocol, repaired-path processing
within the 30-fps budget, clean loss/recovery, normal Push control/audio, and
exact official-artifact rollback.

V3 does not identify or anchor to Sampler as an internal Bitwig object. The
physical resize makes that limitation concrete: the correct normalized raster
region can remain stable while Bitwig reflows the desired device outside it.
This evidence therefore does not claim an aesthetically useful crop across
arbitrary Bitwig layouts, a production-quality device lens, capture of plug-in
child windows, continuity of a dead protocol session across a full Bitwig
receiver-process restart, Push 2 hardware, or zero private allocation inside
Apple frameworks.
