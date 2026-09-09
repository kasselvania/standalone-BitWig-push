# Sampler context lens — implementation contract

Authorized by the maintainer on 2026-09-09. This is one interaction, not a successor capture framework. Implementation is local and unqualified until the physical interaction passes.

## Result

Selecting/loading Sampler in Bitwig alone does not replace a Track/Mix screen on Push. Entering the device-parameter mode for that same native Sampler permits its verified live device image. Leaving that context immediately restores current DrivenByMoss semantics. Existing encoder bindings and all MIDI/audio ownership remain unchanged.

## Construction and runtime sequence

1. Bitwig creates the existing DrivenByMoss model and Push display. A Bitwig-native matcher identifies Sampler; object equality checks that the controller cursor and editor selection refer to the same device. A display name is not type authority.
2. Successful Push startup retains the accepted ordinary-launch ingress. Push owns the local visibility decision: exact parameter mode, supported native device, and current instance. No video producer can override that decision.
3. The producer receives current context, verifies a visible Sampler and estimates its center and extent from its own stable visual features. Physical display/window corners and normalized window percentages are not device identity or geometry.
4. The FFmpeg processing path extracts and uniformly fits that measured device rectangle. Only complete current pixels may reach the accepted ingress and sole DrivenByMoss USB writer.
5. Context changes invalidate prior visual authority. Leaving Device Parameters, selecting another device, losing the visible device, or an ambiguous match yields current semantics. A later return must not resurrect a frame from the former context.

The first unproved dependency is reliable association of the exact native Sampler cursor with the visible device and its measured center/extent. A crop rendering somewhere on Push is not a substitute for that proof. Prove this locally before installing a derivative.

## Initial supported case

One visible, editor-selected native Sampler in Bitwig's device chain. Locate the device itself and update center/extent after movement or UI reflow; refuse incomplete/ambiguous observations. This does not promise hidden-window capture, arbitrary native devices, or localization of multiple visually indistinguishable instances. System capture and per-device tracking cost are measured separately.

## Protected owners

Keep current-semantic redraw, raster sink, frame validation/storage, accepted protocol v1 and its write bounds, MIDI, audio, and Push USB writer. The missing context handoff must be explicit; a producer-side CLEAR alone cannot enforce mode switching. No installation, security-setting change, or additional foreground helper UI is a prerequisite for the local localization proof.

## Acceptance

Prove mouse selection while Track/Mix stays semantic; Device Parameters for the matched Sampler shows the real device; current controls work; measured center/extent follow supported movement and reflow; exit/mismatch/loss restore current semantics; re-entry uses only current-context pixels. Verify ordinary controls/MPE/transport/audio/headphones and exact official extension restoration after any fixture swap. Generated tests and local image analysis are not physical acceptance.
