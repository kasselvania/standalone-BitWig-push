# Protocols and frame contracts

This document summarizes the stable internal contracts between Pushwig's visual producers and the DrivenByMoss derivative. Historical design/evidence files contain the deeper experiment records.

## Raster sink

The DrivenByMoss derivative exposes a narrow raster-writing contract to its own Push display pipeline.

Current format:

```text
OPAQUE_BGRA8888
```

Rules:

- top-to-bottom rows;
- bytes per pixel: B, G, R, A;
- copied alpha must be `0xFF`;
- source stride may include padding;
- destination region must fit the current bitmap;
- validation completes before any destination mutation;
- rejected writes change zero destination bytes;
- the write is synchronous;
- the caller retains exclusive ownership of the source bytes until return;
- no scaling, filtering, blending, or color conversion occurs inside the raster sink.

The sink applies pixels to the same logical semantic bitmap that DrivenByMoss was already going to send. It does not create a second Push display owner.

## External raster protocol v1

Visual producers publish frames to the DrivenByMoss derivative over IPv4 loopback.

```text
producer
    -> TCP 127.0.0.1
    -> authenticated complete messages
    -> fixed latest-frame publication
    -> nonblocking display adoption
    -> raster sink
```

### Transport

- IPv4 loopback only;
- default project port: `45291` (configurable);
- one active producer connection;
- one receiver thread;
- bounded fixed frame storage;
- no application FIFO of historical frames.

### Header

Protocol v1 uses an 80-byte network-byte-order header.

Important fields include:

```text
magic           0x50575852
version         1
message type    HELLO / FRAME / CLEAR
pixel format    NONE / OPAQUE_BGRA8888
session         128-bit producer session
sequence        positive strictly increasing signed-64 range
x / y
width / height
stride
payload length
```

Maximum frame payload:

```text
614400 bytes   # 960 * 160 * 4
```

Reserved fields must be zero.

### Authentication

A connection begins with one `HELLO` carrying a 32-byte capability decoded from an owner-private token file. Authentication occurs before frame authority.

The token proves possession of the capability, not operating-system process identity.

### FRAME

A frame is published only after the receiver has accepted:

- the complete header;
- authenticated session identity;
- strictly increasing sequence;
- destination geometry;
- stride and payload arithmetic;
- the complete payload;
- opaque alpha for copied pixels.

Partial/truncated/malformed data never becomes a visible frame.

### CLEAR

`CLEAR` immediately revokes external visual authority for the session while leaving the authenticated connection usable.

### Latest-frame behavior

Only the newest complete publication matters. If producers publish faster than the display adopts frames, intermediate unadopted frames are superseded rather than replayed later.

The display/composition thread never blocks on socket reads and never takes a blocking publication lock.

### Freshness and failure

Freshness is based on the receiver's local monotonic receipt time.

External visual authority is removed after conditions such as:

- no producer;
- explicit CLEAR;
- disconnect/crash;
- stale frame;
- wrong session or invalid sequence;
- malformed/truncated/oversized input;
- failed raster application;
- receiver/helper shutdown.

Fallback is always the newest current semantic DrivenByMoss display.

## Producer behavior

The maintained macOS helper:

- creates one nonzero session per connection;
- sends `HELLO` once;
- sends positive strictly increasing FRAME/CLEAR sequences;
- publishes only complete opaque-BGRA frames;
- uses bounded socket writes;
- does not maintain a replay backlog.

## Stability

These contracts are stable internal project interfaces, but protocol v1 is not yet promised as a long-term third-party public SDK. Breaking it requires an explicit compatibility/migration decision because the maintained helper and DrivenByMoss derivative already depend on it.
