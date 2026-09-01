# V1D-1 lifecycle and pixel-correctness proof

## Date, machine state, and authority

- Evidence date: 2026-09-01 PDT.
- Machine state: exact 960×160 local harness plus the accepted real Mac/Bitwig/Push fixture.
- Central basis/tree: `c94d1b74d702e696d6cc4cc89625f1a2f7a95530` / `8539026fc9476bbf2df34b310190a57906113b90`.
- DrivenByMoss basis/tree: `852b520933eed87fbe496a04b5c18819a10b3564` / `d03a372e2efcf41b22cef46501e08efbfb0c0036`.
- Source PR/head/tree: [kasselvania/DrivenByMoss#4](https://github.com/kasselvania/DrivenByMoss/pull/4), `3c3ca02ff81ab5ce110ae3d714e20b5fca05a03f`, tree `c4e42825d069421a44b3241349de9a7c6453a3ad`.

## Startup ownership and composition rule

`Push2Display` reads these properties once during construction:

```text
pushwig.syntheticOverlay
pushwig.dynamicLocalVisual
pushwig.dynamicLocalRaster
```

Selection precedence is raster, then V1C vector, then V1B static, then pass-through. Raster and vector paths request a fresh render from the newest retained semantic `ModelInfo` before every send. Static/default do not. `Push2Display.send` retains its shutdown/null guard, invokes exactly one selected pipeline, and invokes the unchanged `PushUsbDisplay.send` once with the returned bitmap.

The production raster rule is therefore:

```text
output = writeOptionalRaster(fullRedraw(currentSemanticModel))
```

It is not mutation of a prior composed output. The pipeline returns the exact same `IBitmap` reference. A non-`IRasterWritableBitmap` input returns unchanged without invoking a writer.

## Bounded nine-state lifecycle

Each state lasts 64 eligible sends; the counter wraps after 576 sends. Generated arrays are class-initialized once.

| State | Source size / offset / stride | Destination | Writer behavior |
| --- | --- | --- | --- |
| SMALL | 64×16 / 16 / 256 | x=16, y=8, 64×16 | one accepted opaque write |
| ODD_PADDED | 117×37 / 19 / 481 | x=48, y=12, 117×37 | one accepted odd-stride write |
| MEDIUM | 480×80 / 8 / 1920 | x=240, y=40, 480×80 | one accepted write |
| FULL | 960×160 / 0 / 3840 | x=0, y=0, 960×160 | one accepted full-frame write |
| REPLACEMENT | 64×16 / 4 / 256 | x=872, y=136, 64×16 | one accepted replacement write |
| NONE | none | none | semantic-only; no writer |
| STALE | none | none | semantic-only; no writer |
| INVALID | none | none | semantic-only; no writer |
| MALFORMED | SMALL parameters with x=-1 | rejected | one writer call; false required; no pixels changed |

The visual patterns include red/green/blue/white/black top bars, asymmetric yellow/magenta lines, and corner markers: red top-left, green top-right, blue bottom-left, white bottom-right. Every applied source alpha is `0xFF`. Padding/sentinel bytes are outside the requested row spans.

## Deterministic external harness

The final Java 21 external harness source SHA-256 was `724095ad2ee2c0273164dada172dabfb63161230df0826269f09aaa5d2305038`. It ran against the exact clean source-head artifact and reported:

```text
stateCount=9
sendsPerState=64
validWriterCalls=320
semanticOnlyWriterCalls=0
malformedWriterCalls=64
sameReference=true
nonRasterFallback=true
cycles=1000
transitions=10000
positiveTargetChanges=707771000
sourceTargetMismatches=0
outsideMismatches=0
oldRegionMismatches=0
noneMismatches=0
staleMismatches=0
invalidMismatches=0
malformedMismatches=0
semanticUpdateEvents=1000
semanticUpdateMismatches=0
```

Exact semantic frame hashes:

```text
A 913cd5b2ef68a516f31cf1c246c1f3cc8e499cdcedc159d949ea56c587f1991b
B 310bcc98288c52e1c4b65a1bbdd260cf4ae41baaaed5e50e2fe2da11787db71e
```

First-cycle full output hashes for SMALL, ODD_PADDED, MEDIUM, FULL, and REPLACEMENT:

```text
31bf1796ab22e2b0dfd823198f114b5ff5b8ed3ce45594773b1b62bb6ec6821b
26e82b101049b0e2c89ebd36c80ba86a73f4c7ba433d948fceeb8eece5222fcc
c296def287e74f5e45ffe601d29735e674715b381b14eaf42b780c365f7c6feb
df6651649f55dbf00756e93ce7084600ffbbc495a0ab275fc3060f89453c7625
d01ec1f1790837d750df32ff3647760479e70f84b1e5414b35d30827b15ae926
```

Target-region hashes:

```text
43e322e2d0276bc7b2d87a10372fb324ef327ab68e8b0d77882cf220157606a4
c90b1234b1cb4beaccabc69c87a36958ff701f6321f4d2b669a3180d4fa582fc
e45a492f90b0941183779567ff3913994f417540d04ad9ce7dc239857d57f0a3
df6651649f55dbf00756e93ce7084600ffbbc495a0ab275fc3060f89453c7625
9e439e6dac97ca9df46e349eb39d9cfb167357ac667ff746aabba4ccf6fa7f66
```

Outside-region hashes:

```text
c7aa17e41df18b4a9d118f53b78ba822b72baa12da6cd0b6ad17f95f143f0f56
297acc9ff0f2a65f91f9b979aa8602ac78f6315522dcb19b274a59827e9b1d28
197a7b8c5e061f85a4684265b5ee56b9da6b55e8f52e3ed0c7e3d9c12a64ca8d
e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
47512913efd9ef6416697b3943bca20e33c67f8b66ee516cf086ae1b8ab4f9cf
```

The FULL outside hash is the SHA-256 of empty content because the target is the entire frame.

## Real-Bitwig observation

Temporary observation-only code derived from the exact source head encoded the semantic bitmap immediately before composition and the output immediately after composition for its bounded correctness window. It retained only aggregate numbers/hashes and emitted no frame or screenshot.

Interactive run:

```text
correctnessSends=1920
completeCycles=3
positiveTargetChanges=107520309
semanticUpdateEvents=26
sourceTargetMismatches=0
outsideMismatches=0
oldRegionMismatches=0
noneMismatches=0
staleMismatches=0
invalidMismatches=0
malformedMismatches=0
semanticUpdateMismatches=0
validWriteRejections=0
invalidWriteAcceptances=0
dimensionErrors=0
aggregate-line SHA-256=7c1bba1e5d2631c274ce60c5992bc2ced22f9ea696e8a742afc4fd2c41125fac
```

Hands-off stable rerun:

```text
correctnessSends=1920
completeCycles=3
positiveTargetChanges=106921696
semanticUpdateEvents=1
all mismatch/rejection/dimension counts=0
aggregate-line SHA-256=63ef69e7f64f193ef6f4d37dd938b3a61bfabe0f3a285e013c417a6f914348b9
```

The maintainer then exercised the exact clean artifact and directly accepted all raster positions, orientation, channels, opacity, movement, replacement, absence/fallback intervals, malformed absence, restoration, and semantic-update-under-coverage rows.

## Commands and tools

Tools included the external Java harness, exact Java 21 classpath, `System.nanoTime`, SHA-256 hashing, temporary aggregate-only Bitwig observation using `IBitmap.encode`, narrowly filtered logs, and direct physical Push observation. No frame file or screenshot was retained.

## What this proves

- Target bytes match the declared source at all five valid geometries.
- Every pixel outside the current target remains the current semantic pixel.
- Old target regions, semantic-only states, malformed rejection, and a semantic update beneath prior coverage restore exactly.
- Source offsets, padded/odd stride, channel order, orientation, opacity, same-reference output, and non-raster fallback behave as specified.
- The current semantic model is the restoration authority.

## What this does not prove

- The lifecycle does not consume an external producer or implement freshness metadata.
- The retained hashes are deterministic proof identities, not proprietary frame dumps.
- The bounded runs are not endurance or cross-device tests.
