# Official-versus-local artifact comparison

## Date and machine state

- Comparison date: 2026-08-31 PDT.
- Machine state: Bitwig was safely stopped before the pre-install comparison.
- Official path: `$HOME/Documents/Bitwig Studio/Extensions/DrivenByMoss.bwextension`.
- Local path: `$HOME/Documents/ChatGPT/BitWig Standalone Push/DrivenByMoss-v1a0-build/target/DrivenByMoss.bwextension`.
- Both artifacts identify themselves as DrivenByMoss 26.4.1 built for Java 21.

## Cryptographic and size comparison

| Artifact | Bytes | SHA-256 |
| --- | ---: | --- |
| Accepted official | 14,362,484 | `98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a` |
| Local clean-source build | 14,362,467 | `61ff21e5f21d96ee64bfe1b09c5971116f1f5075d5805bc015f0a168fe00b8f9` |

`cmp -s` returned exit 1. The archives are not byte-identical, and the local archive is 17 bytes smaller.

## Metadata comparison

Both manifests report exactly:

```text
Manifest-Version: 1.0
Created-By: Maven JAR Plugin 3.5.0
Java-Version: 21
Build-Jdk-Spec: 21
Implementation-Title: DrivenByMoss
Implementation-Version: 26.4.1
```

Both embedded `pom.properties` files identify:

```text
artifactId=DrivenByMoss
groupId=de.mossgrabers
version=26.4.1
```

Each archive contains 4,869 entries, including 4,337 `.class` entries.

## Entry and extracted-payload comparison

The comparison used two levels:

1. `diff` over sorted `unzip -Z1` output returned exit 0: both archives have exactly the same entry-name set.
2. Both archives were extracted into separate temporary directories and compared with `diff -qr`.

The extracted comparison reported exactly three differing files:

```text
META-INF/maven/de.mossgrabers/DrivenByMoss/pom.properties
META-INF/maven/de.mossgrabers/DrivenByMoss/pom.xml
THIRD-PARTY.txt
```

For each of those files:

- `file` identifies CRLF line terminators in the official copy and LF line terminators in the local copy.
- `diff -w` returns exit 0.

No other extracted file differs. Thus all compiled classes, resources, documentation, images, and packaged native/library payloads compare byte-identically after extraction; only newline encoding differs in those three text metadata/notice files.

The raw archive entry order also differs, and entry timestamps reflect different build environments/times. Those archive-level details, plus the three line-ending differences, explain why the JAR containers have different hashes. This result is a bounded artifact comparison, not a reproducible-build claim.

## Tools and commands used

- `shasum -a 256`, `stat`, `file`
- `cmp -s`
- `unzip -p`, `unzip -Z1`, `unzip -t`
- `sort`, `diff`, `diff -qr`, `diff -w`
- Temporary extracted trees under `/private/tmp`; no extracted payload is committed.

## What this evidence proves

- The local artifact is not being confused with the accepted official artifact; each has a distinct retained hash.
- Both archives contain the same version metadata and entry-name set.
- The locally generated executable/resource payload matches the official extracted payload except for newline encoding in three non-class text files.
- Archive non-identity is precisely bounded rather than dismissed as unexplained.

## What this evidence does not prove

- It does not claim bit-for-bit reproducible JAR output.
- It does not prove Maven would emit the same archive on a different host or date.
- It does not prove runtime behavior; Bitwig and Push acceptance are separate evidence.
- It does not make the official binary redistributable or commit either binary.
