# Sampler device-location proof

Local implementation work for the maintainer's September 9, 2026 interaction request. **Not yet a live Push producer or accepted contextual replacement.** [Interaction contract](../../docs/design/sampler-context-lens.md).

The locator recognizes a constellation of Sampler controls, then measures the enclosing control-body border. It reports the body's center and current width/height. It does not use a stored desktop location, a normalized window crop, or a fixed device size. The measured body currently excludes the narrow device-name/power strip on the left. Exact desired presentation is pending maintainer confirmation.

## Run locally

Requires the installed Apple Swift toolchain/Vision and FFmpeg. No app installation, new app identity, permission reset, or DrivenByMoss replacement is involved. Screen capture still requires ordinary macOS permission; the tool does not change it.

From the repository root:

```sh
sampler_scratch=$(mktemp -d /tmp/pushwig-sampler.XXXXXX)
xcrun swiftc -O visuals/sampler/SamplerLocator.swift visuals/sampler/TestSamplerLocator.swift -o "$sampler_scratch/TestSamplerLocator"
"$sampler_scratch/TestSamplerLocator"
xcrun swiftc -O visuals/sampler/SamplerLocator.swift visuals/sampler/ObserveSampler.swift -o "$sampler_scratch/ObserveSampler"
xcrun swiftc -O visuals/sampler/SamplerLocator.swift visuals/sampler/CaptureSamplerProof.swift -o "$sampler_scratch/CaptureSamplerProof"
```

`ObserveSampler image.png` measures an existing local image. `preview.py --observer /path/to/ObserveSampler input.png output.png` invokes the real FFmpeg crop/scale/pad filters using those measured bounds.

`CaptureSamplerProof <explicit-current-Bitwig-windowID> <private-output-directory>` performs one complete local observation. The window ID must be read from the current Bitwig process, not copied from this record for a later session. The command validates ownership and on-screen status, acquires one physical-display image using FFmpeg AVFoundation, restricts recognition to the actual window bounds, measures Sampler, rejects overlapping windows, then asks FFmpeg to crop and uniformly fit the measured device into 960×160. Output is centered with side padding rather than stretched. The proof supports exactly one active display and a wholly on-display Bitwig window.

This is **visible-screen acquisition**, not hidden/independent-window capture. Window geometry is only the recognition search domain and point-to-pixel conversion. Sampler geometry comes from current visual features. Windows covering the device can prevent a match; an overlap check also refuses measured regions covered by other windows. The system pointer is excluded by `capture_cursor=0`; other applications' software overlays are not exempted. Before/after window metadata checks are a diagnostic safeguard, not a proven continuous occlusion/lifetime model.

Local PNGs can contain proprietary/private pixels. Keep them in the private scratch directory, never commit them, and remove them after local inspection. The command refuses existing image filenames. It bounds each FFmpeg operation to 15 seconds plus termination of its own child; it never closes or launches Bitwig.

## Observed September 9, 2026

Base for this local work: capture-retirement head `0ab96e4a0306b94d9be6e6a50d59df42ddd0b169`, tree `7b79aa6c429d30423a420f707f631c2497f6404f`. Retirement PR #59 remains a dependency; retired capture code is not resurrected.

One native Sampler was visible in Bitwig. The maintainer moved and resized the window between observations. The same compiled detector, with no coordinate/configuration changes, measured:

| Observation | Window image | Sampler center | Body size |
| --- | --- | --- | --- |
| Before move/resize | 3882×1810 | (1441.5, 1409) | 1659×438 |
| After move/resize | 3418×2026 | (1441.5, 1625) | 1659×438 |

These are independently acquired window-image pixel coordinates, including the OS screenshot margins. The measured body moved down 216 pixels as Bitwig reflowed. This proves reacquisition after the operation, **not continuous tracking during a drag** and not every UI layout/scale.

An actual FFmpeg 9.0.1 AVFoundation acquisition then returned 6860×2894 pixels for the sole 3430×1447-point display, a measured uniform 2× conversion. The Bitwig search domain was `(1954,206,3282,1890)` pixels, derived from its current window metadata. Within that domain the detector found center `(1373.5,1573)`, size `1659×438`. FFmpeg applied `crop=1659:438:544:1354:exact=1` to that search image and uniformly fitted the result to 960×160. No device coordinates were manually selected.

Source `bgr0` is the supported FFmpeg AVFoundation format for this backend; requesting `bgra` failed. FFmpeg emits capture-configuration warnings even on the successful one-frame route. That success is a frame result, not proof of a sustained requested 30-fps cadence.

Local SHA-256 identities (images are not in Git):

| Material | SHA-256 |
| --- | --- |
| Before window image | `f4b9540ebbd169ec2ca9a23c061e6607b397a9837e95c85a56bf1f3ff9a846b8` |
| After window image | `6c02eb63fa9483243ea0b45c4a360473ca07006ee3076d459b11e06fb104987d` |
| FFmpeg acquired display image | `7ae505afcb76c37135774e1c58c18f608707f882b6e25cc84bad4865b847c65e` |
| FFmpeg Bitwig search image | `7a5db69ea3bf40caf79cbf17acd212c5aa02a8b0fdf4fb9300047f23d104ea37` |
| FFmpeg fitted Sampler output | `a9e86f47cf722a95d6d55f181d310733a907a7be58a96f184def0dcf5a7f9fe0` |

The after-resize observation measured text recognition 152.824 ms, pixel conversion 11.268 ms and border location 0.828 ms. The FFmpeg search image measured recognition 212.915 ms and border location 0.645 ms in a later single run. **These are individual observation costs, not live latency percentiles, CPU usage, or a 30-fps result.** Full OCR on the entire very wide desktop failed to recognize the small labels; limiting recognition to the Bitwig search domain succeeded. Repeated whole-frame allocation/OCR is not the intended per-frame tracking path.

An additional automatic capture refused when the device was hidden; another refused when an on-screen software overlay intersected the measured region. No captured image was sent to Push. The official extension remained installed throughout.

## Tests and remaining work

The final local test run passed **85 checks**: translation, UI scale, width variation, missing/duplicate landmarks, obstructed borders, invalid/nonfinite geometry, and a real Vision request against generated text. All three Swift command-line programs compile with the installed toolchain. No Bitwig screenshot is a committed fixture.

Installed official extension SHA-256 was read back unchanged as `98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a`. No candidate was installed, so no artifact swap/rollback occurred during this proof.

Still unproved: cheap continuous tracking; robust live occlusion/lifetime handling; native-device identity on the real API rather than mocks; current context/generation handoff; local DrivenByMoss mode gating; live FFmpeg-to-ingress integration; end-to-end performance; physical semantic/video switching and rollback of a future candidate. A static locator result must not be reported as any of these.
