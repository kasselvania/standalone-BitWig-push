# Environment fixture

## Date

2026-08-31, inspected between 10:39 and 10:52 PDT.

## Machine state

Bitwig Studio 6.1 was already running on the maintainer's Mac. One display was online. This initial inspection occurred before the maintainer reported plugging in Push; two filtered CoreAudio passes contained no Push audio device. The initial USB command used a data-type name that is not authoritative on this macOS version, so this document makes no machine-derived claim about the earlier USB tree. A corrected positive USB result after connection is retained in `push-usb-audio.md`. An existing Bitwig project was open; project, track, device, and account content was not retained.

## Sanitized environment

### Operating system and hardware class

```text
ProductName: macOS
ProductVersion: 26.4.1
BuildVersion: 25E253

Darwin kernel: 25.4.0
Kernel build: Darwin Kernel Version 25.4.0; root:xnu-12377.101.15~1/RELEASE_ARM64_T6000
Architecture: arm64

Model Name: MacBook Pro
Model Identifier: MacBookPro18,2
Model Number: Z14V00171LL/A
Chip: Apple M1 Max
CPU cores: 10 (8 performance, 2 efficiency)
Memory: 64 GB
GPU cores: 32
```

The hostname, serial number, hardware UUID, provisioning identifier, and unrelated hardware were removed before retention.

### Bitwig Studio

```text
Application: /Applications/Bitwig Studio.app
CFBundleShortVersionString: 6.1
CFBundleVersion: 6.1
Latest launched version record: 6.1
Runtime state: running
```

No activation or license data was inspected or retained.

### Connected display fixture

`system_profiler SPDisplaysDataType`, with serial/UUID fields removed, reported one online display:

```text
Display name reported by macOS: 40C1U
Physical/backing resolution: 6860 x 2894
UI looks like: 3430 x 1447
Refresh rate: 100.00 Hz
Main display: yes
Mirroring: off
Online: yes
```

With only one online display, the arrangement is a single main, non-mirrored surface; there is no inter-display offset to retain. The physical-to-logical dimensions are 2:1 in each axis. This is fixture evidence, not a product requirement.

### Visible Bitwig window and panels

A read-only Computer Use capture of the existing Bitwig main window produced a 1522 x 768 JPEG capture extent. The tool may scale application captures, so this value is retained as the observed capture extent rather than claimed as an AppKit point size or CoreGraphics backing-pixel size.

Visible state, without retaining project content:

- the Arrange workspace was selected;
- the arranger timeline and track/clip-launcher area were visible;
- the device panel was open across the bottom;
- no native device was selected for S0 acceptance;
- no floating or undocked Expanded Device View was demonstrated;
- a display-profile name was not exposed by the accessibility tree and is therefore not claimed.

Those bullets describe only the initial read-only UI observation. The maintainer's later native-device and Expanded Device View results are retained separately in `manual-acceptance.md`.

The UI capture itself is not committed.

## Tools and commands used

```text
sw_vers
uname -a                 # hostname replaced before output retention
uname -m
system_profiler SPHardwareDataType
system_profiler SPDisplaysDataType
/usr/libexec/PlistBuddy ... Bitwig Studio.app/Contents/Info.plist
pgrep -fl Bitwig
Computer Use get_app_state(Bitwig Studio)  # read-only; screenshot not retained
```

Profiler output was filtered before retention rather than committed wholesale.

## What this evidence proves

- The operating system, kernel family/build, CPU architecture, relevant Mac class, memory, and GPU class of this fixture.
- The installed and running Bitwig Studio version/build string.
- The one-display resolution/scaling/refresh fixture and its single-display arrangement.
- The limited Bitwig panel state that was observable without altering the existing session.

## What this evidence does not prove

- It does not prove a portable monitor/layout profile.
- It does not prove an exact unscaled Bitwig window geometry because the read-only UI tool may scale its capture.
- It does not prove the selected Bitwig display-profile name.
- It does not prove Expanded Device View open/float behavior.
- It does not prove any Push control, display, USB, or audio behavior.
