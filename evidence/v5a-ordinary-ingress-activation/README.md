# V5A — ordinary Bitwig ingress: final acceptance

Status: **READY FOR FINAL REVIEW**, not merged. Owning [issue #53](https://github.com/kasselvania/standalone-BitWig-push/issues/53); implementation [DrivenByMoss PR #6](https://github.com/kasselvania/DrivenByMoss/pull/6). Build/repair: 2026-09-04. Completed physical acceptance/rollback: 2026-09-09, maintainer's accepted macOS + Bitwig + Push 3 fixture. This record separates deterministic, process, physical, and recovery facts.

## Exact custody

| Object | Commit / SHA-256 | Tree / size |
| --- | --- | --- |
| Central basis | `8a8d1d3d3cc4e4c8588bf8dc79e047055eaa6db9` | `fff9707fe242f269f4045bb63a404ce773c36dc7` |
| DrivenByMoss parent / `pushwig/main` | `7e3416a1bdddbcbeec4e35e6531652e1618723de` | `c8bc3f9e052e8f0b7b5dd256657697349d303740` |
| Final source / `pushwig/v5a-ordinary-ingress-activation` | `9cab625a736e31e2ec5d5b7bcec77cc778839048` | `dbf3dc8d4e6d6b95a654088f85b8a183584063b7` |
| Tested candidate | `ea69daa18a41011105c8228035dd377964ca05f5cf37196f0629fc70824050e6` | 14,402,726 bytes |
| Restored official | `98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a` | Sole scanned extension |

Source worktree: `$HOME/Documents/ChatGPT/BitWig Standalone Push/DrivenByMoss-v5a`. Central evidence worktree: sibling `standalone-BitWig-push-v5a-final`, branch `pushwig/v5a-final-acceptance`. The central PR commit identifies this record; no self-referential evidence-head claim is embedded here. Existing source PR was amended with an explicit lease on reviewed head `ed3e317d8eea84672e674058788753169aa32961`, retaining one substantive commit above its original parent. No production code changed after the final build or during acceptance.

## Narrow ownership and startup repair

The default-Off global Push controller preference is **Pushwig → External visual ingress (requires restart)**. It is read once during configuration initialization. No JVM external-ingress activation properties, direct executable launch, or wrapper are used.

`Push2Display` construction records the request but creates no ingress authority. External precedence remains pass-through until successful activation, including activation failure. `PushControllerSetup.startup()` invokes the idempotent public internal hook `Push2Display.startExternalIngress()` after the existing startup operations. Public visibility is needed only across the existing Java packages. `GenericControllerExtension.init()` already schedules startup only after full setup initialization returns.

The display retains activation, pipeline, composition, and shutdown ownership. One lifecycle monitor serializes startup/shutdown; a separate short frame lock safely publishes the pipeline to sends. Filesystem/startup/socket-bind/join work is not performed while holding the frame lock. Redraw is fixed true during construction for an external request, before any external pixels can be applied; this also covers a send that overlaps startup publication. Repeated startup never duplicates or retries activation; shutdown-before-startup prevents later activation.

The approved rendezvous remains at `$HOME/.pushwig/runtime/external-raster-v1`: 0700 directories, 0600 files, one lifetime owner lock, exclusive fresh 32-byte capability represented as 64 hex bytes, atomic nonsecret `current.json` after receiver bind. Manifest fields are `schema_version`, `protocol_version`, `transport`, `port`, relative `capability_file`, `session_generation`, `owner_pid`, `owner_start_epoch_millis`. Port 45291, IPv4 loopback, freshness 1500 ms. Safe dead-session remnants are removed under lock; unsafe entries fail semantic-only. Manifest invalidation precedes receiver shutdown; receiver termination removes capability/session files. Dormant `owner.lock` remains intentionally.

Changed production paths relative to the accepted source basis (prefix `src/main/java/de/mossgrabers/controller/ableton/push/`):

- `PushConfiguration.java`
- `PushControllerSetup.java`
- `controller/Push2Display.java`
- `controller/ExternalRasterPushFramePipeline.java`
- `controller/ExternalRasterReceiver.java`
- `controller/PushwigExternalIngressActivation.java`
- `controller/PushwigRuntimeRendezvous.java`

Only `PushControllerSetup`, `Push2Display`, and the lifecycle test changed in the startup-order amend. Reviewed rendezvous, receiver validation, protocol, store, raster sink, USB, MIDI, and audio ownership were not redesigned. No extra queue, receiver, store, sink, or writer.

## Deterministic/build proof

Explicit environment: `JAVA_HOME=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home`, `PATH=$JAVA_HOME/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin`. Java/Javac 21.0.11, Maven 3.9.16, macOS 26.4.1 arm64, read from inside that environment.

One targeted compile/run of the changed classes and lifecycle suite passed, followed by one final complete `scripts/test-pushwig-external-ingress-activation.sh` run, 2026-09-04 22:47:32–22:47:59 UTC, exit 0. Its own `mvn -q clean package -Dbitwig.extension.directory=target` is the broader package build; no redundant clean/install/package run surrounded it. All three suites passed:

1. `PushConfigurationIngressSettingTest`: persisted On/Off, default Off, Push 1 exclusion.
2. `PushwigRuntimeRendezvousTest`: private root/files, manifest non-disclosure, exclusive owner, safe stale cleanup, malformed/trailing JSON, unsafe mode, unknown entry/symlink refusal, publication-collision cleanup.
3. `ExternalRasterIngressLifecycleTest`: production HELLO/FRAME/CLEAR/store adoption, bind failure, disconnect, wrong and previous-session capabilities, active shutdown, fresh immediate restart and terminal cleanup; plus actual `Push2Display` construction/startup/repeat/shutdown-first/failure/redraw regression.

The added display test constructs the real display with a fake host bitmap/USB adapter, uses the real receiver/store, and calls its actual send path. It verifies no pre-startup listener/manifest/capability, one unchanged activation after repeated startup, no activation after shutdown, pass-through despite enabled lower diagnostics on failure, and a new semantic render before every external raster application even with unchanged model. It is not a second lifecycle/frame-store implementation. Adapter observation proves call ordering, not physical pixel rendering.

`javap -c -p` against the final JAR proves no constructor activation call and `startExternalIngress` as the final startup call after `updateColorPalette`. Source diff/check confirms protected paths unchanged. Extracted base-versus-candidate comparison:

- `PushUsbDisplay.class` byte-identical, SHA-256 `288b576b3f2ed064f8d9a0c6f6d384fb3516a0858cc22e7879bee896df83dec3`.
- `LatestExternalRasterFrameStore.class` byte-identical, SHA-256 `8cfa9663fdcdebc613d6e04e09dd62aca31a1abfb558205300b0e789426f3cd1`.

The package phase emits `target/DrivenByMoss-26.4.1.jar`, not an install-phase `.bwextension`. That exact JAR was copied byte-for-byte under the canonical `.bwextension` filename; no second build. Manifest remains Implementation-Version 26.4.1, Java-Version 21, Maven JAR Plugin 3.5.0. No binaries committed.

Runner SHA-256: `2573aad4899cb7a445e3d44e2998eaf001b1038045e12d7f4f84cb64453d446e`. Final lifecycle-test source SHA-256: `f9cb66523fbf9f4c35c6b1e8be130a25e49aaf9761a3efaf5354e5277958dd2d`. The other two test classes and runner remain in the same source commit; no permanent test dependency or POM change.

## Physical program and process evidence

Session accounting: prior Checkpoint C had three constructor-head DEVELOPMENT VERIFICATION launches, followed by official recovery; those do not qualify the repaired head. On September 4 the repaired candidate had two preparatory launches: first the persisted setting was visibly Off, changed On with no hot activation; the next normal launch created authority, but the maintainer could not watch and acceptance paused. Those two incomplete launches are non-final preparation, not physical PASS evidence. On September 9 the fixture was found stopped with no session/listener, the exact candidate still installed, and the official backup intact. The completed FINAL ACCEPTANCE program used **two candidate launches plus one official recovery launch**. No capture tests or new development matrix.

Both candidate launches and official recovery used `open -a '/Applications/Bitwig Studio.app'`; all three JVM option variables were checked absent in shell and launchd. Sole installed-artifact hash, normal controller behavior, and session ownership support actual load. No file-presence-only loading claim.

Temporary standard-library producer command: `python3 -u /private/tmp/pushwig-v5a-final-producer.py`. September 9 source SHA-256 `f80cf1949af4c6097918523732a910974319285de465f48eaffb48aca022bd8f`. It validated private paths/modes/schema/basename, separately read capability, authenticated through existing protocol v1, and sent one reusable opaque BGRA pattern at about 10 fps. Fixed destination `(400,0,560,160)`, stride 2240; red/green/blue/yellow bands of unequal widths, white 24×24 top-left marker, cyan 12-pixel bottom strip. Pattern payload SHA-256 `08a3e61e5f6599e091fdc058ae78ee3b953f4235bb989d2619a778f7c36a1fc6`. No producer source, capabilities, frames, screenshots, or full logs committed. No new performance campaign claimed.

| Check | Direct maintainer result |
| --- | --- |
| Ordinary visible/usable Bitwig and standard DrivenByMoss before producer | PASS, “confirmed” |
| Pattern colors/orientation/destination; semantics remain on left | PASS, row 1 |
| No tearing/stray pixels | PASS, row 2 |
| Pads and pressure/MPE | PASS, row 3 |
| Encoders and transport | PASS, row 4 |
| Track, Device, Session modes | PASS, row 5 |
| Push audio/headphones; no unusual lag/dropouts | PASS, row 6 |
| CLEAR restores current semantics immediately without residue | PASS |
| Reconnect/new FRAME clean; controls/audio normal | PASS |
| Disconnect without CLEAR restores current semantics | PASS |
| Connected-but-stale input restores semantics after about 1.5 s | PASS; socket remained ESTABLISHED during pause |
| Resume updates after staleness | PASS |
| Producer exit without CLEAR restores semantics | PASS; producer exited 0 and only LISTEN remained |
| Normal Bitwig quit with receiver idle | PASS; exact application/audio-engine/listener absent, current/capability removed |
| Immediate ordinary relaunch/new session; pattern/control/audio normal | PASS; explicitly reconfirmed in final “1–2 yes” |
| Normal quit with producer active | PASS; expected receiver-closed/broken-pipe handling, producer exited 0 and zeroed buffers |
| Official normal display/controls/audio/headphones/no generated pixels | PASS, final row 2 |
| Final official quit | PASS, explicit “closed” and process readback |

First completed candidate session generation `50a0a3c03a5b197d10bba82b9f377d8d`, owner PID 18437/start epoch ms 1788970026604; capability fingerprint SHA-256 `59f7f2ab36710d669881e27343241063e5ea868301227553df2831aa0dbb1d82`. Immediate restart generation `7400a2f3a54c1f82f62139503b33891d`, owner PID 29311/start epoch ms 1788970350438; capability fingerprint `4623e38ff07507a70ccc0cadbc7836e6efec439ab28559aaa44626b1f68fd437`. Fingerprints differ; actual capability values are not retained. Each had one current manifest/capability and one listener at 127.0.0.1:45291. `lsof` labels the Java socket IPv6 internally but its bound address and producer connection are IPv4 loopback. Old-capability refusal is reused from the unchanged deterministic test, not falsely claimed as a live hostile-input test.

Tools: `ps -axo pid=,comm=` with exact executable filtering; `lsof -nP -iTCP:45291`; `stat`, `find`, `shasum -a 256`; safe nonsecret manifest readback; generated producer; direct user observations. These prove observed cleanup/fresh session and physical behavior, not nanosecond ordering. Manifest-before-receiver shutdown ordering is source/test evidence. Narrow log searches did not provide a separate controller trace; no absence-of-all-log-errors claim substitutes for physical results.

## Exact rollback and final state

Official backup was moved intact before installation to `$HOME/Documents/ChatGPT/BitWig Standalone Push/v5a-artifact-backups/20260904T224955Z/DrivenByMoss-official.bwextension`. On September 9 after active shutdown, candidate hash and official backup hash were reverified. Candidate was moved intact to the same directory as `DrivenByMoss-v5a-final-ea69daa1.bwextension`, outside scan paths. The untouched official backup was moved to `$HOME/Documents/Bitwig Studio/Extensions/DrivenByMoss.bwextension`.

At 2026-09-09 16:20:43 UTC, after maintainer-confirmed official use and final quit: official SHA-256 exactly `98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a`; exactly one scanned DrivenByMoss artifact; no Bitwig application/audio-engine or port-45291 socket; no current manifest/capability, only intentional dormant 0600 `owner.lock`. Producer had exited. No force quit, discarded project work, extension-source modification during acceptance, or second USB owner.

## What this does and does not prove

The completed result proves ordinary persisted activation after successful setup startup, real generated-frame publication through the preserved data plane, semantic restoration on all required authority-loss paths, physical controls/audio, idle/active normal shutdown, fresh immediate restart, and exact official recovery on this Mac/Push 3 fixture. Ready for final technical-lead merge review; neither PR is merged and issue #53 remains open.

No Push 2 hardware, Windows/non-POSIX runtime, capture source, semantic device localization, malicious same-user filesystem-race defense, general crash/power-loss cleanup, exhaustive log/error absence, latency benchmark, or long-duration endurance claim. The September 4–9 unattended gap is not an endurance result. Default-Off may need re-enabling after replacing the extension with an official build; the actual setting was read from UI, not assumed preserved. Unknown/unsafe runtime entries intentionally require attention; one ingress per user and restart-scoped activation remain product constraints.

After acceptance, active-document sunset belongs to the maintainer: retire the V5A recovery/checkpoint ladder from `CURRENT_SLICE.md`, V5A emergency/failed-PR restrictions from `AGENTS.md`, and obsolete failed-session recipes/publication gates in the active issue/design guidance. Preserve durable ownership, local-versus-published proof, deterministic-before-physical, and exact rollback rules. This PR changes none of those authority/status documents.
