# Build and artifact comparison

## Date, machine state, and authority

- Evidence date: 2026-09-01 PDT.
- Machine state: isolated clean base/head worktrees on the accepted macOS arm64 fixture.
- Actual central basis/tree: `4265dc7b6f1cabf2dcbad1b827d002bd9062cf4f` / `2af6b4757e5906ce74a3b52c5ee82323f5e32406`.
- DrivenByMoss basis/tree: `1ae0b74f383314d170a5960ca763bdf9c319e787` / `a81e5c4330b31f36845c25e98e322990d62f0c67`.
- Source PR/head/tree: [kasselvania/DrivenByMoss#3](https://github.com/kasselvania/DrivenByMoss/pull/3), `4b3326eddcf2d890de3baa10b93f6e80842d41e1`, tree `d03a372e2efcf41b22cef46501e08efbfb0c0036`.

## Exact build command

Both accepted base and proposed head used:

```text
env \
  JAVA_HOME=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home \
  PATH=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin \
  mvn clean install package -Dbitwig.extension.directory=target
```

Toolchain:

```text
OpenJDK 21.0.11 Homebrew, arm64
javac 21.0.11
Apache Maven 3.9.16
```

Both builds succeeded. The base compiled 1,439 source files and the head compiled 1,440. Known warnings were limited to module-info shading, overlapping `META-INF/MANIFEST.MF`, and replacement of the already attached Bitwig ZIP on the package repetition.

## Artifact identities

| Artifact | Commit | Bytes | SHA-256 | ZIP entries | Extracted files |
| --- | --- | ---: | --- | ---: | ---: |
| Accepted base | `1ae0b74f383314d170a5960ca763bdf9c319e787` | 14,365,128 | `3f6a6f7bc574cec0163fd4ef594c3fdfcfa5c9817f301502be960e0b95bda4a8` | 4,872 | 4,441 |
| Proposed head | `4b3326eddcf2d890de3baa10b93f6e80842d41e1` | 14,367,247 | `f9671047e342ed3d2503fae3423ea27725830e359e75b51e29fc88ac316be4b3` | 4,873 | 4,442 |

Both manifests identify DrivenByMoss 26.4.1 and Java 21. Byte identity of the enclosing archive was not expected or claimed.

## Extracted payload delta

After extraction and metadata-insensitive payload comparison, executable differences were exactly:

```text
de/mossgrabers/framework/controller/display/AbstractGraphicDisplay.class
de/mossgrabers/controller/ableton/push/controller/Push2Display.class
de/mossgrabers/controller/ableton/push/controller/DynamicLocalPushFramePipeline.class
```

No unrelated class or resource differed.

Critical class SHA-256 readback:

```text
PushUsbDisplay.class (base and head):
288b576b3f2ed064f8d9a0c6f6d384fb3516a0858cc22e7879bee896df83dec3

PushFramePipeline.class (base and head):
c037dba6ff4bb678bc3bf33168d10c427e71bb581370d8c096f6860110365491

PassThroughPushFramePipeline.class (base and head):
2b8447ff08fba686f33dc5060fa8858a7fee0ba8753ebfcb54350b7db2f0763b

SyntheticOverlayPushFramePipeline.class (base and head):
000e1d50a965bd26f1e1d1562ec57c9b95f876f590e365f38a567821f80b547d
```

Changed/new head-class hashes:

```text
AbstractGraphicDisplay.class:          30570d697786bda562aafa145f4d8e261a347d0749bea58ec90d7b9d42752343
Push2Display.class:                    d30ae2f755b0b32dc9cf0f707cfa55f18ec3f48a685df1381eb28cc6c36175d7
DynamicLocalPushFramePipeline.class:   8db7fc9e80ca659fc934b7f653e7b17305fe5d74bdf4b44c9d9269fcfb9330e4
```

## Bytecode proof

`javap -c -p` against the exact proposed-head artifact proved:

1. `AbstractGraphicDisplay.send` creates one new `ModelInfo`, compares it, stores it before the redraw hook, and preserves transient-list cleanup.
2. The framework hook defaults to false.
3. `Push2Display` reads the two properties only during construction.
4. Dynamic true selects the dynamic instance before the static branch.
5. The send guard still checks shutdown and non-null USB display.
6. Send invokes one frame-pipeline process and one `PushUsbDisplay.send`.
7. Dynamic process invokes one renderer only for A/B/C/D and none for NONE/STALE/INVALID.
8. Dynamic process returns its input argument and contains no `new`.
9. The four renderer objects are created once in the class initializer.
10. No asynchronous composition handoff was added.

## Commands and tools

Tools included isolated Git worktrees, exact-path Java/Maven, `shasum -a 256`, `stat`, `file`, `unzip -l`, extracted-tree `diff`/`cmp`, per-class hashing, `javap -c -p`, and final Git status/diff checks.

## What this proves

- Base and head both build under the same accepted toolchain.
- The proposed binary delta is exactly bounded to the authorized source envelope.
- `PushUsbDisplay` and accepted V1A/V1B pipeline classes remain byte-identical.
- The installed clean fixture artifact is cryptographically tied to the exact source PR head.

## What this does not prove

- Archive hashes are not claimed reproducible across arbitrary machines or times.
- Build comparison alone does not prove pixels, performance, physical behavior, or rollback.
