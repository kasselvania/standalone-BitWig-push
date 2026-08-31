# V1B activation and rendering proof

## Date and machine state

- Evidence date: 2026-08-31 PDT.
- Machine state: accepted macOS 26.4.1 arm64 fixture, Bitwig Studio 6.1, real Push 3 connected.
- Central basis: `a13faef08ac8bb75a9e32f7ff7d4bc07fcd41c6e`, tree `c06009f822fee7bf36096739e7be6589f0b9ae34`.
- Source basis: `033ccef8c64f08e8d8d41fa90d48fa06b326a1a1`, tree `9aec7429ff093addee001a62a5a07309708fd592`.
- Source PR/head/tree: [kasselvania/DrivenByMoss#2](https://github.com/kasselvania/DrivenByMoss/pull/2), `a2e0341b7bccfa4e6b13614f4adffc2235f785f4`, tree `a81e5c4330b31f36845c25e98e322990d62f0c67`.

## Startup selection

Application metadata identified the executable as:

```text
/Applications/Bitwig Studio.app/Contents/MacOS/BitwigStudio
```

Property-off launches used normal Launch Services startup after confirming no `JAVA_TOOL_OPTIONS`, `JDK_JAVA_OPTIONS`, or `_JAVA_OPTIONS` value was present. Property-on launches used the actual executable before process start:

```text
env JAVA_TOOL_OPTIONS=-Dpushwig.syntheticOverlay=true \
  /Applications/Bitwig\ Studio.app/Contents/MacOS/BitwigStudio
```

Property delivery was proved independently by temporary observation output `selection enabled=true`, immediate visible overlay activation on the real Push, and the same visible activation with the exact clean committed artifact. The property-off observation recorded `selection enabled=false`, and all off/recovery launches showed no mark.

## Exact renderer behavior

The selected synthetic singleton owns one class-initialized reusable `IRenderer`. It draws only:

| Layer | X | Y | Width | Height | Color |
| --- | ---: | ---: | ---: | ---: | --- |
| Outer | 856 | 4 | 96 | 16 | `ColorEx.PINK` (`RGB 255,0,220`) |
| Inner | 860 | 8 | 88 | 8 | `ColorEx.WHITE` (`RGB 255,255,255`) |

`process` invokes `semanticFrame.render(false, RENDERER)` once and returns `semanticFrame` directly. It does not encode, copy, retain, queue, or replace the bitmap.

## Bytecode result

`javap -c -p` against the exact final classes proved:

- `Push2Display` calls `Boolean.getBoolean("pushwig.syntheticOverlay")` only in construction.
- False selects `PassThroughPushFramePipeline.INSTANCE`; true selects `SyntheticOverlayPushFramePipeline.INSTANCE`.
- No property read occurs in `send` or either `process` implementation.
- `SyntheticOverlayPushFramePipeline.process` contains one `IBitmap.render` invocation followed by `aload_1; areturn`.
- The renderer is installed once in class initialization; no `new` instruction appears in `process`.
- The renderer body contains exactly two `fillRectangle` calls at the declared coordinates/colors.
- `Push2Display.send` preserves the shutdown/null guard, invokes one pipeline call, and then one `PushUsbDisplay.send`.

## Temporary external harness

The uncommitted external harness lived outside both repositories. Source SHA-256:

```text
8df0b95c49f16211c059ff230b28ff93a181bdf662203b1b46a3afb5ed81d163
```

Invocation shape:

```text
javac -cp $HOME/.../DrivenByMoss-v1b/target/classes -d classes V1BPipelineHarness.java
java -cp classes:$HOME/.../DrivenByMoss-v1b/target/classes V1BPipelineHarness
```

Result:

```text
HARNESS_PASS identity=true render_once=true renderer_reused=true rectangles=2 pass_through_render_calls=0
```

The harness also recorded 20,000-call local method samples after warmup: pass-through p50/p95/max 42/83/292 ns and synthetic fake-render p50/p95/max 83/84/204,667 ns. Real `BitmapImpl` timing is retained separately and is authoritative for the fixture.

## Commands and tools

Tools included `PlistBuddy`, environment inspection, exact executable launch, `javap -c -p`, `javac`, `java`, `shasum -a 256`, source searches, exact installed-artifact hashing, temporary observation instrumentation, and direct Push observation.

## What this proves

- Startup selection is default-off and fixed for the lifetime of each `Push2Display` instance.
- The enabled pipeline uses one reusable renderer, one synchronous callback, and the exact same `IBitmap` reference.
- The transport boundary, guard, and exactly-one-`PushUsbDisplay.send` behavior remain intact.

## What this does not prove

- Bytecode and the fake-context harness alone do not prove host bitmap preservation; the real `BitmapImpl` before/after proof is retained separately.
- The diagnostic property is not a supported user setting or runtime hot switch.
- No external visual source or final compositor behavior is implied.
