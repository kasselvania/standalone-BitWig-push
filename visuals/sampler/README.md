# Sampler contextual lens

Local implementation work for the maintainer's September 9, 2026 interaction request. **The repaired live producer passed a focused steady-image/context-return and controls/audio recheck; it is not yet final-product accepted.** Exact measurements, remaining limitations and official recovery are recorded below. [Interaction contract](../../docs/design/sampler-context-lens.md).

September 10: the maintainer chose [layout A](presentation-prototype/README.md): four permanent remote readouts on each side, original action/navigation words retained. The disposable A/B simulator is removed after the decision; its code remains in Git history. The repaired image has since passed the focused physical check below; the new no-argument foreground utility remains unqualified on hardware.

September 10: [controller-color trace and existing-setting diagnostic](controller-color-trace.md) separates Bitwig's remote mapping colors, DrivenByMoss text-theme settings, and physical button LEDs. No new controller or capture behavior is implemented by that investigation.

The locator recognizes a constellation of Sampler controls, then measures the enclosing control-body border. It reports the body's center and current width/height. It does not use a stored desktop location, a normalized window crop, or a fixed device size. The measured body excludes the narrow device-name/power strip on the left; modulator exclusion is still not solved.

## Foreground utility — September 10

The current slice starts at `2277be61cc45200c81b93874d005c92b13509724`, tree `68d3496d6f435d1f615015afc2e5566b98cf101b`. It preserves the approved presentation and the useful foreground lifecycle from `fb193c53ac15990773d55be675af7e0fe4edb87a`: no-argument execution, exactly-one-window selection, kernel-backed PID/start/executable validation, context tickets, fresh-frame refusal, bounded metrics and synchronous ownership. [Foreground contract](../../docs/design/sampler-context-lens.md#foreground-utility--commissioned-september-10).

Removed: `SamplerService.swift`, `sampler-agent.plist`, `sampler-service.sh`, `TestSamplerService.sh`, their build/tests, producer singleton/status-file dependency, and current service instructions. The utility writes no runtime status files and does not install, launch, configure or restart Bitwig.

### Build and ordinary foreground use

Run in an ordinary Terminal with the existing capture permission. Do not install anything:

```sh
sampler_build=$(mktemp -d /tmp/pushwig-sampler-live.XXXXXX)
sh visuals/sampler/build-live.sh "$sampler_build"
"$sampler_build/SamplerLive"
```

The last line is the one foreground command. Start it before or after ordinary Bitwig. No window ID or duration is needed. It waits without FFmpeg until current V5A authority, a supported Sampler Device Parameters context and exactly one visible ordinary Bitwig-owned window exist. The development extension supplies that authority; the official extension intentionally does not. Extension custody remains a separate maintainer-managed fixture procedure, never a producer function.

FFmpeg resolves through the foreground PATH, or explicitly via `--ffmpeg /path/to/ffmpeg`. The resolved target must be an executable regular file; its path prints once. No implicit Homebrew executable fallback, installation, upgrade or permission manipulation occurs. Building still uses the installed Swift and Homebrew FFmpeg C libraries for the unchanged fit path. This is not a standalone distribution.

Optional diagnostics: `--window-id ID`, `--duration seconds` (positive, at most 1800). Ctrl-C/SIGTERM stops the owned FFmpeg child, sends CLEAR where connected, disconnects and prints final metrics. It never quits Bitwig. The existing visible-screen envelope still requires the measured Sampler to be uncovered on one supported display.

Terminal transitions separate missing V5A/ingress, missing context, zero/multiple windows, acquisition, first-frame wait, locating, active output and fallback reasons. “Ingress disabled or unavailable” is an observation of missing authority, not a claim to have read the preference. No per-frame logging is used; rapid frame-driven transitions are rate-limited to one terminal update per second and reason counters retain all occurrences.

FFmpeg stderr retains a bounded 4096-byte diagnostic tail (not per-frame showinfo). **No complete first frame within five seconds is a fatal source-startup failure:** clear, stop child, disconnect, exit nonzero with the excerpt. The locator is not blamed for absent frames. This does not extend the existing 250-ms visual freshness or socket-write deadlines. After completed-frame source failures, the runtime abstains under the existing current-ticket rules; it never retries a spent authentication ticket.

Eight metric series each retain at most 10,000 timings, with lifetime counts/maxima. They are metadata, not frame queues. One reusable source frame, fixed byte transport and existing fit output remain; native FFmpeg capture allocation is separate and not zero-copy.

### Historical service result

The installed LaunchAgent reached controller context but FFmpeg delivered zero complete frames. The exact background permission/source cause was not established. The service was disabled and the official artifact restored exactly. This slice does not retry that approach. The complete failed implementation and evidence remain in Git history at `2277be61cc45200c81b93874d005c92b13509724`.

### Continuity repairs — generated verification and blocked physical recheck

Latest maintainer authorization treats the foreground lifecycle as provisionally proven and permits two repository-owned corrections without reopening acquisition. Foreground checkpoint `dada4a96a35d0a1214b726503c03612dd8b4ef31`, tree `b4c420273927f74811de502b74e73bc32cf9a2d7`, preserves the service deletion, useful runtime and factual blocked session. The checkpoint is not acceptance. The previous blocked-run record below remains historical evidence, not a prohibition on this newly authorized repair.

**Controller repair:** DrivenByMoss commit `56d8a7e8cbc25c1212a983a0f8824d1d55674f3e`, parent `93fb2a48d1e35dfeb69f902a44d8035a0b7db557`, tree `d4aaf37dd2d55e73cbdfaf43943c04df9e0f4533`. Exact played-note/chord origin is `AbstractView.displayChord()`. It now uses `IDisplay.notifyPlayedChord()` whose default remains ordinary notification. Push2Display suppresses only that typed full-screen feedback during eligible available Sampler context. Every other notification/overlay stays blocking; no string matching and no producer notification awareness. This is the authorized minimal suppression option, not a compact badge.

Changed Java paths: `framework/controller/display/IDisplay.java`, `framework/featuregroup/AbstractView.java`, `controller/ableton/push/controller/Push2Display.java` under `src/main/java/de/mossgrabers/`, and `src/test/java/de/mossgrabers/controller/ableton/push/controller/ExternalRasterIngressLifecycleTest.java`. Java 21 package and all six affected suites passed (settings, rendezvous, lifecycle; composition 470, LEDs 217, native API simulation 35). Initial sandbox socket refusal was resolved by running the same compiled tests with loopback permission, not another build. Real production display tests preserve image for typed notes, refuse identical ordinary-notification text, retain blocking graph/notification precedence and restore ordinary note feedback after context revoke. Extracted `PushUsbDisplay`, receiver, latest-frame store and external pipeline classes remain byte-identical to the prior tested derivative.

Tested extension JAR: 14,420,711 bytes, SHA-256 `128b5e9239d55c635e5da69cbc3c43bbbf3f4070047c5047a1fdac76841c4750`. Installed temporarily for the September 11 recheck below, then replaced by the untouched official artifact. One Java package build only; no receiver/protocol/USB change.

**Producer repair:** the existing SamplerImageLock now distinguishes acquiring/locked/suspect/lost, scores patches instead of requiring zero differing samples, and checks current body edges. The [exact confidence and lifetime rules](../../docs/design/sampler-context-lens.md#foreground-continuity-repair--authorized-after-the-blocked-run) are initial generated-test-qualified thresholds, not empirically tuned real-Sampler claims. Suspect output uses newly captured bytes only, with at least two-thirds good anchors and three coherent edges, at most three frames and 100 ms after strict verification. Context/source/occlusion/staleness loss invalidates geometry; no retained image or changed freshness deadline. The recognizer and uniform-fit implementation themselves are unchanged.

Final affected command: `sh visuals/sampler/build-live.sh /tmp/pushwig-sampler-continuity.95RKOB`. **117 locator + 239 live-path checks passed.** Reused generated locator fixture tests exercise actual strict body detection, one-patch tolerance, three-frame and elapsed-time cutoffs, structural-majority and edge refusal, recovery, hard invalidation, empty/ambiguous OCR and cooldown classification. Actual runtime tests retain source/session checks, validate transition record fields/bounds and contiguous refusal-run accounting. Generated no-first-frame stop: 612.018 ms with shortened 500-ms test bound. Generated stalled socket: 250.241 ms. These are regression samples, not new live performance distributions.

Prepared foreground executable: 383,704 bytes, SHA-256 `b8608c79f2088bd9111dade7b4818031a2ca90083fee748242e4bc1adc32512d`. Source hashes:

| File | SHA-256 |
| --- | --- |
| SamplerLive.swift | `9acf94b378148fa53f3aec3cd030b3e95bc8f6f51405b70b0399b42f2199557f` |
| TestSamplerRuntime.swift | `4e7f8c628777fd840c93f5ccf935bd0829097a83095314d9fb6fd1a61164e6ca` |
| TestSamplerLocator.swift | `54b4dfe245034a82eb515808bf18f907dfff7bf0288a3f1f39a84bf4e772dfbe` |
| build-live.sh | `1325eafd9d9d1e91aa2a4e6ae5dc2b81cc94369c530b06e73aa2529f2697cfa3` |

Final metrics now include classified tracker reasons, a last-128 transition ring with identity/geometry/confidence/action/source-time, per-reason contiguous refusal-burst counts and maximum lengths. No frames/capabilities/status files or background service. The bounded ring is not a complete long-session trace; accepted-stage timing still excludes rejected frames and warmup.

At **2026-09-11 03:47:51 UTC** read-only preparation verification found the exact official artifact, no Bitwig/engine/producer/FFmpeg/listener and no active session files; dormant owner.lock remained. No fixture launch, permission change or installation was performed while the maintainer was away. The subsequent maintainer-attended recheck follows; neither candidate is final-PR-ready.

#### September 11 combined physical recheck and official recovery

**Blocked on recovery after uncovering.** Tested central head `073c4a75e2bf5e46a8fda985c1340c7900b732f5`, tree `f9023b95d1bad63542b6c0a79c045c09101cc779`, with the exact controller and executable identities above. The ordinary foreground command was started before Bitwig; waiting without FFmpeg was verified, followed by ordinary Bitwig launch without JVM option injection. No service or permission changes and no mid-session rebuild.

Direct maintainer observations: initial presentation "looks and runs awesome"; movement and resize recover, but slowly; leaving and returning to context recovers; knobs, encoders, touch, pads and other functionality work. Covering Bitwig restores semantics, but uncovering does **not** restore Sampler. Exact five-cycle count, candidate headphone/audio rows and producer-only restart were not individually confirmed, so the full program is not claimed passed.

The supplied terminal transcript includes two runs. Only `/tmp/pushwig-sampler-continuity.95RKOB/SamplerLive` belongs to this recheck; the earlier 3,037-frame run is excluded. Current run: **9,314 accepted, 4,871 discarded**, no terminal fatal failure. Accepted-stage processing p50/p95/max **11.576/14.063/46.962 ms**; capture-to-send **68.882/76.365/149.148 ms**, 8,984 measured samples after per-acquisition warmup. These are not end-to-end display latency or a CPU/RSS measurement.

Classified counters: old-at-read 2,291; old-after-processing 165; body-not-found 471; OCR cooldown 1,610; OCR no-landmarks 296; occluded 19. Counters include transitions exercised by the user and are not all unexplained steady-state failures. There were 2,743 tracker events with only the last 128 retained. The final retained interval has stable source/context identity and advancing, fresh source timestamps, with repeated no-landmark/cooldown outcomes and no verified body. This narrows the failed return to reacquisition while frames still arrive; it does **not** establish why the current source image yields no landmarks or reconstruct the earlier coverage event. No cached-image workaround, longer freshness deadline or speculative root-cause claim is made.

Maintainer stopped the foreground utility with Ctrl-C and quit Bitwig normally. Candidate was preserved outside scan paths; untouched official restored. Maintainer then confirmed ordinary official display, controls, Push audio/headphones, no captured imagery and normal quit. Final verification **2026-09-11 19:16:42 UTC**: no Bitwig/audio engine/SamplerLive/FFmpeg processes, no TCP-45291 listener, no current manifest/capability/Sampler notice; only intentional dormant `owner.lock`. Exactly one scanned DrivenByMoss extension, SHA-256 **`98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a`**. Unrelated extensions unchanged. Local artifact custody is `sampler-artifact-backups/continuity.g7cz8L` outside the checkout. This record is a factual checkpoint, not product acceptance or a final PR.

### Same-source occlusion recovery — September 11, generated qualification

Implementation basis: `a3e0d07225a0246f20550548fe9ac537268c9e04`, tree `958c1dd02e96ed882e04488a4f637d4badef3955`. Its failed physical record above is unchanged. The lead authorized only the recovery path; no DrivenByMoss, FFmpeg backend, protocol, freshness, service or permission changes.

`SamplerImageLock.revokeForOcclusion()` clears active body authority and retains only an untrusted geometry/landmark/signature hypothesis from a locked state. Runtime checks coverage against that hypothesis and immediately sends CLEAR; it does not call the locator or publish while that region remains covered. An uncovered fresh frame must pass the existing >=80% good landmark-patch rule, all four body edges and strict body remeasurement. No suspect grace is allowed for recovery. Failed verification discards the hypothesis and publishes nothing; ordinary OCR is available on the next frame. All existing hard invalidations clear the candidate; dimensions are checked before coverage as well as inside the locator. Existing post-processing source/context/freshness checks remain in force. No image or borrowed pointer is retained.

Build: `sh visuals/sampler/build-live.sh /tmp/pushwig-sampler-occlusion.liIN2t`. Compilation completed; sandboxed Vision execution refused a CVPixelBuffer. The same compiled `TestSamplerLocator` and `TestSamplerLive` then ran with native Vision/loopback access, without rebuilding or capturing a desktop: **117 locator + 282 live checks passed**. The real FFmpeg -> runtime -> crop/fit -> protocol regression exercises three coverage/recovery cycles with OCR unavailable after initial acquisition, one CLEAR per transition, no covered publication, and two alternating generated center colors matching current-frame bytes on the wire. Tracker tests additionally reject changed signatures and a single failed border, prove ordinary OCR fallback, and exercise candidate deletion by hard invalidation reasons/dimension changes. Existing runtime identity/context/geometry/stale-source tests still pass. These tests do not prove live Vision or physical recovery.

Generated bounded-failure samples: stalled socket 250.086 ms; missing-first-frame plus child shutdown 580.948 ms with the existing shortened 500-ms test bound. No performance campaign or freshness change.

Prepared executable SHA-256: `e92713c90db62aec172e9d3a3265d503964f78dba595e67c38868c0e0ffd2d00`.
Changed source SHA-256: `SamplerLive.swift` = `6ef1eac35f5333a9e1bb01f5fbd00caf88d26d0ef846872e6ee5aa1e7c8f9f73`; `TestSamplerRuntime.swift` = `0ac55ed3dce4fa39c6d96b681b1a291d9c4fd60e5ddb6d247200b31302edd75d`.

**Focused physical check pending; no PR.** Official artifact remains installed at exact SHA-256 `98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a`. Post-test readback found no Bitwig/engine/producer/FFmpeg/listener and only dormant owner.lock. Reuse the already tested controller artifact above, without rebuilding it, for the attended initial/cover/uncover (two or three repeats)/one-control check and exact rollback. This local development checkpoint is not acceptance.

### Previous foreground qualification — blocked run

**SAMPLER_FOREGROUND_UTILITY_BLOCKED:** generated verification passed and automatic foreground entry/return worked physically, but normal note-name notifications suppress the Sampler image. The run stopped at that continuity limitation, and exact official rollback passed. Five fully qualified exit/return cycles, move/resize, producer-only restart and every candidate controls/audio row were not individually confirmed; do not claim the complete acceptance program passed. The retained earlier successful focused product checkpoint remains `ccc781b000399239b54563193047c0f5598c3b7f`. No new DrivenByMoss build or source change was made.

Final affected command: `sh visuals/sampler/build-live.sh /tmp/pushwig-sampler-foreground.3vGqyE`. Apple Swift 6.3.1, arm64 macOS 26, installed FFmpeg 9.0.1. Build products and compiler cache are outside the checkout. **117 locator checks + 222 live-path checks passed.** Focused iteration used `TestSamplerLive --foreground`; the final command reran the whole affected generated suite once. A mistaken initial test expected CLEAR without any prior image; the existing client correctly only disconnects in that case. No protocol change was made to satisfy that test.

The actual runtime with a real generated FFmpeg source deliberately filtered to emit no frames stopped and reaped its child in **615.789 ms** against a shortened **500-ms test deadline**. Production uses **5000 ms**, checked during short reads (up to 50-ms poll granularity), followed by the existing at-most-one-second graceful-child wait before terminating an unresponsive owned child. No locator invocation, fabricated frame, reconnect loop or live child remained in the generated failure. Stalled protocol write: **250.715 ms**, one regression sample, not a new performance campaign. Tests also cover PATH/explicit executable selection, executable symlinks, non-executable/absent/directory refusal, option validation, zero/one/multiple windows, actual context/socket/acquisition lifecycle, fresh generations, stale-source refusal, idempotent shutdown, bounded timing storage and rate-limited terminal states.

Executable: **357,720 bytes**, SHA-256 `f5c41b1bc7f673af9858b49892bb5812de69a054c5cb20fcb6e1244f7778aed3`; `codesign --verify --strict` passed. This is an ordinary local executable, not a packaged/signed-distribution application. Source identities:

| File | SHA-256 |
| --- | --- |
| `SamplerLive.swift` | `eb731478575bf3c3fe830478a4cab12c79de89ed78890135981e84bf9c2a1466` |
| `FFmpegSamplerStream.swift` | `29d8cb75454bfa8af4f261e6fa435e569b022ca08bc7209fa9337c37199f3786` |
| `TestSamplerLive.swift` | `640eef3f0e04c054d1e5a67c954043400062035679a8955e60c46c9ce7998c97` |
| `TestSamplerRuntime.swift` | `da8bc4078e6a73c065253e28b05ebc54e0fdaf52a3cba511aba5b0c29084be12` |
| `build-live.sh` | `3698a7d594c2fc0078e1fba3b6d8aa0e3c1903ddc00a6e2268adaddfa0770360` |

Pre-fixture readback at **2026-09-10 23:17:46 UTC**: Bitwig, audio engine, producer, FFmpeg and port-45291 listener absent; current manifest/capability/Sampler notice absent; only dormant ingress `owner.lock` remained. Exactly one scanned DrivenByMoss artifact matched official SHA-256 `98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a`. The retained Sampler derivative matched `abe439c9813f879db51a7a6f69b9270ffeec33e9346a8e534f96d7fee2fe9dbd`. The old agent remained disabled; no permission, service or extension change was made during generated verification. These are custody/process observations, not a new physical acceptance result.

### Focused physical result and safe stop

The maintainer started the exact executable **without arguments in their ordinary iTerm/zsh session**, before Bitwig. At 23:21:44 UTC it was waiting, with no FFmpeg, Bitwig or listener. The official artifact was preserved intact outside scan paths and the retained derivative installed as the sole DrivenByMoss copy. Ordinary `open -a 'Bitwig Studio'`, without JVM options, created current V5A authority. At 23:23:22 UTC the context was null and the producer still had no FFmpeg. The maintainer entered Sampler Device Parameters and confirmed: **“Yes, image appears automatically.”** No window-ID entry or duration was used. One owned FFmpeg child and one producer connection were then observed.

During the session, the maintainer reported an iTerm prompt about bypassing certain system settings and approved it, explicitly saying capture worked before approval. Exact dialog wording/permission identity and causal effect were not established. The agent did not open settings or manipulate TCC. This is not an unchanged-consent or permission-onboarding proof; the user-approved permission was not revoked during rollback.

The maintainer subsequently reported that return works and the interaction otherwise worked very well, but temporary played-note cards such as C/D# make the Sampler image disappear. Read-only inspection of unchanged DrivenByMoss head `93fb2a48d1e35dfeb69f902a44d8035a0b7db557` found the blanket composition condition `!hasSemanticOverlay()` in `Push2Display.send()` (line 251). `AbstractGraphicDisplay.hasSemanticOverlay()` (lines 458–460) includes any retained notification or overlay. It is **not necessarily device-context revocation**: a valid sampler session can remain while the pipeline receives zero session/null presentation, discards the current display frame and returns semantics. This proves the suppression rule and supports the reported behavior; the precise note-event callback was not instrumented. Correcting that controller behavior is outside this foreground-only, no-DrivenByMoss-change slice. Do not disable the user's note-name display to manufacture a pass.

The maintainer deliberately pressed Ctrl-C and supplied final metrics: **3,037 accepted / 637 discarded**, `failure=none`, `capturing=false`. The last reported state before stopping was locator temporarily unavailable in complete source frames. Six acquisition starts, four first complete frames and six context changes are counters, not proof of five complete physical cycles. Final reasons:

| Reason | Count |
| --- | ---: |
| acquisitionStart | 6 |
| authorityOrSourceFailure | 219 |
| contextChange | 6 |
| contextChangedDuringFrame | 2 |
| deliveryTimeout | 1 |
| firstCompleteFrame | 4 |
| geometryChange | 1 |
| geometryReacquisition | 3 |
| locatorMissing | 572 |
| occluded | 5 |
| oldAtRead | 57 |
| stateTransitions | 60 |

Authority failures include deliberate pre-Bitwig missing-authority polling. Locator refusals are separate from the Java overlay rule; their temporal breakdown is unavailable, so they cannot all be attributed to normal steady use, resize or note cards. Acquisitions can be interrupted by context loss before a first frame; six starts/four deliveries alone do not establish startup failure. No fatal first-frame failure occurred. No longer freshness timeout, stale-frame replay, source rewrite or service retry was introduced.

Final measured timings, milliseconds (rounded to six decimals):

| Series | Samples | p50 | p95 | max |
| --- | ---: | ---: | ---: | ---: |
| Source interval | 3670 | 33.333000 | 33.334000 | 200.000000 |
| Frame read | 3674 | 20.845416 | 30.345334 | 82.886416 |
| Age at read | 3674 | 58.438583 | 152.898708 | 758.983458 |
| Accepted processing | 2947 | 11.980083 | 15.920541 | 84.167458 |
| Accepted capture-to-send | 2947 | 69.310958 | 77.892791 | 146.312291 |
| Accepted locate | 2947 | 0.697250 | 0.953250 | 71.931667 |
| Accepted fit | 2947 | 5.044708 | 6.360708 | 20.017125 |
| Accepted socket send | 2947 | 0.064291 | 0.098500 | 0.848292 |

Accepted-stage distributions exclude the first 30 sends per acquisition and all refused frames. Source interval is not publication cadence. This short run does not establish endurance, uninterrupted output, or a new allocation/performance qualification.

**Rollback completed:** user Ctrl-C was followed by observed producer/FFmpeg absence. The maintainer quit Bitwig normally. At 23:33:15 UTC application/audio-engine/listener/session files were absent. The derivative was moved intact outside scan paths and the untouched official file restored; exactly one scanned copy matched `98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a`. Ordinary official Bitwig was relaunched and the maintainer confirmed standard display with no image, controls, Push audio/headphones, then normal quit. At **23:35:06 UTC**, final readback verified all Bitwig/producer/FFmpeg/listener processes absent, current manifest/capability/Sampler notice absent, dormant ingress `owner.lock` retained, official hash still exact, and old service still disabled.

At the end of that run the foreground edits were left uncommitted under its original success gate. The maintainer subsequently corrected that process and explicitly authorized checkpointing plus the two repairs above. No final Sampler PR was opened, and the earlier incomplete physical program is not retroactively claimed as complete.

## Run locally

### New live development build (not yet fixture-qualified)

```sh
sampler_live_output=$(mktemp -d /tmp/pushwig-sampler-live.XXXXXX)
sh visuals/sampler/build-live.sh "$sampler_live_output"
```

The runner uses installed Swift and FFmpeg 9 libraries, builds outside the checkout, and runs generated locator, stream, crop/fit, private-schema and blocked-socket tests. It does not acquire the desktop or touch Bitwig/Push. Before the foreground lifecycle additions, the focused delivery-repair build passed 117 locator checks and 145 live-path checks including 40 changing FFmpeg `testsrc` frames, padded stride, different crop pixels, output-buffer reuse, large-window storage, multiple-display selection, unrelated-window continuity versus actual coverage, EOF/close, an intentional consumer stall and a stalled-reader write failure at 250.921 ms (one timing sample, not a performance campaign). It also builds the opt-in generated `TestSamplerHandoff` benchmark below.

The separate DrivenByMoss branch `pushwig/sampler-context-render` is based on the physically passed, still-unmerged LED head `cf0e70ea9f2144a45c1dc6039a25c9b90a06b92b`. Its six affected suites cover settings/rendezvous/lifecycle, actual raster pipeline, actual DeviceParams mode data/touch and the native coordinator against fake API endpoints. Native endpoint tests are not real Bitwig API acceptance.

Development fixture identities, September 10:

- DrivenByMoss head `93fb2a48d1e35dfeb69f902a44d8035a0b7db557`, tree `622983fad14bab0a16df950eac4976112583b59d`.
- Tested Java-21 extension: 14,420,465 bytes; SHA-256 `abe439c9813f879db51a7a6f69b9270ffeec33e9346a8e534f96d7fee2fe9dbd`.
- Initial `SamplerLive` executable SHA-256 `fb80db4fa4bca66b000ed9677e947e892b48b69d9b73eac1787e60bc4658d881`; corrected window-size/display-selection build `3a1da455ee52c9d110076f0d53f713c90ea900b0cc111dbfb4b846c2c69e2618`. The Java artifact was not rebuilt or replaced during those producer corrections.
- All six Java suites pass. Composition tests pass 470 checks standalone, then 582 with the actual Swift generated sender connected to the production Java receiver/pipeline. The latter verifies exact center bytes and full semantic restoration after CLEAR, not physical Push output.
- The final package was built once with explicit Homebrew Java/Javac 21.0.11 and Maven 3.9.16. `PushUsbDisplay.class`, `BitmapImpl.class` and `IRasterWritableBitmap.class` remain byte-identical to the LED-tested artifact; no generated archive is committed.

Reproduce the cross-language generated check after the Java test runner and Swift build: run `SamplerLensCompositionTest` with the built `TestSamplerLive` executable as its sole argument, using the same Java classpath as `scripts/test-pushwig-sampler-context.sh`. No real capability, Bitwig frame or hardware connection is used.

Initial development fixture startup, September 10: the saved ingress setting was Off. The maintainer enabled it and quit normally; an ordinary relaunch created the current V5A session and a native-Sampler context after the maintainer selected its parameter page. The earlier 4096-wide search cap was inadequate for the current 5488×2316-pixel window; the corrected finite limit matches the existing 8192×4320 display envelope. The Mac also reported two active displays, so selection now uses the display wholly containing Bitwig rather than requiring all other displays to be absent. The first run refused before acquisition (zero frames). A second run acquired current frames but published zero because other applications covered Bitwig. Its 3,956 source intervals were p50 33.333 ms, p95 33.334 ms, maximum 100 ms; this is acquisition cadence only, not successful output performance. A private one-frame diagnostic established the occlusion; it was removed after inspection and was never published or committed. After raising the existing Bitwig window, the unchanged corrected producer reported an actual 1659×438 Sampler body inside the 5488×2316 search and began publishing the center. The ensuing physical development result **failed**, as recorded below; startup and generated tests are not acceptance.

### September 10 live layout: flicker failure, not acceptance

The maintainer directly reported that stable frames look very good, but the image flickers on and off. This supports provisional layout appeal only, not live reliability, readability of all fields, controls/audio acceptance or completion. The five-minute-bounded producer was stopped normally before its deadline. Bitwig and the project were not closed by the agent.

Exact producer `3a1da455ee52c9d110076f0d53f713c90ea900b0cc111dbfb4b846c2c69e2618`, central source `538439c402c0f4f000543b6cd8805e4feadfe5d7` / tree `d830850d9d7d2d45134545a2afbd9f6b9c88238a`, Java extension unchanged from the identities above:

| Measurement | Samples | p50 ms | p95 ms | Maximum ms |
| --- | ---: | ---: | ---: | ---: |
| Source timestamp intervals | 5,198 | 33.333 | 33.334 | 100.000 |
| Accepted processing, excluding pipe read | 1,708 | 12.753 | 17.072 | 29.615 |
| Capture timestamp through send completion | 1,708 | 212.615 | 248.618 | 250.267 |

1,738 sends, 3,462 discarded frames. The last row includes socket send; the existing 250-ms producer age check occurs immediately before send, so completion can exceed it slightly. There is no source-to-send 30-fps pass. One same-run process snapshot showed producer 35.5% CPU / 182,576 KiB RSS and FFmpeg 34.9% / 946,912 KiB; those are single snapshots, not peak/growth measurements. Logs also report one process/application identity lookup refusal and one selected-window ownership refusal, followed by recovery; exact API failure cause remains unresolved. The initial producer did not count individual discard causes, so attributing every original discard specifically to transport would overclaim.

One bounded local attempt used FFmpeg area scaling of the search to 3072×1296 before the pipe. Generated pixels/geometry passed, but the actual 75-second run was worse: zero sends; 1,072 discards, comprising 1,066 `oldAtRead` and six `locatorMissing`. Age at read: p50 902.141 ms, p95 1,154.823 ms, max 1,412.626 ms. Completed pipe-read invocation: p50 59.677 ms, p95 78.381 ms, max 99.621 ms. Source intervals: p50 66.667 ms, p95 100 ms, max 300 ms (1,070 samples). There were two acquisition starts, one source/authority failure and 11 delivery-timeout checks. A single snapshot showed producer 7.8% CPU / 71,056 KiB RSS and FFmpeg 102.4% / 1,348,272 KiB. Failed executable identity: `21e43e9acedffa16c04ed7a20e99fd95c38207b22023c097541816b9a7cb7ae2`. **That scaling change and its dedicated test were removed; it is not proposed source architecture.** Raw screenshots are not retained. The final source keeps only useful fallback/pipe-age counters, more precise lookup error messages, and additional generated locator-scale regression coverage.

Remaining work is capture/delivery and source-lifetime reliability, not another layout decision. Do not increase the freshness timeout, replay a cached device image, blame the second display without evidence, or treat transient full-window traffic as the intended final pipeline. Ordinary coverage must produce stable semantic fallback; resume must be based on current verified source/context. The broader usability limitation of visible-screen acquisition is explicit and unresolved. Both test producers have exited. No successful product PR or final physical acceptance is claimed.

Final diagnostic-only source build after removing the failed scaling change: executable SHA-256 `1bab6937f3e797eaf9c75be2d65600eab996ee3504c74ad03772a83035916f5b`; 117 locator and 129 live-path generated checks pass. This executable has not been live-qualified and is not offered as a flicker fix. The tested Java extension was unchanged throughout the producer attempts.

**Official restoration, September 10 at 20:04:55 UTC:** after the maintainer reported normal Bitwig closure, `pgrep`, `lsof` and scoped process/file listings verified application/audio-engine, port-45291 listener and test-producer absence. The current manifest, capability and Sampler-context notice were absent; the intentional dormant `owner.lock` was retained. The tested derivative was moved intact outside scan paths, and the untouched official backup moved back to the canonical extension filename. `shasum -a 256` confirmed official SHA-256 `98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a` and retained derivative SHA-256 `abe439c9813f879db51a7a6f69b9270ffeec33e9346a8e534f96d7fee2fe9dbd`. Exactly one DrivenByMoss extension was scanned; both unrelated extensions were untouched. Ordinary `open -a 'Bitwig Studio'` launch followed with all three JVM-option variables absent, and readback showed no ingress listener or session files. Asked to confirm the standard display, controls, Push audio/headphones, absence of captured imagery and normal quit, the maintainer replied **“confirmed, closed.”** Final readback at 20:08:01 UTC independently verified application/audio-engine, producer and listener absence, no live manifest/capability/context notice, the exact official hash and one scanned DrivenByMoss extension. The dormant `owner.lock` remains. This completes official recovery, not acceptance of the failed live-feed test.

### September 10 delivery repair — local proof and focused physical recheck

Repair basis: central `0e623eb9ba00eccfb8c06e3778ae931ca8a1a606`, tree `45d3b417102627cabff493cc01b054f4a9c959b2`. DrivenByMoss remains at `93fb2a48d1e35dfeb69f902a44d8035a0b7db557` / tree `622983fad14bab0a16df950eac4976112583b59d`; its source and tested archive were not modified or rebuilt. Layout A, freshness limits, V5A discovery, v1 messages, raster and USB owners are unchanged.

The previous synchronous handoff spent too much of each frame interval transferring a 50,840,832-byte raw image through the Darwin pipe. A generated same-size workload with 17 ms of intervening computation reproduced accumulated delay. Direct writes and reducing reader overhead alone did not sustain that imposed workload. The retained repair uses an anonymous local socket pair for **the same FFmpeg stdout byte stream**, direct AVIO writes, a one-packet output queue and a nonblocking drain-before-poll reader. Readback verifies send/receive kernel capacities at no more than 262,144 bytes each. No new listener, named socket, worker, application frame FIFO, second image buffer or capture backend is added. The source PTS and frame-index pairing remain intact. FFmpeg still owns separate native allocations/queues; the socket limit is not a total native-memory claim.

Separately, whole-desktop occluder-array equality was a false source-identity test. A generated regression now proves that unrelated window movement can leave the same captured source valid. The selected window/owner/bounds/display must still match, and the measured device must be uncovered at **both** before/after observations. Occlusion, movement during processing and replacement still refuse output. This does not solve the capture-time occlusion/association gap or explain the earlier intermittent application/process lookup failures; those remain named live checks.

Reproduction, after the normal build above:

```sh
"$sampler_live_output/TestSamplerHandoff" 360 17
```

The committed benchmark uses a 5488×2316 red source with an alternating blue marker, 60 warmup frames and 300 measured frames. It stamps Unix time at FFmpeg's filter exit, maps that to the host clock with a clock-jump refusal, and imposes 17 ms of test-only synchronous computation before the next read. This measures handoff, **not native acquisition or the actual locator/fit/send work**. No full-image copy is allocated for comparisons. All 359 marker changes, both sampled color regions, dimensions, frame/PTS order and input-buffer reuse passed; pixel mismatches were zero.

| Exact final generated build, 300 samples | p50 ms | p95 ms | Max ms |
| --- | ---: | ---: | ---: |
| Filter exit → complete read | 10.374 | 33.378 | 92.503 |
| Filter exit → imposed work complete | 27.380 | 50.379 | 109.528 |
| Delivery intervals | 33.044 | 36.705 | 80.979 |

Observed delivery 30.282 fps; zero measured completions exceeded 250 ms. The matched original implementation delivered 27.275 fps with filter-to-work p50 469.337 / p95 705.517 / max 760.707 ms; all 300 measured completions exceeded 250 ms. These are short, sequential runs, not an isolated scheduling environment or endurance proof. An earlier socket-repair iteration had p95 193.773 / max 322.717 ms and six over-250-ms samples under the same synthetic work budget. Retain that variability: the final run is not a promise that scheduling can never cause a late frame.

A separate temporary non-publishing measurement exercised the **actual FFmpeg AVFoundation input** with cursor capture off, exact current display ID 5 / 6860×2894 pixels, a 5488×2316 search at `(0,0)`, unchanged source PTS, the same 17-ms test workload and 60+300 frames. The source images were discarded; no proprietary pixels were saved. Bitwig remained closed, no ingress connection was made, and the official extension remained installed.

| Actual acquisition measurement, 300 samples each | Original p50/p95/max ms | Repaired p50/p95/max ms |
| --- | --- | --- |
| Capture PTS → complete read | 716.743 / 916.697 / 930.681 | 62.021 / 69.456 / 83.789 |
| Capture PTS → imposed work complete | 733.744 / 933.698 / 947.681 | 79.041 / 86.476 / 101.074 |
| Delivery interval | 34.705 / 41.319 / 61.363 | 35.666 / 40.184 / 58.777 |

Original delivery 27.905 fps / 255 over-250-ms samples; repaired delivery 30.008 fps / zero over-250-ms samples. This confirms source-clock agreement and a useful acquisition/handoff improvement at the failed fixture's image size. It excludes Sampler recognition, actual process/context validation, fitting, socket publication, receiver and physical Push. CPU/RSS were not remeasured for this repair; neither old snapshots nor kernel-buffer capacity establish total working-set growth.

Commands: `xcrun swiftc -O -warnings-as-errors FFmpegSamplerStream.swift MeasureAcquisition.swift -o MeasureAcquisition`, then `MeasureAcquisition 5`; the original stream file was exported from the exact basis using `git archive`, not a rewritten baseline. Both diagnostic children exited and left no FFmpeg process. Native observer SHA-256 `14ea9194497c51ad877bf0847e265f77e21d47c1602a030a6804e0873698de3f`; repaired observer executable `7176239a6c2307fa1f4659c9f384548fcf0bd430f2787fa6da5189c159dad3f0`; original observer executable `b53148825e25aca5d63adcb12d079fdca047cad822d5481aef071f44b9de9bf7`. This temporary observer is not a new installed application or product entry point; the generated regression is retained in Git.

Final repair identities (FFmpeg 9.0.1, installed Homebrew `9.0.1_1`; ordinary external Swift build, no installation or permission change):

| Material | SHA-256 |
| --- | --- |
| `FFmpegSamplerStream.swift` | `57f149fb419ec071818c5318911625ec601031c2414771faf1b8de974dbfe891` |
| `SamplerLive.swift` | `5309003a5c4c54fb09e710bdea5ec5595da75c7eb9f21f2896848b8022852d19` |
| `TestSamplerLive.swift` | `d393fe0443c86ee6884e6b2a1847f8a7fba3255f4222a41cd0b6fe7dc53a4b6c` |
| `TestSamplerHandoff.swift` | `10c61a9335f719c61dd30d2b900e88860655648fe1aaccfc3dc13a111defb95f` |
| `build-live.sh` | `e1e8c79fa3eeba3514121adb67367a43ecbc0a4ddc21abcd15a58fa8abef62bd` |
| `SamplerLive`, 288,104 bytes | `4e4f529585f930dfa1bfda0bd3e950294fbc0b9784cadd0bc21a08a70a6aa280` |
| `TestSamplerHandoff` | `11e304a70d93d4ede9d2711a61591cb121563f97d50bd564958ccbd8e6882c3e` |

117 locator and 145 live-path checks pass, including bounded/idempotent close, natural child EOF, output reuse, changing generated frames and unchanged protocol deadline. The corrected path received the focused physical observation below. The previously failed live run stays failed; this recheck does not establish complete product acceptance.

#### Focused repaired run, September 10, approximately 21:12–21:15 UTC

Exact tested central head `bba029e2ddf63edc0aa4be670807e1fe0f6bdf04`, tree `9599a2687e3b9f37478b119c94df375bb383d443`; `SamplerLive` SHA-256 `4e4f529585f930dfa1bfda0bd3e950294fbc0b9784cadd0bc21a08a70a6aa280`. The Java head/tree and archive above were reused without rebuilding. The installed candidate and untouched official backup were both rehashed. The maintainer enabled the existing restart-scoped setting; current-process readback then showed one listener, one current manifest/capability and a Sampler context. No JVM options were injected.

Invocation: `SamplerLive 20531 180`. The selected current Bitwig window was 2744×1158 logical points, with a 5488×2316 acquisition search and an automatically measured 1659×438 Sampler body. Window ID is a run identity, not future configuration. The destination remained `(238,25,484,114)`. The initial locator refused output; later the selected window was raised through ordinary application UI, and current-image publication began. This sequence does not assign every locator refusal to coverage.

The maintainer directly reported **“it works GREAT”**, described the image as looking fantastic, and independently exercised leaving the device-context page and returning. The image returned with a small perceived delay. This supports steady-image usability during the observed interval and contextual return; it does not quantify reacquisition latency, prove every displayed action/value, or independently confirm every control/audio row. The producer ended normally at its 180-second bound, sent CLEAR/disconnected, and both producer and FFmpeg were absent at the 21:16:44 UTC check. Bitwig remained open awaiting normal maintainer shutdown and exact official restoration.

| Complete repaired live run | Samples | p50 ms | p95 ms | Max ms |
| --- | ---: | ---: | ---: | ---: |
| Source PTS intervals | 5,164 | 33.333 | 33.334 | 66.667 |
| Complete frame-read invocation | 5,166 | 13.386 | 31.014 | 90.840 |
| Capture PTS → read completion | 5,166 | 64.937 | 184.172 | 466.250 |
| Accepted processing, excluding frame read | 3,421 | 15.902 | 22.379 | 173.015 |
| Capture PTS → accepted send completion | 3,421 | 79.875 | 124.537 | 249.408 |

3,451 frames were sent; accepted timing excludes the first 30 accepted frames. All 1,714 explicit frame discards are accounted for: 1,661 missing locator, 32 too old after processing, 19 too old at read and two context changes during processing. Other event counters were three acquisition starts, four context changes, 15 delivery-timeout checks and one frame failure. The frame failure was a selected-window ownership refusal followed by a new acquisition attempt; the exact lookup cause remains unresolved. No subsequent accepted-frame log followed that final attempt before the run ended, so this event is not separately claimed to have recovered. The user's successful device-page return occurred earlier and has its own accepted-frame readback.

These distributions separate approximately 30-fps source delivery from accepted publication. They do not claim uninterrupted 30-fps output, zero late frames, zero fallback or a measured end-to-end physical display latency. Compared with the earlier failed run, accepted capture-to-send p95 decreased from 248.618 to 124.537 ms while the freshness limit and Java artifact stayed unchanged. The runs were not controlled matched workloads.

One early same-run process snapshot showed producer 39.3% CPU / 202,208 KiB RSS and FFmpeg 33.5% / 1,101,248 KiB RSS. These are snapshots, not peak, steady-state or growth measurements. No frames, screenshots, capability contents or raw logs are committed. Remaining limitations include visible-screen coverage, locator acquisition failures, the intermittent ownership lookup refusal, unmeasured contextual return latency and native capture memory cost.

Asked specifically about pads, pressure, encoders, transport and Push audio/headphones, the maintainer confirmed **“yes. they all worked fine. bitwig is now closed.”** Process/listener readback and session-directory inspection found no Bitwig application/audio-engine, producer, FFmpeg, listener, manifest, capability or context notice; the intentional dormant `owner.lock` remained. At **21:20:17 UTC**, the tested derivative was moved intact outside scan paths and the untouched official backup restored. SHA-256 readback was exactly `98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a`; the retained derivative still matched `abe439c9813f879db51a7a6f69b9270ffeec33e9346a8e534f96d7fee2fe9dbd`. One DrivenByMoss extension was scanned and unrelated extensions were untouched. Ordinary `open -a 'Bitwig Studio'` followed with all three JVM-option variables absent. Asked to confirm the standard display, controls and audio/headphones with no captured image, then quit normally, the maintainer replied **“Confirmed, and quit.”** Final readback at **21:27:22 UTC** verified no Bitwig application/audio-engine/plugin-host, producer or FFmpeg process, no port-45291 connection/listener and no live manifest/capability/context notice. Only the dormant `owner.lock` remained. The official hash and sole scanned DrivenByMoss extension were reverified. This completes the focused physical repair check and exact official recovery, not a claim that all source-lifetime or product limitations are resolved.

Only after safe derivative custody and an ordinary Bitwig launch, run:

```sh
"$sampler_live_output/SamplerLive" CURRENT_EXPLICIT_BITWIG_WINDOW_ID 180
```

Read the ID from the current Bitwig window, not a historical record. The producer waits for the controller's native-Sampler Device Parameters context, reads the private V5A manifest and generation-specific context notice, and supplies only the center image. Leaving the page restores actual semantics locally in the controller. It never supplies aliases, values or button meanings. Stop with Ctrl-C or let the bounded duration expire. Restore the exact official extension after testing.

Current limitations and actual ownership are in the [design](../../docs/design/sampler-context-lens.md#initial-ffmpeg-development-path). Most importantly: visible-screen acquisition, conservative occlusion refusal, window wholly within one unambiguous display (additional displays allowed), explicit window instance, English Sampler features, no proven modulator exclusion and no image markers. The focused live measurements and physical observations above do not establish final product acceptance. The older individual observations below are historical evidence, not qualification of the new producer.

### Original single-frame local observation

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
