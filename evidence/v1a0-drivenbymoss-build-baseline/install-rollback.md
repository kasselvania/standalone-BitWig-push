# Temporary installation and exact rollback

## Date and machine state

- Experiment date: 2026-08-31 PDT.
- Host: accepted S0 Mac, Bitwig Studio 6.1, real Ableton Push 3 connected.
- Extension scan path: `$HOME/Documents/Bitwig Studio/Extensions`.
- Installed filename throughout: `DrivenByMoss.bwextension`.
- No extension was replaced while Bitwig was running.

## Pre-install gates

The maintainer saved work and quit Bitwig normally. A host process-table check over executable names returned `NO_BITWIG_EXECUTABLES`.

Immediately before the swap:

```text
official installed SHA-256
98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a

local build SHA-256
61ff21e5f21d96ee64bfe1b09c5971116f1f5075d5805bc015f0a168fe00b8f9
```

`find` returned exactly one DrivenByMoss extension in the user scan directory: the accepted official file at its expected path.

## Backup and temporary install

A timestamped directory was created outside every Bitwig extension scan path:

```text
$HOME/Documents/ChatGPT/BitWig Standalone Push/v1a0-official-backup-20260831T122127-0700
```

Procedure:

1. Moved, rather than overwrote, the official file into that directory.
2. Recomputed the backup SHA-256 and obtained the exact official hash.
3. Confirmed the installed path was absent and the scan directory contained no DrivenByMoss artifact.
4. Copied the local build to the exact expected installed filename.
5. Recomputed the installed SHA-256 and obtained the exact local-build hash.
6. Confirmed exactly one DrivenByMoss extension existed in the scan directory.

Installed local state:

| Field | Result |
| --- | --- |
| Path | `$HOME/Documents/Bitwig Studio/Extensions/DrivenByMoss.bwextension` |
| Bytes | 14,362,467 |
| SHA-256 | `61ff21e5f21d96ee64bfe1b09c5971116f1f5075d5805bc015f0a168fe00b8f9` |
| Scan-directory count | 1 |

## Local-build load evidence

Bitwig was launched normally after the local hash had been verified at the sole scanned path.

Sanitized startup facts retained from Bitwig's logs:

- 12:22:37 PDT: Bitwig Studio 6.1 revision `94a90411037fa337883222813b7372a3ace9dbd7` started.
- 12:22:43 PDT: the engine started and connected to the control-surface service.
- 12:22:44–12:22:45 PDT: Bitwig enumerated and opened Ableton Push 3 Audio and its Live MIDI input/output ports.

File presence was not treated as load proof. While this sole local artifact was installed, the maintainer directly exercised the real controller and reported all eleven rows in `manual-acceptance.md` as PASS, including the normal DrivenByMoss semantic display.

No source patch was attempted in response to warnings or observations.

## Rollback

After acceptance, the maintainer again quit Bitwig normally. Host executable-name inspection again returned `NO_BITWIG_EXECUTABLES`.

Before moving either file, hashes were rechecked:

| File at that moment | SHA-256 |
| --- | --- |
| Sole installed local artifact | `61ff21e5f21d96ee64bfe1b09c5971116f1f5075d5805bc015f0a168fe00b8f9` |
| Untouched official backup | `98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a` |

Rollback steps:

1. Moved the installed local copy outside the scan path as `DrivenByMoss.local-tested.bwextension` in the timestamped experiment directory. Its hash remained the exact local-build hash.
2. Moved the untouched official backup back to the exact original filename and path.
3. Recomputed the installed hash.
4. Confirmed exactly one DrivenByMoss extension existed in the scan directory.

Final installed state:

| Field | Result |
| --- | --- |
| Path | `$HOME/Documents/Bitwig Studio/Extensions/DrivenByMoss.bwextension` |
| Bytes | 14,362,484 |
| Preserved mtime | 2025-11-28 22:28:38 PST |
| SHA-256 | `98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a` |
| Scan-directory count | 1 |

The tested local copy remains outside Bitwig's scan path and is also reproducible from the clean build worktree; no built binary is in the central Git worktree.

## Restored-official load evidence

Bitwig was relaunched normally after the official hash and count were verified.

Sanitized retained facts:

- 12:33:32 PDT: Bitwig Studio 6.1 revision `94a90411037fa337883222813b7372a3ace9dbd7` started.
- 12:33:43 PDT: the engine connected to the control-surface service.
- 12:33:44–12:33:45 PDT: Ableton Push 3 Audio opened at 48 kHz/512 samples and the Push Live MIDI input/output ports opened.
- Bitwig's Controllers page displayed the configured `Ableton Push 3` entry with the Push Live input/output ports.
- The maintainer directly confirmed that Push showed the normal DrivenByMoss display rather than the connection screen.

This is sufficient rollback/loadability confirmation without rerunning the entire eleven-row local-build acceptance matrix.

## Tools and commands used

- Host process-table inspection limited to executable names
- `shasum -a 256`, `stat`, `find`, `wc`
- `mkdir`, `mv`, `cp -p`, `test`
- Bitwig normal quit/launch and Controllers UI inspection
- Sanitized, narrowly selected Bitwig startup/engine log facts
- Maintainer direct observation of the physical Push display

## What this evidence proves

- Bitwig was stopped before both file swaps.
- The official binary was never overwritten; it was moved intact, verified, and restored.
- Exactly one local artifact was scanned for the local-build test.
- The local artifact was actually loaded and exercised, not merely copied.
- The exact official artifact is restored as the sole scanned DrivenByMoss extension and is loadable.

## What this evidence does not prove

- It does not claim Bitwig logs alone prove controller behavior; direct observations are separately stated.
- It does not retain complete raw logs, screenshots, device identifiers, or account/license details.
- It does not test forced termination, corrupted artifacts, multiple-extension conflict behavior, or reconnect recovery.
- It does not leave the local build active in the user's ordinary Bitwig environment.
