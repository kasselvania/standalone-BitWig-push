# Source topology and custody

## Date, machine state, and authority

- Date: 2026-09-02 PDT.
- Machine state: accepted macOS 26.4.1 arm64 fixture; source and evidence used
  separate clean worktrees.
- Corrected central basis/tree:
  `7c15abaf55c0080b2f80971e845b4ee6f1bfcc46` /
  `730726784b57016714c0a44c8f0f8caf1c5b0141`.
- Source PR/head/parent/tree:
  [PR #43](https://github.com/kasselvania/standalone-BitWig-push/pull/43) /
  `03fb8c8824714e4bbefd7224848ca9cdad069088` /
  `7c15abaf55c0080b2f80971e845b4ee6f1bfcc46` /
  `f1f68bc6f0ba6527bb146a7ee93fd4333ffaf796`.
- Source branch: `capture/v2-macos-display-crop-lens`; exactly one commit above
  the corrected basis.
- Evidence branch: `codex/v2-macos-display-crop-evidence`, directly from the
  same corrected basis.
- DrivenByMoss accepted integration commit/tree, read back clean and unchanged:
  `7e3416a1bdddbcbeec4e35e6531652e1618723de` /
  `c8bc3f9e052e8f0b7b5dd256657697349d303740`.

## Repository roles

The central source/evidence remote was
`git@github.com:kasselvania/standalone-BitWig-push.git`. The clean DrivenByMoss
build checkout retained role-correct remotes:

```text
origin   git@github.com:kasselvania/DrivenByMoss.git
upstream https://github.com/git-moss/DrivenByMoss.git
```

No DrivenByMoss branch, source path, PR, transport, bitmap, or USB class was
modified in V2. The helper remains a separate process that speaks the already
accepted V1D-2 local protocol.

## Exact source envelope and hashes

| Production path | SHA-256 |
| --- | --- |
| `capture/macos/Package.swift` | `840d992d8262b2028da0e3a6b7b4f7e827798923d11327591b109fe25d34ce78` |
| `capture/macos/Resources/Info.plist` | `f9bd4954b240300babcb79defb2df334818c17329c276b9c3b93a332f8ee17c0` |
| `capture/macos/Sources/PushwigCaptureHelper/AspectMapping.swift` | `aed502baf6dd5eace85cdb7e9835c2a1c4b7754aa704170fc588c3f743b883a3` |
| `capture/macos/Sources/PushwigCaptureHelper/CaptureConfiguration.swift` | `c89a674b9bc6cff0731f75cea529ac4a76923b8cb70cc398fa89ccf0bef58d6b` |
| `capture/macos/Sources/PushwigCaptureHelper/DisplayCropCapture.swift` | `bcb27ec0ccda99627d7a8b6c6123c7985ed2c7df1e620096d7bc0897e17f9df1` |
| `capture/macos/Sources/PushwigCaptureHelper/DisplayDiscovery.swift` | `5bdfb9a3b218a6475af1b8e4286408b5b6ca1d941ef1a9088b9299d5ec9e631d` |
| `capture/macos/Sources/PushwigCaptureHelper/ExternalRasterProtocolClient.swift` | `03c47ffb9b1ed64c56acfa89375d0fb04b1681e18ddf85dcefec7f1e7f2d4ba8` |
| `capture/macos/Sources/PushwigCaptureHelper/SourceValidityGate.swift` | `bf82977cc253093a0390b2b5819f4b57a94c82cee2ef14addfc0167a737a838f` |
| `capture/macos/Sources/PushwigCaptureHelper/main.swift` | `187cf2ac05aa2898397d3e4a754409502418e3c97467177ceba85eaf83bdedc8` |
| `capture/macos/Tests/PushwigCaptureHelperTests/PushwigCaptureHelperTests.swift` | `6e711c773bb0799c6d22c97de563c1fdd742743039119c5331b73107aefc96bb` |
| `capture/macos/scripts/build-app.sh` | `e208c77e35b6f633fc4bd22699e58d8c2fa3332b0b157a1dd4ed6c6cb651bf0b` |

`git diff --check` passed. `git diff --name-only` showed exactly these eleven
paths, all beneath `capture/macos/**`; `git rev-list --count` returned one.
Searches found no use of `PushUsbDisplay`, `IRasterWritableBitmap`,
`BitmapImpl`, `0.0.0.0`, deprecated whole-screen capture, Accessibility/mouse
injection, private TCC access/reset, UI automation, or an unbounded frame queue.

The in-place repair modified seven of the eleven already-authorized paths:
`AspectMapping.swift`, `CaptureConfiguration.swift`,
`DisplayCropCapture.swift`, `DisplayDiscovery.swift`,
`ExternalRasterProtocolClient.swift`, `main.swift`, and the existing test file.
It added no commit, package dependency, callback queue, thread, executor, frame
slot, or source path. The original source commit was amended and still has the
exact required parent.

## Quarantined branch

The earlier branch `capture/v2-macos-dedicated-window-lens` remains at
`f5bd7fd990ee74956aa1168ba8b747f0f63286ab`. GitHub query returned zero pull
requests for it. Ancestry and patch-ID/cherry-pick checks showed that commit is
neither an ancestor of nor incorporated in the production display-crop head.
The new branch was created directly from the corrected authority basis.

## Commands and tools

Commands included `git fetch origin --prune`, `git rev-parse`, `git log`,
`git worktree list`, `git status --short`, `git diff --exit-code`,
`git diff --cached --exit-code`, `git diff --check`, `git diff --name-only`,
`git rev-list --count`, `git merge-base --is-ancestor`, `git cherry`, `rg`,
`shasum -a 256`, and `gh pr list/view`.

## Exact result

The proposed source is one clean commit on the corrected authority basis with
only the authorized helper paths. DrivenByMoss remained at its accepted clean
integration tree, and the quarantined branch supplied no source history.

## What this proves

- Source custody, parentage, path envelope, source identity, and separation from
  the fixed consumer/USB authority are exact and independently auditable.
- The dedicated-window experiment was not promoted by ancestry or cherry-pick.

## What this does not prove

- Source topology alone does not prove ScreenCaptureKit behavior, TCC identity,
  physical Push pixels, timing, or rollback; those proofs are retained in the
  companion evidence documents.
