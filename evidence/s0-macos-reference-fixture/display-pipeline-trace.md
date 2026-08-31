# DrivenByMoss Push 3 display-pipeline trace

## Date and source state

- Inspection date: 2026-08-31.
- Installed artifact: DrivenByMoss 26.4.1, SHA-256 `98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a`.
- Pinned source: tag `26.4.1`, commit `fd03245ab38fa5149c45934051d937ee9fda6d08`, tree `edd2ad636b0aa1f39919f0ffd05c968015450075`.
- Machine state: Bitwig Studio 6.1 running. Source inspection began before the maintainer connected Push; a later corrected host pass enumerated the connected controller and its audio device, as retained in `push-usb-audio.md`.

All links below are pinned to the tested commit.

## Verified call chain

```text
Bitwig ControllerExtension.flush()
  -> GenericControllerExtension.flush()
  -> AbstractControllerSetup.flush()
  -> AbstractControlSurface.flush()
       -> host-scheduled flushHandler (1 ms; repeated flushes coalesced)
       -> internalFlushHandler()
       -> updateViewControls()
  -> active AbstractView.updateControlSurface()
  -> active BaseMode.updateDisplay()
       -> mode-specific updateDisplay2(IGraphicDisplay)
       -> AbstractGraphicDisplay.send()
            -> ModelInfo snapshot
            -> renderImage() if semantic model changed
                 -> persistent 960 x 160 BitmapImpl render callback
                 -> clear, components, overlays, notification
            -> Push2Display.send(IBitmap)       [complete semantic bitmap]
            -> PushUsbDisplay.send(IBitmap)     [transport encoding begins]
                 -> BitmapImpl.encode(IEncoder callback)
                 -> ARGB32-memory byte consumption and 16-bit conversion
                 -> 128 bytes of padding per scan line
                 -> XOR signal shaping
                 -> single transfer executor
                 -> 16-byte header, then 327,680-byte image block
                 -> Bitwig USB output pipe for interface 0 / endpoint 0x01
```

## Semantic display entry and ownership

1. The Push 3 extension definition constructs a `PushControllerSetup` with `PushVersion.VERSION_3`: [`Push3ControllerExtensionDefinition.getControllerSetup`](https://github.com/git-moss/DrivenByMoss/blob/fd03245ab38fa5149c45934051d937ee9fda6d08/src/main/java/de/mossgrabers/bitwig/controller/ableton/push/Push3ControllerExtensionDefinition.java#L37-L42).
2. `PushControllerSetup.createSurface` creates one `PushControlSurface`. Push 1 gets a text display; every non-Push-1 version, including Push 3, gets one `Push2Display`: [`PushControllerSetup.createSurface`](https://github.com/git-moss/DrivenByMoss/blob/fd03245ab38fa5149c45934051d937ee9fda6d08/src/main/java/de/mossgrabers/controller/ableton/push/PushControllerSetup.java#L311-L330).
3. `AbstractControlSurface.addGraphicsDisplay` stores the display and registers its same bitmap with Bitwig's hardware-surface pixel-display object: [`AbstractControlSurface.addGraphicsDisplay`](https://github.com/git-moss/DrivenByMoss/blob/fd03245ab38fa5149c45934051d937ee9fda6d08/src/main/java/de/mossgrabers/framework/controller/AbstractControlSurface.java#L364-L371). That Bitwig hardware-display object is not the USB transport; the only Push USB calls are described below.
4. `Push2Display` owns one `PushUsbDisplay` and fixes the graphic dimensions at 960 x 160: [`Push2Display` constructor](https://github.com/git-moss/DrivenByMoss/blob/fd03245ab38fa5149c45934051d937ee9fda6d08/src/main/java/de/mossgrabers/controller/ableton/push/controller/Push2Display.java#L23-L42).

The control surface owns the `Push2Display`; `Push2Display` owns the persistent semantic bitmap through `AbstractGraphicDisplay` and owns the sole `PushUsbDisplay` instance used by that surface.

## When the frame becomes complete

Bitwig invokes the generic extension `flush`, which delegates to the setup: [`GenericControllerExtension.flush`](https://github.com/git-moss/DrivenByMoss/blob/fd03245ab38fa5149c45934051d937ee9fda6d08/src/main/java/de/mossgrabers/bitwig/framework/extension/GenericControllerExtension.java#L59-L64) and [`AbstractControllerSetup.flush`](https://github.com/git-moss/DrivenByMoss/blob/fd03245ab38fa5149c45934051d937ee9fda6d08/src/main/java/de/mossgrabers/framework/controller/AbstractControllerSetup.java#L174-L186).

The surface does not render directly in `flush`. It increments an update counter and schedules `flushHandler` through the host after 1 ms. Repeated calls are collapsed to another scheduled pass rather than recursively rendered: [`AbstractControlSurface.flush/flushHandler`](https://github.com/git-moss/DrivenByMoss/blob/fd03245ab38fa5149c45934051d937ee9fda6d08/src/main/java/de/mossgrabers/framework/controller/AbstractControlSurface.java#L736-L816).

`updateViewControls` asks the active view to update. `AbstractView.updateControlSurface` asks the active mode to update its display: [`AbstractControlSurface.updateViewControls`](https://github.com/git-moss/DrivenByMoss/blob/fd03245ab38fa5149c45934051d937ee9fda6d08/src/main/java/de/mossgrabers/framework/controller/AbstractControlSurface.java#L1117-L1124) and [`AbstractView.updateControlSurface`](https://github.com/git-moss/DrivenByMoss/blob/fd03245ab38fa5149c45934051d937ee9fda6d08/src/main/java/de/mossgrabers/framework/featuregroup/AbstractView.java#L82-L92).

For modern Push versions, `BaseMode.updateDisplay` calls the active mode's `updateDisplay2`, which adds semantic components, then immediately calls `display.send()`: [`BaseMode.updateDisplay`](https://github.com/git-moss/DrivenByMoss/blob/fd03245ab38fa5149c45934051d937ee9fda6d08/src/main/java/de/mossgrabers/controller/ableton/push/mode/BaseMode.java#L63-L78). A representative device-semantic renderer is [`DeviceParamsMode.updateDisplay2`](https://github.com/git-moss/DrivenByMoss/blob/fd03245ab38fa5149c45934051d937ee9fda6d08/src/main/java/de/mossgrabers/controller/ableton/push/mode/device/DeviceParamsMode.java#L421-L473); it converts cursor-device and parameter state into eight graphic display components.

`AbstractGraphicDisplay.send()` snapshots the semantic model and calls `renderImage()` only when that model compares unequal. `renderImage()` invokes the bitmap render callback, clears the full frame, draws every component, then overlays and any notification. Only after that callback returns does line 197 call the protected `send(this.image)`: [`AbstractGraphicDisplay.send`](https://github.com/git-moss/DrivenByMoss/blob/fd03245ab38fa5149c45934051d937ee9fda6d08/src/main/java/de/mossgrabers/framework/controller/display/AbstractGraphicDisplay.java#L167-L206) and [`AbstractGraphicDisplay.renderImage`](https://github.com/git-moss/DrivenByMoss/blob/fd03245ab38fa5149c45934051d937ee9fda6d08/src/main/java/de/mossgrabers/framework/controller/display/AbstractGraphicDisplay.java#L442-L484).

**The semantic frame is complete at the entry to `Push2Display.send(IBitmap)`.** No Push-specific pixel conversion, padding, XOR, header construction, or endpoint write has happened yet.

## Concrete bitmap behavior

- `Push2Display` asks its superclass to create one 960 x 160 bitmap and reuses it for the lifetime of the display.
- `HostImpl.createBitmap` requests `BitmapFormat.ARGB32` from Bitwig and wraps it in `BitmapImpl`: [`HostImpl.createBitmap`](https://github.com/git-moss/DrivenByMoss/blob/fd03245ab38fa5149c45934051d937ee9fda6d08/src/main/java/de/mossgrabers/bitwig/framework/daw/HostImpl.java#L254-L259).
- The concrete runtime type is the record `BitmapImpl(Bitmap bitmap)`: [`BitmapImpl`](https://github.com/git-moss/DrivenByMoss/blob/fd03245ab38fa5149c45934051d937ee9fda6d08/src/main/java/de/mossgrabers/bitwig/framework/graphics/BitmapImpl.java#L17-L56).
- `IBitmap` exposes `render(boolean, IRenderer)` and `encode(IEncoder)` but no direct width, height, pixel getter, clone, or copy operation: [`IBitmap`](https://github.com/git-moss/DrivenByMoss/blob/fd03245ab38fa5149c45934051d937ee9fda6d08/src/main/java/de/mossgrabers/framework/graphics/IBitmap.java#L12-L43).
- The concrete `BitmapImpl.encode` is a real readback hook: it creates a `ByteBuffer` over Bitwig's bitmap memory and passes it, plus width and height, to the supplied encoder callback. A caller can copy or hash bytes inside that callback.
- Repeated encoding is supported by this implementation because each `encode` call creates a fresh `ByteBuffer` view over the persistent memory block. There is no retained immutable snapshot.
- Additional drawing is syntactically possible through another `IBitmap.render` call. The pinned DrivenByMoss source does not prove whether a second Bitwig render callback preserves all previous pixels under every condition. V1A does not need that behavior; it belongs to a later synthetic-composition proof.
- There is no interface-level bitmap-to-bitmap blit or copy constructor. The `BitmapImpl` record does expose its Bitwig `Bitmap`, but downcasting to use that accessor would make a project boundary depend on a Bitwig-specific type.

The no-op pipeline can therefore forward the exact same `IBitmap` object without encoding, copying, allocating, or drawing.

## Cadence, scheduling, and suppression

- The semantic assembly, render decision, and `BitmapImpl.encode` occur synchronously on the Bitwig host-scheduled controller callback path.
- Only `sendData` runs on `PushUsbDisplay`'s single-thread executor. The mutable Bitwig bitmap is not handed to that executor; it is encoded synchronously into `byteStore` first.
- No numeric display Hz is declared in this source. The update opportunity is host-driven by Bitwig's `ControllerExtension.flush`, then deferred by 1 ms through the surface scheduler. An exact runtime frame rate remains a V1A measurement, not an S0 source claim.
- `AbstractGraphicDisplay` suppresses **rendering** when its `ModelInfo` is equal, but it still calls `send(this.image)` on every display update. It does not suppress encoding or transfer submission.
- [`ModelInfo.equals/hashCode`](https://github.com/git-moss/DrivenByMoss/blob/fd03245ab38fa5149c45934051d937ee9fda6d08/src/main/java/de/mossgrabers/framework/graphics/display/ModelInfo.java#L73-L109) compares components and notification, but omits the overlays list. Overlay-only semantic changes are therefore not independently dirty-tracked by this comparison.
- `PushUsbDisplay.send` submits one task per call. There is no bounded queue, duplicate-frame suppression, or latest-task replacement. Because tasks copy the shared `byteStore` only when they run, a backlog can send duplicate copies of a newer frame rather than preserving each historical frame.

These details make an allocation-free, synchronous identity pipeline the only justified V1A behavior. V1A must not add another queue or move the mutable semantic bitmap across threads.

## Transport encoding and USB transmission

`Push2Display.send` is only a shutdown guard plus delegation to `PushUsbDisplay.send`: [`Push2Display.send`](https://github.com/git-moss/DrivenByMoss/blob/fd03245ab38fa5149c45934051d937ee9fda6d08/src/main/java/de/mossgrabers/controller/ableton/push/controller/Push2Display.java#L85-L92).

Transport-specific work begins at [`PushUsbDisplay.send`](https://github.com/git-moss/DrivenByMoss/blob/fd03245ab38fa5149c45934051d937ee9fda6d08/src/main/java/de/mossgrabers/controller/ableton/push/controller/PushUsbDisplay.java#L91-L141):

1. Its concrete encoder is an inline `IEncoder` lambda, not a separate encoder class.
2. For each of 960 x 160 pixels it consumes four bitmap-memory bytes in blue, green, red, unused-alpha order.
3. `sPixelFromRGB` quantizes to 5 blue bits, 6 green bits, and 5 red bits and packs them as high blue / middle green / low red: [`sPixelFromRGB`](https://github.com/git-moss/DrivenByMoss/blob/fd03245ab38fa5149c45934051d937ee9fda6d08/src/main/java/de/mossgrabers/controller/ableton/push/controller/PushUsbDisplay.java#L224-L231).
4. It writes the low byte and then high byte of each 16-bit pixel.
5. `DATA_SZ` is `20 * 0x4000 = 327,680` bytes. Raw 960 x 160 x 2 pixel data is 307,200 bytes, leaving 20,480 bytes, or exactly 128 zero padding bytes per scan line. Each transmitted scan line is therefore 2,048 bytes.
6. It XORs the entire image block, including padding, with the repeating byte pattern `E7 F3 E7 FF`: [`signalShaping`](https://github.com/git-moss/DrivenByMoss/blob/fd03245ab38fa5149c45934051d937ee9fda6d08/src/main/java/de/mossgrabers/controller/ableton/push/controller/PushUsbDisplay.java#L143-L162).
7. The executor copies the shaped Java byte array into the Bitwig memory block, then writes the fixed 16-byte header followed by the 327,680-byte image block, each with a 1,000 ms timeout: [`sendData`](https://github.com/git-moss/DrivenByMoss/blob/fd03245ab38fa5149c45934051d937ee9fda6d08/src/main/java/de/mossgrabers/controller/ableton/push/controller/PushUsbDisplay.java#L165-L185).

`PushUsbDisplay` does not validate dimensions or format beyond the method's 960 x 160 documentation. A future pipeline must not send an arbitrary external frame directly to transport; it must preserve or produce the required validated final bitmap.

## USB claim, writer, shutdown, errors, and reconnect

The Push 3 definition declares vendor `0x2982`, product `0x1969`, interface `0`, endpoint address `0x01`, bulk transfer: [`Push3ControllerDefinition`](https://github.com/git-moss/DrivenByMoss/blob/fd03245ab38fa5149c45934051d937ee9fda6d08/src/main/java/de/mossgrabers/controller/ableton/push/Push3ControllerDefinition.java#L21-L32) and [`claimUSBDevice`](https://github.com/git-moss/DrivenByMoss/blob/fd03245ab38fa5149c45934051d937ee9fda6d08/src/main/java/de/mossgrabers/controller/ableton/push/Push3ControllerDefinition.java#L71-L77).

The Bitwig extension definition turns that declaration into a hardware-device matcher, interface matcher, and bulk endpoint matcher: [`AbstractControllerExtensionDefinition.listHardwareDevices`](https://github.com/git-moss/DrivenByMoss/blob/fd03245ab38fa5149c45934051d937ee9fda6d08/src/main/java/de/mossgrabers/bitwig/framework/extension/AbstractControllerExtensionDefinition.java#L149-L174) and [matcher construction](https://github.com/git-moss/DrivenByMoss/blob/fd03245ab38fa5149c45934051d937ee9fda6d08/src/main/java/de/mossgrabers/bitwig/framework/extension/AbstractControllerExtensionDefinition.java#L194-L211).

`PushUsbDisplay` asks the host for matched device index 0 and matched interface/endpoint index `(0, 0)`: [`PushUsbDisplay` constructor](https://github.com/git-moss/DrivenByMoss/blob/fd03245ab38fa5149c45934051d937ee9fda6d08/src/main/java/de/mossgrabers/controller/ableton/push/controller/PushUsbDisplay.java#L64-L88). `UsbDeviceImpl` resolves those matched indexes to Bitwig's interface and pipe: [`UsbDeviceImpl.getEndpoint`](https://github.com/git-moss/DrivenByMoss/blob/fd03245ab38fa5149c45934051d937ee9fda6d08/src/main/java/de/mossgrabers/bitwig/framework/usb/UsbDeviceImpl.java#L46-L57).

Writer audit within the pinned source:

- exactly one `new Push2Display` call exists;
- `Push2Display` contains exactly one `new PushUsbDisplay` call;
- the Push package has one matched endpoint lookup and only the header/image calls in `PushUsbDisplay.sendData` write it;
- `UsbEndpointImpl.send` writes only if the matched pipe direction is `OUT`: [`UsbEndpointImpl.send`](https://github.com/git-moss/DrivenByMoss/blob/fd03245ab38fa5149c45934051d937ee9fda6d08/src/main/java/de/mossgrabers/bitwig/framework/usb/UsbEndpointImpl.java#L43-L59).

This proves one source-level steady-state writer object per active Push surface. It cannot prove that no unrelated external process attempts to claim the interface; source inspection and host enumeration do not establish system-wide exclusive ownership.

Lifecycle behavior:

- Initial device/endpoint lookup failure is caught, logged, and leaves both fields null. There is no retry loop inside `PushUsbDisplay`.
- Transfer failures are caught and logged inside `UsbEndpointImpl`; they do not propagate to invalidate the endpoint, retry the frame, or recreate the device.
- `Push2Display.shutdown` sends a final semantic message, marks itself shut down, then shuts down the USB display and the notification executor: [`Push2Display.shutdown`](https://github.com/git-moss/DrivenByMoss/blob/fd03245ab38fa5149c45934051d937ee9fda6d08/src/main/java/de/mossgrabers/controller/ableton/push/controller/Push2Display.java#L56-L83).
- `PushUsbDisplay.shutdown` nulls device/endpoint and shuts down the transfer executor: [`PushUsbDisplay.shutdown`](https://github.com/git-moss/DrivenByMoss/blob/fd03245ab38fa5149c45934051d937ee9fda6d08/src/main/java/de/mossgrabers/controller/ableton/push/controller/PushUsbDisplay.java#L188-L220).
- Setup exit subsequently asks the host to release USB devices, while `UsbDeviceImpl.release` states that Bitwig handles release automatically: [`AbstractControllerSetup.exit`](https://github.com/git-moss/DrivenByMoss/blob/fd03245ab38fa5149c45934051d937ee9fda6d08/src/main/java/de/mossgrabers/framework/controller/AbstractControllerSetup.java#L160-L170) and [`UsbDeviceImpl.release`](https://github.com/git-moss/DrivenByMoss/blob/fd03245ab38fa5149c45934051d937ee9fda6d08/src/main/java/de/mossgrabers/bitwig/framework/usb/UsbDeviceImpl.java#L60-L66).

Source-proven gap: reconnect is not implemented by `PushUsbDisplay`; any successful unplug/replug recovery depends on Bitwig recreating/reactivating the controller extension or another host lifecycle behavior. Real reconnect behavior remains a hardware observation, not a source claim.

## Why Push 3 reuses `Push2Display`

The reuse is intentional in code: `PushControllerSetup.createSurface` branches only for Push 1 text display; Push 2 and Push 3 both take the modern graphic-display branch. The Push 2 and Push 3 definitions use the same display interface `0`, bulk endpoint `0x01`, and the same `Push2Display`/`PushUsbDisplay` protocol implementation; only their product IDs differ (`0x1967` versus `0x1969`): [`Push2ControllerDefinition`](https://github.com/git-moss/DrivenByMoss/blob/fd03245ab38fa5149c45934051d937ee9fda6d08/src/main/java/de/mossgrabers/controller/ableton/push/Push2ControllerDefinition.java#L21-L32).

The source contains no explanatory design comment beyond that deliberate branch and matching USB shape. It proves reuse and the shared implemented protocol; the historical rationale is an inference from those facts, not a quoted upstream claim.

## Tools and commands used

Read-only inspection used `git rev-parse`, `git show`, `git log`, `git grep`, `rg`, `nl`, `sed`, `find`, archive metadata inspection, and `javap` against the locally installed Bitwig public API classes. No upstream source or installed binary was edited.

## What this evidence proves

- The complete source-level semantic-renderer-to-USB path at the tested revision.
- The concrete bitmap type, creation path, readback mechanism, reuse, and copy limitations.
- The exact point at which the semantic 960 x 160 frame is complete.
- The actual inline encoder, pixel conversion, scan-line padding, XOR shaping, header/image writes, device matcher, interface, and endpoint.
- The source-level scheduling, render suppression, lack of transport suppression, error handling, shutdown, and absence of internal reconnect.
- The one-writer object graph inside DrivenByMoss.

## What this evidence does not prove

- A numeric live frame rate, allocation profile, or USB throughput on the maintainer's Push.
- Real reconnect behavior or exclusive ownership against unrelated processes.
- That a second `IBitmap.render` call is a safe preserving overlay operation.
- Pixel equivalence of a V1A implementation, because V1A has not been implemented.
- Any manual Push control, display, or audio result.
