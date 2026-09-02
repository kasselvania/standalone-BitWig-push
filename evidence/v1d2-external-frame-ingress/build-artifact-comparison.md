# Build and artifact comparison

## Date, state, and authority

- Date: 2026-09-01 PDT.
- Machine state: macOS 26.4.1 build 25E253, Darwin 25.4.0, arm64.
- Central basis/tree:
  `fe8216fcadc9879bafa96acbb0f064f1d6625f4b` /
  `580786862a6f034aa111b60c4d434e64c44c7211`.
- DrivenByMoss basis/tree:
  `663d719207ef58ec84b4d235c43211ec5da43605` /
  `c4e42825d069421a44b3241349de9a7c6453a3ad`.
- Source PR/head/tree:
  <https://github.com/kasselvania/DrivenByMoss/pull/5> /
  `830b778b720a06f56de08861d27052228c82c63b` /
  `c8bc3f9e052e8f0b7b5dd256657697349d303740`.
- Harness/producer/observer SHA-256:
  `007822786260f89a9c3d005b669162389843a4dad2fb3293c6c131762c32bd18` /
  `993cb0f4d14c0a909a629ac4063e6e1937cb50ca42075e9fbbd3f099253bacbb` /
  `2e6ff0f6e2236e0b6ad85a831ba3f8c18f3362263eeaba425749fb4cbf929eb4`.

## Exact toolchain

The explicit environment, not host-default Java selection, reported:

- OpenJDK 21.0.11, Homebrew arm64;
- `javac 21.0.11`;
- Apache Maven 3.9.16;
- Java/Javac path:
  `/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home/bin`;
- Maven path: `/opt/homebrew/bin/mvn`;
- `JAVA_HOME`:
  `/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home`.

Both isolated clean worktrees ran:

```text
env \
  JAVA_HOME=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home \
  PATH=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin \
  mvn clean install package -Dbitwig.extension.directory=target
```

Both builds exited successfully. Generated extension binaries are not
committed.

## Artifact identities

| Source | Size | SHA-256 |
| --- | ---: | --- |
| accepted base `663d719...` | 14,373,269 bytes | `dc686d35240790bfd979bc10cff550de9481d8d568a3d85de82a8532ffbdf293` |
| exact V1D-2 head `830b778...` | 14,388,379 bytes | `026f88905cbd27890fca333cdcb5820c4fedaa3273359bb75b7e6106fd59278e` |

Both manifests are byte-identical at SHA-256
`8a588c0c8ea068220cd13a415daf68e71cbbdb9e0a3fb244957535ce60808c4b`.
They retain Java 21, title `DrivenByMoss`, and version 26.4.1. No extension,
controller, MIDI discovery, VID/PID, USB interface/endpoint, or project version
metadata changed.

Base contained 4,876 archive entries and head 4,880. Archive metadata was not
used as payload equality; both archives were extracted and compared by path and
content.

## Exact extracted payload delta

Only these executable payload changes exist:

- modified `Push2Display.class`;
- new `ExternalRasterPushFramePipeline.class`;
- new `ExternalRasterReceiver.class`;
- new `LatestExternalRasterFrameStore.class`;
- new compiler-generated
  `LatestExternalRasterFrameStore$DisplayFrame.class`.

The nested class comes directly from one source-level construction-time
metadata holder and is not allocated per frame. All unrelated classes and
resources are byte-identical.

## Protected class comparison

Each base/head pair is byte-identical at the listed SHA-256:

| Class | SHA-256 |
| --- | --- |
| `PushUsbDisplay.class` | `288b576b3f2ed064f8d9a0c6f6d384fb3516a0858cc22e7879bee896df83dec3` |
| `BitmapImpl.class` | `e65e21f2c250a2b24a76b23710c85d216cb3ab18bd50aa226085e05d857cd23a` |
| `IRasterWritableBitmap.class` | `6f30b33a1c08c02126065fa3d0264f0e7fa66ce29fdaa1d2e663098dd34e4626` |
| `RasterPixelFormat.class` | `8d2c16d68aac73b4ff793ec24604cc1a5b2145150aaf8c982bd17f96a046d735` |
| `AbstractGraphicDisplay.class` | `30570d697786bda562aafa145f4d8e261a347d0749bea58ec90d7b9d42752343` |
| `DynamicLocalRasterPushFramePipeline.class` | `93eb4350b44ced7d33b952ab41f31e4b4c38506448fef5b38d0625c1263a0631` |
| `DynamicLocalPushFramePipeline.class` | `8db7fc9e80ca659fc934b7f653e7b17305fe5d74bdf4b44c9d9269fcfb9330e4` |
| `SyntheticOverlayPushFramePipeline.class` | `000e1d50a965bd26f1e1d1562ec57c9b95f876f590e365f38a567821f80b547d` |
| `PassThroughPushFramePipeline.class` | `2b8447ff08fba686f33dc5060fa8858a7fee0ba8753ebfcb54350b7db2f0763b` |
| `PushFramePipeline.class` | `c037dba6ff4bb678bc3bf33168d10c427e71bb581370d8c096f6860110365491` |

This proves that pixel conversion, RGB565 encoding, scan-line padding, XOR
shaping, transfer scheduling, the accepted V1D-1 bulk writer, retained semantic
redraw contract, and the existing USB owner did not change.

## Bytecode and temporary proof artifacts

`javap -c -p` output SHA-256 values:

- external pipeline:
  `75acc6f4e34726d6063cfbadc3b6fbfeeec98e3ace70c1746981611302b7d123`;
- `Push2Display`:
  `8f981ceb6a9e48b71492d0e40526c1042b4d77f4f5538fec36b55ee8580248ff`;
- receiver:
  `9c12e0bc83100900852e8a070c54a933addca59a7bc2c245c77a120f97a842cb`;
- store:
  `c497f16f7906a0f13b0faf43e5a1297031f9bf59468be98faac60f373513c284`.

The temporary Java harness and Python producer identities are above. The final
observer patch SHA-256 is
`75ef6dd932d04b89096c94c3ba86978e704b012b5ff58483dd0b1d004912c81b`
and observer artifact SHA-256 is
`31af0afc675371af301f4a6b94f6e7e54866e53ef6078568f2c0ea01382d28a3`.
No temporary proof source/binary or extension artifact is committed.

## Commands and tools

Evidence used the exact environment commands above, `git status`, `shasum -a
256`, `unzip` extraction, sorted entry-name comparison, `diff -qr`, `cmp`,
manifest inspection, protected-class hashing, `javap -c -p`, and clean-source
readback after each build.

## Exact result

Base and head builds passed under one toolchain. The artifact and manifest are
cryptographically identified, the extracted delta is precisely bounded, and
every protected class is byte-identical.

## What this proves

- The installed derivative used in final acceptance is the exact clean PR-head
  build.
- Transport/bitmap/raster-sink/earlier-pipeline payloads were not modified.
- The sole extra nested class is construction-time metadata rather than a
  hidden per-frame allocation.

## What this does not prove

- Base and head are not expected to be byte-identical because production source
  changed; this is not a reproducible-build claim against the official binary.
- Build/extraction evidence alone does not prove runtime behavior; deterministic
  and physical evidence is retained separately.
