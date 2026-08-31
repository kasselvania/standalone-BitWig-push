# Current Slice: V1A-0 — DrivenByMoss Derivative Fork and Local Build Baseline

## Status

Ready to start from current `main` after S0 merge commit `e1e394e99685cfcea953014b07653012cb8183be`.

## Primary claim

Establish the implementation repository and prove that the exact unmodified DrivenByMoss 26.4.1 source pinned by S0 can be built, temporarily installed, loaded by Bitwig Studio, and exercised successfully on the accepted macOS fixture before any frame-pipeline behavior is changed.

This is a deliberately small pre-implementation gate. S0 proved the official installed artifact, exact source pin, and display seam, but did not perform a local source build. Build/toolchain/install/rollback uncertainty must be separated from V1A's no-op frame-pipeline uncertainty.

## Repository topology

Two repositories have different ownership roles:

- `kasselvania/standalone-BitWig-push` remains the project authority, roadmap, evidence, and cross-component integration repository.
- A GitHub fork of `git-moss/DrivenByMoss` under `kasselvania` becomes the implementation repository for the narrow controller-extension derivative.

The DrivenByMoss fork must preserve upstream history and LGPL provenance. Do not copy DrivenByMoss source into this repository.

Required upstream basis:

```text
Upstream repository: git-moss/DrivenByMoss
Tag:                26.4.1
Commit:             fd03245ab38fa5149c45934051d937ee9fda6d08
Tree:               edd2ad636b0aa1f39919f0ffd05c968015450075
```

Create or verify a stable fork branch equivalent to:

```text
pushwig/upstream-26.4.1
```

pointing exactly to that commit. The local checkout must use:

```text
origin   -> kasselvania fork
upstream -> git-moss/DrivenByMoss
```

## In scope

1. Create or verify the `kasselvania/DrivenByMoss` GitHub fork.
2. Configure `origin` and `upstream` remotes correctly in a clean local checkout.
3. Create/verify `pushwig/upstream-26.4.1` at the exact S0 source commit.
4. Record the Mac build toolchain:
   - Java vendor/version and `JAVA_HOME`;
   - Maven version;
   - architecture;
   - relevant Bitwig extension directory.
5. Build the **unmodified** pinned source using the upstream macOS build shape:

   ```text
   mvn clean install package -Dbitwig.extension.directory=target
   ```

   with a Java 21 toolchain.
6. Record:
   - exact source commit/tree;
   - build command and exit result;
   - resulting artifact path, size, SHA-256, manifest, and Maven metadata;
   - whether the locally built artifact is or is not byte-identical to the official artifact, without treating a difference as failure by itself.
7. Temporarily replace the official installed extension through a reversible process:
   - stop or safely reload Bitwig as required;
   - move the official artifact to a backup location outside Bitwig's extension scan path;
   - install the locally built artifact under the expected filename;
   - preserve the official artifact hash from S0.
8. Confirm Bitwig loads the locally built extension and execute the accepted behavioral baseline:
   - Push connection;
   - notes;
   - pressure/MPE where configured;
   - encoders;
   - transport;
   - semantic display;
   - Push audio-device presence;
   - audible master output through Push headphones;
   - native-device selection;
   - Expanded Device View open;
   - Expanded Device View float/undock.
9. Restore the exact official 26.4.1 artifact at the end of the slice unless an explicit maintainer decision says otherwise.
10. Verify the restored official artifact SHA-256 is:

   ```text
   98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a
   ```
11. Retain sanitized evidence under:

   ```text
   evidence/v1a0-drivenbymoss-build-baseline/
   ```

12. Leave both repositories and all relevant worktrees clean.

## Expected evidence

Use a structure equivalent to:

```text
evidence/v1a0-drivenbymoss-build-baseline/
├── README.md
├── repository-topology.md
├── toolchain.md
├── build-result.md
├── artifact-comparison.md
├── install-rollback.md
└── manual-acceptance.md
```

Every evidence file should state what it proves and what it does not prove.

Sanitize personal paths as `$HOME`, and do not retain serial numbers, hardware UUIDs, account/license data, hostnames, IP addresses, proprietary binaries, or private UI captures.

## Explicit non-goals

- no `PushFramePipeline` implementation;
- no `PushDisplayTransport` abstraction;
- no source behavior change in DrivenByMoss;
- no version or extension-ID change;
- no overlay or synthetic pixels;
- no frame hashing instrumentation inside the extension;
- no new queue, executor, thread, or USB writer;
- no IPC, shared memory, or external frame ingress;
- no ScreenCaptureKit helper or Screen Recording permission request;
- no visual resolver or pixel-anchor implementation;
- no Steam Deck/Linux validation;
- no yabridge, Monome, plugdata, hardware, battery, or CM11EB work;
- no attempt to make the locally built JAR reproducible byte-for-byte unless the unmodified build naturally is.

## Acceptance criteria

V1A-0 is complete only when all of the following are true:

1. The implementation fork exists and retains upstream history.
2. `pushwig/upstream-26.4.1` resolves exactly to `fd03245ab38fa5149c45934051d937ee9fda6d08` and tree `edd2ad636b0aa1f39919f0ffd05c968015450075`.
3. The local checkout has correct `origin` and `upstream` remotes and a clean unmodified source tree.
4. The pinned source builds successfully on the accepted Mac with Java 21 and Maven.
5. The built extension artifact is cryptographically identified and its metadata retained.
6. Bitwig loads the locally built artifact.
7. The full accepted manual baseline passes, or every failure is characterized precisely enough to decide whether build parity is blocked.
8. The official artifact can be restored safely and its exact S0 SHA-256 is reverified.
9. No functional source change or V1A implementation enters the slice.
10. Another agent can start V1A from a proven build/install/fork baseline without rediscovering toolchain or rollback behavior.

## Expected V1A handoff

After V1A-0 closes, V1A may introduce only the identity frame boundary proven by S0:

```text
complete semantic IBitmap
        -> PushFramePipeline identity process
        -> existing Push USB transport
```

The first functional derivative should then be reviewed independently for object identity, pixel equivalence, call order, timing, allocation behavior, shutdown, reconnect observations, and one-writer preservation.

## Review standard

Do not mark V1A-0 complete because Maven produced a file. The locally built extension must be loaded and exercised on the real Mac + Bitwig + Push fixture, and the rollback to the exact official artifact must be retained.
