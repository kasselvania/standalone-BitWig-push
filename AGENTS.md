# AGENTS.md — Maintainer and coding-agent rules

This file is for maintainers and coding agents executing repository work. It is not the public onboarding document. Human contributors should start with `README.md` and `CONTRIBUTING.md`.

## Authority

When instructions conflict, use this order:

1. the maintainer's current explicit instruction;
2. the owning issue / reviewed PR scope;
3. this file;
4. `CURRENT_SLICE.md` when an implementation slice is active;
5. the relevant durable architecture/design/protocol document.

Stop and surface real conflicts. Do not create additional governance layers merely to avoid making an engineering decision.

## Core invariants

- Bitwig remains the DAW/audio-engine authority.
- DrivenByMoss remains the semantic controller authority through the current architecture.
- Exactly one component owns the Push USB display endpoint in steady state.
- Visual-source work never blocks musical control or audio.
- V1D-2 remains the final bounded local raster ingress unless a concrete reviewed blocker requires change.
- The remote desktop is not the Push visual transport.
- Historical composed pixels are never restoration authority.
- Wrong or unsupported visual content is worse than semantic-only fallback.
- Platform/backend-specific source objects do not define portable device/presentation behavior.
- A backend that returns pixels but materially disrupts host application use is not product-valid for that operating mode.
- Existing good DrivenByMoss screens are preserved unless a deliberate Pushwig experience is better for that context.
- Do not redistribute proprietary Bitwig/Ableton binaries, activation material, firmware, or committed proprietary UI frame fixtures.

## Fixture versus product scope

The Mac is a development fixture. It proved the downstream Push visual path and one ScreenCaptureKit backend. It does not define the product source architecture.

V5 uses Weston/PipeWire on Linux as a reference implementation of a managed visual workspace. Weston, PipeWire, VNC/RDP, Wayland/X11, and Linux handles remain backend details rather than permanent product dependencies.

The Steam Deck remains the first named appliance fixture; V5 should avoid making SteamOS/power/Flatpak constraints part of the initial managed-workspace proof unless the maintainer explicitly selects the Deck.

## Current managed-workspace model

The current product/source architecture separates:

```text
one Bitwig session
        -> semantic/control plane -> DrivenByMoss -> Push presentation
        -> canonical managed workspace
             +-> raw frame stream -> Pushwig frame adapter -> V1D-2
             +-> full remote desktop/input -> service client
```

Remote-client size and connection state do not define canonical workspace geometry or Pushwig source identity.

Read `docs/design/managed-visual-workspace.md` and `docs/RUNTIME_STRATEGY.md` for durable vocabulary. The owning issue remains executable authority.

## Work should be product-shaped

Do not create a slice for one obvious helper call or one implementation detail.

A new implementation unit should normally deliver a user-visible capability, remove a significant product limitation, add a real runtime/backend, materially improve operation/packaging, or close a meaningful reliability gap.

Research can be narrow when the uncertainty itself blocks the next product capability.

V5 is one product-shaped source/runtime milestone. Do not split Weston setup, PipeWire capture, the Linux adapter, remote desktop, or fixture evidence into separate implementation slices unless a real blocker forces one component to be isolated.

## Tests and evidence

Use committed regression tests for stable deterministic contracts whenever practical.

Temporary harnesses are appropriate for native instrumentation, exploratory compositor/backend diagnosis, destructive fixture work, or performance measurement. Graduate stable behavior into repository tests when practical.

Use one concise evidence file for V5 unless a second file is genuinely needed.

See `docs/TESTING.md`.

## Branch and worktree lifecycle

Follow `docs/BRANCH_AND_WORKTREE_POLICY.md`.

Key rules:

- branches are temporary review transport;
- durable authority is merged history, docs, issues/PRs, and retained evidence;
- use role-oriented or component-oriented names;
- research stays local by default;
- merged branches are cleanup-eligible immediately;
- quarantines require an issue, exact SHA, owner, reason, and expiry;
- worktrees are not archives.

Before deleting a worktree, verify it is clean and contains no unpushed/unique work. Never use blind `git clean`, `reset --hard`, or bulk deletion as a cleanup shortcut.

## PR discipline

- One PR should have one primary product/maintenance claim.
- V5 uses one central implementation PR unless a real source-ownership boundary appears.
- No separate authority or evidence PR.
- Production source PRs normally use a true merge commit when preserving the exact reviewed source head is useful.
- Rebase merge is not used for governed work.
- Keep fixture evidence proportional to the claim.

## Current project state

Accepted foundations include:

- semantic restoration;
- validated opaque-BGRA raster sink;
- authenticated bounded external latest-frame ingress;
- real pixels on physical Push with controls/audio preserved;
- macOS window-relative capture and helper-local crop/scale as an engineering proof;
- a native-device behavior catalog and device-aware presentation design model.

V4 / issue #49 is blocked because the current macOS primary-window ScreenCaptureKit source is not acceptable for ordinary attached use.

**V5 / issue #50 is active.** It proves one managed Linux Bitwig workspace with canonical geometry, raw PipeWire frames, a committed Pushwig Linux frame adapter, an independent full remote-desktop path, and actual frames through unchanged V1D-2.

Do not resume the Sampler page, anchors, Browser redesign, gamescope/Steam Deck packaging, XDG portal attached capture, or Mac replacement capture inside V5.

## Final report expectations

Report:

- issue/PR;
- actual host/runtime basis;
- branch/base/head/tree;
- exact changed paths;
- Weston/backend configuration and canonical geometry;
- PipeWire source identity and negotiated format;
- frame-adapter tests/performance;
- remote-desktop path and authentication/bind posture;
- remote resize/disconnect/reconnect results;
- Bitwig/control/audio result;
- V1D-2/Push result when hardware is available;
- failure/restart/shutdown behavior;
- important limitations;
- worktree cleanliness and cleanup eligibility.

Do not turn the report into a command transcript or restate all governance.
