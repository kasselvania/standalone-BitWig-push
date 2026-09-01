# V1D-1 build and artifact comparison

## Date, machine state, and authority

- Evidence date: 2026-09-01 PDT.
- Machine state: accepted macOS 26.4.1 arm64 Mac; isolated clean base/head worktrees; Bitwig not required for builds.
- Central basis/tree: `c94d1b74d702e696d6cc4cc89625f1a2f7a95530` / `8539026fc9476bbf2df34b310190a57906113b90`.
- DrivenByMoss basis/tree: `852b520933eed87fbe496a04b5c18819a10b3564` / `d03a372e2efcf41b22cef46501e08efbfb0c0036`.
- Source PR/head/tree: [kasselvania/DrivenByMoss#4](https://github.com/kasselvania/DrivenByMoss/pull/4), `3c3ca02ff81ab5ce110ae3d714e20b5fca05a03f`, tree `c4e42825d069421a44b3241349de9a7c6453a3ad`.

## Exact environment and command

```text
JAVA_HOME=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home
PATH=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin
OpenJDK 21.0.11 Homebrew, arm64
javac 21.0.11
Apache Maven 3.9.16
```

Both isolated clean worktrees ran:

```sh
env \
  JAVA_HOME=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home \
  PATH=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin \
  mvn clean install package -Dbitwig.extension.directory=target
```

Base finished at 2026-09-01 13:13:27 PDT in 11.345 seconds; head finished at 13:13:44 PDT in 9.908 seconds. Both exited 0 with `BUILD SUCCESS`. Retained Maven warnings were the existing shade warning for `module-info.class`, overlapping `META-INF/MANIFEST.MF`, and replacement of an already attached assembly artifact; no warning changed the five-class comparison or exit result.

## Artifact identities

| Build | Commit/tree | Bytes | SHA-256 | Entries |
| --- | --- | ---: | --- | ---: |
| Accepted base | `852b520933eed87fbe496a04b5c18819a10b3564` / `d03a372e2efcf41b22cef46501e08efbfb0c0036` | 14,367,247 | `502a1858a53f558d8e47aa92330f7ed44096e95ad629a81f06787119c2ae1ae3` | 4,873 |
| Exact V1D-1 head | `3c3ca02ff81ab5ce110ae3d714e20b5fca05a03f` / `c4e42825d069421a44b3241349de9a7c6453a3ad` | 14,373,269 | `476a57a3733cd350bd068de44a5a1019df5e198c49572d1f633e43e006ae2877` | 4,876 |

Both manifests are identical:

```text
Manifest-Version: 1.0
Created-By: Maven JAR Plugin 3.5.0
Java-Version: 21
Build-Jdk-Spec: 21
Implementation-Title: DrivenByMoss
Implementation-Version: 26.4.1
```

## Extracted payload delta

Bytewise recursive comparison of extracted archives found exactly:

```text
changed: de/mossgrabers/bitwig/framework/graphics/BitmapImpl.class
changed: de/mossgrabers/controller/ableton/push/controller/Push2Display.class
new:     de/mossgrabers/controller/ableton/push/controller/DynamicLocalRasterPushFramePipeline.class
new:     de/mossgrabers/framework/graphics/IRasterWritableBitmap.class
new:     de/mossgrabers/framework/graphics/RasterPixelFormat.class
```

No enum-switch helper or other generated class appeared. All unrelated classes/resources were byte-identical after extraction.

Required protected classes were byte-identical base/head:

```text
PushUsbDisplay.class                     288b576b3f2ed064f8d9a0c6f6d384fb3516a0858cc22e7879bee896df83dec3
PushFramePipeline.class                  c037dba6ff4bb678bc3bf33168d10c427e71bb581370d8c096f6860110365491
PassThroughPushFramePipeline.class       2b8447ff08fba686f33dc5060fa8858a7fee0ba8753ebfcb54350b7db2f0763b
SyntheticOverlayPushFramePipeline.class  000e1d50a965bd26f1e1d1562ec57c9b95f876f590e365f38a567821f80b547d
DynamicLocalPushFramePipeline.class      8db7fc9e80ca659fc934b7f653e7b17305fe5d74bdf4b44c9d9269fcfb9330e4
AbstractGraphicDisplay.class             30570d697786bda562aafa145f4d8e261a347d0749bea58ec90d7b9d42752343
```

## Bytecode proof

Full `javap -c -p` output hashes:

```text
BitmapImpl                              4fe3ac19d06d26d831026a3a2d344bf3a410acd47ea84c966d2cbda4510db7e8
DynamicLocalRasterPushFramePipeline     14937b21fd9002971936411e22a46aba4d7c164e0c0d79b57d817f8942d3c2ff
Push2Display                            10a815481cf9b57a139d55d3fedfc92236d8ebd7ecd316ac986ac296f5b62d95
IRasterWritableBitmap                   70bd07f3b699f50a4b4314953d0c41f10a2ad2856bfb5f6943ba3cbd35f9c8ce
RasterPixelFormat                       cf48152a5f87ba9a3ad809bb82d04ca732247c7fca5f9f7a87730ada0bc79f18
```

Disassembly plus harness execution proved:

1. the raster property is read only during `Push2Display` construction;
2. raster precedes vector and static selection;
3. raster/vector enable redraw and static/default do not;
4. `Push2Display.send` preserves its shutdown/null guard and one pipeline/one USB send;
5. the raster pipeline returns its input reference;
6. valid states call one writer, semantic-only states call none, and MALFORMED calls once;
7. source arrays are allocated only during class initialization;
8. `BitmapImpl` obtains/caches one destination view during construction;
9. validation and complete alpha scan precede row writes;
10. the row loop uses absolute `ByteBuffer.put(int, byte[], int, int)`;
11. destination cursor state is not mutated;
12. invalid calls do not bind and owner binding precedes the first write;
13. `writeRasterRegion` has no per-call object allocation;
14. existing `render` and `encode` methods remain delegated;
15. no asynchronous handoff or USB dependency was added.

The only exceptional allocation in the raster pipeline is `IllegalStateException` if the MALFORMED probe is incorrectly accepted; this is fail-closed contract violation handling, not a valid-frame allocation.

## Harness compile/run

Final harness source SHA-256: `724095ad2ee2c0273164dada172dabfb63161230df0826269f09aaa5d2305038`.

It compiled with Java 21 against the exact head artifact plus `$HOME/.m2/repository/com/bitwig/extension-api/21/extension-api-21.jar`, then ran with the same classpath. The rerun exited 0 after 592,712 assertions. No harness source/class entered either repository.

## Commands and tools

Commands included the exact Maven invocation, Java/Javac/Maven version readback, `stat`, `shasum -a 256`, `unzip -Z1`, archive extraction, `diff -rq`, per-class SHA-256, `javap -c -p`, `rg`, external `javac`/`java`, and final Git status/diff checks.

## What this proves

- Both accepted base and exact V1D-1 head build successfully under the same explicit toolchain.
- Executable payload change is exactly the authorized five-class envelope.
- Transport and accepted V1A/V1B/V1C/framework classes are byte-identical.
- The exact artifact installed on the real fixture corresponds to the source PR head.

## What this does not prove

- It does not claim byte-for-byte reproducibility against the official binary.
- The official and derivative artifacts intentionally have different hashes.
- Build success alone does not prove Bitwig loading or hardware behavior; those are retained separately.
