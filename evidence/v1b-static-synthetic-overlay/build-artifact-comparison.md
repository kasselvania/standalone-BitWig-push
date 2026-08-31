# V1B build and artifact comparison

## Date and machine state

- Evidence date: 2026-08-31 PDT.
- Machine state: accepted macOS 26.4.1 arm64 fixture; isolated clean base and feature worktrees.
- Central basis: `a13faef08ac8bb75a9e32f7ff7d4bc07fcd41c6e`, tree `c06009f822fee7bf36096739e7be6589f0b9ae34`.
- Source basis: `033ccef8c64f08e8d8d41fa90d48fa06b326a1a1`, tree `9aec7429ff093addee001a62a5a07309708fd592`.
- Source PR/head/tree: [kasselvania/DrivenByMoss#2](https://github.com/kasselvania/DrivenByMoss/pull/2), `a2e0341b7bccfa4e6b13614f4adffc2235f785f4`, tree `a81e5c4330b31f36845c25e98e322990d62f0c67`.

## Exact toolchain and command

```text
OpenJDK: 21.0.11 (Homebrew), arm64
javac:   21.0.11
Maven:   3.9.16
```

Both worktrees used exactly:

```text
env \
  JAVA_HOME=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home \
  PATH=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin \
  mvn clean install package -Dbitwig.extension.directory=target
```

Base build started `2026-08-31T21:15:20Z`, completed successfully in 9.820 seconds, and compiled 1,438 sources. The exact final source-head rebuild started `2026-08-31T21:41:13Z`, completed successfully in 10.447 seconds, and compiled 1,439 sources. Both ended with clean tracked source status.

Known warnings were identical in character: shaded `module-info.class`, overlapping `META-INF/MANIFEST.MF` with `jsr305`, and the existing second-pass attached-Bitwig-zip replacement warning. There were no compiler errors or test failures; upstream config has no test sources.

## Artifact result

| Artifact | Commit | Bytes | SHA-256 |
| --- | --- | ---: | --- |
| Accepted base | `033ccef8c64f08e8d8d41fa90d48fa06b326a1a1` | 14,363,745 | `ebe2233712b02b27f4d240195fad1b81c6ac02ea78e52310c256f3d1da47da6a` |
| Exact V1B head | `a2e0341b7bccfa4e6b13614f4adffc2235f785f4` | 14,365,128 | `117dbffd8ec8baa6c128893c6726b676ddacbc2b1ba645ef685f8bd6b90f75e6` |

Both manifests state Java 21, `Implementation-Title: DrivenByMoss`, and `Implementation-Version: 26.4.1`; embedded Maven coordinates remain `de.mossgrabers:DrivenByMoss:26.4.1`. Byte identity was not expected or claimed because the payload intentionally adds one class and modifies one class, and archive timestamps can vary.

## Extracted payload comparison

After extraction, the only payload differences were:

```text
Push2Display.class                                  changed
SyntheticOverlayPushFramePipeline.class             added
```

All unrelated extracted files/resources were byte-identical. The entry-name set differed only by the new synthetic class.

Critical class hashes:

| Class | Base SHA-256 | Head SHA-256 | Result |
| --- | --- | --- | --- |
| `PushUsbDisplay.class` | `288b576b3f2ed064f8d9a0c6f6d384fb3516a0858cc22e7879bee896df83dec3` | same | byte-identical |
| `PushFramePipeline.class` | `c037dba6ff4bb678bc3bf33168d10c427e71bb581370d8c096f6860110365491` | same | byte-identical |
| `PassThroughPushFramePipeline.class` | `2b8447ff08fba686f33dc5060fa8858a7fee0ba8753ebfcb54350b7db2f0763b` | same | byte-identical |
| `Push2Display.class` | `6c81f0e6dff08959eeeba7191552d94811c6bb86ab9e9e78479aa1cce47a3e7f` | `e9f5a0d04d3aa24ec012653f85e76ba55f55a259003c57b16820545b3c219982` | expected change |
| `SyntheticOverlayPushFramePipeline.class` | absent | `000e1d50a965bd26f1e1d1562ec57c9b95f876f590e365f38a567821f80b547d` | expected addition |

## Commands and tools

Tools included exact-environment `java -version`, `javac -version`, `mvn --version`, clean Maven builds, `shasum -a 256`, `stat`, `file`, `unzip`, `find`, sorted entry lists, `diff -qr`, `cmp`, manifest/pom extraction, and final Git status/diff checks.

## What this proves

- The accepted base and exact V1B head both build under the same required toolchain.
- The installed/tested V1B binary is cryptographically tied to the exact proposed head build.
- Executable payload change is bounded to the expected class modification/addition.
- `PushUsbDisplay` and both accepted V1A pipeline classes remain byte-identical.

## What this does not prove

- Artifact SHA differences do not imply unrelated payload differences, and no reproducible-archive claim is made.
- A clean build does not alone prove property delivery, pixels, timing, real hardware behavior, or rollback.
