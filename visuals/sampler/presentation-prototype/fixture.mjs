// Known generated inputs for design review, NOT reconstructed atomic Bitwig snapshots.
// Epochs here are test inputs. A live source of equivalent authority is still missing.
export function initialFixture() {
  return { mode: 'DEVICE_PARAMS', page: 'Page 1', touched: new Set(), sourceAvailable: true,
    // Actual DeviceParamsMode menu words; states/capabilities here are generated, not API readback.
    actions: [
      { label: 'On', active: true }, { label: 'Parameters', active: true },
      { label: 'Expanded', active: false }, { label: 'Chains', active: false },
      { label: 'Banks', active: false }, { label: 'Pin Device', active: false },
      { label: 'Window', active: false }, { label: 'Up', active: true },
    ], showDevices: true,
    pending: false, pitch: false, moved: false, serial: 1, revision: 'fixture-binding-1',
    slots: [
      { alias: 'Speed', target: 'Speed', value: '100 %', normalized: .5, number: 100, suffix: '%', step: 1 },
      { alias: 'Pitch', target: 'Pitch Transpose', value: '0.00 st', normalized: .5, number: 0, suffix: 'st', step: .1 },
      { alias: 'Start', target: 'Play / Position Offset', value: '0.00 %', normalized: 0, number: 0, suffix: '%', step: 1 },
      { alias: 'Glide time', target: 'Glide time', value: '0.00 ms', normalized: 0, number: 0, suffix: 'ms', step: 1 },
      { alias: 'Pan', target: 'Pan', value: '0.00 %', normalized: .5, number: 0, suffix: '%', step: 1 },
      { alias: 'Vel Sens.', target: 'Velocity Sensitivity', value: '+30.0 dB', normalized: .3, number: 30, suffix: 'dB', step: .5 },
      { alias: 'Gain', target: 'Voice Gain / Drive', value: '0.0 dB', normalized: .5, number: 0, suffix: 'dB', step: .5 },
      { alias: 'Output', target: 'Output', value: '0.0 dB', normalized: .5, number: 0, suffix: 'dB', step: .5 },
    ], observation: null, associations: {} };
}

export function observeFixture(state) {
  state.sourceAvailable = true;
  const source = state.moved ? { x: 133, y: 81, width: 1500, height: 375 } : { x: 34, y: 28, width: 1200, height: 300 };
  state.observation = { id: `generated-observation-${++state.serial}`, bindingRevision: state.revision, status: 'verified', source };
  function region(x) { return { x: source.x + x * source.width / 1200, y: source.y + 208 * source.height / 300,
    width: 14 * source.width / 1200, height: 14 * source.height / 300 }; }
  const association = (slot, x) => ({ observationId: state.observation.id, bindingRevision: state.revision, slot, candidates: [region(x)] });
  state.associations = { 0: association(0, state.pitch ? 46 : 156), 1: association(1, 46) };
}

export function reassignFixture(state) {
  state.pitch = !state.pitch; state.pending = true; state.revision = `fixture-binding-${++state.serial}`;
  const slot = state.slots[0]; slot.alias = 'binding probe'; slot.target = null; slot.value = '—';
}

export function settleFixture(state) {
  state.pending = false;
  const slot = state.slots[0]; slot.target = state.pitch ? 'Pitch Transpose' : 'Speed';
  slot.number = state.pitch ? 0 : 100; slot.suffix = state.pitch ? 'st' : '%'; slot.step = state.pitch ? .1 : 1;
  slot.value = state.pitch ? '0.00 st' : '100 %'; observeFixture(state);
}
