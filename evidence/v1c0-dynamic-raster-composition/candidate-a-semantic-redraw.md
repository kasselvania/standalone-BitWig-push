# Candidate A — retained current semantic redraw

## Date, machine state, and custody

- Evidence date: 2026-08-31 PDT.
- Machine state: accepted macOS 26.4.1 arm64 fixture; isolated local research worktrees; no source branch push or source PR.
- Central basis: `24431c70eb720235b9c7836d9b2842a798d81d54`, tree `bb72673d2b3ce01ed6525a6ab7f2096dde1ac7bf`.
- DrivenByMoss parent: `1ae0b74f383314d170a5960ca763bdf9c319e787`, tree `a81e5c4330b31f36845c25e98e322990d62f0c67`.
- Research worktree: `$HOME/Documents/ChatGPT/BitWig Standalone Push/DrivenByMoss-v1c0`.
- Local branch: `research/v1c0-semantic-redraw`.
- Local commit: `3e8df95e9cc489e69da72b9acb82f2d06c90dd00`.
- Candidate tree: `f448eeda923232346037074a75b71c485e56ebe8`.
- Commit subject: `V1C-0 research: prototype retained semantic redraw`.
- Complete committed-patch SHA-256: `fd289e686677e74c07b16bed84ac1e44e1eefec5716343f964898f74f8b57deb`.

After a final `git fetch origin --prune`, `origin/pushwig/main` remained `1ae0b74f383314d170a5960ca763bdf9c319e787`; no remote branch contained the local research commit. The worktree was clean.

## Exact prototype source envelope

The local commit changed exactly:

```text
M src/main/java/de/mossgrabers/framework/controller/display/AbstractGraphicDisplay.java
M src/main/java/de/mossgrabers/controller/ableton/push/controller/Push2Display.java
A src/main/java/de/mossgrabers/controller/ableton/push/controller/ResearchDynamicOverlayPushFramePipeline.java
```

Complete source file SHA-256 values:

| Path | SHA-256 |
| --- | --- |
| `AbstractGraphicDisplay.java` | `f4891d265807c417bd0dd26f1762fc8d6569912eea9e064383ad0216869baa07` |
| `Push2Display.java` | `5870e6009acdc0f44d4ef340beaa5f854b54c081ddc5732bb07ffb1c430e137b` |
| `ResearchDynamicOverlayPushFramePipeline.java` | `572f84d519dcf66ef02db54cec2a51a8a77c1a4a9f75e9c6611fbbaa05401ba2` |

`PushUsbDisplay.java`, `pom.xml`, the accepted V1A pipeline types, IDs, USB matching, encoder, padding, XOR, and transfer scheduling were not modified.

## Prototype ownership rule

The prototype makes three narrow changes:

1. `AbstractGraphicDisplay.send()` always stores the newest copied `ModelInfo`, even when `ModelInfo.equals` says its equality-covered fields are unchanged.
2. A protected `shouldRedrawCurrentModel()` hook defaults to `false`, preserving ordinary graphics-display dirty rendering.
3. Only `Push2Display` returns `true` from that hook when the startup-scoped research property `pushwig.v1c0DynamicOverlay` selected the dynamic research pipeline.

The resulting eligible-send sequence is synchronous:

```text
new ModelInfo copy
        -> retain newest model
        -> full semantic render into persistent IBitmap
        -> one PushFramePipeline.process call
        -> zero or one bounded render callback for current visual state
        -> same IBitmap reference
        -> one PushUsbDisplay.send call
```

The deterministic local sequence used four 64x16 marks and then three semantic-only states:

| State | Bounds | Outer color | Inner mark |
| --- | --- | --- | --- |
| A / R1 | `[16,4,64,16]` | red | white `[20,8,56,8]` |
| B / R2 | `[304,32,64,16]` | orange | white `[308,36,56,8]` |
| C / R3 | `[560,112,64,16]` | green | white `[564,116,56,8]` |
| D / R4 | `[880,72,64,16]` | blue | white `[884,76,56,8]` |
| none | none | semantic-only | none |
| stale | none | semantic-only | none |
| invalid | none | semantic-only | none |

Each state lasted 64 eligible sends on the fixture build. The pipeline stores only a bounded counter and four class-initialized renderer instances; it retains no bitmap and returns the exact input reference.

## Build and bytecode result

Both exact base and candidate built successfully with exit code 0 under Java 21.0.11 and Maven 3.9.16 using the accepted command:

| Build | Artifact completion | Bytes | SHA-256 | ZIP entries / extracted files |
| --- | --- | ---: | --- | ---: |
| Accepted base | 2026-08-31 16:01:58 PDT | 14,365,128 | `fe54e68a83826b726fe2dbba2c810733c64fadb731371448bcaef04fdc12d485` | 4,872 / 4,441 |
| Candidate A | 2026-08-31 16:02:17 PDT | 14,367,441 | `22b37222aa9242f822c4717168ecde0d66cab10488caaabec9fe481cffba4c72` | 4,873 / 4,442 |

Both manifests were identical: Java 21, `Implementation-Title: DrivenByMoss`, and `Implementation-Version: 26.4.1`. Archive timestamps/order were not treated as payload differences.

The only relevant Maven warnings were the accepted shading warnings about `module-info.class`, the overlapping `META-INF/MANIFEST.MF`, and replacement of the already attached Bitwig ZIP during the repeated lifecycle bound to the requested command. No compile or test failure occurred.

`git diff --check` passed before commit. `javap -c -p` against the exact clean artifact proved:

- newest `ModelInfo` is stored before the redraw decision;
- the default hook returns `false`;
- the Push override returns its final startup decision;
- `Push2Display.send` preserves the shutdown/null guard;
- it calls `PushFramePipeline.process` once and `PushUsbDisplay.send` once;
- each visual state invokes `IBitmap.render` once, while none/stale/invalid invoke it zero times;
- `process` returns local argument 1 directly;
- no bitmap, frame, queue, thread, task, or transport object is created in `process`;
- the renderer instances are initialized once in the class initializer.

The existing shutdown executor and `AbstractGraphicDisplay` notification scheduler appear in inherited context only. Candidate A adds no thread, queue, executor, timer, USB object, socket, shared memory, or asynchronous handoff.

## Artifact payload custody

Same-toolchain extraction compared 4,441 base files with 4,442 candidate files. The only executable payload changes were:

```text
AbstractGraphicDisplay.class                    changed
Push2Display.class                              changed
ResearchDynamicOverlayPushFramePipeline.class   added
```

`PushUsbDisplay.class` remained byte-identical at SHA-256 `288b576b3f2ed064f8d9a0c6f6d384fb3516a0858cc22e7879bee896df83dec3`. `PushFramePipeline.class`, `PassThroughPushFramePipeline.class`, and `SyntheticOverlayPushFramePipeline.class` also remained byte-identical.

## Commands and tools

Commands included `git status`, `git diff --check`, `git show --binary`, `git rev-parse`, `git branch -r --contains`, exact Java/Maven builds, `javap -c -p`, `shasum -a 256`, `unzip`, `find`, `diff -qr`, and the external raster harness described in `pixel-restoration.md`.

## What this proves

- Candidate A is a concrete, buildable, bounded source seam rather than a class-name inference.
- Ordinary graphic displays remain on their existing dirty-render path because the new hook defaults off.
- Dynamic Push output is rebuilt from the newest retained semantic model before each generated layer.
- USB encoding/transport stays byte-identical and sole-owned.

## What this does not prove

- The research class/property is not the final V1C production naming or generated-local-frame API.
- The local research commit is not proposed for merge and has no source PR.
- Source/bytecode proof alone does not prove pixel restoration or hardware behavior; those are retained separately.
