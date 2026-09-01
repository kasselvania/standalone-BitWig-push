# Startup selection and regression paths

## Date, machine state, and authority

- Evidence date: 2026-09-01 PDT.
- Machine state: one exact clean V1C artifact exercised through four separate Bitwig startups on the accepted Mac + Push 3 fixture.
- Actual central basis/tree: `4265dc7b6f1cabf2dcbad1b827d002bd9062cf4f` / `2af6b4757e5906ce74a3b52c5ee82323f5e32406`.
- DrivenByMoss basis/tree: `1ae0b74f383314d170a5960ca763bdf9c319e787` / `a81e5c4330b31f36845c25e98e322990d62f0c67`.
- Source PR/head/tree: [kasselvania/DrivenByMoss#3](https://github.com/kasselvania/DrivenByMoss/pull/3), `4b3326eddcf2d890de3baa10b93f6e80842d41e1`, tree `d03a372e2efcf41b22cef46501e08efbfb0c0036`.
- Exact artifact SHA-256: `f9671047e342ed3d2503fae3423ea27725830e359e75b51e29fc88ac316be4b3`.

## Construction-time selection

`Push2Display` reads these Java system properties exactly once during construction:

```text
pushwig.syntheticOverlay
pushwig.dynamicLocalVisual
```

Selection order:

| Dynamic | Static | Selected path | Forced semantic redraw |
| --- | --- | --- | --- |
| false | false | `PassThroughPushFramePipeline.INSTANCE` | no |
| false | true | `SyntheticOverlayPushFramePipeline.INSTANCE` | no |
| true | false | new instance-local `DynamicLocalPushFramePipeline` | yes |
| true | true | new instance-local `DynamicLocalPushFramePipeline` | yes |

The properties are not polled per frame. Dynamic selection has explicit precedence and the fixed V1B mark is not stacked.

## Bytecode and harness selection proof

`javap -c -p` showed two `Boolean.getBoolean` calls in the constructor, the dynamic branch before the static branch, and no property read in either send or pipeline process. The external harness instantiated all four combinations and failed closed on any selection mismatch; all four passed.

## Real startup phases

All launches used Bitwig's actual executable, with the property supplied before process start.

### Default

```text
env -u JAVA_TOOL_OPTIONS "/Applications/Bitwig Studio.app/Contents/MacOS/BitwigStudio"
```

Result: all eleven controller/audio rows passed; no V1B or V1C visual appeared; no relevant extension/display error was observed; normal quit.

### V1B static

```text
JAVA_TOOL_OPTIONS=-Dpushwig.syntheticOverlay=true
```

Result: the fixed pink/white V1B mark appeared; no A/B/C/D movement occurred; Track, Device Parameters, Session/Browser, controls, and audio remained correct; no smear/clear/lag/xrun/relevant error; normal quit.

### Both properties

```text
JAVA_TOOL_OPTIONS="-Dpushwig.syntheticOverlay=true -Dpushwig.dynamicLocalVisual=true"
```

Result: dynamic A/B/C/D lifecycle selected; fixed V1B mark not stacked; current semantics restored; normal quit.

### V1C dynamic only

```text
JAVA_TOOL_OPTIONS=-Dpushwig.dynamicLocalVisual=true
```

Result: full dynamic lifecycle, representative modes, control/audio baseline, overlay update, clean notification lifecycle, and normal quit passed.

Current-run startup logs were used only to prove property delivery. Direct behavior came from the maintainer, not from log/file presence.

## Commands and tools

Tools included exact executable launches with `env`, narrow current-run startup-log filters, `javap -c -p`, the external property-selection harness, exact-name process checks, and direct real Push acceptance.

## What this proves

- One artifact provides all four startup combinations with explicit, construction-scoped selection.
- Default and accepted V1B behavior remain available.
- Dynamic selection wins when both properties are true, without stacking the V1B visual.

## What this does not prove

- There is no runtime hot switching or user-facing setting.
- Restart is the selection/removal boundary.
- No claim is made for a Push 2 physical fixture.
