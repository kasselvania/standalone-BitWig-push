#!/usr/bin/env node
// Native Canvas execution of the actual preview renderer. No browser, screenshot or live app.
// Requires @napi-rs/canvas (available in the existing Codex workspace runtime; not auto-installed).
import { createRequire } from 'node:module';
import { createHash } from 'node:crypto';
import { mkdtempSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import assert from 'node:assert/strict';
import { initialFixture, observeFixture, reassignFixture, settleFixture } from './fixture.mjs';
import { makeSchematic, renderScreen } from './presentation.mjs';
const { createCanvas } = createRequire(import.meta.url)('@napi-rs/canvas');
const output = createCanvas(960, 160), source = createCanvas(1, 1), ctx = output.getContext('2d');
const directory = mkdtempSync(join(tmpdir(), 'pushwig-sampler-render-'));
const state = initialFixture(); observeFixture(state); makeSchematic(source, state.observation.source);
const cases = [];
function draw(name, variant = 'A', retain = false) {
  const result = renderScreen(ctx, state, variant, source);
  const rgba = ctx.getImageData(0, 0, 960, 160).data;
  for (let i = 3; i < rgba.length; i += 4) assert.equal(rgba[i], 255);
  const hash = createHash('sha256').update(rgba).digest('hex');
  cases.push({ name, hash, image: result.showImage, annotations: result.decisions.filter(x => x.projected).length });
  if (retain) writeFileSync(join(directory, `${name}.png`), output.toBuffer('image/png'), { mode: 0o600, flag: 'wx' });
  return { ...result, hash };
}
const rest = draw('rest', 'A', true); assert.equal(rest.showImage, true);
const valuesBefore = JSON.stringify(state.slots);
state.touched.add(0); const touch = draw('touch-speed', 'A', true);
assert.equal(touch.decisions[0].projected !== null, true);
assert.equal(JSON.stringify(state.slots), valuesBefore, 'touch never rotates');
assert.deepEqual(touch.mapping, rest.mapping, 'touch never moves camera');
state.slots[0].value = '101 %'; const value = draw('current-value'); assert.notEqual(value.hash, touch.hash);
state.slots[0].value = '100 %'; state.touched.add(1); const multi = draw('two-touches', 'A', true);
assert.equal(multi.decisions.filter(x => x.projected).length, 2);
state.touched.clear(); state.touched.add(3); const unresolved = draw('unresolved-location', 'A', true);
assert.equal(unresolved.showImage, true); assert.equal(unresolved.decisions[0].projected, null);
state.touched.clear(); state.touched.add(0); state.associations[0].candidates.push({ ...state.associations[0].candidates[0] });
assert.equal(draw('ambiguous').decisions[0].projected, null);
observeFixture(state); state.associations[0].observationId = 'old-frame';
assert.equal(draw('old-observation').decisions[0].projected, null);
reassignFixture(state); assert.equal(draw('binding-pending', 'A', true).showImage, false);
observeFixture(state); assert.equal(draw('reacquire-cannot-resolve-binding').showImage, false);
settleFixture(state); const remap = draw('same-label-pitch', 'A', true);
assert.equal(state.slots[0].alias, 'binding probe'); assert.equal(remap.showImage, true);
assert.ok(remap.decisions[0].projected.x < touch.decisions[0].projected.x);
reassignFixture(state); settleFixture(state);
assert.equal(state.slots[0].alias, 'binding probe');
assert.equal(draw('same-label-speed').decisions[0].projected.x, touch.decisions[0].projected.x);
for (const mode of ['VOLUME', 'MASTER_TEMP', 'OTHER_DEVICE']) {
  state.mode = mode; assert.equal(draw(mode).showImage, false);
}
state.mode = 'DEVICE_PARAMS'; state.sourceAvailable = false; state.observation = null; state.associations = {};
assert.equal(draw('lost-source').showImage, false);
observeFixture(state); const reacquired = draw('reacquired'); assert.equal(reacquired.showImage, true);
state.moved = true; observeFixture(state); makeSchematic(source, state.observation.source);
const moved = draw('moved-and-resized');
assert.ok(Math.abs(moved.decisions[0].projected.x - reacquired.decisions[0].projected.x) < 1e-9);
state.touched.clear(); assert.equal(draw('release').decisions.length, 0);
assert.equal(draw('B-rest', 'B', true).showImage, true);
state.touched.add(0); assert.equal(draw('B-touch', 'B', true).showImage, true);
// Full redraw of the reusable destination removes every earlier highlight.
state.touched.clear(); const cleanRest = draw('clean-rest');
state.touched.add(0); draw('temporary-touch'); state.touched.clear();
assert.equal(draw('release-exact-restoration').hash, cleanRest.hash);
console.log(JSON.stringify({ result: 'PASS', checks: cases.length, dimensions: [960, 160],
  directory, cases, scope: 'native execution of generated presentation, not browser interaction or physical Push acceptance' }, null, 2));
