# V1A implementation and identity proof

## Date and machine state

- Evidence date: 2026-08-31 PDT.
- Machine state: accepted macOS 26.4.1 arm64 fixture; proof executed against the exact committed V1A artifact before fixture installation.
- Central basis: `a36779d4c04a11d6c6e9ce0d48c34ea3b813a0cc`, tree `bc4634da23f794f2afd39c63fab9eb5cf44524c1`.
- Source basis: `fd03245ab38fa5149c45934051d937ee9fda6d08`, tree `edd2ad636b0aa1f39919f0ffd05c968015450075`.
- Source PR/head/tree: [kasselvania/DrivenByMoss#1](https://github.com/kasselvania/DrivenByMoss/pull/1), `6e1e4cbd2e725a7951e5b4dc1278fbb6e7b5d61c`, `9aec7429ff093addee001a62a5a07309708fd592`.
- Artifact under proof: SHA-256 `94e69a2f2ce91ac6522ed6a0c1c52d7c216dea3a8c3d03f76c2221886bc62706`.

## Source behavior

`PushFramePipeline` is a functional interface whose sole operation accepts and returns `IBitmap`. `PassThroughPushFramePipeline` is a final class with one eagerly created `INSTANCE`; its private constructor prevents per-send construction, and its `process` implementation is exactly `return semanticFrame;`.

The existing public `Push2Display` constructor assigns the singleton to one final field. It exposes no pipeline constructor injection or user configuration.

Inside the pre-existing semantic guard, `Push2Display.send` now performs:

```java
if (!this.isShutdown && this.usbDisplay != null)
{
    final IBitmap outputFrame = this.framePipeline.process (image);
    this.usbDisplay.send (outputFrame);
}
```

The local reference is not a heap allocation. There is one pipeline call and one existing transport call. `PushUsbDisplay` ownership and all downstream encoding/transfer behavior are unchanged.

## Static source checks

Commands included:

```text
git diff --check
git status --short
git diff --stat
git diff --name-only
git diff --unified=0 --no-color
rg -n 'Thread|Executor|Scheduled|Timer|Queue|Future|USB|IUsb|ByteBuffer|encode\(|render\(|ScreenCapture|SCWindow|CVPixelBuffer|CGWindow' <new pipeline files>
git diff -- PushUsbDisplay.java pom.xml
```

The exact three-path envelope passed. Added lines and both new types contained none of the forbidden terms. The `PushUsbDisplay.java` and `pom.xml` diffs were empty. DrivenByMoss stores these Java files with CRLF endings; Git's standard `cr-at-eol` whitespace classification was selected so `git diff --check` validated content without line-ending churn.

The existing `ExecutorService`, lambda, and `Thread.currentThread()` in `Push2Display.shutdown` are inherited upstream behavior. They were not added, changed, or moved by V1A.

## Bytecode proof

The exact committed extension was disassembled with the pinned JDK:

```text
javap -classpath target/DrivenByMoss.bwextension -c -p \
  de.mossgrabers.controller.ableton.push.controller.PassThroughPushFramePipeline \
  de.mossgrabers.controller.ableton.push.controller.PushFramePipeline \
  de.mossgrabers.controller.ableton.push.controller.Push2Display
```

The pass-through method is:

```text
0: aload_1
1: areturn
```

It directly returns the input reference and contains no `new`, method invocation, pixel access, encode/render call, or storage. The class initializer has one `new` for the process-wide singleton; that executes at class initialization, not per display send, and allocates no frame.

`Push2Display.send(IBitmap)` disassembled to:

```text
0:  aload_0
1:  getfield isShutdown
4:  ifne 33
7:  aload_0
8:  getfield usbDisplay
11: ifnull 33
14: aload_0
15: getfield framePipeline
18: aload_1
19: invokeinterface PushFramePipeline.process
24: astore_2
25: aload_0
26: getfield usbDisplay
29: aload_2
30: invokevirtual PushUsbDisplay.send
33: return
```

This proves the two guards, exactly one synchronous pipeline invocation, exactly one following `PushUsbDisplay.send`, and no asynchronous handoff in the display-send method.

## Temporary reference-identity harness

A temporary Java harness outside both repositories used a dynamic `IBitmap` proxy, called `PassThroughPushFramePipeline.INSTANCE.process(input)`, and failed nonzero unless `result == input`.

- Harness source SHA-256: `b03c828fb1037f886c9e492483b8d72cb38db38197e711232837cf9e6ad259e0`.
- Compile/run environment: the same JDK 21 path as the build, with the exact committed V1A artifact on the classpath.
- Result: `PASS: result == input`, exit 0.
- Retention: source and class were removed from `/private/tmp`; neither repository contains the harness.

## Single-writer and transport result

V1A constructs no USB object and introduces no second writer. `Push2Display` still owns the same single `PushUsbDisplay`, and `PushUsbDisplay.class` is byte-identical between the base and head builds at SHA-256 `288b576b3f2ed064f8d9a0c6f6d384fb3516a0858cc22e7879bee896df83dec3`.

Therefore the existing pixel conversion, scan-line padding, XOR shaping, memory blocks, `byteStore`, transfer executor, interface/endpoint matching, transfer-error behavior, and shutdown path remain the accepted upstream implementation.

## What this proves

- The identity pipeline returns the same Java object, not a copied or re-rendered bitmap.
- The boundary is synchronous and adds no per-send object, buffer, task, lambda, queue, or future allocation.
- The existing one-writer `PushUsbDisplay` transport remains downstream and unmodified.

## What this does not prove

- Bytecode and harness evidence do not measure frame cadence, latency, garbage-collector behavior, or USB timing.
- They do not prove real Bitwig/Push behavior; that remains a separate physical gate.
- V1A deliberately provides no alternate pipeline selection or external-frame ingress. A later V1B change must introduce composition deliberately without placing macOS types in the controller extension.
