# Capture experiments retired

Date: 2026-09-09. Maintainer-authorized removal, not a new source implementation.

## Boundary

Remove the accumulated V2–V5B capture experiments from current product code and architectural standing. Preserve the accepted DrivenByMoss integration, including later V5A activation; do not reset the repository to a pre-V2 date.

Central removal basis: `99e87115796673ac55bf24cfa956bac672dfcd4e`, tree `8dfa71247a2c531a7c17d4b687ecb8482f1f7c30`.

DrivenByMoss remains unchanged at accepted `pushwig/main` commit `997158b0a4ddd932a0a985c8b74ffff1e631120f`, tree `dbf3dc8d4e6d6b95a654088f85b8a183584063b7`: composition, current-semantic restoration, raster sink, authenticated latest-frame ingress, ordinary-launch activation and sole USB writer.

## Removed current structure

- The entire experimental `capture/macos` package: source, capture-specific tests, profiles and app build tooling, including its coupled Swift producer client.
- V2 display-crop and V3 window-relative implementation designs.
- Unimplemented device-aware presentation, managed-workspace and frame-source-bakeoff designs.
- V5B's candidate-selection document and active-work instruction.

The wire protocol and V5A rendezvous specification remain supported contracts. Removing the Swift helper does not remove or change the receiver. No replacement producer or FFmpeg layer is implemented here.

## History, not product authority

- [Pre-removal source tree](https://github.com/kasselvania/standalone-BitWig-push/tree/99e87115796673ac55bf24cfa956bac672dfcd4e/capture/macos).
- [Pre-removal design documents](https://github.com/kasselvania/standalone-BitWig-push/tree/99e87115796673ac55bf24cfa956bac672dfcd4e/docs/design).
- [V2 source PR #43](https://github.com/kasselvania/standalone-BitWig-push/pull/43), [V3 PR #46](https://github.com/kasselvania/standalone-BitWig-push/pull/46), and [closed failed V5 PR #52](https://github.com/kasselvania/standalone-BitWig-push/pull/52) retain published experiments.
- [Evidence index](../../evidence/README.md) retains observations and limitations. Historical commands and source paths refer to those recorded commits, not current tooling.

V5B was stopped by the maintainer, not completed. Its local probe showed selected Bitwig pixels without obstructing controls, but the integrated run was reported as jerky/flashing with poor resize behavior. Controls remained normal. A later local correction was not physically qualified; it is not an accepted result. Unpublished V5B code was discarded locally with explicit permission into Trash rather than a new archive PR. Its subsequent local recoverability is no longer established; see the custody note below.

Older research and the native-device observation catalog are retained as historical/unselected material. They do not prescribe a resolver, semantic camera, profile hierarchy, source framework or workspace manager.

## Mac cleanup

The three agent-added apps were removed from the user Applications directory: PushwigCaptureHelper, Pushwig Window Source, and Pushwig Window Source Probe. Identified Pushwig scratch builds/logs, an older helper-only app backup, eight retired central capture worktrees and the pinned ScreenCaptureLite checkout were placed in recoverable Trash. Clean worktree heads were checked against remote history; local branch refs were not deleted. The unpublished V5B file tree was copied and compared before its worktree was removed.

Custody readback: the Trash collection was verified at approximately 421 MB. A later check at 14:04 local time found Trash empty. No empty-Trash or permanent-delete command was issued in this cleanup, and the cause was not established. Therefore these local copies are no longer claimed recoverable. Published source remains in Git history; the unpublished V5B changes were never pushed.

Bitwig, pre-existing capture tools, projects, DrivenByMoss worktrees and extension backups were not removed. No TCC database, privacy permission, keychain or trust setting was modified. macOS may retain old permission entries after app removal.

The official scanned extension was verified as SHA-256 `98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a`. Cleanup does not require replacing it or another physical acceptance cycle. No Pushwig source process or active manifest/capability remained; dormant owner.lock was preserved. Ordinary Bitwig was left running, not quit or modified.

## Verification scope

Check removal/path envelope, unchanged activation-guide blob and DrivenByMoss state, Markdown links, shell syntax and `git diff --check`. Do not rebuild retired helpers or rerun the physical fixture to justify their deletion. This record proves retirement and custody, not a new video-source result.
