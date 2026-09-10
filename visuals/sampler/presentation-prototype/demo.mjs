// Throwaway, in-memory UI exercise. No controller API or source acquisition exists here.
import { COLORS, makeSchematic, renderScreen } from './presentation.mjs';
import { initialFixture, observeFixture, reassignFixture, settleFixture } from './fixture.mjs';

const $ = id => document.getElementById(id);
const ctx = $('screen').getContext('2d');
const sourceImage = document.createElement('canvas');
const variantNames = { A: 'A · Four values on each side', B: 'B · All eight values in one list' };
let variant = new URL(location.href).searchParams.get('variant') === 'B' ? 'B' : 'A';
let state, timer, scenario = 0;
let lastResult;

function reset() {
  clearTimeout(timer); scenario++;
  state = initialFixture();
  $('mode').value = state.mode; $('slot').value = '0'; supplyObservation();
}

function supplyObservation() {
  observeFixture(state);
  makeSchematic(sourceImage, state.observation.source); render();
}

function render(message = '') {
  lastResult = renderScreen(ctx, state, variant, sourceImage);
  document.querySelectorAll('.knob').forEach((button, i) => button.setAttribute('aria-pressed', String(state.touched.has(i))));
  document.querySelectorAll('.led-button').forEach((button, i) => {
    button.title = `${state.actions[i].label} — simulated device action, not remote ${i + 1}`;
    button.setAttribute('aria-pressed', String(state.actions[i].active));
  });
  $('settle').disabled = !state.pending;
  $('increase').disabled = $('decrease').disabled = state.pending;
  $('variant-label').textContent = variantNames[variant];
  $('design-description').textContent = variant === 'A'
    ? 'Four permanent readouts on each side. Device action words stay aligned with the buttons; device/page navigation remains along the bottom. Touch adds emphasis without hiding any value or moving the image.'
    : 'All eight permanent readouts in one left-hand list. The device sits to the right; action and navigation rows stay in place. Compare the smaller text and longer eye movement against A.';
  $('state').textContent = JSON.stringify({ input: 'GENERATED ONLY — NOT LIVE AUTHORITY', variant, mode: state.mode,
    rawTouches: [...state.touched].map(i => i + 1), pendingBinding: state.pending, sourceAvailable: state.sourceAvailable,
    actions: state.actions, showDevices: state.showDevices,
    observation: state.observation, render: lastResult, slots: state.slots.map(({ alias, target, value }, i) => ({ slot: i + 1, alias, target, value })) }, null, 2);
  $('screen').dataset.showImage = String(lastResult.showImage);
  $('screen').dataset.annotations = String(lastResult.decisions.filter(x => x.projected).length);
  if (message) $('result').textContent = message;
}

for (let i = 0; i < 8; i++) {
  const button = document.createElement('button'); button.className = 'knob';
  button.setAttribute('aria-label', `Touch encoder ${i + 1}`); button.setAttribute('aria-pressed', 'false');
  button.innerHTML = `<span></span><small>${i + 1}</small>`;
  button.addEventListener('pointerdown', e => { button.setPointerCapture(e.pointerId); state.touched.add(i); render(); });
  for (const event of ['pointerup', 'pointercancel', 'lostpointercapture']) {
    button.addEventListener(event, () => { state.touched.delete(i); render(); });
  }
  // Enter/Space supplies a latched touch for mouse/keyboard accessibility and multitouch comparison.
  button.addEventListener('click', e => { if (e.detail === 0) { state.touched.has(i) ? state.touched.delete(i) : state.touched.add(i); render(); } });
  $('hardware').append(button);
  const action = document.createElement('button'); action.className = 'led-button';
  action.style.setProperty('--slot-color', COLORS[i]);
  action.setAttribute('aria-label', `Simulate upper button ${i + 1}: ${initialFixture().actions[i].label}`);
  action.onclick = () => {
    if (i === 3) state.mode = state.mode === 'DEVICE_CHAINS' ? 'DEVICE_PARAMS' : 'DEVICE_CHAINS';
    else if (i === 4) { state.mode = 'DEVICE_PARAMS'; state.showDevices = !state.showDevices; }
    else if (i === 7) {
      if (!state.showDevices) state.showDevices = true;
      else state.mode = 'VOLUME';
    } else state.actions[i].active = !state.actions[i].active;
    state.actions[3].active = state.mode === 'DEVICE_CHAINS';
    state.actions[4].active = !state.showDevices && state.mode === 'DEVICE_PARAMS';
    $('mode').value = state.mode;
    render(`Simulated ${state.actions[i].label} button. No Bitwig action was sent. The LED's slot color is separate from this button's function.`);
  };
  $('action-hardware').append(action);
  const option = document.createElement('option'); option.value = i; option.textContent = `Knob ${i + 1}`; $('slot').append(option);
}

function cycle() {
  variant = variant === 'A' ? 'B' : 'A'; const url = new URL(location.href);
  url.searchParams.set('variant', variant); history.replaceState(null, '', url); render();
}
$('previous').onclick = $('next').onclick = cycle;
document.addEventListener('keydown', e => {
  if (e.target.matches('input, select, textarea, [contenteditable]')) return;
  if (e.key === 'ArrowLeft' || e.key === 'ArrowRight') { e.preventDefault(); cycle(); }
  if (/^[1-8]$/.test(e.key) && !e.repeat) { state.touched.add(Number(e.key) - 1); render(); }
});
document.addEventListener('keyup', e => { if (/^[1-8]$/.test(e.key)) { state.touched.delete(Number(e.key) - 1); render(); } });
function release() { state.touched.clear(); render(); }
window.addEventListener('blur', release);
document.addEventListener('visibilitychange', () => { if (document.hidden) release(); });
$('release').onclick = release;
$('reset').onclick = reset;
$('mode').onchange = () => {
  state.mode = $('mode').value;
  state.actions[3].active = state.mode === 'DEVICE_CHAINS';
  render('Context changed; touch is not treated as a binding.');
};

function editValue(direction) {
  if (state.pending) return;
  const slot = state.slots[Number($('slot').value)];
  slot.number += direction * slot.step; slot.normalized = Math.max(0, Math.min(1, slot.normalized + direction * .01));
  slot.value = `${slot.number.toFixed(slot.suffix === 'st' ? 2 : 1)} ${slot.suffix}`;
  render('Generated value update. No parameter or MIDI message was sent.');
}
$('decrease').onclick = () => editValue(-1); $('increase').onclick = () => editValue(1);
$('reassign').onclick = () => {
  reassignFixture(state);
  render('Old alias/location is not reused. Only explicit replacement fixture data can resolve this demo.');
};
$('settle').onclick = () => {
  settleFixture(state); makeSchematic(sourceImage, state.observation.source); render();
};
$('lost').onclick = () => { state.sourceAvailable = false; state.observation = null; state.associations = {}; render('Source unavailable: no image and no surviving marker.'); };
$('reacquire').onclick = supplyObservation;
$('ambiguous').onclick = () => {
  const a = state.associations[Number($('slot').value)];
  if (a) a.candidates.push({ ...a.candidates[0], x: a.candidates[0].x + 30 });
  render('Multiple possible markers: value remains readable, graphical association is withheld.');
};
$('move').onclick = () => { state.moved = !state.moved; supplyObservation(); render('Generated translation + uniform resize: same projected image and marker position. Not a live tracker test.'); };
$('old').onclick = () => {
  if (state.associations[0]) state.associations[0].observationId = 'old-fixture-observation';
  render('Old observation cannot supply a current highlight.');
};
$('download').onclick = () => {
  const a = document.createElement('a'); a.download = `generated-sampler-layout-${variant}.png`;
  a.href = $('screen').toDataURL('image/png'); a.click();
};
$('demo').onclick = () => {
  reset(); const current = scenario;
  const steps = [
    () => { state.touched.add(0); render('1. Touch: current value and marker, no value change.'); },
    () => editValue(1),
    () => { state.touched.add(1); render('2. Two touches: stable image, both numbered markers.'); },
    () => { $('reassign').click(); },
    () => { $('settle').click(); render('3. Same alias, different target; fixture association replaced.'); },
    () => { state.mode = 'VOLUME'; $('mode').value = state.mode; render('4. Track/Mix: no device image.'); },
    () => { state.mode = 'DEVICE_PARAMS'; $('mode').value = state.mode; release(); render('5. Restored context.'); },
  ];
  function next() { if (scenario !== current || !steps.length) return; steps.shift()(); timer = setTimeout(next, 1400); }
  next();
};
reset();
