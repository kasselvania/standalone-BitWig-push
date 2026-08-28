## Claim

What single project claim does this PR prove or improve?

## Scope

What is changed?

## Explicit non-goals

What adjacent work is intentionally not included?

## Validation

Describe tests performed, including real Push/Bitwig hardware where relevant.

## Evidence

Link retained evidence, logs, measurements, screenshots/photos, or explain why none is required.

## Upstream / licensing impact

Does this change copy, patch, fork, vendor, or depend on third-party code? If yes, name the exact upstream revision and license implications.

## Failure / recovery behavior

For integration changes, what happens if this component crashes, disconnects, or cannot find its expected device/window?

## Checklist

- [ ] I read `AGENTS.md` and `CURRENT_SLICE.md`.
- [ ] The PR has one primary claim.
- [ ] I did not widen the current slice silently.
- [ ] Real-device claims have retained evidence where appropriate.
- [ ] No credentials, activation data, serial numbers, private network details, or proprietary binaries are committed.
- [ ] Visual work does not introduce a dependency from musical control/audio onto capture/render latency.
