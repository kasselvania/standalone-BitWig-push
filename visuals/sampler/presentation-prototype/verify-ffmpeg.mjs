#!/usr/bin/env node
// Generated pixels only. Uses actual FFmpeg crop/scale/pad/format, no capture device or socket.
// This confirms coordinates/format, NOT throughput or live context authorization.
import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { createHash } from 'node:crypto';
import { fit, projectRegion } from './geometry.mjs';

const width = 1400, height = 500;
const source = { x: 90, y: 82, width: 1200, height: 300 };
const marker = { x: source.x + 156, y: source.y + 208, width: 28, height: 28 };
const map = fit(source, { x: 210, y: 40, width: 540, height: 116 });
const pixels = Buffer.alloc(width * height * 4);
function rect(r, color) {
  for (let y = r.y; y < r.y + r.height; y++) for (let x = r.x; x < r.x + r.width; x++) {
    pixels.set(color, (y * width + x) * 4);
  }
}
rect({ x: 0, y: 0, width, height }, [255, 0, 255, 255]); // outside sentinel: must not leak
rect(source, [32, 48, 64, 255]);
rect({ x: source.x, y: source.y, width: 90, height: 60 }, [0, 255, 0, 255]);
rect(marker, [255, 0, 0, 255]);
const outputWidth = Math.round(map.width), outputHeight = Math.round(map.height);
const graph = `crop=${source.width}:${source.height}:${source.x}:${source.y}:exact=1,`
  + `scale=${outputWidth}:${outputHeight}:flags=neighbor,`
  + `pad=960:160:${Math.round(map.x)}:${Math.round(map.y)}:color=black,setsar=1,format=bgra`;
const result = spawnSync('ffmpeg', ['-hide_banner', '-loglevel', 'error', '-nostdin', '-f', 'rawvideo',
  '-pixel_format', 'rgba', '-video_size', `${width}x${height}`, '-i', 'pipe:0', '-vf', graph,
  '-frames:v', '1', '-f', 'rawvideo', '-pix_fmt', 'bgra', 'pipe:1'],
{ input: pixels, maxBuffer: 4 * 1024 * 1024, timeout: 15000 });
assert.ifError(result.error);
assert.equal(result.status, 0, result.stderr?.toString());
const out = result.stdout; assert.equal(out.length, 614400);
let red = 0, sentinel = 0, badAlpha = 0, outside = 0;
let left = 960, top = 160, right = -1, bottom = -1;
for (let y = 0; y < 160; y++) for (let x = 0; x < 960; x++) {
  const [b, g, r, a] = out.subarray((y * 960 + x) * 4, (y * 960 + x) * 4 + 4);
  if (a !== 255) badAlpha++;
  if (r === 255 && g === 0 && b === 255) sentinel++;
  if (x < map.x || y < map.y || x >= map.x + map.width || y >= map.y + map.height) {
    if (r !== 0 || g !== 0 || b !== 0) outside++;
  }
  if (r === 255 && g === 0 && b === 0) { red++; left = Math.min(left, x); right = Math.max(right, x); top = Math.min(top, y); bottom = Math.max(bottom, y); }
}
const projected = projectRegion(map, marker);
assert.equal(sentinel, 0); assert.equal(badAlpha, 0); assert.equal(outside, 0); assert.ok(red > 0);
// Sampling rounds to actual output pixels. No independent annotation rescale is used.
assert.ok(Math.abs((left + right + 1) / 2 - (projected.x + projected.width / 2)) <= 1);
assert.ok(Math.abs((top + bottom + 1) / 2 - (projected.y + projected.height / 2)) <= 1);
const version = spawnSync('ffmpeg', ['-version'], { encoding: 'utf8', timeout: 5000 });
console.log(JSON.stringify({ result: 'PASS', version: version.stdout.split('\n')[0], graph,
  source, marker, projected, measuredMarker: { left, top, right, bottom, pixels: red },
  outsideSourceSentinelPixels: sentinel, outsideDestinationPixels: outside, nonOpaquePixels: badAlpha,
  outputBytes: out.length, outputSHA256: createHash('sha256').update(out).digest('hex'),
  scope: 'generated one-frame geometry/opaque-BGRA check, not live capture or performance' }, null, 2));
