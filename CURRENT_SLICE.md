# Current Work — Repository maintenance and next product selection

## Status

V2 is accepted and merged.

Accepted V2 source merge:

```text
7d62e15c87b8224f870b1a2513f20d756d5a5f12
```

Accepted V2 evidence merge:

```text
8bb63fbdfa2c4a9a45e272c33e3d7c281178a83f
```

The project now has a maintained macOS helper that can capture a configured Bitwig display crop, map it without aspect distortion, publish opaque BGRA through the accepted external frame boundary, and show live Sampler pixels on a physical Push 3 while normal controls and audio remain operational.

## Current maintenance interval

Before the next feature slice, complete the repository cleanup tracked by:

- [#41 — branch and worktree lifecycle governance](https://github.com/kasselvania/standalone-BitWig-push/issues/41)
- [#42 — public project framing and documentation architecture](https://github.com/kasselvania/standalone-BitWig-push/issues/42)

The maintenance goal is practical:

- make README/contributor entry conventional and clear;
- keep detailed evidence without making it onboarding material;
- establish branch/worktree lifecycle rules;
- stop accumulating completed feature/evidence branches;
- distinguish committed regression tests from one-off experimental evidence.

## No active implementation slice

Do not start another micro-slice during this maintenance interval.

The next functional work should be selected as a product-shaped capability, not a chain of tiny governance proofs.

The leading next milestone is an adaptive Bitwig-window visual lens:

```text
identify the Bitwig application window
        -> express the working visual crop relative to that window
        -> survive move / resize / recreation
        -> load a saved visual profile
        -> launch through a usable configuration path
        -> current visuals on Push
```

Automatic device/panel recognition and semantic pixel anchors should be added when they materially improve that working product path, not as prerequisites to touching it.

## Stable boundaries to preserve

- DrivenByMoss owns semantic control and the sole Push display transport.
- The capture helper never owns Push USB, MIDI, or audio.
- Visual failure returns to current semantic output.
- The accepted external frame protocol and raster sink remain stable unless a real product blocker requires change.
- The fixed-layout V2 crop is a proven fixture, not a claim of automatic localization.

See `README.md`, `docs/ARCHITECTURE.md`, `docs/ROADMAP.md`, and the owning issues for current context.
