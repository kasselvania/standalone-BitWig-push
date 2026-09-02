## Summary

What changes for a user, contributor, or maintainer?

## Issue / branch role

- Issue:
- Branch role: source / evidence / documentation / authority / research
- Base:
- Cleanup event after merge:

## Scope

What changed? What important adjacent work is intentionally not included?

## Ownership / failure behavior

If this crosses a controller, capture, frame, protocol, or hardware boundary, what owns what and what happens when it fails?

## Testing

Committed tests run:

```text
commands / results
```

Temporary harnesses used (if any) and why they remain temporary:

```text
none / details
```

Real Push / Bitwig / hardware checks required by this claim:

```text
none / concise result
```

## Evidence

Link any retained evidence that cannot be represented by committed tests. Do not duplicate implementation prose just to create an evidence section.

## Third-party / licensing impact

Does this change patch, copy, vendor, or depend on third-party code? If yes, state the upstream project/revision and license implications.

## Checklist

- [ ] The PR has one primary product/maintenance claim.
- [ ] Stable deterministic behavior is covered by committed tests where practical.
- [ ] Real-device claims have enough evidence to distinguish observation from assumption.
- [ ] No credentials, capability tokens, activation data, serial numbers, private network details, or proprietary binaries are committed.
- [ ] Visual work does not make musical control/audio wait on capture/render/network work.
- [ ] Branch/worktree cleanup eligibility is stated.
- [ ] Maintainer/agent-governed work follows `AGENTS.md` and `CURRENT_SLICE.md` when applicable.
