# Crop, aspect, pixel, and protocol contract

## Date, machine state, and authority

- Date: 2026-09-02 PDT.
- Machine state: accepted display ID 5 at `3430x1447` ScreenCaptureKit points;
  output observed on the real Push 3 through the accepted V1D-2 derivative.
- Central basis/tree:
  `7c15abaf55c0080b2f80971e845b4ee6f1bfcc46` /
  `730726784b57016714c0a44c8f0f8caf1c5b0141`.
- Source PR/head/tree:
  [PR #43](https://github.com/kasselvania/standalone-BitWig-push/pull/43) /
  `03fb8c8824714e4bbefd7224848ca9cdad069088` /
  `f1f68bc6f0ba6527bb146a7ee93fd4333ffaf796`.
- Previously retained full-run source head/helper SHA-256:
  `c6c4e05c6c4bc1924b529a28990ea633515667cf` /
  `7dc775f8eaa6ef50d85c24394ca22e492ceba9cd07738b97a893f0a3604564cc`.

## Exact geometry

| Quantity | Value |
| --- | --- |
| Normalized configured crop | `x=0.14, y=0.68, width=0.45, height=0.305` |
| Requested floating source rect | `480.2, 983.96, 1543.5, 441.335` |
| Requested aspect | `3.497343287979` |
| Push destination | `x=400, y=0, width=560, height=160` |
| Destination aspect | `3.5` |
| Policy | centered cover |
| Effective maximal source rect | `x=480.2, y=984.1275, width=1543.5, height=441.0` points |
| Effective aspect | exactly `3.5` |
| Uniform scale | `560/1543.5 = 160/441 = 0.362811791383...` output pixels per source point |
| Cropped from requested bounds | left/right 0 points; top/bottom 0.1675 points |
| Padding | none |

The helper validates finite normalized values and closed bounds before display
or protocol access. `AspectMapping.centeredCover` derives the maximal centered
fractional rectangle inside the requested crop with exactly the destination
aspect. ScreenCaptureKit accepts fractional `CGRect` source geometry, so no
greatest-common-divisor or integer-multiple quantization is needed. It then
gives ScreenCaptureKit this bounded point-space `sourceRect` and exact
`560x160` output-pixel dimensions. X and Y are never scaled independently.

ScreenCaptureKit reported selected display content `3430x1447` and
`pointPixelScale=2`. `SCDisplay.width`/`height`,
`SCContentFilter.contentRect`, and `SCStreamConfiguration.sourceRect` are all in
ScreenCaptureKit screen points. `pointPixelScale` translates points to output
pixels; the helper does not multiply `sourceRect` by it. Queue depth was two,
cursor capture was off, pixel format was 32-bit BGRA, and only complete frame
statuses were eligible.

Runtime fixture revalidation is point-consistent: it compares the accepted
ScreenCaptureKit point facts with `CGDisplayBounds`, not with
`CGDisplayPixelsWide`/`CGDisplayPixelsHigh`. Exact display ID remains mandatory,
and there is no first-display fallback.

## Non-clean-GCD regression

The same requested crop mapped to destination `559x160` as:

```text
effective source rect = 480.992921875,983.96,1541.91415625,441.335 points
effective aspect      = 3.49375
uniform scale         = 0.362536395255305 output pixels per source point
ideal area retained   = 0.998972566407515 of the requested crop
```

The former GCD-multiple construction would have selected only `1118x320`.
Deterministic tests prove the replacement stays centered and in bounds, uses
one scale, handles source crops both wider and taller than the destination,
retains the maximal ideal rectangle rather than severely overcropping, and
still rejects invalid and nonfinite geometry.

## Historical temporary-distortion precision

The deleted temporary reconnaissance helper visibly distorted the visual under
a rough mapping. Its exact historical mechanism cannot be reconstructed from
retained source because that temporary source was intentionally removed. The
historical cause is therefore indeterminate; this evidence does not invent a
coordinate-space or independent-axis diagnosis.

Production V2 independently proves the repaired outcome through explicit
point-space geometry, one uniform centered-cover scale, equality of the
effective and destination aspects, deterministic geometry tests, and direct
physical confirmation. The focused amended-app smoke again showed useful,
undistorted proportions on the accepted Push fixture.

The maintainer's direct verdict was that proportions looked correct and no
visible stretch or distortion remained. Moving Bitwig in and out of the fixed
crop changed the content, but did not change its geometry; that is a known
fixture-localization limitation, not aspect distortion.

## Pixel contract

The captured CVPixelBuffer had:

```text
width=560
height=160
source bytesPerRow=2304
useful/output stride=2240
payload=358400 bytes
format=OPAQUE_BGRA8888
row order=top-to-bottom
byte order=B,G,R,A
alpha=0xFF for every output pixel
```

One reusable 358,400-byte output buffer copies only 2,240 useful bytes per row,
excluding 64 bytes of source padding. Alpha is forced opaque during the copy.
No full-display-sized helper payload is allocated or sent.

In the previously retained full 30-fps run:

- first useful-source and first published-output SHA-256 were both
  `dffe7180e0139331dce5203db7cf3720f653119802b2b7bf208d600772cf8dea`;
- alpha mismatches: zero;
- pixel-format mismatches: zero;
- dimension/stride failures: zero;
- incomplete/invalid samples published: zero;
- full-display payloads: zero;
- wrong-destination publications: zero.

No proprietary pixel data or frame was retained.

The exact amended-head focused run again recorded matching first useful-source
and first published-output SHA-256 values,
`8d8a54c86ee9b3edb037939464398cff72af2ae122238884ff08d33ac7f877a5`,
over 1,003 post-warmup publications, with zero alpha, pixel-format,
dimension, stride, full-display, or wrong-destination failures.

## Accepted protocol-v1 publication

The helper uses magic `0x50575852`, version 1, an 80-byte network-order header,
HELLO/FRAME/CLEAR message values 1/2/3, NONE/OPAQUE_BGRA8888 format values 0/1,
and the existing 614,400-byte maximum. It connects only to configured IPv4
loopback, parses a bounded private capability file without logging it, creates
one nonzero 128-bit session per connection, sends HELLO once, and advances a
positive nonwrapping sequence.

The previously retained 30-fps run sent 2,179 FRAME messages, one CLEAR, and
sequences 1 through 2,180. The focused amended normal-quit run sent 135 FRAME
messages and two CLEARs through sequence 137 with zero protocol failures. The
one serialized output queue and reusable header/output storage do not replay or
backlog old frames. DrivenByMoss remained the sole Push USB writer.

## Exact result

All deterministic geometry/pixel/protocol assertions passed. The real Push
showed the crop with correct proportions, orientation, channels, opacity, and
bounds. Runtime mismatch, incomplete-publication, full-display-payload, and
wrong-destination counts were all zero.

## Commands and tools

Evidence came from exact configuration readback, deterministic Swift geometry,
pixel-normalization, header, sequence, and CLEAR tests; aggregate runtime
metrics; generated pixels; SHA-256 comparison; and direct physical orientation,
channel, alpha, bounds, and aspect observation.

## What this proves

- The configured crop is bounded, maximal, and uniformly mapped to the exact
  Push destination without padding or independent-axis distortion.
- The published payload is complete opaque top-to-bottom BGRA, excludes source
  row padding, stays below the protocol cap, and never becomes a full-display
  transmission.
- The accepted receiver and one-writer ownership were reused unchanged.

## What this does not prove

- Equal first-frame source/output hashes cover the useful post-ScreenCaptureKit
  output bytes, not proprietary desktop pixels before Apple's crop/scale.
- The precise cause of the deleted temporary helper's distortion is not proven
  and cannot be reconstructed from retained material; that historical gap is
  separate from the exact production-geometry result.
- The result does not establish a general fit-policy API, arbitrary display
  scaling behavior, transparency, remote transport, or automatic crop
  localization.
