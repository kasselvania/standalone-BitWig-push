# Sampler context lens — implementation contract

Authorized by the maintainer on 2026-09-09. This is one interaction, not a successor capture framework. Implementation is local and unqualified until the physical interaction passes.

## Result

Selecting/loading Sampler in Bitwig alone does not replace a Track/Mix screen on Push. Entering the device-parameter mode for that same native Sampler permits its verified live device image. Leaving that context immediately restores current DrivenByMoss semantics. Existing encoder bindings and all MIDI/audio ownership remain unchanged.

## Construction and runtime sequence

1. Bitwig creates the existing DrivenByMoss model and Push display. A Bitwig-native matcher identifies Sampler; object equality checks that the controller cursor and editor selection refer to the same device. A display name is not type authority.
2. Successful Push startup retains the accepted ordinary-launch ingress. Push owns the local visibility decision: exact parameter mode, supported native device, and current instance. No video producer can override that decision.
3. The producer receives current context, verifies a visible Sampler and estimates its center and extent from its own stable visual features. Physical display/window corners and normalized window percentages are not device identity or geometry.
4. The FFmpeg processing path extracts and uniformly fits that measured device rectangle. Only complete current pixels may reach the accepted ingress and sole DrivenByMoss USB writer.
5. Context changes invalidate prior visual authority. Leaving Device Parameters, selecting another device, losing the visible device, or an ambiguous match yields current semantics. A later return must not resurrect a frame from the former context.

The first unproved dependency is reliable association of the exact native Sampler cursor with the visible device and its measured center/extent. A crop rendering somewhere on Push is not a substitute for that proof. Local generated checks precede installation. In the maintainer-authorized September 10 development fixture, first qualify the actual native context with the producer stopped, then enable the image path. This is a development test, not acceptance of unproved native-instance behavior.

## Initial supported case

One visible, editor-selected native Sampler in Bitwig's device chain. Locate the device itself and update center/extent after movement or UI reflow; refuse incomplete/ambiguous observations. This does not promise hidden-window capture, arbitrary native devices, or localization of multiple visually indistinguishable instances. System capture and per-device tracking cost are measured separately.

## Protected owners

Keep current-semantic redraw, raster sink, frame validation/storage, accepted protocol v1 and its write bounds, MIDI, audio, and Push USB writer. The missing context handoff must be explicit; a producer-side CLEAR alone cannot enforce mode switching. No installation, security-setting change, or additional foreground helper UI is a prerequisite for the local localization proof.

## Acceptance

Prove mouse selection while Track/Mix stays semantic; Device Parameters for the matched Sampler shows the real device; current controls work; measured center/extent follow supported movement and reflow; exit/mismatch/loss restore current semantics; re-entry uses only current-context pixels. Verify ordinary controls/MPE/transport/audio/headphones and exact official extension restoration after any fixture swap. Generated tests and local image analysis are not physical acceptance.

## Approved presentation A — September 10

The maintainer approved layout A in the [offline screen preview](../../visuals/sampler/presentation-prototype/README.md): four permanent readouts on each side of the stationary device image. This is design approval, not physical acceptance of a live implementation.

The maintainer clarified the required information after the physical LED proof: keep the existing device-button action words and states aligned with their buttons, preserve lower device/page navigation, and continuously show all eight current remote aliases/formatted values. An LED's encoder-slot color must not relabel the button's independent device action. Touch adds emphasis; it must not be the only way to see a value.

Fit the device uniformly and keep its image stationary on touch. Retain the top action and bottom navigation strips. The single-left-list and touch-to-reveal alternatives are superseded. Missing visual correspondence retains the value without inventing a location. Multiple touches must not erase other readouts or silently choose one by event order. No zoom/camera behavior is proposed. Real text/image readability at 960×160 remains a review question, not a result inferred from a large desktop mockup.

The UI must distinguish the editable remote alias from its current target and use actual hardware touch, not the mode-local flag observed stale after a mode change. A changed alias is not a mapping revision; an unchanged alias is not proof of the same target. Direct current value updates must not require image recognition to refresh a number.

The existing diagnostic does not produce atomic context/assignment authority. Its same-label remap and triangle relocation establish a controlled observation, not universal slot-to-pixel identity. Before any live replacement, the binding owner must supply meaningful current-context identity and loss/rebind invalidation; a producer must associate current pixels with that context. A fixed delay, a freshly wrapped snapshot, name matching, or a producer-only CLEAR does not establish this. Native identity, modulator exclusion and continuous source validity also remain unproved. The preview's generated IDs and markers are deliberately not offered as a solution to those gaps.

## Live integration under development

DrivenByMoss remains the renderer and data owner for all action words/states, remote aliases/formatted values, raw hardware touch and lower navigation. The producer supplies only the uniformly fitted center image, at `(238,25,484,114)` within the 960×160 output. It must not paint the readouts, interpret MIDI, or infer parameter values from pixels. Unverified remote-to-image markers are omitted; raw touch still emphasizes the correct numbered readout.

The implementation retains the existing protocol-v1 128-bit producer session identity through receiver publication and display adoption. The controller requires an exact context-session identity and center destination before raster application. This changes internal metadata, not the wire format, receiver count, frame buffers, raster sink or USB writer. A prior context's publication is refused locally even if it is fresh or the producer has not yet noticed a context change.

The ordinary semantic bitmap is rendered first. The compact presentation is applied only after an eligible center frame succeeds; missing, stale, wrong-context or out-of-bounds frames leave the complete ordinary semantic output intact. Native Sampler/editor association and the context-to-producer handoff must be proven before enabling this path in the fixture. The initial controller integration is not permission to substitute an arbitrary image or a display-name match for those prerequisites.

### Context lifetime and handoff

The native observer uses the existing catalogue UUID matcher, equality with an independently editor-following cursor, and a pinned observation cursor. It commands only its own observation cursor, never encoder binding or editor selection. Pending cursor requests grant no authority. Native identity/position observations, mode transitions and remote-page changes revoke the ticket; a qualified context gets a new UUID. Tests exercise the real observer against simulated API endpoints. They do **not** establish the live host's pinned-cursor behavior on same-index deletion/replacement or atomic callback batching. The initial fixture must keep one selected Sampler and explicitly qualify the actual API behavior; no universal device-instance or assignment-identity claim is made.

The display owns a coalesced, non-secret notice at `~/.pushwig/runtime/sampler-lens-v1/<ingress-generation>.json`. Its one small metadata worker is separate from display send; it never carries frames. Atomic private-file replacement occurs only on context transitions. The accepted V5A `external-raster-v1` directory receives no additional files. Generation-specific notice/temp filenames prevent old shutdown from deleting a new lifecycle's notice. Orphaned non-secret notices after a crash are not current authority: the producer selects only the generation named by the currently validated V5A manifest.

Each ticket is one producer connection's v1 session ID. Disconnect of that exact session makes the controller issue a fresh ticket; disconnect of an older context does not disturb a newer one. CLEAR keeps the current connection. A lost context invalidates pixels locally before filesystem publication catches up. Existing notifications/semantic overlays also suppress the compact image presentation. There is no new receiver, frame store, USB writer or frame queue.

### Initial FFmpeg development path

`SamplerLive` uses the already installed FFmpeg executable and its AVFoundation visible-screen input, with cursor/mouse-click capture off. It is **not** desktop-independent window capture. The explicitly selected current Bitwig window must be wholly inside one unambiguous display; other displays may remain active. Bounded enumeration retains that display's ID, point bounds, mode pixels and FFmpeg index. The index follows `CGGetActiveDisplayList`, as used by [FFmpeg 9's AVFoundation input](https://raw.githubusercontent.com/FFmpeg/FFmpeg/n9.0.1/libavdevice/avfoundation.m). Revalidation includes the display identity/geometry; topology or window changes refuse old frames and restart acquisition. This is not cross-display drag acceptance. Current window bounds limit recognition work; device geometry still comes from Sampler's feature constellation and enclosing border, not a normalized window percentage. Occlusion/loss refuses publication; window recreation requires explicit current-window reselection.

FFmpeg's source PTS is retained with `-copyts`; integer showinfo PTS/timebase are paired with the exact raw frame index. Live publication requires measured agreement with the CoreMedia host clock, a frame newer than the observed context, and age no greater than 250 ms before send. Old transport data is discarded, never stamped with receipt time. The September 10 delivery repair replaces the raw-video Darwin pipe with an anonymous `AF_UNIX` socket pair, retaining the same child and synchronous reader. Send/receive kernel capacities are each set and read back at at most 256 KiB, descriptors are close-on-exec except the child's explicit stdout mapping, FFmpeg uses direct writes and a one-packet output queue, and the reader polls only when a nonblocking read would wait. There is no listening endpoint, filesystem socket, new worker or application frame FIFO. One raw input buffer is reused; metadata remains bounded to four timestamps and a 32 KiB diagnostic accumulator. FFmpeg's native acquisition/processing storage is separate and is not claimed zero-copy or bounded merely by these socket capacities.

The declared acquisition envelope is an active display mode no larger than 8192×4320 pixels. The cropped Bitwig search image shares that finite bound (one reusable buffer, at most 141,557,760 bytes); it must not impose an arbitrary smaller window width. The September 10 fixture's 2744×1158-point window at 2× requires a 5488×2316 search, or 50,840,832 bytes. Generated FFmpeg frames at that exact pixel size verify transport and buffer reuse before live acquisition. FFmpeg still allocates/copies acquisition images/packets internally; this is not zero-copy. The helper borrows its reusable search buffer synchronously. Vision reacquires labels on lock loss (at most twice a second); normal frames revalidate their sampled label pixels and enclosing border without OCR. The locator still includes the Expressions/modulator area: modulator exclusion is **not solved**. Source continuity compares the selected window ID, owner PID, bounds and display facts; unrelated changes elsewhere in the desktop window list are not a source replacement. The measured Sampler region must be uncovered at both before/after observations. This correction removes a false rejection, not the remaining capture-time occlusion/association uncertainty.

FFmpeg libswscale applies the measured crop and uniform Lanczos fit into one reusable 484×114 BGRA output (220,704 bytes). Fit rounding loses less than one output pixel per axis; remaining space is opaque black. Alpha is normalized to 255. Scaler state is reused for unchanged dimensions. The producer validates private V5A/current-context files and process birth identity, reads the capability separately, and sends unchanged v1 messages with one 250 ms complete-message deadline. It neither launches Bitwig nor installs an app or changes permissions.

These are development implementations with generated regression tests. They are not yet the completed live interaction, a 30-fps result, a validated remote-to-marker map or physical acceptance.

The September 10 live layout run failed reliability: individual frames looked good to the maintainer, but video repeatedly fell back to semantics. [Retained timings and the rejected local optimization](../../visuals/sampler/README.md#september-10-live-layout-flicker-failure-not-acceptance) are implementation evidence, not an accepted source model. Capture and transport must sustain current frames; extending stale validity or presenting an old image is not the repair. Ordinary occlusion and display changes also need a usable, stable fallback/reacquisition experience before acceptance.

The subsequent delivery repair passed a focused physical steady-image/context-return and controls/audio recheck, followed by byte-exact official recovery. [The exact run and remaining limitations](../../visuals/sampler/README.md#focused-repaired-run-september-10-approximately-21122115-utc) remain separate from final-product acceptance. One intermittent identity refusal and a small perceived return delay were retained. The repair did not change layout, Java, receiver, freshness or protocol.

## Foreground utility — commissioned September 10

Keep the approved presentation and controller owners. One foreground command in an ordinary Terminal session runs without a window ID or duration. No installation, packaging, background service, login startup, status-file service or permission onboarding belongs to this slice. It does not add Slice mode, Browser, image markers, a new capture backend or a general device framework.

Construction/runtime:

1. The foreground process resolves an optional `--ffmpeg` path, otherwise the current Terminal PATH, validates a regular executable, and prints the selected path once. It neither launches Bitwig nor edits preferences, files or permissions.
2. With no valid current V5A/Sampler notice, it remains idle with no FFmpeg child and no connection.
3. Validate the manifest owner's PID, birth time and actual executable's Bitwig bundle identity using current kernel/filesystem facts. Do not make this synchronous command-line loop depend on AppKit's run-loop-updated running-application list.
4. Select exactly one visible ordinary window of that verified PID. Titles, largest/first window and monitor position do not choose it. Missing/ambiguous ownership restores semantics; diagnostic explicit-window selection remains available.
5. Current eligible context plus current unique source permits the existing synchronous FFmpeg/locator/fit/v1 path. Context loss closes capture and clears/disconnects; geometry/window/session changes invalidate old pixels and restart from current facts.
6. Context/source loss invalidates cached geometry and signatures. Within one current identity only, bounded suspect tracking may crop a new current frame using recently verified geometry under the continuity rules below. Neither cached imagery nor a reused context ticket is allowed.
7. Terminal state changes distinguish authority/context/window waiting, acquisition/first-frame waiting, locating, active image, geometry/occlusion loss, semantic fallback and source failure. No per-frame logging or status file is used. If the first complete frame has not arrived within five seconds, the foreground utility clears/closes, stops its child and exits with a bounded stderr excerpt; it does not repeat permission attempts indefinitely. This startup limit does not extend the 250-ms frame-freshness rule.
8. Ctrl-C/SIGTERM or an optional diagnostic duration clears/disconnects, stops the owned child and prints bounded final in-memory metrics. The first 30 accepted sends per acquisition are warmup; each timing series retains at most 10,000 samples.

The first unproved dependency is the no-argument foreground interaction through repeated real controller-context transitions. Generated tests exercise its real lifecycle with generated FFmpeg input and real protocol sockets, followed by one ordinary-Terminal physical session and exact official recovery. Existing capture permission is a fixture prerequisite; this slice never changes it. Repeated visible fallback under ordinary eligible use stops the run and is retained for a separate visual-continuity decision, not hidden by longer freshness or cached imagery.

Shared code is limited to actual process/window lifetime, bounded transport, crop/fit, and controller-owned bindings/presentation. Sampler recognition and its eligibility notice remain device-specific. Device categories and future behavior-family designs do not impose inheritance trees or a public profile SDK.

## Foreground continuity repair — authorized after the blocked run

The foreground operating model is provisionally proven; the two remaining owners are controller presentation policy and producer tracking. No capture/backend/service/packaging decision is reopened. The checkpoint is a development record, not acceptance. One combined physical session remains required when the maintainer is present.

Controller: the existing played-note/chord call in `AbstractView.displayChord()` uses a typed `IDisplay.notifyPlayedChord()` entry. Default behavior is ordinary notification. Only Push2Display suppresses this feedback while current Sampler context/publisher is available. All retained ordinary notifications, errors and overlays still block composition. This v0 suppresses the full-screen note card rather than adding a badge. No string recognition or producer notification policy is involved.

Producer: `SamplerImageLock` owns ACQUIRING/LOCKED/SUSPECT/LOST geometry/signatures, never image storage. Initial acquisition still requires the original OCR constellation and strict body locator. Each patch compares 64 grayscale samples with tolerance 12, taking the best of the original location and four one-pixel axial offsets. A patch passes at 58/64 matches. Strong tracking requires at least 80% passing patches, all four edges agreeing, and successful strict body remeasurement. Each edge samples 32 positions and requires 28 within gray tolerance 4.

Only a current two-thirds patch majority plus three of four coherent body edges can authorize SUSPECT geometry reuse, for at most three consecutive frames AND 100 ms since strict verification. Geometry must remain in bounds. The runtime independently requires unchanged PID/birth/window/display/context/session, fresh monotonic PTS, no coverage before/after processing, and unchanged final controller authority. Hard losses invalidate the tracker immediately; late frames still use the existing 250-ms freshness limit. No frame or destination storage was added. Exhausted confidence means semantic fallback, not delayed CLEAR or stale-image hold.

These thresholds are explicit initial engineering values exercised with generated disturbances, **not calibrated real-Sampler performance claims**. OCR remains at most 2 Hz while reacquiring. Failure reasons distinguish signature mismatch/majority, border failure, OCR cooldown/empty/ambiguity/error and body-not-found. Runtime reasons additionally cover authority/geometry/occlusion/staleness.

At most 128 transition records retain monotonic time, source PTS, context/ingress identifiers, PID/birth/window/display, window/body rectangles, anchor/border confidence and action. No pixels or capabilities are recorded. Contiguous refusal runs retain per-reason burst counts and maximum frame lengths; an open burst is identified separately. Eight existing timing arrays remain bounded. Final metrics must be interpreted with this scope, not as a complete unbounded event history.
