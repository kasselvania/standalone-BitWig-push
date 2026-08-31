# DrivenByMoss artifact and source provenance

## Date

2026-08-31, inspected while Bitwig Studio 6.1 was running. The installed extension was not rebuilt, replaced, reinstalled, or modified.

## Machine state

The installed artifact was located in Bitwig's standard user extension directory. Upstream source was cloned into a separate sibling checkout and detached at the proven tag commit; it was not copied or submoduled into this repository.

## Installed artifact

```text
Filename: DrivenByMoss.bwextension
Sanitized path: $HOME/Documents/Bitwig Studio/Extensions/DrivenByMoss.bwextension
File type: Java archive data (JAR)
Size: 14,362,484 bytes
Filesystem modification time: 2025-11-28T22:28:38-0800
SHA-256: 98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a
```

Embedded Maven metadata:

```text
groupId=de.mossgrabers
artifactId=DrivenByMoss
version=26.4.1
```

Embedded manifest metadata:

```text
Manifest-Version: 1.0
Created-By: Maven JAR Plugin 3.5.0
Java-Version: 21
Build-Jdk-Spec: 21
Implementation-Title: DrivenByMoss
Implementation-Version: 26.4.1
```

## Official-distribution comparison

The README at the pinned tag directs users to the author's [official Bitwig download site](https://www.mossgrabers.de/Software/Bitwig/Bitwig.html). The versioned official distribution was downloaded over HTTPS only to a temporary directory:

```text
URL: https://www.mossgrabers.de/Software/Bitwig/DrivenByMoss-26.4.1-Bitwig.zip
ZIP SHA-256: 74ca945da45ed945582875bb3af8b65053b199316155eb98e90a203aa598571a
Contained DrivenByMoss.bwextension SHA-256:
  98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a
cmp(installed, official-contained-extension): identical, exit 0
```

The installed extension is therefore byte-for-byte identical to the extension inside the official 26.4.1 distribution. The distribution itself is not retained in this repository.

## Exact upstream source pin

```text
Repository: https://github.com/git-moss/DrivenByMoss
Tag: 26.4.1
Commit: fd03245ab38fa5149c45934051d937ee9fda6d08
Tree: edd2ad636b0aa1f39919f0ffd05c968015450075
Parent: a192d5ae85225a30be36a584ce712e0dae859d82
Commit date: 2025-11-28T22:33:03+01:00
Source checkout state: detached HEAD at the tag commit
```

Pinned links:

- [tag commit](https://github.com/git-moss/DrivenByMoss/commit/fd03245ab38fa5149c45934051d937ee9fda6d08)
- [source tree](https://github.com/git-moss/DrivenByMoss/tree/fd03245ab38fa5149c45934051d937ee9fda6d08)
- [26.4.1 release record](https://github.com/git-moss/DrivenByMoss/releases/tag/26.4.1)
- [tag README directing users to the official site](https://github.com/git-moss/DrivenByMoss/blob/fd03245ab38fa5149c45934051d937ee9fda6d08/README.md#L5-L7)

## Provenance verdict

The tested artifact is pinned to upstream tag `26.4.1`, commit `fd03245ab38fa5149c45934051d937ee9fda6d08`. This is not a closest-release guess: the installed bytes exactly match the author's official versioned distribution artifact, and that version has an exact upstream tag.

One narrower limitation remains: the JAR manifest does not embed a Git commit hash, and S0 did not perform a reproducible rebuild. The correspondence is proven by the exact official artifact/version/tag chain, not by comparing a locally rebuilt JAR.

## Tools and commands used

```text
find ... -iname '*.bwextension'
shasum -a 256 DrivenByMoss.bwextension
stat ... DrivenByMoss.bwextension
file DrivenByMoss.bwextension
unzip -Z1 DrivenByMoss.bwextension
unzip -p DrivenByMoss.bwextension META-INF/MANIFEST.MF
unzip -p DrivenByMoss.bwextension META-INF/maven/de.mossgrabers/DrivenByMoss/pom.properties
git clone git@github.com:git-moss/DrivenByMoss.git
git tag -l '*26.4.1*'
git rev-parse '26.4.1^{commit}'
git rev-parse '26.4.1^{tree}'
git switch --detach 26.4.1
curl --fail --location <official versioned ZIP URL>
unzip <official ZIP> DrivenByMoss.bwextension
shasum -a 256 <official ZIP and contained extension>
cmp -s <installed extension> <official contained extension>
```

## What this evidence proves

- The exact installed filename, sanitized location, size, version/build metadata, and SHA-256.
- Byte identity with the official 26.4.1 distribution artifact.
- An exact upstream tag, commit, and tree for source inspection.

## What this evidence does not prove

- It does not prove reproducible-build byte identity from a local checkout.
- It does not prove that Bitwig had an active Push 3 controller instance during this inspection.
- It does not grant redistribution rights for the third-party binary, which is intentionally absent here.
