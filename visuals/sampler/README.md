# Sampler device-location proof

Local implementation work for the maintainer's September 9, 2026 interaction request. **Not yet a live Push producer or accepted contextual replacement.** [Interaction contract](../../docs/design/sampler-context-lens.md).

September 10: [960×160 actions, all-eight-values and device-image preview](presentation-prototype/README.md), revised after the maintainer required the existing button-action words and continuous values alongside the image. Two generated layouts retain both navigation/action rows. It does not resolve the live identity/binding gaps below and does not install or connect anything to Bitwig/Push.

September 10: [controller-color trace and existing-setting diagnostic](controller-color-trace.md) separates Bitwig's remote mapping colors, DrivenByMoss text-theme settings, and physical button LEDs. No new controller or capture behavior is implemented by that investigation.

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

## Remote-binding and touch observation — September 9 diagnostic

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

### Actual binding, label, value and marker observations

The exact diagnostic artifact above was installed after a maintainer-confirmed normal quit and official-artifact preservation. Bitwig was launched ordinarily without JVM-option injection. The observer attached to the existing Push controller; there was no producer, video replacement, OSC controller, capture app installation or permission change. Central diagnostic tooling at `6ae14ebf1a78313df45ee7985abd578461403f00` / tree `f1a09348394e3b56ff0cb1b91502848ba658bdc2` was unchanged during this observation.

First, the same selected Sampler and its remote page existed while Push's active mode was VOLUME: encoder 1's actual target was track Volume/-4.0 dB, although remote slot 1 already exposed Speed/100%. On entering DEVICE_PARAMS, the eight mode-requested remote proxies and observed hardware targets became:

| Slot | Editable remote label | Hardware target name | Initial formatted value |
| --- | --- | --- | --- |
| 1 | Speed | Speed | 100 % |
| 2 | Pitch | Pitch Transpose | 0.00 st |
| 3 | Start | Play / Position Offset | 0.00 % |
| 4 | Glide time | Glide time | 0.00 ms |
| 5 | Pan | Pan | 0.00 % |
| 6 | Vel Sens. | Velocity Sensitivity | +30.0 dB |
| 7 | Gain | Voice Gain / Drive | 0.0 dB |
| 8 | Output | Output | 0.0 dB |

This directly distinguishes selected-device remote metadata from the current hardware binding. These names are observations, not immutable native parameter identifiers.

Following the [documented instance-local preset-page workflow](https://www.bitwig.com/userguide/latest/midi_controllers/), the maintainer created temporary preset page `Perform`, assigned only its first slot to Speed, and renamed that slot `binding probe`. Shared Device Pages and the original Page 1 assignments were not edited by the agent. The maintainer then removed/reassigned only that temporary slot to Pitch and re-entered the identical alias.

| State | Exact remote alias | Hardware target name | API formatted value | Sole detected device-body marker |
| --- | --- | --- | --- | --- |
| Speed assignment, records 337/339 | binding probe | Speed | 85.2 % | red, (1691,1681) |
| Pitch assignment, records 348/350 | binding probe | Pitch Transpose | 0.00 st | red, (1615,1689) |

Both images have the same detected device center `(1828.5,1573)` and size `1673×438` in a `3282×1890` Bitwig search image. Each marker is a 9×9 top-left triangle, RGB `(243,25,54)`, shape agreement 1. Direct image inspection places the first on Speed and the second on Pitch; the sole detected marker moved `(-76,+8)` pixels. The remote-control pane lies outside the measured body. The detector did not assign slot numbers from color: the deliberately isolated slot-1 mapping and the existing API observations establish this controlled association.

Local-only search-image SHA-256 values:

- Eight-slot baseline: `ae5734aeed37ac77e3ed8f8ed2116e42e74832a705d4e6d756a706a4f5957ab0`.
- Single Speed assignment: `76ba4818eb1017ebe25d0212fcd98bf24ebbf938b859861b90758ea7bd124d04`.
- Same-alias Pitch assignment: `6ea8f99044c13e24e13ccb71d65dc828ac9aff9a3712fd1df2af82e58ea25a43`.

Commands: existing `CaptureSamplerProof` with freshly read Bitwig window ownership/bounds; FFmpeg crop of the current search rectangle; `ObserveSamplerMarkers` on the resulting image; `shasum -a 256`; complete-JSONL readbacks using Ruby/JSON. The Bitwig window moved between the baseline and temporary-page observations; no detector coordinates were edited. The Speed/Pitch comparison used screen search `(1648,458,3282,1890)` pixels from the same current window's `(824,229,1641,945)` point bounds, at measured 2× scale. Marker scans were individually 2.933458 ms and 2.854291 ms, excluding acquisition/OCR/decode. This is not a live latency distribution.

**Capture-method limitation:** the complete guarded Pitch capture refused because before/after window-or-occluder metadata changed. Its acquired image was separately inspected and analyzed offline: the complete Sampler body and remote pane are unobscured in that particular frame. A retry was obscured by another app and refused recognition. Therefore the Pitch result is a static acquired-image observation, not a passed guarded live-capture run. No refused image was sent to Push. Do not promote this result into a proven continuous capture/occlusion model.

The mapping route exposes removal (`remoteExists=false`, `hardwareHasTarget=false`) followed by mapping-in-progress and the new target. This proves that specific route, not that `isBeingMapped` catches every possible reassignment or that the final alias identifies its target. All other slots on Perform remained unassigned; Bitwig briefly advanced mapping-in-progress to the next empty slot after each assignment.

### Conductive touch, context and asynchronous state

- Hardware and active-mode touch snapshots observed `[1,2] -> [2] -> []`. The maintainer confirmed accidental rotation during the initially requested touch-only gestures. These are touch-plus-rotation observations, not a touch-only pass or evidence that conductivity changes values.
- Encoder-originated changes carried `causedByThisControl=true`; a controlled mouse-only Speed edit produced 155 such value callbacks with the flag false, zero touch callbacks and 18 complete snapshots with no touch or remote/hardware value/format mismatch in the inspected records 87–259. This is a bounded inspected interval, not the entire edit count. The API distinguishes this hardware from other origins; only the controlled human action identifies the mouse here, not a general mouse-versus-automation classifier.
- Later short touch/release pairs 351–354 and 355–358 showed unchanged Pitch/0.00 st and no intervening hardware-value event. Separate touch reporting without value changes is observed in those intervals, without reclassifying the earlier nudged gestures.
- Mode change while row 1 remained touched: DEVICE_PARAMS/Speed -> VOLUME/Volume, then physical release, then return to DEVICE_PARAMS/Speed. Raw hardware touch survived the switch and cleared on release. **DeviceParams' mode-local touched flag was still true after returning with the finger released** (records 303/323/330). It is stale bookkeeping, not reliable physical-touch authority. The observer did not change that existing routing or investigate automation-gesture lifetime.
- Master touch: slot9 true -> MASTER_TEMP, then slot9 false -> DEVICE_PARAMS, with current parameter bindings restored. The maintainer explicitly reported seeing the mixer screen. Logged return is established; a separate explicit human confirmation of the visible return was not supplied.
- Remote-page changes are machine-observed: Perform/Pitch -> Page 1/Speed -> Perform/Pitch, including page rebinding while raw row-1 touch remained true. The maintainer could not confidently judge the requested physical page-following result. **Do not count that as physical UI acceptance** or assert the prescribed action order; the recorded sequence is what is known.
- **Not an atomic context snapshot:** record 407 has new mode MASTER_TEMP with still-cached old Pitch target information; record 415 has restored DEVICE_PARAMS with still-cached Volume information, followed by settled Pitch data at record 420. Independently arriving mode/binding/value observations cannot simply be relabeled a coherent product authority snapshot. A fixed delay, matching label or image hash does not solve this ownership gap.

### Recovery, retention and remaining boundary

After the maintainer reported normal Bitwig closure, application/audio-engine processes and the ingress listener were absent. The runtime directory contained only the intentional dormant `owner.lock`, with no current manifest/capability. The diagnostic artifact was moved intact outside the scan path and the untouched official extension restored to its canonical filename. Restored SHA-256: `98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a`. Exactly one DrivenByMoss extension was scanned; unrelated extensions were untouched. Ordinary Bitwig was relaunched without JVM options and opened the official archive. Asked to confirm the usual DrivenByMoss display, controls, Push audio/headphones and normal quit, the maintainer replied **`confirm closed`**. Final readback independently verified application/audio-engine/listener absence, no current manifest/capability, the exact official hash and one scanned DrivenByMoss extension. This is official recovery confirmation, not acceptance of a new visual interface.

**Trace-retention gap:** complete records were inspected through record 433 while the observer ran. After normal quit the raw file was observed at 350875 bytes, but it disappeared from Bitwig's temporary directory during the official relaunch before it was copied/hashed externally. Selected inspected records are retained in this account and the tool readbacks; the complete raw-trace hash, final count and unread tail are unavailable. This is an evidence-custody error, not a passed full-trace retention claim. Do not repeat the physical session merely to conceal that gap. Logs/images and project contents are not committed. The temporary Perform preset page was user-created in the test project; the agent did not delete it or discard unsaved work.

After retaining the measurements and hashes, the ten PNGs generated for this binding diagnostic were deleted from their explicit private scratch locations. User-provided attachments and unrelated files were untouched. The diagnostic extension remains intact outside the scan path; its source/tests remain on the named diagnostic branch, not installed or accepted as production behavior.

**Conclusion:** the controlled case demonstrates editable remote alias versus current hardware target name/value, independent conductive touch, contextual rebinding, and a matching visual marker relocation. It does not establish immutable native target identity, all assignment routes, all eight marker shapes, automatic general pixel-to-parameter association, knob-center/extent localization, native-Sampler type identity, atomic context publication, inexpensive continuous tracking, or a useful completed semantic/video interface. No production display replacement is being claimed. The next design must use actual binding ownership and hardware touch, not labels or stale per-mode flags as authority.
