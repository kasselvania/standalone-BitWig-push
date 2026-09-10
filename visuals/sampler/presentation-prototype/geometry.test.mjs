// Checks the coordinate/association functions actually used by the local preview.
// A supplied fixture revision is NOT proof of a real Bitwig binding revision.
import test from 'node:test';
import assert from 'node:assert/strict';
import { fit, projectRegion, associatedRegion } from './geometry.mjs';

const viewport = { x: 210, y: 40, width: 540, height: 116 };
const source = { x: 34, y: 28, width: 1200, height: 300 };
const marker = { x: 190, y: 236, width: 14, height: 14 };
const observation = { id: 'frame-A', bindingRevision: 'binding-A', status: 'verified', source };
const association = { observationId: 'frame-A', bindingRevision: 'binding-A', slot: 0, candidates: [marker] };
function near(a, b) { assert.ok(Math.abs(a - b) < 1e-9, `${a} != ${b}`); }

test('one uniform fit, bottom-centred, in declared 960x160 viewport', () => {
  for (const [width, height] of [[1200, 300], [1673, 438], [2000, 280], [600, 450]]) {
    const map = fit({ ...source, width, height }, viewport);
    near(map.width / width, map.height / height);
    near(map.x + map.width / 2, viewport.x + viewport.width / 2);
    near(map.y + map.height, viewport.y + viewport.height);
    assert.ok(map.x >= viewport.x && map.y >= viewport.y);
    assert.ok(map.width <= viewport.width && map.height <= viewport.height);
  }
});
test('translated/resized image and marker use the same transform', () => {
  const before = projectRegion(fit(source, viewport), marker);
  for (const scale of [.6, 1, 1.25, 2]) {
    const moved = { x: 181, y: 73, width: source.width * scale, height: source.height * scale };
    const movedMarker = { x: moved.x + (marker.x - source.x) * scale,
      y: moved.y + (marker.y - source.y) * scale, width: marker.width * scale, height: marker.height * scale };
    const after = projectRegion(fit(moved, viewport), movedMarker);
    for (const key of ['x', 'y', 'width', 'height']) near(after[key], before[key]);
  }
});
test('top-left orientation and no annotation outside the actual source crop', () => {
  const map = fit(source, viewport);
  const topLeft = projectRegion(map, { ...source, width: 1, height: 1 });
  near(topLeft.x, map.x); near(topLeft.y, map.y);
  for (const bad of [{ ...marker, x: source.x - 1 }, { ...marker, y: source.y - 1 },
    { ...marker, x: source.x + source.width }, { ...marker, y: source.y + source.height },
    { ...marker, width: NaN }, { ...marker, height: 0 }, null]) assert.equal(projectRegion(map, bad), null);
});
test('nonfinite or impossible source/destination refuses before drawing', () => {
  for (const bad of [null, { ...source, x: -1 }, { ...source, width: 0 }, { ...source, height: Infinity }, { ...source, y: NaN }]) {
    assert.equal(fit(bad, viewport), null);
  }
  for (const bad of [null, { ...viewport, x: -1 }, { ...viewport, width: 960 }, { ...viewport, height: 161 }, { ...viewport, y: NaN }]) {
    assert.equal(fit(source, bad), null);
  }
});
test('one explicit current association projects without inventing knob geometry', () => {
  assert.deepEqual(associatedRegion(observation, association, 0), marker);
  assert.notEqual(associatedRegion(observation, association, 0), marker);
});
test('same label cannot authorize a changed binding', () => {
  assert.equal(associatedRegion({ ...observation, bindingRevision: 'binding-B', alias: 'binding probe' },
    { ...association, alias: 'binding probe' }, 0), null);
});
test('old observation, missing identity, wrong slot, and unverified source refuse', () => {
  for (const update of [{ id: 'frame-B' }, { id: '' }, { bindingRevision: '' }, { status: 'unverified' }]) {
    assert.equal(associatedRegion({ ...observation, ...update }, association, 0), null);
  }
  for (const slot of [-1, 1, 8, NaN, .5]) assert.equal(associatedRegion(observation, association, slot), null);
  assert.equal(associatedRegion(null, association, 0), null);
  assert.equal(associatedRegion(observation, null, 0), null);
});
test('ambiguous, empty, or out-of-crop marker refuses without a nearest/color heuristic', () => {
  for (const candidates of [[], [marker, marker], [{ ...marker, x: 0 }]]) {
    assert.equal(associatedRegion(observation, { ...association, candidates }, 0), null);
  }
});
test('returned geometry does not retain mutable input rectangles', () => {
  const input = { ...source }; const map = fit(input, viewport); input.x = 999;
  assert.equal(map.source.x, source.x);
});
