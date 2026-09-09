#!/usr/bin/env python3
"""Local proof: observed center/extent -> actual FFmpeg crop/fit. No Push or live capture."""
import argparse
import hashlib
import json
import subprocess


def filter_graph(bounds):
    width, height = bounds["width"], bounds["height"]
    x = round(bounds["centerX"] - width / 2)
    y = round(bounds["centerY"] - height / 2)
    return (f"crop=w={width}:h={height}:x={x}:y={y}:exact=1,"
            "scale=w=960:h=160:force_original_aspect_ratio=decrease:flags=lanczos,"
            "pad=960:160:(ow-iw)/2:(oh-ih)/2:color=black,setsar=1,format=rgba")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--observer", required=True)
    parser.add_argument("--ffmpeg", default="ffmpeg")
    parser.add_argument("image")
    parser.add_argument("output", help="Local-only PNG; never commit captured device images")
    args = parser.parse_args()
    result = subprocess.run([args.observer, args.image], check=True, capture_output=True, text=True)
    observation = json.loads(result.stdout)
    bounds = observation["bounds"]
    graph = filter_graph(bounds)
    subprocess.run([args.ffmpeg, "-hide_banner", "-loglevel", "error", "-nostdin", "-n", "-i", args.image,
                    "-vf", graph, "-frames:v", "1", args.output], check=True)
    with open(args.output, "rb") as output:
        digest = hashlib.file_digest(output, "sha256").hexdigest()
    print(json.dumps({"bounds": bounds, "filter": graph, "outputSha256": digest,
                      "recognitionMs": observation["recognitionMs"], "boundsMs": observation["boundsMs"]}, indent=2))


if __name__ == "__main__":
    main()
