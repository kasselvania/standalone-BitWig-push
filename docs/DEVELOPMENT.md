# Development

This document is the practical entry point for building and testing Pushwig source.

## Repository layout

```text
capture/macos/   maintained macOS capture helper + Swift tests
docs/            architecture, development, testing, roadmap, design notes
evidence/        retained experiment / real-hardware acceptance records
AGENTS.md        maintainer/coding-agent execution policy
CURRENT_SLICE.md maintainer current-work summary
```

The controller-extension implementation lives in a separate fork:

```text
https://github.com/kasselvania/DrivenByMoss
```

See [`integrations/drivenbymoss.md`](integrations/drivenbymoss.md).

## macOS helper requirements

The accepted V2 fixture used a current macOS/Xcode/Swift toolchain. The package declares macOS 14 or later.

Check your active toolchain:

```bash
sw_vers
xcode-select -p
xcrun swift --version
xcrun --sdk macosx --show-sdk-version
```

## Run committed Swift tests

```bash
cd capture/macos
xcrun swift test
```

These tests cover maintained deterministic contracts such as configuration validation, display selection, aspect mapping, BGRA normalization, protocol header layout, sequence behavior, and bounded authority transitions.

See [`TESTING.md`](TESTING.md).

## Build the helper app

The repository includes a deterministic bundle wrapper:

```bash
cd capture/macos
./scripts/build-app.sh \
  --output-dir /tmp/pushwig-app \
  --scratch-dir /tmp/pushwig-build
```

The script:

- performs a release Swift build;
- creates `PushwigCaptureHelper.app`;
- installs the retained `Info.plist`;
- ad-hoc signs the development app;
- verifies the signature and bundle identifier;
- emits a content manifest.

Build products should remain outside the repository.

The helper bundle identifier is:

```text
com.kasselvania.pushwig.capture-helper
```

A stable installed app identity matters because macOS Screen Recording permission is attached to that application identity.

## Screen Recording permission

Pushwig uses public macOS ScreenCaptureKit/CoreGraphics permission APIs. Do not manipulate the TCC database directly.

For local real-capture work, launch the same built/installed app identity before and after permission changes. The helper will report when a relaunch is required.

## External frame receiver

The helper publishes to the Pushwig DrivenByMoss derivative over the internal loopback frame protocol described in [`PROTOCOLS.md`](PROTOCOLS.md).

Real Push testing therefore requires:

- a compatible DrivenByMoss derivative installed in Bitwig;
- external frame ingress enabled in that derivative;
- an owner-private capability token file;
- matching loopback port/token configuration in the helper.

The normal official DrivenByMoss artifact should be backed up and restored after derivative fixture work. The evidence directories retain the exact historical fixture/rollback procedures; ordinary contributors do not need those details just to build the helper or run its tests.

## DrivenByMoss development

The fork uses:

```text
origin:   git@github.com:kasselvania/DrivenByMoss.git
upstream: https://github.com/git-moss/DrivenByMoss.git
```

Project integration lives on `pushwig/main`; the accepted upstream anchor is `pushwig/upstream-26.4.1`.

The accepted Java/Maven build shape is:

```bash
env \
  JAVA_HOME=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home \
  PATH=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin \
  mvn clean install package -Dbitwig.extension.directory=target
```

Do not silently develop Pushwig changes on fork `master` or upstream `master`.

## Branches and worktrees

Read [`BRANCH_AND_WORKTREE_POLICY.md`](BRANCH_AND_WORKTREE_POLICY.md) before opening a project branch.

For ordinary work:

- branch from the current durable integration branch;
- one PR role per branch;
- research stays local by default;
- use detached/local worktrees for base-build or observation tasks;
- delete merged branches instead of preserving them as history.

Use `scripts/branch-audit.sh` for a read-only local inventory.

## Before opening a PR

At minimum:

```bash
git status --short
git diff --check
```

Run the committed tests relevant to your component and record any real-hardware checks the PR actually depends on.

Do not commit credentials, capability tokens, activation data, proprietary binaries, private projects, serial numbers, or raw proprietary UI capture fixtures.
