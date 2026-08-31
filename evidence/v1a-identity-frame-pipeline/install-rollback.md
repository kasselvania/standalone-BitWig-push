# V1A real-fixture installation and rollback

## Date and machine state

- Evidence date: 2026-08-31 PDT.
- Host: accepted macOS 26.4.1 arm64 fixture, Bitwig Studio 6.1, Ableton Push 3 connected.
- Central basis: `a36779d4c04a11d6c6e9ce0d48c34ea3b813a0cc`, tree `bc4634da23f794f2afd39c63fab9eb5cf44524c1`.
- Source basis: `fd03245ab38fa5149c45934051d937ee9fda6d08`, tree `edd2ad636b0aa1f39919f0ffd05c968015450075`.
- Source PR/head/tree: [kasselvania/DrivenByMoss#1](https://github.com/kasselvania/DrivenByMoss/pull/1), `6e1e4cbd2e725a7951e5b4dc1278fbb6e7b5d61c`, `9aec7429ff093addee001a62a5a07309708fd592`.
- V1A artifact SHA-256: `94e69a2f2ce91ac6522ed6a0c1c52d7c216dea3a8c3d03f76c2221886bc62706`.

## Pre-install readback

Before any file change, targeted process inspection showed Bitwig was still running, so no replacement occurred. Read-only artifact checks established:

```text
Installed path: $HOME/Documents/Bitwig Studio/Extensions/DrivenByMoss.bwextension
Size: 14,362,484 bytes
SHA-256: 98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a
Matching files in the user extension directory: exactly one
```

This is the accepted official artifact. The initial process gate correctly refused replacement while Bitwig remained active. After the maintainer saved work and quit normally, exact-name process checks for `BitwigStudio` and `BitwigAudioEngine-ARM64-NEON` returned no processes.

## Backup and V1A installation

The timestamped experiment directory was outside every Bitwig extension scan path:

```text
$HOME/Documents/ChatGPT/BitWig Standalone Push/v1a-official-backup-20260831T132436-0700
```

The swap used explicit paths and hard preconditions for both hashes. The first shell expression stopped on a quoting error before it created the backup directory; immediate readback proved the official path and hash were unchanged and the backup path did not exist. The corrected command then:

1. moved, rather than overwrote, the official artifact to `DrivenByMoss.official.bwextension` in the timestamped directory;
2. reverified the backup's exact official hash;
3. copied the exact PR-head build to the canonical installed filename;
4. reverified the installed V1A hash; and
5. confirmed exactly one matching extension in the user scan directory.

| State | Size | SHA-256 | Scan count |
| --- | ---: | --- | ---: |
| Untouched official backup | 14,362,484 bytes | `98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a` | outside scan path |
| Sole installed V1A | 14,363,745 bytes | `94e69a2f2ce91ac6522ed6a0c1c52d7c216dea3a8c3d03f76c2221886bc62706` | 1 |

The official backup retained its original 2025-11-28 22:28:38 PST modification time. The installed V1A hash was rechecked after the complete manual run and remained exact.

## Exact V1A load evidence

Bitwig was launched normally only after the sole installed path had the exact V1A hash. Sanitized current-run facts were:

- 13:25:43 PDT: Bitwig Studio 6.1 revision `94a90411037fa337883222813b7372a3ace9dbd7` started.
- 13:25:48 PDT: the Bitwig engine started and connected to the control-surface service.
- 13:25:50 PDT: Ableton Push 3 Audio opened at 48 kHz with a 512-sample block size.
- 13:25:50 PDT: both Ableton Push 3 Live Port MIDI directions opened.
- While that sole derivative artifact was installed, the maintainer directly passed all eleven controller/display/audio/native-device rows in `manual-acceptance.md`.
- A narrowly filtered current-run search for controller, extension, display, MIDI, Push, or USB errors/exceptions/failures returned no matches.

File presence and enumeration were not promoted to behavioral proof; the normal semantic display and physical controls were confirmed directly.

## Ordinary shutdown and exact rollback

After acceptance, the maintainer quit Bitwig normally. Exact executable-name inspection again returned no Bitwig or Bitwig audio-engine process. Immediately before rollback:

| File | SHA-256 |
| --- | --- |
| Sole installed V1A artifact | `94e69a2f2ce91ac6522ed6a0c1c52d7c216dea3a8c3d03f76c2221886bc62706` |
| Untouched official backup | `98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a` |

Rollback then:

1. moved the tested derivative outside the scan path as `DrivenByMoss.v1a-tested.bwextension` in the timestamped directory;
2. verified that moved copy retained the exact V1A hash;
3. moved the untouched official artifact back to `$HOME/Documents/Bitwig Studio/Extensions/DrivenByMoss.bwextension`;
4. verified the restored official hash and preserved mtime; and
5. confirmed exactly one matching extension in the user scan directory.

Final installed state:

| Field | Exact result |
| --- | --- |
| Installed path | `$HOME/Documents/Bitwig Studio/Extensions/DrivenByMoss.bwextension` |
| Size | 14,362,484 bytes |
| Preserved mtime | 2025-11-28 22:28:38 PST |
| SHA-256 | `98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a` |
| Scan-directory count | 1 |

## Restored-official load evidence

Bitwig was relaunched normally after the final official hash/count readback:

- 13:35:10 PDT: Bitwig Studio 6.1 revision `94a90411037fa337883222813b7372a3ace9dbd7` started.
- 13:35:16 PDT: the engine started and connected to the control-surface service.
- 13:35:17 PDT: Ableton Push 3 Audio opened at 48 kHz/512 samples.
- 13:35:18 PDT: both Push Live MIDI directions opened.
- The narrow current-run controller/extension/display error filter returned no matches.
- The maintainer directly confirmed that Push showed its normal DrivenByMoss display rather than the connection screen.

The ordinary environment is left running Bitwig with the exact official artifact restored. The tested derivative copy remains outside the scan path and is independently reproducible from the clean source worktree.

## Commands and tools

The experiment used exact-name process checks, `stat`, `shasum -a 256`, `file`, scoped `find`, `mv`, `cp -p`, hard shell preconditions, Bitwig's normal UI launch/quit flow, narrowly filtered sanitized `BitwigStudio.log` and `engine.log` facts, and direct maintainer observation. No force-quit, reinstall, source patch, full log, screenshot corpus, or unrelated machine inventory was retained.

## What this proves

- No extension was replaced while Bitwig was active.
- The sole exact PR-head artifact loaded and drove the real Push baseline.
- The derivative run shut down normally.
- The untouched official artifact was restored byte-for-byte to its original path and remains loadable.
- Exactly one DrivenByMoss extension remains in Bitwig's user scan directory.

## What this does not prove

- The experiment is not a cable-removal, forced-crash, reconnect, endurance, or detailed latency test.
- Startup/controller facts do not independently prove visual identity; that result is the maintainer's direct observation documented separately.
