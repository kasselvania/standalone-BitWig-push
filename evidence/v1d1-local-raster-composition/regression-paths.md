# V1D-1 regression and startup-precedence paths

## Date, machine state, and authority

- Evidence date: 2026-09-01 PDT.
- Machine state: accepted Mac/Bitwig/DrivenByMoss/Push fixture; each startup used the same exact clean source-head artifact and a normal quit boundary.
- Central basis/tree: `c94d1b74d702e696d6cc4cc89625f1a2f7a95530` / `8539026fc9476bbf2df34b310190a57906113b90`.
- DrivenByMoss basis/tree: `852b520933eed87fbe496a04b5c18819a10b3564` / `d03a372e2efcf41b22cef46501e08efbfb0c0036`.
- Source PR/head/tree: [kasselvania/DrivenByMoss#4](https://github.com/kasselvania/DrivenByMoss/pull/4), `3c3ca02ff81ab5ce110ae3d714e20b5fca05a03f`, tree `c4e42825d069421a44b3241349de9a7c6453a3ad`.
- Installed derivative for every formal phase: SHA-256 `476a57a3733cd350bd068de44a5a1019df5e198c49572d1f633e43e006ae2877`.

## Startup matrix

| Phase | Launch properties | Expected/observed selection | Direct result |
| --- | --- | --- | --- |
| A default | `env -u JAVA_TOOL_OPTIONS` | pass-through; no forced redraw/project visual | all 14 rows PASS |
| B V1B | `-Dpushwig.syntheticOverlay=true` | fixed accepted pink/white static overlay only | all 7 rows PASS |
| C V1C | `-Dpushwig.dynamicLocalVisual=true` | accepted vector A/B/C/D/NONE/STALE/INVALID lifecycle only | all 5 rows PASS |
| D precedence | all three properties true | V1D-1 raster only | all 5 rows PASS |
| E V1D-1 | `-Dpushwig.dynamicLocalRaster=true` | raster nine-state lifecycle only | all 38 rows PASS |

For every property-enabled phase, the current Bitwig log directly showed the exact `JAVA_TOOL_OPTIONS` supplied before startup. `open -a` was not used. Exact-name process checks showed Bitwig Studio and its audio engine absent before artifact changes and between phase transitions.

## Source/bytecode selection proof

`Push2Display` reads each Boolean property once during construction. Bytecode orders branches:

1. raster — new `DynamicLocalRasterPushFramePipeline`, redraw enabled;
2. V1C vector — new `DynamicLocalPushFramePipeline`, redraw enabled;
3. V1B static — `SyntheticOverlayPushFramePipeline.INSTANCE`, redraw disabled;
4. default — `PassThroughPushFramePipeline.INSTANCE`, redraw disabled.

No property is polled by `send` or `process`. The all-properties physical run showed the raster lifecycle only: no fixed V1B mark and no V1C boxes were stacked.

## Preserved implementation paths

Extracted-class comparison proved these accepted classes byte-identical between the integration base and V1D-1 head:

```text
PushUsbDisplay.class                     288b576b3f2ed064f8d9a0c6f6d384fb3516a0858cc22e7879bee896df83dec3
PushFramePipeline.class                  c037dba6ff4bb678bc3bf33168d10c427e71bb581370d8c096f6860110365491
PassThroughPushFramePipeline.class       2b8447ff08fba686f33dc5060fa8858a7fee0ba8753ebfcb54350b7db2f0763b
SyntheticOverlayPushFramePipeline.class  000e1d50a965bd26f1e1d1562ec57c9b95f876f590e365f38a567821f80b547d
DynamicLocalPushFramePipeline.class      8db7fc9e80ca659fc934b7f653e7b17305fe5d74bdf4b44c9d9269fcfb9330e4
AbstractGraphicDisplay.class             30570d697786bda562aafa145f4d8e261a347d0749bea58ec90d7b9d42752343
```

The non-raster external-harness path returned the exact same plain `IBitmap` reference on every call and invoked no raster writer. The default/V1B/V1C physical phases retained normal representative modes, controls, display, Push audio, and normal quit.

## One-writer and transport rule

`Push2Display.send` still applies one shutdown/null guard, calls one selected frame pipeline, and calls `PushUsbDisplay.send` once. `PushUsbDisplay.class` is byte-identical. No USB device, endpoint, transport, queue, scheduler, or second output bitmap was added. Thus the existing extension-owned `PushUsbDisplay` remains the sole steady-state Push display writer.

## Commands and tools

Evidence used exact executable launches with explicit environment, exact-name `pgrep`, narrowly filtered current-run logs, `javap -c -p`, extracted payload/class SHA-256 comparison, the non-raster harness path, and direct maintainer observation of the real Push.

## What this proves

- Default, V1B, V1C, and V1D-1 remain mutually selected startup paths.
- Raster precedence is deterministic when all properties are true.
- Accepted transport, pipeline, and retained-semantic redraw classes remain byte-identical where required.
- The exact clean head introduces no second display writer and passed the regression fixture.

## What this does not prove

- No runtime hot switching is implemented or tested; restart is the selection/removal boundary.
- The task makes no Push 2 hardware claim despite the shared source class.
- Representative regression runs are not endurance, cable-removal, crash, or latency tests.
