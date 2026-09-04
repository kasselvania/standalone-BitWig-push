#!/usr/bin/env python3
# Copyright (c) 2026 Standalone Bitwig Push contributors
# SPDX-License-Identifier: MIT

"""Bounded local protocol-v1 probe sink; retains hashes/counts, never frame files."""

import argparse
from collections import Counter
import hashlib
import socket
import struct
import time

HEADER = struct.Struct(">IHHIIIIQQQIIIIII8x")
MAGIC = 0x50575852


def receive_exact(connection: socket.socket, size: int) -> bytes:
    parts = bytearray()
    while len(parts) < size:
        chunk = connection.recv(size - len(parts))
        if not chunk:
            raise EOFError(f"EOF after {len(parts)} of {size} bytes")
        parts.extend(chunk)
    return bytes(parts)


def read_token(path: str) -> bytes:
    with open(path, "rb") as handle:
        text = handle.read(128)
    return bytes.fromhex(text.decode("ascii").strip())


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--port", type=int, required=True)
    parser.add_argument("--token-file", required=True)
    parser.add_argument("--frames", type=int, default=120)
    parser.add_argument("--timeout", type=float, default=30)
    args = parser.parse_args()
    capability = read_token(args.token_file)
    if len(capability) != 32:
        raise SystemExit("token must decode to 32 bytes")

    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind(("127.0.0.1", args.port))
    server.listen(1)
    server.settimeout(args.timeout)
    print(f"SINK ready port={args.port}", flush=True)
    connection, _ = server.accept()
    connection.settimeout(args.timeout)
    frames = 0
    clears = 0
    hashes: set[str] = set()
    first_pixels: set[tuple[int, int, int, int]] = set()
    started = time.monotonic()
    last_sequence = 0
    first_hash = None
    last_hash = None
    while frames < args.frames:
        try:
            raw_header = receive_exact(connection, HEADER.size)
        except EOFError:
            break
        if any(raw_header[72:]):
            raise SystemExit("nonzero reserved header tail")
        values = HEADER.unpack(raw_header)
        (magic, version, header_length, message_type, reserved, pixel_format,
         _reserved2, session_high, session_low, sequence, x, y, width, height,
         stride, payload_length) = values
        if magic != MAGIC or version != 1 or header_length != 80 or reserved or _reserved2:
            raise SystemExit("invalid protocol header")
        payload = receive_exact(connection, payload_length)
        if message_type == 1:
            if payload != capability or sequence != 0 or session_high == 0 and session_low == 0:
                raise SystemExit("invalid HELLO")
            print("SINK hello=accepted", flush=True)
            continue
        if sequence <= last_sequence:
            raise SystemExit("non-increasing sequence")
        last_sequence = sequence
        if message_type == 3:
            clears += 1
            continue
        if message_type != 2 or pixel_format != 1 or payload_length != stride * height:
            raise SystemExit("invalid FRAME")
        if len(payload[3::4]) != payload[3::4].count(255):
            raise SystemExit("nonopaque frame")
        frames += 1
        last_hash = hashlib.sha256(payload).hexdigest()
        hashes.add(last_hash)
        if first_hash is None:
            first_hash = last_hash
            colors = Counter(struct.iter_unpack("4B", payload))
            print(f"SINK_FIRST dimensions={width}x{height} stride={stride} "
                  f"sha256={first_hash} colors_top8={colors.most_common(8)}", flush=True)
        if payload:
            first_pixels.add(tuple(payload[:4]))
    elapsed = time.monotonic() - started
    print(
        f"SINK_RESULT frames={frames} clears={clears} unique_hashes={len(hashes)} "
        f"first_pixels={sorted(first_pixels)} elapsed_s={elapsed:.6f} "
        f"observed_fps={frames / elapsed:.3f} last_sequence={last_sequence}",
        flush=True,
    )
    print(f"SINK_HASH first={first_hash} last={last_hash}", flush=True)
    connection.close()
    server.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
