# Display selection and source-validity guard

## Date, machine state, and authority

- Date: 2026-09-02 PDT.
- Machine state: accepted single-display macOS 26.4.1 arm64 fixture; Bitwig
  Studio 6.1 bundle ID read back as `com.bitwig.studio`.
- Central basis/tree:
  `7c15abaf55c0080b2f80971e845b4ee6f1bfcc46` /
  `730726784b57016714c0a44c8f0f8caf1c5b0141`.
- Source PR/head/tree:
  [PR #43](https://github.com/kasselvania/standalone-BitWig-push/pull/43) /
  `03fb8c8824714e4bbefd7224848ca9cdad069088` /
  `f1f68bc6f0ba6527bb146a7ee93fd4333ffaf796`.

## Display inventory and exact selection

The bounded `--list-displays` mode returned one relevant ScreenCaptureKit
display:

```text
display_id=5 width=3430 height=1447 unit=screen-points main=true frame=0,0,3430,1447
```

Capture required explicit `--display-id 5`,
`--expected-display-width 3430`, and `--expected-display-height 1447`.
`DisplayDiscovery.select` requires exactly one identifier match and exact
dimensions. It does not choose the first element. The running capture also
revalidates active-display ID, dimensions, bounds/arrangement, and main-display
role using public CoreGraphics point-space display bounds.

The unit contract is explicit: `SCDisplay.width`/`height`,
`SCContentFilter.contentRect`, and `SCStreamConfiguration.sourceRect` are screen
points. `pointPixelScale` translates points to output pixels and is not applied
to `sourceRect`. Continued revalidation uses `CGDisplayBounds`, not the
pixel-unit `CGDisplayPixelsWide`/`CGDisplayPixelsHigh` APIs.

The deterministic tests reject absent, unknown, ambiguous, wrong-width,
wrong-height, rearranged, and no-longer-active fixtures. The 21-case runtime
matrix separately rejected unknown ID and wrong dimensions before capture or
protocol connection. Safely simulated runtime disappearance and drift exercised
`DisplayDiscovery.validateCurrent`; no physical display topology was changed.

## Source-validity contract

The configured guard is exact:

```text
required running application bundle ID = com.bitwig.studio
frontmost application bundle ID        = com.bitwig.studio
```

`NSWorkspace.runningApplications` and
`NSWorkspace.frontmostApplication` are the only source-validity inputs. The
guard is evaluated every 100 ms. Active-display validation occurs every five
guard polls (0.5 seconds), and Screen Recording preflight is rechecked every 50
polls (5 seconds). These checks use public APIs and no Accessibility, mouse,
private WindowServer, or image-recognition mechanism.

When the guard becomes invalid, one serialized CLEAR is sent if visual
authority existed and further FRAME publication is suppressed. When it becomes
valid again, only current capture samples resume; no historical frame queue
exists.

## Failed first guard run and correction

The first real guard run exposed an implementation defect rather than being
accepted: the helper used `dispatchMain()`. The maintainer put another app in
front, but the crop remained on Push. Independent OS readback showed
`com.openai.codex` was frontmost while helper counters reported zero invalid
transitions. `NSWorkspace` state on that execution shape was not advancing on
the AppKit main run loop.

The defect was corrected before the original sole source commit by running
`NSApplication.shared.run()`. That accepted source was rebuilt and retested.
The repaired probe recorded 1,202 guard polls, 240 display revalidations, 24
permission revalidations, two valid transitions, one invalid transition, 2,602
published frames, 817 suppressed samples, two CLEAR messages (focus loss and
normal stop), and zero capture/pixel errors. The maintainer confirmed that
focus loss cleared to semantics and returning Bitwig frontmost resumed the
current crop cleanly.

The exact amended head retained that event-loop implementation. Its focused
smoke recorded two guard-invalid and two guard-valid transitions, two authority
revocations, and zero protocol, stream, pixel, stride, or destination errors in
the accepted normal-quit run. The maintainer again directly confirmed semantic
CLEAR while another app was frontmost and current-crop recovery when Bitwig
returned frontmost.

This correction is retained because the initial failure demonstrates why a
source-only reading of the guard would not have been sufficient.

## Commands and tools

Tools included the helper's bounded display inventory, `plutil` bundle-ID
readback from Bitwig, `NSWorkspace` observation, narrow process/frontmost
readback, aggregate helper counters, deterministic Swift tests, runtime invalid
configuration invocations, and direct maintainer focus changes. No mouse or UI
automation drove the lifecycle.

## Exact result

- Correct display selected: PASS.
- Wrong/absent/drifted display abstention: PASS in deterministic and executable
  tests.
- Bitwig frontmost/running -> FRAME: PASS.
- Another application frontmost -> one CLEAR, no FRAME, semantics: PASS after
  the final AppKit-run-loop correction.
- Bitwig frontmost again -> current FRAME, no replay: PASS.
- Bitwig quit -> no continuing visual authority: PASS.

## What this proves

- Selection and continued fixture authority are tied to explicit display facts,
  not ordering or a silent fallback.
- The final helper's public running/frontmost guard revokes and restores visual
  authority correctly on the accepted fixture.

## What this does not prove

- Frontmost Bitwig does not prove that Sampler or the intended device panel is
  inside the crop. Bitwig can remain frontmost while the fixed crop contains
  other desktop content.
- The deterministic display-loss proof is not a physical hot-unplug,
  resolution-change, or rearrangement test.
