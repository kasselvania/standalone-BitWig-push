# V1A-0 DrivenByMoss build baseline

## Date and machine state

- Evidence date: 2026-08-31 PDT.
- Host: the accepted S0 macOS fixture, macOS 26.4.1 (25E253), Darwin 25.4.0, arm64.
- Bitwig Studio: 6.1, revision `94a90411037fa337883222813b7372a3ace9dbd7`.
- Controller: the accepted Ableton Push 3 fixture, connected over USB and also selected as Bitwig's audio device during acceptance.
- Final ordinary state: Bitwig is running with the official `DrivenByMoss.bwextension` restored at `$HOME/Documents/Bitwig Studio/Extensions/DrivenByMoss.bwextension`.
- Final official SHA-256: `98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a`.

## Status

**V1A-0 complete.**

The implementation fork is a real GitHub fork, the stable fork branch preserves the accepted upstream commit without divergence, the exact clean source built under Java 21, Bitwig loaded and exercised the local artifact with the real Push 3, and the exact official artifact was restored and loaded afterward.

No DrivenByMoss functional source change was made. No DrivenByMoss source commit or source pull request was created for this slice.

## Accepted authorities

| Authority | Exact value |
| --- | --- |
| Central `origin/main` commit | `df7f2d93c87e1d2fe38c95f1e94be7c04ffa6692` |
| Central `origin/main` tree | `d7fd83283b6f1909f16e1950255fd1e0c570328d` |
| DrivenByMoss version/tag | `26.4.1` |
| DrivenByMoss commit | `fd03245ab38fa5149c45934051d937ee9fda6d08` |
| DrivenByMoss tree | `edd2ad636b0aa1f39919f0ffd05c968015450075` |
| Official artifact SHA-256 | `98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a` |
| Local artifact SHA-256 | `61ff21e5f21d96ee64bfe1b09c5971116f1f5075d5805bc015f0a168fe00b8f9` |

## Result summary

- `https://github.com/kasselvania/DrivenByMoss` exists and GitHub reports `isFork: true` with parent `git-moss/DrivenByMoss`.
- Fork branch `pushwig/upstream-26.4.1` points exactly to commit `fd03245ab38fa5149c45934051d937ee9fda6d08`, tree `edd2ad636b0aa1f39919f0ffd05c968015450075`.
- The build source was a clean detached worktree at that exact commit and tree before and after the build.
- The exact command `mvn clean install package -Dbitwig.extension.directory=target`, run with an explicit Java 21 environment, completed with exit code 0 and `BUILD SUCCESS`.
- The local extension is version 26.4.1, 14,362,467 bytes, and has SHA-256 `61ff21e5f21d96ee64bfe1b09c5971116f1f5075d5805bc015f0a168fe00b8f9`.
- The local archive is not byte-identical to the official archive. Their extracted entry names are identical; all extracted files are byte-identical except newline encoding in three build/notice metadata files.
- The local artifact was the sole extension in Bitwig's user extension scan directory when Bitwig launched.
- The maintainer directly reported all eleven controller, display, audio, and compatible Expanded Device View checks as PASS.
- Organ does not expose an Expanded Device View. Polysynth was used for the valid open-and-undock checks.
- Rollback restored exactly one scanned official artifact with the accepted SHA-256. Bitwig then showed the configured Push controller, opened its audio/MIDI endpoints, and the maintainer confirmed the normal DrivenByMoss display.

## Evidence index

- `repository-topology.md` — central worktree, real fork, remotes, tag, stable branch, and clean source custody.
- `toolchain.md` — host state, Java/Maven discovery, authorized Maven installation, and the explicit Java 21 build environment.
- `build-result.md` — clean-source build command, result, warnings, output artifacts, and archive metadata.
- `artifact-comparison.md` — official-versus-local cryptographic, archive, and extracted-payload comparison.
- `install-rollback.md` — process gates, exact backup/install hashes, Bitwig load evidence, rollback, and final official state.
- `manual-acceptance.md` — the eleven direct real-hardware results and the Organ/Polysynth clarification.

## Tools and commands used

The retained result was produced with `git`, `gh`, `sw_vers`, `uname`, `/usr/libexec/java_home`, `java`, `javac`, Maven, Homebrew, `shasum`, `stat`, `file`, `unzip`, `cmp`, `diff`, `find`, Bitwig's sanitized current/previous-run logs, and direct macOS UI inspection. Exact commands and scoped outputs are in the topic files.

No raw profiler inventory, full Bitwig logs, proprietary binaries, screenshots, user projects, account data, serial numbers, hardware UUIDs, hostnames, or IP addresses are retained here.

## What this evidence proves

- The accepted upstream source is under proper fork custody without source divergence.
- The exact clean 26.4.1 source builds successfully on the accepted Mac with Java 21 and Maven 3.9.16.
- The resulting extension is cryptographically identified and structurally understood relative to the accepted official artifact.
- Bitwig actually loaded the sole local artifact and the real Push baseline passed.
- The experiment was reversible, and the exact official artifact is restored and loadable.
- V1A can begin without rediscovering fork, build, artifact, temporary-install, or rollback mechanics.

## What this evidence does not prove

- It does not claim byte-for-byte reproducible JAR output.
- It does not test a functional DrivenByMoss modification; the source was intentionally unmodified.
- It does not implement or test `PushFramePipeline`, display transport changes, overlays, IPC, ScreenCaptureKit, or pixel-anchor behavior.
- It does not constitute a reconnect, crash, endurance, latency, or performance benchmark.
- It does not make Organ support Expanded Device View; that Bitwig device has no such view.
