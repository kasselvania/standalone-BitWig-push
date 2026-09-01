# Protocol version 1

## Date, state, and identities

- Date: 2026-09-01 PDT.
- Machine state: accepted macOS 26.4.1 arm64 fixture; local IPv4 loopback only.
- Central basis/tree: `5597624bd50e5ef95ecd3af82ea1816ce4facd21` / `ec016bd3174345e32f1a6d47eb061820e7a1e9b9`.
- DrivenByMoss basis/tree: `663d719207ef58ec84b4d235c43211ec5da43605` / `c4e42825d069421a44b3241349de9a7c6453a3ad`.
- Candidate head/tree: `4f00972355fcf7b5f0ead0fef3365b81850be12f` / `7202267e51d0f2613cea93d186b132a996ec14ec`.
- Producer SHA-256: `b19192e78ff225b85e1a6e40178939bb5e5c344bd4a9e9526696e95f095022aa`; Python `3.14.5`.

## Transport and discovery

- Transport: one TCP byte stream.
- Bind: explicit IPv4 `127.0.0.1`; never wildcard or IPv6 wildcard.
- Endpoint: construction-time configurable port, default `45291`, accepted range `1024..65535`.
- Backlog: `1`.
- One active producer: the one receiver thread accepts and handles one connection synchronously; there is no per-connection thread or application connection queue.
- Address reuse: enabled before bind so a normally closed listener can restart immediately; a second active listener remains rejected.
- Bind/configuration failure: one construction-time error, no receiver thread, ordinary semantic display remains usable; no retry/error loop.

## Authentication and local security

- One 256-bit unpredictable capability token (`32` exact bytes) authenticates the HELLO message.
- The candidate reads a private file containing 64 hexadecimal characters plus optional trailing ASCII whitespace.
- Any POSIX group/other permission bit causes startup rejection; the tested file mode was `0600`.
- Token comparison covers all 32 bytes using an accumulated XOR result.
- Authentication completes before session/frame authority is accepted.
- The token value was never logged, retained in evidence, placed in process arguments, or placed directly in environment variables. The private token-file path and port were supplied to Bitwig construction properties and to the temporary producer command.
- Token staging and loaded file bytes are zeroed after use; the receiver token array is zeroed after shutdown. The temporary token file is outside both repositories and is removed after retained hashes/results are complete.
- Wrong token/version/magic closes that connection without frame authority; the receiver returns to accept.

## Fixed header

All multibyte fields are network byte order (big-endian). The header is exactly `80` bytes.

| Offset | Width | Field | Rule |
| ---: | ---: | --- | --- |
| 0 | 4 | magic | unsigned bits `0x50575852` (`PWXR`) |
| 4 | 2 | protocol version | unsigned `1` |
| 6 | 2 | header length | unsigned `80` |
| 8 | 4 | message type | `1=HELLO`, `2=FRAME`, `3=CLEAR` |
| 12 | 4 | flags/reserved | must be `0` |
| 16 | 4 | pixel format | `0=NONE`, `1=OPAQUE_BGRA8888` |
| 20 | 4 | reserved | must be `0` |
| 24 | 8 | session high | opaque 64-bit half |
| 32 | 8 | session low | opaque 64-bit half |
| 40 | 8 | sequence | positive signed Java `long`, `1..2^63-1`; HELLO uses `0` |
| 48 | 4 | destination x | signed field, validated nonnegative for FRAME |
| 52 | 4 | destination y | signed field, validated nonnegative for FRAME |
| 56 | 4 | width | signed field, validated `>=1` for FRAME |
| 60 | 4 | height | signed field, validated `>=1` for FRAME |
| 64 | 4 | source stride | signed field, validated `>=width*4` for FRAME |
| 68 | 4 | payload length | exact validated length |
| 72 | 8 | reserved | must be `0` |

Unknown magic, version, header length, type, format, flag/reserved bit, session, or invalid arithmetic/geometry closes the session and clears its authority. Protocol v1 has no extension fields to ignore.

## Message definitions

### HELLO

- Type `1`, format `NONE`.
- Nonzero 128-bit producer session (`sessionHigh != 0 || sessionLow != 0`).
- Sequence and all geometry fields are zero.
- Payload length exactly `32`; payload is the raw capability-token bytes.
- Total message size: `112` bytes.

### FRAME

- Type `2`, format `OPAQUE_BGRA8888`.
- Same session halves as the accepted HELLO.
- Positive strictly increasing sequence.
- Source offset is implicitly zero.
- Pixels are top-to-bottom BGRA bytes; every alpha byte must equal `0xFF`.
- Destination rectangle must fit exactly within `960x160`.
- `payloadLength = (height - 1) * stride + width * 4`, with overflow-safe `long` arithmetic.
- Maximum payload: `614,400` bytes, exactly one full `960x160x4` Push frame. This deliberately narrows the leading 1 MiB cap to the largest useful uncompressed protocol-v1 frame.
- Maximum total frame message: `614,480` bytes.
- No compression, scaling, blending, resampling, producer timestamp, or color-management field exists.

### CLEAR

- Type `3`, format `NONE`.
- Same session halves and next positive sequence.
- All geometry and payload fields are zero; no payload follows.
- CLEAR invalidates the current publication immediately and does not depend on staleness.

## Complete-message and publication rule

Publication changes only after the full 80-byte header, common-header/session/sequence checks, overflow-safe geometry/length checks, the complete bounded payload, opaque-alpha scan, and local monotonic receipt timestamp all succeed. The receiver then copies the complete staging payload to fixed publication storage under one critical section.

EOF/shutdown mid-header or mid-payload publishes nothing. A slow valid sender becomes visible only after the complete payload passes validation. Partial/truncated or rejected bytes never become display-owned.

## Session, sequence, and freshness

- The HELLO carries the producer's 128-bit session identity; each accepted TCP connection also receives a local monotonically increasing generation.
- Beginning a new authenticated connection invalidates old publication/display authority before accepting its first frame.
- Within a session, sequence must be strictly increasing and positive.
- Duplicate or lower sequence closes/invalidate the session and does not refresh freshness.
- Skipped sequence is accepted and counted; it is not replayed later.
- A new authenticated session may reset sequence to `1`.
- Old-connection writes cannot publish because generation must still match the active store generation.
- Freshness authority is `System.nanoTime()` captured only after one complete frame is accepted.
- Construction-time default stale timeout: `1,500 ms`; permitted test range `100..10,000 ms`. The default admits tested 1 fps while promptly removing stopped 15/30/60 fps producers.
- There is no producer timestamp, so wall-clock skew/anomaly cannot affect authority.

## Failure disposition

Authentication/common-header/metadata/alpha/sequence failures close that connection, invalidate authenticated session authority where applicable, and return the receiver to accept. Clean close, producer crash, explicit clear, staleness, new session, writer rejection, receiver close, and shutdown all advance the authority epoch so the display falls back to a newly redrawn semantic frame.

## Commands and tools

The protocol was exercised by the deterministic Python producer, the Java correctness harness, byte-at-a-time and truncated sends, `lsof` loopback readback, source inspection, and bytecode disassembly. No Java serialization or Java-specific object framing was used.

## What this proves

- Protocol v1 is exact, language-neutral, bounded before payload read, and admits no partial publication.
- Session/sequence/freshness semantics are locally enforceable without trusting producer clocks.
- The authentication posture prevents accidental local injection by a process without the private token.

## What this does not prove

- The capability is not an OS identity proof and does not defend a same-user process able to read the private token file or inspect the process's filesystem access.
- This does not define a stable public protocol commitment, encryption, remote transport, producer discovery service, alpha/compression/scaling, or multi-producer arbitration.
