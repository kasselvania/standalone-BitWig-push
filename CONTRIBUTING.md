# Contributing

Thanks for helping build Standalone Bitwig Push.

This is an experimental hardware/software project. Useful contributions include code, protocol validation, hardware measurements, documentation, test evidence, visual-design experiments and reproducible failure reports.

## Before changing code

Read, in order:

1. `AGENTS.md`
2. `CURRENT_SLICE.md`
3. `docs/ARCHITECTURE.md`
4. `docs/ROADMAP.md`

Open an issue for substantial work unless the change is an obvious documentation correction.

## Branches and pull requests

Use a focused branch from current `main`. Keep one primary claim per PR.

A good PR explains:

- what claim it proves;
- what it deliberately does not change;
- how it was tested;
- whether real Push/Bitwig hardware was involved;
- what evidence was retained;
- any upstream code/license implications.

Do not combine broad cleanup with experimental hardware or protocol changes.

## Real-device claims

If a change claims that something works on Push, retain enough evidence for another contributor to distinguish observation from assumption.

For example:

- USB/ALSA/PipeWire enumeration;
- test commands and exit status;
- device/host versions;
- frame timings;
- photographs or continuity notes;
- short manual acceptance results.

Never commit credentials, Bitwig activation data, Push serial numbers, private network details, or proprietary firmware/binaries.

## Hardware safety

Hardware modifications are performed at the contributor’s own risk.

For power work:

- measure first;
- identify ground and voltage domains;
- document source/sink direction;
- do not tie VBUS/power rails together by assumption;
- current-limit bench supplies during first power experiments where appropriate;
- battery experiments require chemistry-appropriate charging and protection.

A successful plugged-in appliance does not require battery support.

## Upstream projects

We expect to collaborate with/fork projects such as DrivenByMoss and to learn from existing Push reverse-engineering work.

Keep provenance clear:

- retain upstream copyright/license notices;
- prefer upstreamable patches where practical;
- document the exact upstream revision used for experiments;
- do not paste third-party code into original-code directories without confirming license compatibility.

## Coding style

Component-specific style will be added when implementation languages are chosen. Until then:

- prefer small observable services and explicit IPC contracts;
- add diagnostics at integration boundaries;
- avoid blocking control paths on visual work;
- make failure modes visible;
- keep experimental flags/configuration reversible.

## Compatibility

The first reference platform is Steam Deck Linux + Flatpak Bitwig + Push 3 Controller over external USB. Other Linux hosts are welcome, but new portability work must not silently break the reference path.

## Project naming

Bitwig, Ableton, Push, Steam Deck, Intel and DrivenByMoss are third-party names used descriptively. Do not imply endorsement or official compatibility.