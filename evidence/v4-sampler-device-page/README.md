# V4 Sampler device page — blocked preflight

Date: 2026-09-03 (America/Los_Angeles). Owning issue: [#49](https://github.com/kasselvania/standalone-BitWig-push/issues/49).

**BLOCKED before production implementation.** The attached-desktop usability
gate fails on the accepted Mac: active desktop-independent Bitwig capture places
the macOS sharing badge over the normal window buttons. The maintainer confirmed
that minimize and full-screen controls cannot be accessed while it is present.
No compliant remedy has been established from the inspected public capture
configuration. This is a product-blocking observation, not a passed fixture or a
claim that every possible future macOS solution has been disproved.

## Custody and method

- Central basis: `d295dab73d082fe3dfdf53e9d61987b50f4257d7`; tree
  `ab1ada433b9e70ecf54763c3ef8062aab5eb814c`. Re-fetched and unchanged on this date.
- Central worktree: `$HOME/Documents/ChatGPT/BitWig Standalone Push/standalone-BitWig-push-v4-sampler`;
  branch `capture/v4-sampler-device-page`. This file is the only change: a blocked
  checkpoint on the requested implementation branch, not a separate evidence slice.
- DrivenByMoss basis/head: `7e3416a1bdddbcbeec4e35e6531652e1618723de`; tree
  `c8bc3f9e052e8f0b7b5dd256657697349d303740`.
  Worktree `$HOME/Documents/ChatGPT/BitWig Standalone Push/DrivenByMoss-v4-sampler`;
  local branch `pushwig/v4-sampler-device-page`, with no changes or new commits.
  `origin` is `git@github.com:kasselvania/DrivenByMoss.git`; `upstream` is
  `https://github.com/git-moss/DrivenByMoss.git`.
- Immutable upstream branch remains commit
  `fd03245ab38fa5149c45934051d937ee9fda6d08`, tree
  `edd2ad636b0aa1f39919f0ffd05c968015450075`.
- Neither a V4 production app nor extension was built or installed. No production
  PR, second evidence branch/PR, status update, or source-owner change was created.

Tools: repository/source/manual inspection; `git fetch`, `rev-parse`, `status`,
`diff --exit-code`, `diff --cached --exit-code`, `diff --check`, and worktree
inventory; `sw_vers`, `uname -m`, `plutil`, `codesign`, `shasum`; the accepted
packaged helper's bounded Bitwig-only window enumeration; read-only native UI
observations; a temporary authenticated loopback sink; `pgrep` and `lsof` for
teardown. No mouse automation, private API, permission reset, or security-setting
change was used.

Machine: macOS 26.4.1 build 25E253, arm64, Bitwig Studio 6.1 bundle
`com.bitwig.studio`, Xcode 26.4.1 build 17E202 / SDK 26.4. Bitwig was launched
normally with the untouched official extension. The reproduction concerns the
main-window controls and did not require a calibrated Sampler layout or a Push
receiver. A Sampler identity/parameter fixture was not established in this run.

## Exact preflight capture

The already installed, unchanged accepted V3 app was run from
`$HOME/Applications/PushwigCaptureHelper.app`, using the maintained V3 diagnostic
profile. Screen Recording permission was already granted to that app identity.

| Material | Identity / SHA-256 |
| --- | --- |
| Bundle ID | `com.kasselvania.pushwig.capture-helper` |
| Executable | `3643470c44f9f8a86b5a77d0e786e434ab9d44e1494a3c9349ac0ea837b02b8f` |
| Info.plist | `2b01780f17aedee57c9d9c0b5946de3ce612f52873f9100cd079a9839604332f` |
| CodeResources | `6686de10a28a2fe11b36cbb86dcbacc827cfc4ea116b4dabf1845e5aee629e9b` |
| Installed file-manifest hash | `0231892b6c97b528d2bab755f0cab7650a43f08c2ce18358096d9c00d555529e` |
| CDHash | `7d59fdcc7b0a30126601b89edfd3ea069effc224` (ad-hoc); strict verification passed |
| V3 diagnostic profile | `0425cb7b04b28ffecd23b711988f37b2112a84935aeb90c15d1380bbf94cc2f9` |
| Accepted WindowRelativeCapture.swift | `65cfab18a6ef06ca573dd021b845f11bb588f9ea12262f511c60c443cb4913dc` |
| Temporary Python sink source | `5f5690a9d14240da509ff5c4069cd3873e9972ad7bc69f9463c02533b7c4c077` |

The installed manifest hashes the UTF-8 output of
`find . -type f -print0 | LC_ALL=C sort -z | xargs -0 shasum -a 256`, run from
the app root (paths include `./`). It contains only the executable, plist, and
CodeResources listed above.

The sink bound an ephemeral IPv4 loopback port, created a private random
capability file, checked HELLO and sequence/session framing, consumed bounded
FRAME payloads, and counted CLEAR. It did not use MIDI, audio, USB, Bitwig's
controller API, or the DrivenByMoss listener. Its optional snapshot action was
not invoked; no captured frames were saved. Its source and capability were
temporary, not product code or committed tests.

Reproduction command shape (paths/ephemeral values sanitized):

```sh
"$HOME/Applications/PushwigCaptureHelper.app/Contents/MacOS/PushwigCaptureHelper" \
  --profile "$V4_WORKTREE/capture/macos/Profiles/bitwig-device-chain.json" \
  --port "$PREFLIGHT_PORT" --token-file "$PREFLIGHT_CAPABILITY_FILE"
```

Exactly one eligible Bitwig window was selected: window ID `1098`, generation
`1`, dimensions `2087x1085` points, `pointPixelScale=2`. The accepted helper used
bounded full-window output `2560x1330` pixels, source stride `10240`, diagnostic
crop `(0.14,0.68,0.45,0.305)`, helper-local effective pixel crop
`(358.4,942.653571,1152,329.142857)`, and destination `(400,0,560,160)`.
These are reproduction facts, **not an accepted tight V4 Sampler profile**.

## Window-control result and public configuration boundary

1. Before capture, read-only UI observation showed the normal window buttons.
2. During the exact app's capture, the purple macOS sharing badge occupied that
   button area. The accessibility tree still listed close, minimize, and
   full-screen elements; that alone did not prove human usability.
3. The maintainer was asked whether hovering around that area exposed usable
   minimize/full-screen controls. Direct answer: **"no, I cannot acces the normal
   minimize and full screen controls while that is there."**
4. The helper was stopped normally. A subsequent read-only UI observation showed
   the badge gone and the ordinary buttons visible again. Post-stop physical
   clicking was not repeated or inferred from the accessibility tree.

The accepted single-window path already sets `showsCursor=false`,
`showMouseClicks=false`, and `includeChildWindows=false`, and never opts into
`SCContentSharingPicker`. These controls are not a solution for the observed
window-button obstruction. Source:
[WindowRelativeCapture.swift at the accepted basis](https://github.com/kasselvania/standalone-BitWig-push/blob/d295dab73d082fe3dfdf53e9d61987b50f4257d7/capture/macos/Sources/PushwigCaptureHelper/WindowRelativeCapture.swift#L120).

Inspection of the installed public SDK distinguished these mechanisms:

- `showsCursor`: cursor pixels in the stream.
- `showMouseClicks`: click-circle pixels, independently controlled.
- `includeChildWindows`: child-window inclusion, documented for display-bound
  window/application sharing; not authority to suppress Bitwig-drawn hover state.
- `SCContentSharingPicker.active`: opting into the content-selection picker UI;
  the accepted helper does not activate it.
- `presenterOverlayPrivacyAlertSetting`: the presenter-overlay privacy alert,
  not a switch for the window sharing badge.
- `includeMenuBar`: no effect for the desktop-independent-window filter.

Inspected SDK header SHA-256 values: `SCStream.h`
`025ce72289d842191571495dfc98ba1f5fec0c00b77ed598ab7cc765a649e9aa`;
`SCContentSharingPicker.h`
`a4b9c438703b9e5b2029c54758a3c3e0c7b762f46731d5e0f1330ee8244fd684`.
No inspected public control established a way to preserve these Bitwig buttons
while keeping the accepted window-stream architecture. No unsupported system
modification or architectural substitution was attempted.

Ordinary OS-cursor exclusion is configured, but pointer/hover/tooltip acceptance
on a tight Sampler visual is **NOT TESTED**. Bitwig-rendered hover state and
tooltip/popover content must not be conflated with the system sharing badge or
declared solved by `showsCursor=false`.

## Stop, teardown, and bounded claims

The normal helper stop completed with exit code `0`, `6097` frames consumed by
the local sink, `1` CLEAR, and a closed connection. Helper counters reported one
capture generation, no stream/protocol failure, no frame after authority loss,
and one delivered idle sample. These are operational preflight observations,
not V4 page-performance or physical Push acceptance. The sink then exited `0`
and removed its capability. The helper process, observer, listener, and private
capability were verified absent. Temporary observer/manual-render files were
removed; no captured image or full log is committed.

The official extension file was never moved or replaced. Bitwig loaded it
normally, without Pushwig test properties.
Before and after, the canonical scanned file
`$HOME/Documents/Bitwig Studio/Extensions/DrivenByMoss.bwextension` hashes to
`98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a`;
exactly one matching artifact was found in that extension directory. Therefore
no derivative rollback was necessary. Bitwig and its audio engine remain open
in the ordinary official-extension session; no project was discarded.

No V4 code/tests, custom layout, supported identity predicate, eight-binding
snapshot, touch emphasis, context/freshness gate, layout envelope, transition
stress, performance result, or new musical-baseline acceptance is claimed.
The production V4 matrix was not reached: window-control requirements 43–44
**FAIL in preflight**, and the remaining V4 physical rows are **NOT TESTED**.
As a source-only preparation fact, the accepted `SpecificDeviceImpl.getID()`
returns an empty string; no live Sampler identity or rename test was performed.

This evidence proves the attached-desktop control gate fails for the exact
accepted helper on this fixture, and that safe teardown leaves the official
environment intact. It does not prove an OS-internal root cause, universal
failure of all public Apple capture designs, or a completed V4 experience.

**Required next decision:** establish a supported attached-mode capture policy
that preserves ordinary Bitwig window controls, or obtain an explicit reviewed
change to that product requirement/architecture. Until then, do not complete
the production Sampler page, invent a second source lane, or substitute a
keyboard/mouse-automation workaround for the failed usability gate.
