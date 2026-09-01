# Raster correctness and restoration

## Evidence identity

- Date: 2026-09-01 PDT.
- Machine state: accepted arm64 macOS + Bitwig Studio 6.1 + DrivenByMoss 26.4.1 + Push 3 fixture.
- Central basis: `a66e1e45ebb2cb72f8ea1cb12e96d1bc46d7c343`, tree `b83e9e9507dc2e26d551abed1f03c30a6b76a551`.
- DrivenByMoss basis: `852b520933eed87fbe496a04b5c18819a10b3564`, tree `d03a372e2efcf41b22cef46501e08efbfb0c0036`.
- Candidate A: local commit `61c659e19faad3944f610022fca5d57f09e7b442`, tree `6d06def69677918e871bb5a0c978be83aab29cb8`.
- Main harness source SHA-256: `7be829d7e302b00226f6fabf005e2a423b91132d6eebdae980acbc57657b6ee7`.
- Supplemental hash-only harness source SHA-256: `fe3db8e287dcc52706917ccec11b1a80f243b1677f8b365fb93ccf36cc24735d`.
- Final observation patch/artifact SHA-256: `2cba0fbffabeb6e7609f6c5ffbdb433e1e9bfa90d9f1e5414f84843a8c4b7e96` / `f7903aabd3266b9c26db34d68279632cffac6281cf453705d7763a0f0617076a`.

## Canonical format and generated corpus

All tests used an exact 960x160 four-byte frame and project-generated opaque BGRA8888 bytes. Rows run top-to-bottom and columns left-to-right. The source is already cropped/scaled. No scaling, interpolation, color conversion, blending, or per-pixel draw operation occurs.

| State | Destination | Source dimensions | Source stride | Offset | Useful bytes |
|---|---|---:|---:|---:|---:|
| SMALL | x=16, y=8 | 64x16 | 256 | 16 | 4,096 |
| ODD/PADDED | x=48, y=12 | 117x37 | 481 | 19 | 17,316 |
| MEDIUM | x=240, y=40 | 480x80 | 1,920 | 8 | 153,600 |
| FULL | x=0, y=0 | 960x160 | 3,840 | 0 | 614,400 |
| REPLACEMENT | x=872, y=136 | 64x16 | 256 | 4 | 4,096 |

Patterns contained distinct corner colors, red/green/blue/white/black bars, asymmetric gradients/markers, opaque alpha, and `0x5A` padding sentinels. The odd source stride is 13 bytes larger than packed width; no sentinel entered output.

## External lifecycle result

The Java 21 external harness ran:

```text
complete cycles: 1,000
state transitions: 9,000
positive target pixel changes: 592,824,431
source-versus-target mismatches: 0
outside-current-region mismatches: 0
old-region restoration mismatches: 0
post-NONE full-frame mismatches: 0
STALE full-frame mismatches: 0
INVALID full-frame mismatches: 0
semantic-update-under-coverage mismatches: 0
partial writes after rejected metadata: 0
```

The lifecycle included movement, overlap, enlargement, reduction, full-frame replacement, NONE, STALE, INVALID, and a semantic-generation change while raster coverage was active. Before every state the harness installed the newest semantic reference, matching the accepted V1C redraw rule.

## Representative deterministic hashes

The supplemental hash-only harness ran against the frozen candidate `BitmapImpl.class`; it regenerated the candidate patterns byte-for-byte and retained only aggregate hashes. Its source was deleted after hashing/running.

```text
semantic reference:
c8540d7f4cb1ff4fbafa9f1ab3e4f46c17a1761f0968959a77748efc5c4337ac

SMALL
  source:  48fe1ec55557ab499bcaf97f225d1bf4e5529856770319815c8d3acfcb866075
  output:  0e641e352aa0cb1ab1cad3a823776c2aa8ac9b2f83b7a53f9411dfa5c0534c2c
  target:  c2259df43e225771c9a601340c4dfa3e12b8cb0bece6a09e9c9de46be1803919
  outside: 04b8b53971492db0a6423542c6428e81cda2b1f7bd568f5d47a3f6dec616b89e

ODD/PADDED
  source:  544d651130dfaec7b12b8e896f91d4a96c26b92fcf238aac826d207fab89bde0
  output:  0f2f48496d5c2ddf64aff0eb3fc8b53db88e50cecef753e91d191d32c80324c8
  target:  9d7d38ded9c241a34fa950d35989708f01fb7a5399c1b7444af3adfdf05fe716
  outside: 2aea4352a147370e578102b27c81958cf311557a20e4140b2ccffb9d65caa4fd

MEDIUM
  source:  5e8995376dcdde7e9e453691c5977e76a6918fb832b36004bfa27bd48cde3a1c
  output:  95acee03177841d817357264d8fe479169312aad5aeeec24079c0a57969514f1
  target:  44dc9dac459aa262b46e6e2c4745d24e60c674f1b222ce482f2c7a2ad42a8f70
  outside: 44f892c6f76f438ea525be977dfafa3bdf56b1b0d6c127e8b200d0f0a48f36bf

FULL
  source/output/target:
  3167e0253fe77aaba4c0c51eee2c7af5147ba2981c6023bcf01dfd0cfac52a77
  outside (empty byte sequence):
  e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855

REPLACEMENT
  source:  af0c4c6631e9391ced0708b566c603ad931b6858b37bb9dee29fff753ae33fd7
  output:  619fbc1951ee56ed7f53711a57e91466e8f3c6a23740fcc05f9750ea0631fa91
  target:  0ba02cd203deb27e4f9b355d406e6f6e7ca605e73807ba970122c60a379d71ce
  outside: 7b9e9576500573c0af82b8b06a2a4ed35ff7c7bcdb8cc2e806c47f7dfe6d97c5

NONE/INVALID semantic-only output:
c8540d7f4cb1ff4fbafa9f1ab3e4f46c17a1761f0968959a77748efc5c4337ac
```

Old-region restoration outside overlap was `true` after ODD/PADDED, MEDIUM, and REPLACEMENT. FULL intentionally covers every prior region. NONE and a rejected invalid write both matched the complete semantic reference.

## Real Bitwig aggregate result

The final observation artifact reported:

```text
sends=1920
complete generated cycles=3
dimensionsValid=true
positiveTargetChanges=102872360
sourceTargetMismatches=0
outsideMismatches=0
oldRegionRestorationMismatches=0
noneMismatches=0
staleMismatches=0
invalidMismatches=0
malformedMismatches=0
semanticUpdateEvents=1
semanticUpdateRestorationMismatches=0
validWriteRejections=0
invalidWriteAcceptances=0
semanticSha256=be0488d4910eb3695fe7f860e64d05fccdd83f9620887f330187b26e872d6fe0
outputSha256=be0488d4910eb3695fe7f860e64d05fccdd83f9620887f330187b26e872d6fe0
```

The final equal semantic/output hashes were recorded in a semantic-only state. UI-controlled track changes forced a semantic update while raster coverage was active; its later restoration mismatch count remained `0`.

## Coherence and physical observation

- A write through the cached destination view was immediately visible through a second aliased view.
- `IBitmap.encode` observed exact accepted bytes before the unchanged transport conversion.
- The physical Push showed the generated patterns at the declared locations, with correct corners, row/column orientation, RGB/white/black bars, and opaque output.
- A new semantic redraw removed prior bytes before movement, replacement, NONE, STALE, INVALID, or malformed intervals; no previous composed output acted as restoration authority.
- The cached destination view remained valid throughout 1,920 sends.
- The maintainer confirmed all physical correctness rows, including no skew, padding sentinel, trail, stale block, scale/coordinate error, filtering surprise, or whole-frame clear.

## Commands and tools

Used Java 21 external harnesses, direct candidate classpath, SHA-256 aggregate reporting, temporary fixed-size in-process arrays/counters, `IBitmap.encode` before/after comparisons, deterministic UI track changes, narrow current-run logs, and direct physical Push observation. No frame or screenshot was written or retained.

## What this proves

The exact selected primitive preserves source pixels in bounds, semantics everywhere else, and the complete V1C restoration lifecycle across valid, absent, stale, invalid, malformed, and semantic-update states.

## What this does not prove

It does not validate captured third-party pixels, scaling, alpha blending, color management, external concurrency, or every possible DrivenByMoss screen. The debug display window was not a separate authority.
