# V1A build and artifact comparison

## Date and machine state

- Evidence date: 2026-08-31 PDT.
- Host: accepted macOS 26.4.1 (25E253), Darwin 25.4.0, arm64 fixture.
- Central basis: `a36779d4c04a11d6c6e9ce0d48c34ea3b813a0cc`, tree `bc4634da23f794f2afd39c63fab9eb5cf44524c1`.
- Source base: `fd03245ab38fa5149c45934051d937ee9fda6d08`, tree `edd2ad636b0aa1f39919f0ffd05c968015450075`.
- Source PR/head/tree: [kasselvania/DrivenByMoss#1](https://github.com/kasselvania/DrivenByMoss/pull/1), `6e1e4cbd2e725a7951e5b4dc1278fbb6e7b5d61c`, `9aec7429ff093addee001a62a5a07309708fd592`.
- Both build worktrees were clean at their exact committed source state; `target/` outputs are ignored and are not committed.

## Exact toolchain

```text
JAVA_HOME=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home
PATH=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin
java  /opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home/bin/java
javac /opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home/bin/javac
mvn   /opt/homebrew/bin/mvn

OpenJDK 21.0.11, Homebrew build 21.0.11
javac 21.0.11
Apache Maven 3.9.16
```

The host-default Java/Maven selection was not used.

## Exact build command and results

Both the accepted base and exact committed head used:

```text
env \
  JAVA_HOME=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home \
  PATH=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin \
  mvn clean install package -Dbitwig.extension.directory=target
```

| Build | UTC start/end | Exit | Maven result |
| --- | --- | ---: | --- |
| Accepted base `fd03245...` | 2026-08-31T20:13:39Z / 20:13:54Z | 0 | `BUILD SUCCESS` |
| Exact V1A head `6e1e4cbd...` | 2026-08-31T20:16:45Z / 20:17:07Z | 0 | `BUILD SUCCESS` |

An initial sandboxed base invocation reached successful compile/package but Maven `install` could not write `$HOME/.m2` (`Operation not permitted`). The exact same command was rerun with narrowly scoped host permission and passed. No source, POM, dependency, or toolchain workaround was applied.

Both successful logs contained the same known Maven Shade warnings: `module-info.class` strong encapsulation and an overlapping `META-INF/MANIFEST.MF` with `jsr305`. The second lifecycle pass also reported the existing attached-Bitwig-zip replacement warning. No compiler error, test failure, or new V1A warning occurred; the project has no configured test sources.

## Artifact identities

| Property | Accepted base build | Exact V1A head build |
| --- | --- | --- |
| Filename | `DrivenByMoss.bwextension` | `DrivenByMoss.bwextension` |
| Size | 14,362,467 bytes | 14,363,745 bytes |
| SHA-256 | `128cb56609d2e1dd929cf6c4688459de2fc96e23ef06cc23306ed33f6b56ebeb` | `94e69a2f2ce91ac6522ed6a0c1c52d7c216dea3a8c3d03f76c2221886bc62706` |
| File type | Java archive data (JAR) | Java archive data (JAR) |
| Entry count | 4,869 | 4,871 |

Both manifests are byte-identical and report:

```text
Manifest-Version: 1.0
Created-By: Maven JAR Plugin 3.5.0
Java-Version: 21
Build-Jdk-Spec: 21
Implementation-Title: DrivenByMoss
Implementation-Version: 26.4.1
```

The embedded `META-INF/maven/de.mossgrabers/DrivenByMoss/pom.properties` reports group `de.mossgrabers`, artifact `DrivenByMoss`, version `26.4.1`.

## Entry and extracted-payload comparison

Commands used `zipinfo -1 | sort`, `comm -3`, separate clean extraction directories, `diff -qr`, `shasum -a 256`, and `cmp -s`. Comparing extracted bytes avoids confusing ZIP entry ordering or timestamps with payload differences.

The head entry set adds exactly:

```text
de/mossgrabers/controller/ableton/push/controller/PassThroughPushFramePipeline.class
de/mossgrabers/controller/ableton/push/controller/PushFramePipeline.class
```

The complete extracted-payload delta is exactly:

```text
added    PassThroughPushFramePipeline.class
changed  Push2Display.class
added    PushFramePipeline.class
```

No other class, manifest, Maven metadata file, resource, native library, notice, or dependency payload differs.

`PushUsbDisplay.class` is byte-identical in both artifacts:

```text
base SHA-256  288b576b3f2ed064f8d9a0c6f6d384fb3516a0858cc22e7879bee896df83dec3
head SHA-256  288b576b3f2ed064f8d9a0c6f6d384fb3516a0858cc22e7879bee896df83dec3
```

For completeness, `Push2Display.class` changed from `0f8b3c795ca71b9d8d4a4eaa4854fd9b1e36518e1a44e15ab2a7a1fc68b391f5` to `6c81f0e6dff08959eeeba7191552d94811c6bb86ab9e9e78479aa1cce47a3e7f`.

The full archives are not byte-identical (`cmp` exit 1), as expected for a functional class-set change. No archive reproducibility claim is made.

## What this proves

- Both source states compile and package successfully under the same explicit toolchain.
- The exact fixture candidate is cryptographically tied to the committed source head.
- Executable payload changes are bounded to the three expected classes, while `PushUsbDisplay.class` and every unrelated payload remain byte-identical.

## What this does not prove

- Artifact comparison does not prove Bitwig loading or real Push behavior.
- It does not prove byte-for-byte reproducible builds across time or machines.
- It does not profile allocation, cadence, latency, or USB transfer behavior.
