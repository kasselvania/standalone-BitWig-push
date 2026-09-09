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

## Remote-binding and touch observation — prepared, live correlation pending

The maintainer subsequently authorized one narrower prerequisite: prove the relationship between the actual Push encoder binding, current remote page/value, touch state, and Bitwig's colored marker on a visible Sampler control. No new screen layout, camera behavior, or video publication is part of this observation.

Construction/runtime: the existing Push 3 setup completes initialization; a diagnostic observer attaches to its **existing** hardware-knob and remote-control API objects; the ordinary startup/mode/binding path remains responsible for operation; callbacks record touch/value/mapping events and post-flush snapshots record current context; a local image observation measures candidate triangles inside the already detected device. The first unproved dependency is correspondence between a specific current Push binding and a particular visible marker. Merely finding a color is not that proof.

### Semantic-side diagnostic

DrivenByMoss branch `codex/sampler-context-lens`, diagnostic commit `a645fcb9e70e4b28a4d7a2ec7f46aaf0f13dfb59`, tree `a038e0beda4ebccd041c7779573417afb8fea6fa`, directly above accepted integration `997158b0a4ddd932a0a985c8b74ffff1e631120f` / `dbf3dc8d4e6d6b95a654088f85b8a183584063b7`.

Changed source: Push 3 extension-definition hookup and `PushBindingTrace.java`; one focused test and runner. No Push 2/1 diagnostic claim. The unfinished native-identity prototype was deliberately excluded using a committed-tree archive for the build.

- Observes eight existing row encoders plus Master, all simultaneous touch states, hardware target name/value/formatted/modulated value, current device/page/mode, remote mapping-in-progress, and whether this hardware control caused a value callback.
- `modeRequestedRemoteSlot` means the mode provider points at that exact existing remote proxy. It is **not** an underlying native parameter ID or proof that a manual hardware override has the same destination.
- `isBeingMapped` is an API observation, not a proven universal assignment-revision signal. Renaming/value changes cannot substitute for assignment identity. Same-name remapping is a required live check.
- No `setBinding`, indication change, synthetic touch, parameter write, selection change, OSC controller, producer, new receiver, or display modification.
- Private temporary JSONL, mode 0600, at most 6,000 records; explicit truncation marker at the limit. Event callbacks and at-most-10-Hz changed snapshots are separate. This is bounded diagnostic logging with buffered file I/O, **not a zero-overhead product context transport**. Normal exit closes the file; observation failures disable the trace without taking down Push. Callbacks are not a single atomic Bitwig state transaction.
- API-21 deterministic observer/integration compile: **19 checks pass**. Existing settings, rendezvous, and receiver/lifecycle suites also pass against the final package. This does not establish live remapping behavior.
- Java/Javac Homebrew OpenJDK 21.0.11; Maven 3.9.16; explicit Java 21 environment. `mvn -q package -Dbitwig.extension.directory=target` succeeds on the committed-tree archive. A first compile caught a captured-variable name collision in the diagnostic hookup; it was corrected before this final head/build.
- Packaged extension/JAR SHA-256: `845abaf9ed6fd2d7c73f19067730f3bbc858ec1bf219d66d26058b0f7426afe4`.
- Extracted comparison with retained V5A artifact `ea69daa18a41011105c8228035dd377964ca05f5cf37196f0629fc70824050e6`: only the Push 3 definition class changes; its anonymous diagnostic hookup class and `PushBindingTrace.class` are added. **All other archive payloads are byte-identical**, including `PushUsbDisplay.class` (SHA-256 `288b576b3f2ed064f8d9a0c6f6d384fb3516a0858cc22e7879bee896df83dec3`).

Targeted runner (inside DrivenByMoss; supply an already built matching artifact):

```sh
sh scripts/test-pushwig-binding-trace.sh /path/to/DrivenByMoss-26.4.1.jar
```

### Image-side diagnostic

```sh
xcrun swiftc -O visuals/sampler/RemoteMarkerDetector.swift visuals/sampler/TestRemoteMarkerDetector.swift -o "$sampler_scratch/TestRemoteMarkerDetector"
"$sampler_scratch/TestRemoteMarkerDetector"
xcrun swiftc -O visuals/sampler/SamplerLocator.swift visuals/sampler/RemoteMarkerDetector.swift visuals/sampler/ObserveSamplerMarkers.swift -o "$sampler_scratch/ObserveSamplerMarkers"
"$sampler_scratch/ObserveSamplerMarkers" /path/to/local-Bitwig-image.png
```

Ten generated marker checks pass: colored triangle geometry, padded RGBA row stride, translation/scale, non-triangle refusal, bounded region and invalid storage. The 85 existing Sampler checks still pass. Detection is bounded offline connected-component/shape analysis, not a claimed per-frame tracker. It measures **marker bounds, not the underlying knob's center/extent**. It does not assign encoder numbers from color.

On the earlier FFmpeg Bitwig search image (SHA-256 `7a5db69ea3bf40caf79cbf17acd212c5aa02a8b0fdf4fb9300047f23d104ea37`), six 9×9 top-left triangular candidates were found. One scan took 2.585 ms, excluding acquisition, OCR and pixel conversion; not a percentile or live latency claim:

| Image-local x,y | Median RGB |
| --- | --- |
| 2085,1521 | 90,199,135 |
| 2053,1593 | 81,158,236 |
| 2117,1593 | 187,99,255 |
| 1229,1681 | 243,25,54 |
| 2077,1681 | 255,74,167 |
| 1153,1689 | 255,116,22 |

This is not an eight-slot match. Attached flags/stems, missing or obscured indications, other colored controls, and indications from another controller/context require separate attribution. The existing locator still depends on the Expressions landmark and includes the modulator area; removing that dependency remains pending rather than being silently claimed solved.

### Live program and fixture state

Pending: compare stable API/Push observations and current device markers; map one slot Speed→Pitch, rename and switch pages; compare mouse/encoder edits; touch-only, two held knobs, release and a page change while held; Master temporary mode and return. Preserve user assignments/automation and agree any deliberate mapping edits before making them. No value-wiggling to infer a target. No final presentation behavior yet.

At preparation, Bitwig was still open, and the official extension remained installed at the exact official SHA-256 above. **The diagnostic has not been installed and no live correlation result is claimed.** A normal save/quit, exact artifact custody, and official rollback are required before/after its temporary use. No new capture app or permission change is needed. Diagnostic logs/images stay local, are never committed, and are removed after the useful measurements are retained.
