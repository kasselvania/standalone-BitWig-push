# DrivenByMoss integration

Pushwig uses a narrow fork of DrivenByMoss for the controller-extension side of the project.

Repository:

```text
https://github.com/kasselvania/DrivenByMoss
```

Upstream:

```text
https://github.com/git-moss/DrivenByMoss
```

## Branch roles

```text
pushwig/main             durable Pushwig integration branch
pushwig/upstream-26.4.1  immutable accepted upstream anchor
```

Feature branches are temporary and deleted after merge. Fork `master`/other upstream mirror branches are not Pushwig feature-history storage.

## What the fork owns

The Pushwig delta owns:

- current semantic redraw before optional visuals;
- validated opaque-BGRA raster application;
- authenticated local latest-frame ingress;
- semantic fallback after visual loss/failure;
- the sole accepted Push display USB transport path.

The fork does **not** own macOS ScreenCaptureKit, window/display discovery, crop profiles, or other platform capture APIs. Those live in platform helpers such as `capture/macos/**` in the central repository.

## Build

The accepted macOS development toolchain uses Java 21 and Maven. The historical accepted command is:

```bash
env \
  JAVA_HOME=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home \
  PATH=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin \
  mvn clean install package -Dbitwig.extension.directory=target
```

Contributors on another system may use an equivalent Java 21/Maven environment, but compatibility claims should record the toolchain actually tested.

## PR flow

Pushwig production changes target `pushwig/main`.

Use a focused feature branch, run the relevant DrivenByMoss build/tests, and keep the delta narrow. Production source PRs are merged with a true merge commit when retaining the exact reviewed source head as a parent is useful; the feature branch is then deleted.

Do not develop Pushwig changes directly on fork `master` or silently update the upstream anchor as part of unrelated work.

## License/provenance

DrivenByMoss is an upstream third-party project. Preserve its copyright/license notices and keep the Pushwig derivative source changes compatible with the upstream license.

The central Pushwig repository does not vendor DrivenByMoss source or built extension binaries.

## Live fixture safety

When testing a derivative inside Bitwig:

- save work and stop Bitwig before replacing the extension;
- keep the official artifact backed up outside scan paths;
- keep exactly one extension in Bitwig's scanned tree;
- restore/reverify the normal official artifact after experiments that require temporary derivative installation.

Exact historical rollback hashes and fixture procedures are retained under `evidence/**`; they are not part of ordinary build setup.
