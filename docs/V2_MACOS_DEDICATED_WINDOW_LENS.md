# V2 — macOS Dedicated-Window Visual Lens

## Purpose

V2 is the first Track V slice to put **real application pixels** on Push.

The accepted V1 foundation already proves:

```text
current semantic frame
        + optional validated opaque BGRA raster
        -> one DrivenByMoss-owned Push output
```

and:

```text
external local producer
        -> authenticated complete latest-frame ingress
        -> nonblocking display adoption
        -> exact semantic fallback
```

V2 therefore does not redesign composition or transport. It adds one normal macOS capture helper that discovers a dedicated top-level window, captures a source-relative region, and publishes it through the accepted external boundary.

## Accepted bases

Central V1D-2 evidence:

```text
commit: 198b44a838009dac0df83464501004b6e6b59d9d
tree:   76d9f92ae8ec7369790b0b8dd325cd4a602e3dbb
```

DrivenByMoss V1D-2 integration:

```text
branch: pushwig/main
commit: 7e3416a1bdddbcbeec4e35e6531652e1618723de
tree:   c8bc3f9e052e8f0b7b5dd256657697349d303740
```

Exact accepted V1D-2 source head contained by that merge:

```text
830b778b720a06f56de08861d27052228c82c63b
```

## Primary claim

```text
unique dedicated Bitwig/plugin window
        -> ScreenCaptureKit helper
        -> normalized source-relative crop
        -> helper-local bounded resize
        -> opaque BGRA8888
        -> V1D-2 protocol v1
        -> current semantic Push frame + captured visual
```

Two real source classes are required:

1. one floating/undocked Bitwig native-device Expanded Device View;
2. one already-installed ordinary plug-in editor.

The result is a visual **lens**, not a desktop mirror.

## Why dedicated windows first

Dedicated top-level windows provide the cleanest source boundary:

- ScreenCaptureKit can capture one window directly;
- physical desktop position is not required for identity;
- occlusion behavior is stronger than screen-region capture;
- resize and monitor movement can be handled relative to the source;
- close/reopen is a bounded identity lifecycle;
- embedded Bitwig panel recognition and pixel anchors remain separate later uncertainty domains.

V2 deliberately does **not** solve embedded-device localization.

## Repository ownership

The first macOS backend lives in the central repository under:

```text
capture/macos/**
```

Expected files:

```text
Package.swift
Resources/Info.plist
scripts/build-app.sh
Sources/PushwigCaptureHelper/main.swift
Sources/PushwigCaptureHelper/CaptureConfiguration.swift
Sources/PushwigCaptureHelper/WindowDiscovery.swift
Sources/PushwigCaptureHelper/WindowCapture.swift
Sources/PushwigCaptureHelper/ExternalRasterProtocolClient.swift
```

The helper may later split into its own repository when contributor/build/release boundaries justify it. V2 does not create that split prematurely.

DrivenByMoss is **not modified** in V2.

## Helper process identity

A Screen Recording permission proof must belong to a normal app identity, not accidentally to Terminal or an IDE.

Preferred development identity:

```text
bundle id: com.kasselvania.pushwig.capture-helper
bundle:    PushwigCaptureHelper.app
```

The preferred first build is SwiftPM plus a deterministic app-bundle wrapper and ad-hoc development signature. Record exact Swift/Xcode/SDK/codesign identities.

If that packaging does not produce a stable TCC identity on the accepted Mac, stop and retain the blocker before switching to an Xcode-project shape.

No Developer ID or notarization claim is required.

## Window descriptor

The fixture descriptor is intentionally narrow:

```text
owner_bundle_id
exact_window_title
source_role
```

The current ScreenCaptureKit `windowID` is the live instance identity.

Selection rules:

```text
exactly one candidate -> capture
zero candidates       -> CLEAR / semantics
multiple candidates   -> CLEAR / abstain
```

Never choose a candidate by desktop x/y.

A closed and reopened window may have a different windowID. Reacquisition is lawful when the logical descriptor again resolves uniquely.

## Window inventory

Before coding fixture assumptions, inventory `SCShareableContent` while Bitwig is running.

Retain sanitized metadata for candidate dedicated windows:

- owning bundle identifier;
- application name;
- title;
- current windowID;
- frame size;
- on-screen state where exposed.

Choose:

- one native Bitwig device with useful visual content in a floating Expanded Device View;
- one already-installed plug-in with a normal editor.

Do not install a product to manufacture a fixture without maintainer approval.

## Capture configuration

Use a desktop-independent dedicated-window ScreenCaptureKit filter.

Requirements:

- no cursor;
- complete frames only;
- `32BGRA` / equivalent BGRA output;
- bounded ScreenCaptureKit queue depth;
- no extra unbounded application queue;
- default requested cadence 30 fps;
- output dimensions bounded by the V1D-2 614,400-byte payload ceiling.

### Source-relative crop

The helper accepts a normalized crop:

```text
x, y, width, height in [0,1]
```

The crop is relative to the current target window dimensions.

When the window resizes or a new matching window instance is acquired:

```text
normalized crop
        -> current source dimensions
        -> recomputed source CGRect
```

Do not store the old absolute desktop rectangle.

### Scaling

V2 authorizes bounded scaling **inside the helper/capture backend** from the selected source crop to one declared Push destination size.

No general visual-adapter fit policy is defined yet.

Record the exact backend/configuration used and whether ScreenCaptureKit or helper code performs scaling.

### Pixel normalization

Before protocol transmission:

- rows are top-to-bottom;
- pixel bytes are B, G, R, A;
- useful payload stride is explicit;
- every transmitted alpha byte is forced to `0xFF`;
- no partial output buffer is published.

## Capture lifecycle

The helper maintains a small source state machine:

```text
NO_SOURCE
UNIQUE_SOURCE
CAPTURING
AMBIGUOUS
PERMISSION_DENIED
CAPTURE_FAILED
```

Transitions to a state without valid visual authority send one protocol CLEAR when a session exists and no equivalent clear is already current.

The helper may poll shareable-window discovery at a bounded low rate for close/reopen/reacquisition. It must not poll at display-frame rate merely to rediscover the same window.

Movement on the same display should not require stream recreation when the windowID remains stable. Resize may update/recreate capture configuration as required by public ScreenCaptureKit behavior.

## Permission lifecycle

Use public macOS Screen Recording permission APIs only.

Required proof:

1. helper preflights permission;
2. denied/unavailable -> no visual authority and semantic-only Push;
3. one actionable local error is emitted;
4. controls/audio remain unaffected;
5. maintainer grants permission through normal System Settings flow;
6. same exact helper build is relaunched if macOS requires it;
7. capture then succeeds.

Do not reset TCC globally or use private APIs to make the test easier.

## V1D-2 client

The helper implements the existing protocol, not a parallel one.

Inputs:

```text
port
token-file path
```

The helper:

- reads the private capability file locally;
- creates one nonzero 128-bit session per TCP connection;
- sends one HELLO;
- sends strictly increasing FRAME/CLEAR sequence values;
- uses format OPAQUE_BGRA8888;
- never exceeds the accepted payload cap;
- never queues historical frames when the receiver is unavailable;
- stops/fails boundedly on receiver loss.

The token value is never logged or retained in Git evidence.

## Development arguments

V2 may use bounded command-line/config inputs for the fixture:

```text
--owner-bundle-id
--title-exact
--role
--crop-normalized
--destination
--fps
--port
--token-file
```

Equivalent bounded syntax is acceptable.

This is development/fixture configuration only. It is not the V3 public adapter SDK.

## Native-device proof

The native-device result must show:

- exact logical descriptor;
- useful real device visual content on Push;
- window movement without wrong-source capture;
- resize smaller/larger with source-relative crop preservation;
- close -> semantic fallback;
- reopen -> reacquisition;
- current semantic/controller operation remains correct.

Prefer a device such as Sampler when it provides a useful floating visual, but select from the actual fixture rather than assuming its title.

## Plug-in proof

The plug-in result must show the same lifecycle with one already-installed ordinary plug-in editor.

Do not generalize one tested plug-in to all VST/VST3/CLAP plug-ins.

If the exact title becomes ambiguous, V2 requires abstention rather than heuristics.

## Move / monitor / occlusion

Required:

- substantial same-display move;
- resize smaller/larger;
- foreground occlusion by another window while dedicated-window capture remains coherent where ScreenCaptureKit supports it.

If two displays are active:

- move the dedicated window between them;
- retain logical identity and useful capture.

If only one display is available, record `NOT TESTED — no second display` and make no cross-display claim. This does not block V2.

## Ambiguity test

Where safely possible, create or identify two windows that satisfy the same selected logical descriptor.

Expected result:

```text
multiple matches
        -> no source selected
        -> CLEAR
        -> semantic-only output
```

If the fixture cannot create a duplicate exact-title candidate safely, retain deterministic resolver-harness evidence and do not claim a physical duplicate-window test.

## Correctness evidence

Do not commit proprietary screenshots or raw frames.

Retain per target:

- owner bundle ID;
- exact title;
- role;
- windowID lifecycle;
- source dimensions;
- normalized crop;
- computed source rect;
- destination rect;
- capture format;
- source bytes-per-row;
- output stride;
- cropped/output SHA-256 hashes;
- protocol sequence ranges;
- frame counts;
- close/reopen/move/resize outcomes.

Required zero counts:

```text
wrong-window selections
frames after authority loss
stale visual after CLEAR/close/permission denial
crop bounds failures
BGRA/channel/alpha mismatches
partial/torn sent frames
old-window-instance frames after reacquire
helper failures affecting Bitwig/Push
```

## Performance

The helper must separate **delivery cadence** from **processing cost**.

At 30 fps retain distributions for:

- sample callback interval;
- pixel-buffer lock/access;
- source crop/configuration update where applicable;
- output copy/alpha normalization;
- protocol header preparation;
- socket send;
- complete helper processing from accepted sample to completed frame send.

Targets:

```text
capture-to-ready processing p95 <= 10 ms
copy/normalize/send p95 <= 2 ms
```

A 33.3 ms sample callback interval at 30 fps is not a 33.3 ms processing cost.

Test 15 and 30 fps. Test 60 fps only when stable; it is optional for V2 acceptance.

Retain:

- CPU usage;
- resident-memory start/end/peak over a stable run;
- dropped/incomplete frame counts;
- protocol supersession counts when observable;
- source loss/reacquisition timing.

No unbounded memory or application frame backlog is acceptable.

## Real Push acceptance

Use the exact accepted V1D-2 integration artifact or an exact rebuild from accepted `pushwig/main`.

Do not modify DrivenByMoss.

Prove:

- Push connects;
- pads/pressure/MPE/encoders/transport work;
- Push audio/headphones work;
- semantic UI remains current around/under the visual destination;
- native real pixels are useful and bounded;
- plug-in real pixels are useful and bounded;
- no accidental entire-desktop source is shown;
- close/reopen/move/resize behavior matches the logical source contract;
- permission denial, missing source, ambiguity, helper exit/crash return to semantics;
- no trail, torn frame, wrong source, abnormal lag, xrun, or dropout;
- helper and Bitwig quit normally.

Then restore and verify the exact official DrivenByMoss artifact as the sole scanned extension.

## PR topology

### Source

```text
branch: capture/v2-macos-dedicated-window-lens
scope:  capture/macos/**
commit: V2: add macOS dedicated-window capture helper
PR:     V2: add macOS dedicated-window visual lens
```

### Evidence

```text
branch: codex/v2-macos-dedicated-window-evidence
scope:  evidence/v2-macos-dedicated-window/**
```

Suggested evidence files:

```text
README.md
source-topology.md
helper-build-and-identity.md
window-discovery-and-lifecycle.md
capture-pixel-contract.md
native-device-result.md
plugin-result.md
permission-and-fallback.md
performance.md
real-fixture-and-rollback.md
```

Both PRs remain open/non-draft/unmerged until technical-lead review.

## Non-goals

- no DrivenByMoss changes;
- no embedded Bitwig-panel resolver;
- no semantic pixel anchors;
- no public visual-adapter SDK;
- no persistent calibration database;
- no mouse or plug-in-control automation;
- no remote capture;
- no Linux/Steam Deck capture;
- no private WindowServer/TCC APIs;
- no multi-layer compositor redesign;
- no second Push bitmap or USB writer;
- no appliance/CM11EB work.

## Completion condition

V2 is accepted only when the exact helper source and evidence PR heads exist; the app identity and permission behavior are retained; one floating native-device window and one ordinary plug-in editor both produce useful real pixels on the real Push through unchanged V1D-2; source lifecycle and ambiguity fallback are correct; processing is bounded; controls/audio remain normal; and the exact official DrivenByMoss artifact is restored.