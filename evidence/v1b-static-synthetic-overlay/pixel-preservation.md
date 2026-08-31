# V1B pixel-preservation proof

## Date and machine state

- Evidence date: 2026-08-31 PDT.
- Machine state: accepted macOS 26.4.1 arm64 fixture, Bitwig Studio 6.1, exact V1B behavior exercised with the real Push 3.
- Central basis: `a13faef08ac8bb75a9e32f7ff7d4bc07fcd41c6e`, tree `c06009f822fee7bf36096739e7be6589f0b9ae34`.
- Source basis: `033ccef8c64f08e8d8d41fa90d48fa06b326a1a1`, tree `9aec7429ff093addee001a62a5a07309708fd592`.
- Source PR/head/tree: [kasselvania/DrivenByMoss#2](https://github.com/kasselvania/DrivenByMoss/pull/2), `a2e0341b7bccfa4e6b13614f4adffc2235f785f4`, tree `a81e5c4330b31f36845c25e98e322990d62f0c67`.

## Comparison method

Bitwig's debug display window was not used as pixel authority because UI crop/scale could confound an exact comparison. Instead, a temporary observation-only build was derived from the exact committed source head. It called `IBitmap.encode` immediately before and immediately after the one synthetic `process` call, copied those two observation buffers only, and compared four bytes per pixel.

The observation patch was never committed. Final temporary source and diff hashes were:

```text
temporary Push2Display.java SHA-256: dba880ff829a45b4bdb49286d4b44054265d9ff36a2f6d6613d245af6de8032f
temporary git diff SHA-256:          678ee021c3b229f3d1e79a17a93b5bfa001bfa947ae3c6f6d2308747d11d579c
enabled metrics file SHA-256:        e994dab53dc825be70520a284ca98e24ec94b20b06af7ac7168d7a3695ad090b
```

No bitmap or raw frame was retained. Only dimensions, hashes, mismatch counts, and two target samples were kept. The temporary source was restored completely before the clean committed-head rebuild; its detached worktree returned to `git diff --exit-code` clean at the exact source head/tree.

## Exact result

Frame and mask:

```text
dimensions: 960x160
target: x=[856,952), y=[4,20)
target pixels: 1,536
outside pixels: 152,064
```

Comparison:

| Metric | Result |
| --- | --- |
| Target-region mismatches | 1,529 |
| Outside-region mismatches | **0** |
| Target before SHA-256 | `ce41051299b9e2712db0cac1cf30173a71388c25dbd9afb7b80bd7ff7bb4e6dd` |
| Target after SHA-256 | `d35362b4cca46271d2552990f20d0b052de18a97c05aaa3c54f085019328cdf0` |
| Outside before SHA-256 | `25f8b6772331fee3d8d0f12be696980a20094e680705791bf34bb0a3adcc5757` |
| Outside after SHA-256 | `25f8b6772331fee3d8d0f12be696980a20094e680705791bf34bb0a3adcc5757` |
| Outer sample at (856,4) | `dc00ffff` BGRA = pink |
| Inner sample at (860,8) | `ffffffff` BGRA = white |

Seven target pixels already equaled their final synthetic values, so 1,529 rather than all 1,536 target pixels changed. The different target hashes plus expected color samples prove the target result; the identical outside hashes and zero mismatch count prove observed outside preservation.

## Repeated-send and semantic-update result

With the property enabled, the maintainer directly confirmed:

- pink outer and white inner mark at the declared top-right bounds;
- no whole-frame clear and coherent semantic content outside the mark;
- correct Track/Mix, Device Parameters, and Session/Browser modes;
- normal track, device, and parameter updates;
- at least 30 seconds with no expansion, smear, duplication, or trail;
- property-off restart removed the mark and restored the full semantic display.

## Commands and tools

Tools included `apply_patch` for temporary observation source, Maven under the exact Java 21 environment, `IBitmap.encode`, Java `MessageDigest` SHA-256, bytewise pixel comparison, `shasum -a 256`, exact artifact installation checks, and direct maintainer observation. No screenshot, display crop, raw frame, or proprietary image was committed or retained.

## What this proves

- On the tested concrete Bitwig `BitmapImpl`, the second synchronous render preserved every observed byte outside the declared rectangle.
- The mark had correct geometry/colors and remained bounded across repeated sends and semantic updates.
- The callback did not clear, scale, smear, or replace the 960x160 semantic frame in this fixture.

## What this does not prove

- This is one accepted Bitwig/macOS/Push fixture, not a cross-version or cross-platform bitmap contract.
- The experiment does not provide damage restoration, arbitrary overlay content, alpha blending, external frames, or runtime removal.
- No Push 2 hardware was tested.
