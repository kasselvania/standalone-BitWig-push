# S0 macOS reference fixture

## Status

**S0 complete.**

Automated host, software, display, artifact-provenance, and pinned-source inspection was performed on 2026-08-31 between 10:39 and 10:52 PDT. The maintainer then reported plugging in the Push 3 during the same local session. At 11:24 PDT, sanitized host inspection identified both the expected Push 3 USB device and its CoreAudio device. The maintainer reported successful controller, semantic-display, audio-device, native-device, and Expanded Device View behavior. For the simple audio result, Bitwig was configured to use Ableton Push as its audio interface and the Bitwig master output was audible from Push's headphone jack.

The Steam Deck remains the later Linux/appliance validation fixture. It was not inspected, altered, or treated as abandoned during S0.

## Evidence index

- `environment.md` — macOS, hardware class, Bitwig, display, and visible Bitwig layout.
- `push-usb-audio.md` — sanitized negative-before-connect and positive-after-connect USB/CoreAudio enumeration.
- `manual-acceptance.md` — the consolidated maintainer checklist and reported results.
- `drivenbymoss-provenance.md` — byte-identical official artifact match and exact source pin.
- `display-pipeline-trace.md` — pinned semantic-renderer-to-USB source trace.
- `v1a-handoff.md` — the narrow V1A seam and no-op design recommendation.

## Date and machine state

- Date: 2026-08-31, America/Los_Angeles.
- Repository basis: `383757894071a9ba1edf8d6a57c667e904b6e2c0`, tree `69f7756e024d3f9007d62c6f029b91fd2ef8d34c`.
- Branch: `codex/s0-macos-reference-fixture`.
- Host state: macOS 26.4.1 on an Apple-silicon MacBook Pro; Bitwig Studio 6.1 running; one online main display; Push 3 connected after the initial inspection and enumerated over USB and CoreAudio.
- DrivenByMoss state: installed artifact left unchanged at `$HOME/Documents/Bitwig Studio/Extensions/DrivenByMoss.bwextension`.

## Tools and commands used

Read-only inspection used `sw_vers`, sanitized `uname`, `system_profiler`, `shasum`, `stat`, `file`, `unzip`, `cmp`, `PlistBuddy`, `pgrep`, Git, GitHub CLI, and a read-only Computer Use capture of the existing Bitwig window. The source checkout was separate from this repository and detached at the proven tag commit. No extension was rebuilt, copied into this repository, replaced, or reinstalled.

## Sanitization

- No serial number, hardware UUID, provisioning identifier, account/license data, hostname, IP address, or unrelated profiler inventory is retained.
- Personal home-directory prefixes are written as `$HOME`.
- The Bitwig UI capture was used only for local observation. It is not committed.
- No Bitwig, Ableton, or DrivenByMoss binary is committed.
- No proprietary UI screenshot or crop is committed.

## What this evidence proves

- The inspected macOS/Bitwig/display fixture is identified without private machine identifiers.
- The installed DrivenByMoss bytes are cryptographically identified and match the official 26.4.1 distribution artifact byte-for-byte.
- The corresponding upstream tag, commit, and tree are pinned.
- The tested source contains a complete, concrete trace from semantic mode rendering to Push USB transfer.
- The narrow V1A cut is inside `Push2Display.send(IBitmap)`, immediately before delegation to `PushUsbDisplay.send(IBitmap)`.
- The connected controller has the expected Push 3 VID/PID, and its CoreAudio device exposes 16 inputs, 16 outputs, and 48 kHz operation.
- The maintainer directly reported the controller, display, audio-device, audible-output, native-device, and Expanded Device View baseline results recorded in `manual-acceptance.md`.

## What this evidence does not prove

- USB/CoreAudio enumeration does not prove Bitwig endpoint ownership or behavioral success; those claims are separately limited to the maintainer's direct observations.
- The headphone-output result does not test Push audio inputs, other output ports, latency, channel mapping, or behavior under reconnect.
- No reconnect or failure-injection test was performed.
- It does not prove an exact numeric runtime frame rate; the pinned source leaves cadence host-driven.
- It does not prove that no external process can contend for the endpoint while the hardware is connected.
- It does not implement or validate a frame pipeline, compositor, overlay, IPC path, capture helper, resolver, or pixel-anchor matcher.
