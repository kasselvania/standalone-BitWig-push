# Development

## Current repository layout

```text
docs/            accepted contracts, contributor guides and research references
evidence/        historical experiment and real-hardware records
scripts/         repository maintenance
```

The retired `capture/macos` package is no longer built or tested as current tooling. There is no capture helper to install and no screen-recording permission prerequisite for working on the accepted frame/activation foundation.

Historical source is linked from [capture retirement](research/capture-experiments-retired.md). Do not copy it back into the product merely to make old build commands work.

## DrivenByMoss runtime

The accepted implementation and its regression tests live in the [DrivenByMoss fork](https://github.com/kasselvania/DrivenByMoss).

```text
origin:   git@github.com:kasselvania/DrivenByMoss.git
upstream: https://github.com/git-moss/DrivenByMoss.git
branch:   pushwig/main
anchor:   pushwig/upstream-26.4.1
```

The accepted Mac build environment is Java 21 and Maven:

```bash
env \
  JAVA_HOME=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home \
  PATH=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin \
  mvn clean install package -Dbitwig.extension.directory=target
```

Use that repository's affected test runner when changing runtime code; do not add redundant package builds around a runner that already builds. No runtime rebuild or physical acceptance rerun is needed merely to remove unrelated central capture source.

## Producer contract

Read [Protocols](PROTOCOLS.md) and the [ordinary-launch activation guide](design/ordinary-launch-ingress-activation.md). A producer discovers the current private session, reads its capability separately and publishes bounded complete frames. The official upstream extension has no Pushwig ingress; that is expected.

A generated producer can exercise the accepted path without a screen-capture backend. New production video work requires an explicit implementation request; this cleanup supplies no replacement source.

## Safe physical work

Save and quit Bitwig normally before replacing an extension. Preserve the official artifact intact outside scan paths, install only one derivative, and restore the official artifact exactly after testing. Do not force-quit, discard projects, or manipulate TCC.

## Repository checks

For central documentation/retirement changes:

```bash
git diff --check
git status --short
bash -n scripts/branch-audit.sh
```

Check changed Markdown links and ensure removed tooling is not still advertised as a current dependency. Run component tests only when that component changes.

See [Testing](TESTING.md), [Branch/worktree policy](BRANCH_AND_WORKTREE_POLICY.md), and [DrivenByMoss integration](integrations/drivenbymoss.md).
