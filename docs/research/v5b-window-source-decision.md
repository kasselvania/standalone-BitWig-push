# V5B source decision: test the window path, not the framework label

Lead source inspection: September 9, 2026. Execution and acceptance are owned by [issue #57](https://github.com/kasselvania/standalone-BitWig-push/issues/57). This is a decision record, not an additional governance layer.

## Decision and uncertainty

Test **ScreenCaptureLite's CoreGraphics single-window backend** on the existing Mac. Do not adopt the library as a permanent dependency or claim that it passes before running it. The specific unresolved question is whether it supplies current Bitwig-window frames without the primary-window sharing-control obstruction already observed with ScreenCaptureKit.

Selected source pin: [`smasherprog/screen_capture_lite` at `0c5beb0e3c5e4f9e0fcc9203025a80ad5164e6a4`](https://github.com/smasherprog/screen_capture_lite/tree/0c5beb0e3c5e4f9e0fcc9203025a80ad5164e6a4). This is an exact development commit, not a claim that a stable release has been qualified. Upstream identifies the project as MIT-licensed; preserve its license and attribution for any reused source.

**The serious caveat is API age.** Apple marks [`CGWindowListCreateImage`](https://developer.apple.com/documentation/coregraphics/cgwindowlistcreateimage) deprecated. The pinned upstream [CMake configuration](https://github.com/smasherprog/screen_capture_lite/blob/0c5beb0e3c5e4f9e0fcc9203025a80ad5164e6a4/CMakeLists.txt) explicitly defaults the macOS deployment target to 14.0. That is a build setting, not evidence of runtime compatibility on the maintainer's macOS 26.4.1 fixture and not a future support guarantee.

V5B allows the upstream backward deployment target with the installed SDK. It does not allow changing SDK headers, suppressing availability errors, private API calls, symbol-loading bypasses, an OS/SDK downgrade, or substituting ScreenCaptureKit. Failure to compile or capture correctly is an early decision result, not permission to start a different backend. Any successful result remains an experimental compatibility backend with its support horizon disclosed at final review.

## What the code actually does

| Layer | Inspected implementation | Consequence |
| --- | --- | --- |
| Mac window dispatch | [`src_cpp/ios/ThreadRunner.cpp`](https://github.com/smasherprog/screen_capture_lite/blob/0c5beb0e3c5e4f9e0fcc9203025a80ad5164e6a4/src_cpp/ios/ThreadRunner.cpp) maps `RunCaptureWindow` to `CGFrameProcessor` | The window route is distinct from the library's monitor route. Use only the window route. |
| Mac acquisition | [`CGFrameProcessor.cpp`](https://github.com/smasherprog/screen_capture_lite/blob/0c5beb0e3c5e4f9e0fcc9203025a80ad5164e6a4/src_cpp/ios/CGFrameProcessor.cpp) calls `CGWindowListCreateImage(CGRectNull, kCGWindowListOptionIncludingWindow, window.Handle, kCGWindowImageBoundsIgnoreFraming)` | It requests the chosen window's image rather than cropping a physical monitor. This is still a platform API, not access to Bitwig's internal framebuffer. |
| Native bytes | The same function reads image dimensions/stride, obtains provider data with `CGDataProviderCopyData`, invokes `ProcessCapture`, then releases the data and image | It copies and allocates at the source. Borrowed callback bytes must not escape their lifetime. No zero-copy claim. |
| Enumeration | [`GetWindows.cpp`](https://github.com/smasherprog/screen_capture_lite/blob/0c5beb0e3c5e4f9e0fcc9203025a80ad5164e6a4/src_cpp/ios/GetWindows.cpp) uses window-list metadata but derives scaling from the first non-mirrored display | Do not inherit this as authoritative geometry. It also accesses window-name metadata without a null check. Use bounded, null-safe selection of the intended application/window. |
| Linux source | [`src_cpp/linux/X11FrameProcessor.cpp`](https://github.com/smasherprog/screen_capture_lite/blob/0c5beb0e3c5e4f9e0fcc9203025a80ad5164e6a4/src_cpp/linux/X11FrameProcessor.cpp) uses X11 window attributes and `XShmGetImage` on the selected window | A concrete source backend exists behind the same capture interface. It is untested here and does not establish Wayland, portal, Flatpak, or occlusion equivalence. Its shared-memory permission/error handling also requires review before Linux deployment; upstream requests mode 0777. |
| Callback contract | [Pinned README](https://github.com/smasherprog/screen_capture_lite/blob/0c5beb0e3c5e4f9e0fcc9203025a80ad5164e6a4/README.md) describes full-frame/damage/mouse callbacks and library-owned bytes | Subscribe to complete frames, omit mouse callbacks, and validate the actual format. Documentation describes BGRA but the native implementation asserts 32-bit size rather than fully validating channel metadata. |

No native probe, package build, Bitwig usability test or physical Push test was performed during this lead preparation. These source facts justify a bounded experiment, not a performance or compatibility claim.

## Why this candidate

The useful difference is **window-bound acquisition without the rejected SCStream route**, with raw bytes before any remote encoding. It directly addresses the missing source layer and has inspectable Mac and Linux backends.

Weylus Community Edition is a corroborating second-screen architecture, not another independent acquisition winner. At [`be2ca4e0aa26e26b61b7469644a07a837a57c9e4`](https://github.com/GoldenDragons/WeylusCommunityEdition/blob/be2ca4e0aa26e26b61b7469644a07a837a57c9e4/src/capturable/core_graphics.rs), its Mac window recorder selects window IDs, optionally includes a cursor window, and returns strided BGR0 data before encoding. It belongs to the same older Quartz window-image family. We are not importing its remote server, input injection, or AGPL application source.

Replacing capture with an FFmpeg encoder, a streaming client, or a cross-platform crop routine would not answer this question. Nor does using C++ alone prove portability. V5B does not claim to have exhausted every alternative.

## Integration with what Pushwig already owns

```text
explicit Bitwig process/window instance
    -> pinned candidate's window acquisition
    -> bounded raw-frame bridge
    -> existing helper crop/scale and opaque BGRA processing
    -> V5A current-session discovery
    -> existing V1D-2 producer client
    -> unchanged DrivenByMoss receiver/store/composition/USB writer
```

The first source probe runs with the official extension untouched and previews locally. That allows source/API/usability failure to be discovered without installing a derivative or involving Push transport. If it passes, continue the same effort through the accepted ingress and physical Push; no new selection gate is needed.

Existing `WindowFrameProcessor.swift` expects a BGRA `CVPixelBuffer`; the candidate supplies borrowed raw image bytes. Add only the narrow input bridge actually required, with a real lifetime and measured copy budget. Do not pretend the types already match or rewrite the existing image-processing layer as a speculative portable core.

Existing `ExternalRasterProtocolClient.swift` accepts a token path and port and already has a whole-message 250 ms write deadline. V5A now publishes those connection facts in `current.json`; a small validated producer-discovery addition is necessary. The official upstream extension does not expose that rendezvous. Use the accepted derivative only after local source proof, and do not reopen receiver activation.

The library-owned acquisition allocation is distinct from Pushwig-owned storage. Bound the allowed source geometry, release each image, preserve at most a measured latest result or synchronous handoff, and measure capture-inclusive cost. Do not add a queue to conceal a slow source.

## Source identity is not device identity

For this work, explicit selection of one Bitwig window is acceptable. Validate its application owner, lifecycle and current handle; the numeric OS handle is runtime state, not a persistent profile. Recreated windows invalidate old frames. Ambiguous selection abstains.

Movement must not change the selected content. A resize may safely clear and reacquire with new measured pixel geometry. Minimized, hidden or lost sources may clear; continuing capture while minimized is not required. Another application's occlusion must not put its pixels into the selected-window stream.

Sampler/Polymer identity, parameter regions, semantic context routing and internal panel reflow are later work. Two different window-local crops must demonstrably select different pixels, but neither is a device anchor.

## Outcome discipline

An early failure yields one concrete issue result and safe local teardown, not a new generic core or WIP preservation PR. A successful candidate yields one central implementation PR with focused tests, runnable generated source proof, concise usage/evidence, and official-artifact rollback. Final review decides whether the demonstrated compatibility envelope is useful despite API deprecation.

V5A remains accepted throughout. Its recovery ladder does not return. No product-wide capture-framework commitment, Linux move, remote-access stack or Sampler restart follows automatically from this experiment.
