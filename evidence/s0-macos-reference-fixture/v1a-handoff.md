# V1A no-op frame-pipeline handoff

## Date and machine state

Prepared 2026-08-31 from DrivenByMoss 26.4.1 at commit `fd03245ab38fa5149c45934051d937ee9fda6d08`. Bitwig Studio 6.1 was running; Push was connected and enumerated later in the same S0 session. This remains a source-grounded design handoff, while hardware results are retained separately.

## Seam verdict

Insert `PushFramePipeline` **inside `Push2Display.send(IBitmap)`, immediately before its existing call to `PushUsbDisplay.send(IBitmap)`**.

Pinned cut:

```java
// Push2Display.send — current source
if (!this.isShutdown && this.usbDisplay != null)
    this.usbDisplay.send(image);
```

Source: [`Push2Display.send`](https://github.com/git-moss/DrivenByMoss/blob/fd03245ab38fa5149c45934051d937ee9fda6d08/src/main/java/de/mossgrabers/controller/ableton/push/controller/Push2Display.java#L85-L92).

At this point:

- semantic rendering has completed;
- the frame is the persistent 960 x 160 Bitwig bitmap;
- no Push pixel conversion, padding, XOR shaping, header construction, or USB write has started;
- `Push2Display` still controls shutdown and owns the one transport object;
- no generic graphic display, semantic mode, or USB encoder needs to change.

This is option 2 in the S0 question, and concretely the boundary between `Push2Display` orchestration and `PushUsbDisplay` transport. Options 2 and 3 describe the same line in the current object graph; the implementation belongs in `Push2Display.send`, not in `AbstractGraphicDisplay` or `PushUsbDisplay`.

## Boundary type and no-op behavior

The V1A boundary type should remain DrivenByMoss's platform-neutral `IBitmap`. On Bitwig, the concrete object is `BitmapImpl`, wrapping a Bitwig `Bitmap` created as ARGB32.

The V1A pass-through pipeline returns **the identical object reference**:

```java
@FunctionalInterface
public interface PushFramePipeline
{
    IBitmap process (IBitmap semanticFrame);
}

public enum PassThroughPushFramePipeline implements PushFramePipeline
{
    INSTANCE;

    @Override
    public IBitmap process (final IBitmap semanticFrame)
    {
        return semanticFrame;
    }
}
```

An explicit transport boundary may remain equally small:

```java
public interface PushDisplayTransport
{
    void send (IBitmap frame);
    void shutdown ();
    boolean isShutdown ();
}
```

`PushUsbDisplay` implements that interface without changing its encoder or USB code. `Push2Display` owns the pipeline and transport and performs:

```java
final IBitmap output = this.framePipeline.process (image);
this.transport.send (output);
```

The sketch is a recommendation only; no code is implemented in S0.

## Exact preservation answer

Yes. The semantic bitmap can be passed pixel-for-pixel and memory-byte-for-memory-byte unchanged in V1A because the no-op returns the same `IBitmap` object and does not invoke `render`, `encode`, or any copier.

For a given source bitmap and unchanged transport, the resulting wire payload is deterministic and unchanged. Scheduling time may shift by a method call, but there is no conversion or alternate representation in the no-op path.

V1A does **not** need:

- a new bitmap;
- an encoder wrapper;
- a second render callback;
- a raw-pixel copy;
- an immutable frame representation;
- another executor, queue, process, or USB owner.

Those mechanisms would add cost and uncertainty before any composition requirement exists.

## Minimal file shape for V1A

Existing DrivenByMoss files to modify:

1. `src/main/java/de/mossgrabers/controller/ableton/push/controller/Push2Display.java`
   - own/inject the pipeline and transport;
   - route the already-complete bitmap through the pipeline;
   - preserve shutdown order and semantic fallback.
2. `src/main/java/de/mossgrabers/controller/ableton/push/controller/PushUsbDisplay.java`
   - implement the narrow `PushDisplayTransport` interface only;
   - do not change encoding, buffers, executor, endpoint, error handling, or lifecycle in V1A.

New derivative/project-owned types:

1. `PushFramePipeline.java` — one synchronous `IBitmap -> IBitmap` operation.
2. `PassThroughPushFramePipeline.java` — allocation-free singleton identity implementation.
3. `PushDisplayTransport.java` — the minimal existing send/shutdown contract.
4. Focused tests for identity, call order, shutdown gating, and no additional writer construction.

No mode/view class, `AbstractGraphicDisplay`, `BitmapImpl`, `HostImpl`, matcher definition, encoder, or endpoint wrapper should change. `PushControllerSetup` does not need to change if the existing `Push2Display` constructor installs the identity pipeline and concrete USB transport; a package-private constructor overload can support test injection.

The class is shared by Push 2 and Push 3. V1A therefore changes the common modern-Push call shape even though the retained hardware acceptance fixture is Push 3. The identity contract must be unit-proven for the shared path; S0 does not claim physical Push 2 acceptance.

## Why the other cuts are worse

### Immediately before `Push2Display.send(IBitmap)`

Changing `AbstractGraphicDisplay.send()` or every semantic caller would broaden the cut into the generic graphic framework and other controllers. The frame is already complete at the protected override, so that broader change has no benefit.

### Inside `PushUsbDisplay.send(IBitmap)` or an encoder wrapper

That is too late. `PushUsbDisplay` is where transport-specific conversion begins. Putting composition there would couple semantic/visual frame policy to BGR565 conversion, scan-line padding, XOR shaping, memory blocks, and USB scheduling. It also makes fallback and testing harder.

### A new immutable frame for V1A

A 960 x 160 ARGB32 snapshot is 614,400 bytes. Creating/copying one on every host-driven display update would introduce large avoidable memory traffic before it is needed and would make exact no-op equivalence harder, not easier.

### A second USB-writing process

This violates the one-writer invariant and is unnecessary. The existing `PushUsbDisplay` already holds the matched interface/endpoint and must remain the only steady-state writer.

## Pixel-equivalence acceptance for V1A

Use three layers of evidence:

1. **Identity unit proof**
   - assert that the pass-through pipeline returns the exact input object (`assertSame`);
   - assert one pipeline call and one transport call per eligible `Push2Display.send`;
   - assert no transport call after shutdown gating.
2. **Read-only semantic-frame hashes**
   - at the pipeline boundary, call `IBitmap.encode` only in a diagnostic build;
   - hash width, height, and a read-only/duplicate view of all raw bitmap bytes before and after `process`;
   - do not advance or mutate the live buffer;
   - retain hashes and mode/state labels, not proprietary screenshots.
3. **Final transport/hardware check**
   - retain deterministic encoded-payload hashes from the unchanged transport path or a synthetic-bitmap transport test;
   - repeat the real pads/MPE/encoders/transport/semantic-display/audio checklist before and after the V1A derivative;
   - characterize cadence and timing rather than claiming visual sameness from one photograph.

Because the no-op returns the same object, raw pre/post hashes must be identical for every sampled frame. Any difference is a V1A failure.

## Allocation, timing, and thread risks

Source-proven current behavior:

- the semantic bitmap is mutable and reused;
- its encoding occurs synchronously on the Bitwig host-scheduled controller path;
- only the copied/shaped transport buffer crosses to the USB executor;
- rendering is dirty-suppressed, but encoding/transfer submission is not;
- transfer tasks are not bounded or replaced by latest-task semantics.

V1A constraints:

- the identity pipeline must allocate nothing per frame;
- it must not retain the mutable `IBitmap` after `process` returns;
- it must not move the bitmap to another thread;
- it must not add a queue, timer, blocking wait, logging on every frame, or USB handle;
- measure pipeline-call time and end-to-end send cadence on the real fixture;
- do not mistake the existing transport task queue for permission to add another queue.

Future composition will need a stable pixel snapshot if work leaves the controller callback. That is a later measured design decision, not a reason to copy in V1A.

## One-writer preservation

Only `PushUsbDisplay` may obtain the matched device/endpoint and invoke USB writes. `PushFramePipeline` receives no `IHost`, `IUsbDevice`, `IUsbEndpoint`, or endpoint address. `Push2Display` remains the single orchestrator that calls one `PushDisplayTransport`.

Tests should construct a fake transport with a call counter; production construction should create exactly one `PushUsbDisplay`. A later helper publishes frames only and never opens Push USB.

## Failure, rollback, and fallback

- Runtime fallback: if a later non-identity pipeline rejects, lacks, or cannot compose an external layer, send the original semantic `IBitmap` to the same transport immediately. V1A itself has no external failure mode.
- Code rollback: revert the small V1A commit so `Push2Display.send` directly invokes `PushUsbDisplay.send` again.
- Operational rollback: restore the already-proven official DrivenByMoss 26.4.1 artifact whose SHA-256 is `98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a`. S0 does not perform that reinstall.

Do not hide pipeline exceptions by dropping the semantic frame. The architectural fallback is the original semantic bitmap through the original writer.

## Later `VisualSourceFrame` ingress

The macOS helper must publish a project-owned, platform-neutral immutable snapshot such as:

```text
VisualSourceFrame
  source_id / source_role
  width / height / pixel_format
  sequence / timestamp
  validity / stale_reason
  confidence
  immutable frame bytes
```

A later pipeline implementation reads at most the latest valid snapshot without blocking, composes it with the current semantic frame, and returns a validated final 960 x 160 bitmap. `SCWindow`, `CGWindowID`, `CVPixelBuffer`, ScreenCaptureKit objects, and permission state remain inside the macOS helper. The helper never receives a USB handle.

V1A should not introduce `VisualSourceFrame`, IPC, shared memory, or composition code; it should only leave a clean synchronous place for those later inputs.

## Proven conclusions versus implementation hypotheses

| Conclusion | Status |
|---|---|
| Complete semantic bitmap reaches `Push2Display.send` before transport encoding. | Proven by pinned source. |
| Runtime bitmap is a persistent 960 x 160 `BitmapImpl` wrapping Bitwig ARGB32 memory. | Proven by pinned source. |
| `IBitmap.encode` permits read-only copying/hashing in its callback. | Proven by concrete implementation. |
| Identity pipeline needs no new bitmap/encoder/render callback/frame representation. | Proven by the boundary and no-op contract. |
| Only `PushUsbDisplay` writes the matched endpoint in DrivenByMoss. | Proven within pinned source. |
| Exact live Bitwig flush/display Hz. | Unproven; measure in V1A. |
| A second `IBitmap.render` safely preserves the semantic pixels. | Unproven; defer to synthetic composition. |
| Host unplug/replug recreates the writer automatically. | Unproven on hardware; no reconnect exists in `PushUsbDisplay`. |
| No unrelated process can contend for Push USB. | Unproven; source inspection and host enumeration do not establish system-wide exclusive ownership. |
| External frames can be composed within timing limits. | Later implementation hypothesis. |

## Tools and commands used

The recommendation comes from the pinned source trace documented in `display-pipeline-trace.md`, using Git, `rg`, `nl`, `sed`, and inspection of the concrete Bitwig bitmap wrapper and Push transport. No implementation, build, install, USB transfer, or capture permission was performed.

## What this evidence proves

- Another agent can make the V1A no-op cut without rediscovering the renderer or entering transport encoding.
- The cut can preserve the exact semantic object and one steady-state USB writer.
- The minimal affected file/type shape, equivalence strategy, risks, rollback, and later platform-neutral ingress are explicit.

## What this evidence does not prove

- It does not prove that a V1A implementation passes tests or hardware acceptance.
- It does not choose a later compositor pixel representation.
- It does not authorize overlay, IPC, capture, resolver, or macOS helper work.
- It does not turn the retained S0 hardware baseline into V1A implementation proof.
