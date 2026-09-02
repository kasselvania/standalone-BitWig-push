# Protocol and security

## Date, state, and authority

- Date: 2026-09-01 PDT.
- Machine state: accepted macOS 26.4.1 arm64 fixture; protocol bound only to
  local IPv4 loopback during the experiment; Bitwig closed after rollback.
- Central basis/tree:
  `fe8216fcadc9879bafa96acbb0f064f1d6625f4b` /
  `580786862a6f034aa111b60c4d434e64c44c7211`.
- DrivenByMoss basis/tree:
  `663d719207ef58ec84b4d235c43211ec5da43605` /
  `c4e42825d069421a44b3241349de9a7c6453a3ad`.
- Source PR/head/tree:
  <https://github.com/kasselvania/DrivenByMoss/pull/5> /
  `830b778b720a06f56de08861d27052228c82c63b` /
  `c8bc3f9e052e8f0b7b5dd256657697349d303740`.
- Harness/producer/observer SHA-256:
  `007822786260f89a9c3d005b669162389843a4dad2fb3293c6c131762c32bd18` /
  `993cb0f4d14c0a909a629ac4063e6e1937cb50ca42075e9fbbd3f099253bacbb` /
  `2e6ff0f6e2236e0b6ad85a831ba3f8c18f3362263eeaba425749fb4cbf929eb4`.

## Endpoint and construction properties

- Transport: one TCP byte stream.
- Bind address: explicit IPv4 `127.0.0.1`; no wildcard/name-derived bind.
- Default port: `45291`; accepted range `1024..65535`.
- Listen backlog: `1`.
- Address reuse: set before bind.
- Stale timeout: default `1500` ms; accepted range `100..10000` ms.
- Activation and configuration are construction-only properties. There is no
  user setting or runtime polling.

A second active listener was rejected while the first continued to work. Each
normal shutdown allowed immediate same-port rebind.

## Capability-file contract

When external ingress is requested, the token-file property must be present and
nonblank. The loader:

1. resolves with no-follow semantics;
2. requires a regular file rather than a directory, symlink, device, or socket;
3. accepts a 64..128-byte regular file and rejects it outside that mandatory
   input-size cap before parsing;
4. requires the first 64 bytes to be ASCII hexadecimal capability characters;
   the remaining 0..64 bytes may contain only ASCII whitespace;
5. decodes exactly 32 bytes without constructing an immutable token string;
6. rejects any POSIX group/other permission bit, making `0600` the accepted
   mode;
7. checks current owner when the platform exposes owner identity;
8. zeroes temporary content bytes after parsing and the retained decoded token
   at receiver shutdown.

The token value was never printed, committed, placed directly in a command
argument/environment value, or retained in evidence. Only its private file
path, loopback port, and timeout were passed to Bitwig. The temporary live
capability file was removed during rollback.

“Optional trailing whitespace” is therefore size-bounded by the mandatory
128-byte input cap; it does not mean an unlimited token file. This clarification
records the existing production contract and resolves wording ambiguity only.
It changes neither source nor authority and does not increase the cap.

## Configuration matrix

The final Java harness produced `21_REJECTED_3_ACCEPTED`:

- rejected: null path, blank path, missing file, directory, symlink;
- rejected: group-readable, group-writable, other-readable, other-writable;
- rejected: short content, invalid hex, odd nonwhitespace content, long
  nonwhitespace content, oversized 129-byte file;
- rejected: low/high/non-numeric port and low/high/non-numeric timeout;
- accepted: valid regular `0600` file, bounded trailing ASCII whitespace, and
  immediate same-port rebind;
- active-listener collision: rejected, with no second receiver thread.

For every rejected construction, no receiver started, one bounded error was
observed by the harness, no token value appeared, and lower visual diagnostics
were not selected. Owner mismatch could not be represented deterministically
as the current unprivileged owner on this fixture; the source and bytecode owner
check were inspected, so this one negative case remains source-proven rather
than runtime-induced.

## Protocol version 1

All multibyte fields use network byte order. Header size is exactly 80 bytes.

| Offset | Width | Field | Rule |
| ---: | ---: | --- | --- |
| 0 | 4 | magic | `0x50575852` |
| 4 | 2 | version | `1` |
| 6 | 2 | header length | `80` |
| 8 | 4 | message type | `1=HELLO`, `2=FRAME`, `3=CLEAR` |
| 12 | 4 | flags/reserved | zero |
| 16 | 4 | format | `0=NONE`, `1=OPAQUE_BGRA8888` |
| 20 | 4 | reserved | zero |
| 24 | 8 | session high | opaque half |
| 32 | 8 | session low | opaque half |
| 40 | 8 | sequence | signed positive for FRAME/CLEAR |
| 48 | 4 | destination x | nonnegative FRAME coordinate |
| 52 | 4 | destination y | nonnegative FRAME coordinate |
| 56 | 4 | width | positive FRAME width |
| 60 | 4 | height | positive FRAME height |
| 64 | 4 | source stride | at least `width*4` |
| 68 | 4 | payload length | exact validated length |
| 72 | 8 | reserved | zero |

Maximum payload is 614,400 bytes and maximum total message is 614,480 bytes.
The receiver uses one fixed 80-byte header and manual big-endian parsing; no
per-message parser or untrusted-length `ByteBuffer`/array is constructed.

### HELLO

HELLO requires `NONE`, a nonzero 128-bit session, zero sequence/geometry, and a
32-byte payload exactly matching the capability. The comparison examines all
32 bytes without early return. FRAME/CLEAR before authentication and a second
HELLO on the same connection are invalid.

### FRAME

FRAME requires the authenticated session, a positive strictly increasing
sequence, `OPAQUE_BGRA8888`, a nonnegative destination rectangle within
`960x160`, positive dimensions, stride at least `width*4`, and exact
overflow-safe payload length `(height-1)*stride + width*4`. Every copied alpha
byte must be `0xFF`; padding bytes are not pixels. Protocol v1 performs no
scaling, cropping, filtering, blending, premultiplication, compression,
producer-clock use, or color conversion.

### CLEAR

CLEAR requires the authenticated session, the next positive sequence, `NONE`,
and zero geometry/stride/payload. It revokes current external authority while
keeping the authenticated connection open.

## Complete-message rule

Publication changes only after the full fixed header; common,
authentication/session/sequence checks; overflow-safe metadata checks; the
entire bounded payload; opaque-alpha validation; and local monotonic receipt
time all succeed. EOF, close, shutdown, or interruption mid-header/payload
publishes nothing. A slow complete frame appears atomically only after its last
validated byte.

The Python producer exercised valid small, odd-padded, medium, full, moving,
replacement, 1/15/30/60 fps, burst, gap, duplicate, lower, exhaustion, reset,
CLEAR, failure, partial, slow, and reconnect cases using only Python 3.14.5
standard-library facilities.

## Commands and tools

Evidence used source/bytecode inspection, the Java conformance harness, the
Python producer, byte-at-a-time/truncated socket sends, exact loopback listener
readback, filesystem type/mode/owner inspection, active collision and immediate
rebind probes, and narrow construction-time error capture.

## Exact result

The endpoint, capability loader, complete-message parser, and language-neutral
wire contract passed all deterministically representable configuration,
authentication, valid-message, malformed, truncated, slow, collision, and
rebind cases. Harness counters included 7 authentication rejects, 11 malformed
rejects, one truncated header, and one truncated payload; no rejected/partial
message became visible.

## What this proves

- Protocol v1 is bounded before payload read and publishes only complete,
  authenticated, validated opaque BGRA regions.
- Invalid configuration fails closed to ordinary semantics without a thread or
  diagnostic fallthrough.
- A producer in another language can implement the exact protocol without Java
  serialization.

## What this does not prove

- Capability possession is not OS process identity and does not defend against
  a same-user process able to read the private file.
- The protocol is not remote, encrypted, multi-producer, compressed, alpha
  blended, scaled, or a promised public adapter API.
- Owner mismatch remains inspected source/bytecode evidence rather than a
  deterministically induced runtime case on this Mac.
