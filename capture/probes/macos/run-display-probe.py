#!/usr/bin/env python3
# Copyright (c) 2026 Standalone Bitwig Push contributors
# SPDX-License-Identifier: MIT

"""Run one bounded generated-source experiment; never retain captured frames."""

import argparse
import json
import os
from pathlib import Path
import secrets
import signal
import subprocess
import sys
import time


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--helper", required=True)
    parser.add_argument("--backend", choices=["avfoundation", "screen-capture-kit"], required=True)
    parser.add_argument("--display-id", required=True)
    parser.add_argument("--width", required=True)
    parser.add_argument("--height", required=True)
    parser.add_argument("--crop", required=True)
    parser.add_argument("--guard", default="com.kasselvania.pushwig.quadrant-fixture")
    parser.add_argument("--destination", default="0,0,560,160")
    parser.add_argument("--port", type=int, default=45351)
    parser.add_argument("--seconds", type=float, default=45)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    if not 1 <= args.seconds <= 600:
        parser.error("probe duration must be 1..600 seconds")
    args.output.mkdir(mode=0o700, parents=True, exist_ok=False)
    token = args.output / "private-capability"
    with os.fdopen(os.open(token, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600), "w") as handle:
        handle.write(secrets.token_hex(32))
    sink = None
    helper = None
    readings = []
    try:
        with (args.output / "sink.log").open("w") as sink_log, (args.output / "helper.log").open("w") as helper_log:
            sink = subprocess.Popen([
                sys.executable, str(Path(__file__).with_name("v1d2-probe-sink.py")),
                "--port", str(args.port), "--token-file", str(token),
                "--frames", "100000", "--timeout", str(args.seconds + 10),
            ], stdout=sink_log, stderr=subprocess.STDOUT)
            for _ in range(100):
                if "SINK ready" in (args.output / "sink.log").read_text():
                    break
                if sink.poll() is not None:
                    raise RuntimeError("probe sink failed to start")
                time.sleep(0.02)
            else:
                raise RuntimeError("probe sink readiness deadline exceeded")
            helper = subprocess.Popen([
                args.helper, "--display-backend", args.backend,
                "--display-id", args.display_id,
                "--expected-display-width", args.width,
                "--expected-display-height", args.height,
                "--crop-normalized", args.crop, "--destination", args.destination,
                "--fps", "30", "--port", str(args.port), "--token-file", str(token),
                "--required-frontmost-bundle-id", args.guard,
            ], stdout=helper_log, stderr=subprocess.STDOUT)
            started = time.monotonic()
            while time.monotonic() - started < args.seconds and helper.poll() is None:
                stats = subprocess.run(
                    ["ps", "-p", str(helper.pid), "-o", "%cpu=,rss="],
                    capture_output=True, text=True, check=False,
                ).stdout.split()
                if len(stats) == 2:
                    threads = subprocess.run(
                        ["ps", "-M", "-p", str(helper.pid), "-o", "pid="],
                        capture_output=True, text=True, check=False,
                    ).stdout.splitlines()
                    readings.append((time.monotonic() - started, float(stats[0]), int(stats[1]), len(threads)))
                time.sleep(0.5)
            stop_start = time.monotonic()
            if helper.poll() is None:
                helper.send_signal(signal.SIGTERM)
            helper_code = helper.wait(timeout=5)
            stop_seconds = time.monotonic() - stop_start
            try:
                sink_code = sink.wait(timeout=2)
            except subprocess.TimeoutExpired:
                sink.terminate()
                sink_code = sink.wait(timeout=2)
        post_warmup = [row for row in readings if row[0] >= 5]
        cpu = sorted(row[1] for row in post_warmup)
        rss = [row[2] for row in post_warmup]
        result = {
            "backend": args.backend, "seconds": args.seconds,
            "helper_exit": helper_code, "sink_exit": sink_code,
            "stop_seconds": stop_seconds, "resource_samples_after_5s": len(cpu),
            "cpu_percent_p50": cpu[(len(cpu) - 1) // 2] if cpu else None,
            "cpu_percent_max": max(cpu) if cpu else None,
            "rss_kib_start_end_peak": [rss[0], rss[-1], max(rss)] if rss else None,
            "process_thread_count_min_max": [min(row[3] for row in post_warmup), max(row[3] for row in post_warmup)] if post_warmup else None,
        }
        (args.output / "result.json").write_text(json.dumps(result, indent=2) + "\n")
        print(json.dumps(result), flush=True)
        print((args.output / "sink.log").read_text(), flush=True)
        print((args.output / "helper.log").read_text(), flush=True)
        return 0 if helper_code == 0 and sink_code == 0 else 1
    finally:
        for process in (helper, sink):
            if process is not None and process.poll() is None:
                process.terminate()
                try:
                    process.wait(timeout=5)
                except subprocess.TimeoutExpired:
                    process.kill()
                    process.wait()
        token.unlink(missing_ok=True)


if __name__ == "__main__":
    raise SystemExit(main())
