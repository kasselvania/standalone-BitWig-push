# Unmodified DrivenByMoss 26.4.1 build result

## Date and machine state

- Build date: 2026-08-31 PDT.
- Build start: 12:15:38 PDT.
- Maven finish: 12:16:48 PDT.
- Host: accepted arm64 macOS fixture.
- Source checkout: `$HOME/Documents/ChatGPT/BitWig Standalone Push/DrivenByMoss-v1a0-build`.
- Source state: clean detached worktree.
- Java: Homebrew OpenJDK 21.0.11.
- Maven: 3.9.16.

## Exact source

```text
commit fd03245ab38fa5149c45934051d937ee9fda6d08
tree   edd2ad636b0aa1f39919f0ffd05c968015450075
tag    26.4.1
```

Before the build, both Git diffs exited 0 and `git status --short` was empty.

## Exact command

```text
env \
  JAVA_HOME=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home \
  PATH=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin \
  mvn clean install package -Dbitwig.extension.directory=target
```

This is the upstream macOS build shape with Java 21 made explicit.

## Maven result

Curated relevant output and result:

```text
Java source files compiled: 1,436
Compiler target: Java 21
Tests: No tests to run.
Maven result: BUILD SUCCESS
Total time: 59.804 s
Finished at: 2026-08-31T12:16:48-07:00
```

- Process exit code: 0.
- The intended `.bwextension` existed at `target/DrivenByMoss.bwextension` at 12:16:41 PDT.
- `unzip -t target/DrivenByMoss.bwextension` ended with `No errors detected in compressed data`.
- Post-build `git diff --exit-code`, `git diff --cached --exit-code`, and `git status --short` again proved the source tree remained unmodified.

## Relevant non-fatal warnings

- Maven reported a checksum-validation warning for the repository-supplied `nativefilechooser-1.3.3.pom`; the build continued.
- The shade step warned about `module-info.class` and an overlapping manifest.
- The assembly step reported an already-attached artifact because the requested lifecycle contains `package` after `install`, causing the package phase to be traversed again.

None of these warnings changed the exit code or source tree. They are retained so a later build does not mistake known baseline output for a V1A regression.

## Produced artifacts

Paths are relative to the detached build worktree.

| Artifact | Bytes | SHA-256 |
| --- | ---: | --- |
| `target/DrivenByMoss.bwextension` | 14,362,467 | `61ff21e5f21d96ee64bfe1b09c5971116f1f5075d5805bc015f0a168fe00b8f9` |
| `target/DrivenByMoss-26.4.1.jar` | 14,362,280 | `abfd1999dabe8e738408630296a353187715b787ca1c6d221df6817a83882201` |
| `target/original-DrivenByMoss-26.4.1.jar` | 5,183,765 | `75cc21ea8c0c8526145e7f3dbb4da64b25dad4950f6dd194da859832bc4b02b5` |
| `target/DrivenByMoss-26.4.1-Bitwig.zip` | 15,326,312 | `ec3dd9b3c4617067e59d34a74fff62ea3280c9cc15198b32b9cdbf89d162511b` |

No produced binary is committed to the central repository.

## Intended extension metadata

`file` identifies the extension as Java archive data. Its manifest contains:

```text
Manifest-Version: 1.0
Created-By: Maven JAR Plugin 3.5.0
Java-Version: 21
Build-Jdk-Spec: 21
Implementation-Title: DrivenByMoss
Implementation-Version: 26.4.1
```

Embedded `META-INF/maven/de.mossgrabers/DrivenByMoss/pom.properties` contains:

```text
artifactId=DrivenByMoss
groupId=de.mossgrabers
version=26.4.1
```

Archive summary:

- 4,869 entries.
- 4,337 `.class` entries.
- Compressed-data integrity check passed.

## Tools and commands used

- `git rev-parse`, `git diff`, `git status`
- `env`, Java 21, Maven 3.9.16
- `shasum -a 256`, `stat`, `file`, `unzip`

## What this evidence proves

- Exact, unmodified DrivenByMoss 26.4.1 source builds on the accepted Mac with the required Java/Maven class of toolchain.
- The generated extension is intact, versioned 26.4.1, and cryptographically identified.
- Maven did not modify tracked or staged source.

## What this evidence does not prove

- Maven reported no tests; this is not a unit-test result.
- A successful build alone does not prove Bitwig loading or Push behavior. Those are separately retained.
- It does not claim byte identity with the official artifact.
- It does not contain a functional source change.
