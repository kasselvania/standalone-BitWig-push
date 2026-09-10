// Throwaway presentation renderer. No live Bitwig state, capture, transport, or production gate.
import { fit, projectRegion, associatedRegion } from './geometry.mjs';

export const COLORS = ['#f31936', '#ff7416', '#efd52b', '#87c847', '#51bdea', '#8c7bfa', '#ff4aa7', '#c6d1d9'];
const BG = '#101416', MUTED = '#a6b0b5', WHITE = '#edf2f4', ACCENT = '#9ce9cb';

function text(ctx, value, x, y, size = 12, color = WHITE, maxWidth = 116) {
  ctx.font = `${size >= 20 ? 500 : 400} ${size}px system-ui`;
  ctx.fillStyle = color; ctx.textBaseline = 'top';
  let label = String(value);
  // Ellipsis, never condensed text. Full text remains in the state panel outside the display.
  while (label.length > 1 && ctx.measureText(label).width > maxWidth) label = label.slice(0, -2) + '…';
  ctx.fillText(label, x, y);
}

function box(ctx, x, y, w, h, color) {
  ctx.fillStyle = color; ctx.fillRect(x, y, w, h);
}

function legend(ctx, slot, i, touched, tall = false) {
  const x = i * 120;
  box(ctx, x + 1, 0, 118, tall ? 160 : 35, touched ? '#233f36' : '#1c2428');
  box(ctx, x + 1, 0, 118, 2, touched ? ACCENT : '#38444b');
  text(ctx, `${i + 1} ${slot.alias}`, x + 5, 5, 12, touched ? ACCENT : MUTED, 110);
  text(ctx, slot.value, x + 5, tall ? 37 : 19, tall ? 21 : 13, WHITE, 110);
  if (tall) {
    text(ctx, slot.target ?? 'Unresolved binding', x + 5, 76, 11, MUTED, 110);
    box(ctx, x + 8, 112, 104, 3, '#364047');
    box(ctx, x + 8, 112, 104 * slot.normalized, 3, COLORS[i]);
    text(ctx, touched ? 'TOUCHED' : 'SEMANTICS', x + 5, 138, 10, MUTED, 110);
  }
}

// An intentionally schematic device surface. Generated shapes are not captured/native pixels.
// This is not a template or recognizer for Bitwig controls.
export function makeSchematic(canvas, source) {
  canvas.width = Math.ceil(source.x + source.width + 12);
  canvas.height = Math.ceil(source.y + source.height + 12);
  const ctx = canvas.getContext('2d');
  box(ctx, 0, 0, canvas.width, canvas.height, '#593253'); // outside-device sentinel
  ctx.save(); ctx.translate(source.x, source.y);
  ctx.scale(source.width / 1200, source.height / 300);
  box(ctx, 0, 0, 1200, 300, '#2e3437');
  box(ctx, 6, 6, 1188, 288, '#181f22');
  text(ctx, 'GENERATED DEVICE DIAGRAM', 24, 16, 16, MUTED, 430);
  box(ctx, 160, 45, 874, 126, '#111719');
  for (let x = 172; x < 1024; x += 4) {
    const h = 8 + Math.abs(Math.sin(x * 0.053) * Math.cos(x * 0.127)) * 91;
    box(ctx, x, 108 - h / 2, 2, h, '#c2ccc9');
  }
  box(ctx, 212, 45, 2, 126, '#e4d738');
  box(ctx, 847, 45, 2, 126, '#6abfaa');
  text(ctx, 'PLAY', 206, 173, 13, '#e4d738'); text(ctx, 'LOOP', 810, 173, 13, '#6abfaa');
  for (const [x, label] of [[40, 'Pitch'], [150, 'Speed'], [440, 'Filter'], [560, 'Res'], [700, 'A'], [795, 'D'], [890, 'S'], [985, 'R'], [1110, 'Out']]) {
    ctx.beginPath(); ctx.arc(x + 32, 239, 25, 0, Math.PI * 2);
    ctx.fillStyle = '#525c60'; ctx.fill(); ctx.strokeStyle = '#efaa68'; ctx.lineWidth = 4; ctx.stroke();
    ctx.beginPath(); ctx.moveTo(x + 32, 239); ctx.lineTo(x + 37, 219); ctx.strokeStyle = '#edf2f4'; ctx.stroke();
    text(ctx, label, x, 271, 16, WHITE, 95);
  }
  for (const [x, y, color] of [[156, 208, COLORS[0]], [46, 208, COLORS[1]]]) {
    ctx.beginPath(); ctx.moveTo(x, y); ctx.lineTo(x + 14, y); ctx.lineTo(x, y + 14);
    ctx.closePath(); ctx.fillStyle = color; ctx.fill();
  }
  text(ctx, 'Single', 24, 57, 16); text(ctx, 'Repitch', 24, 105, 16, '#93d9ec');
  text(ctx, 'Spectral', 24, 142, 16, MUTED); text(ctx, 'Cycles', 24, 179, 16, MUTED);
  text(ctx, 'NOTE', 1080, 58, 16); text(ctx, 'FX', 1090, 123, 16, MUTED);
  ctx.restore();
}

export function renderScreen(ctx, state, variant, sourceImage) {
  ctx.save(); ctx.clearRect(0, 0, 960, 160); box(ctx, 0, 0, 960, 160, BG);
  const deviceAllowed = state.mode === 'DEVICE_PARAMS' && state.observation?.status === 'verified'
    && !state.pending && state.sourceAvailable;
  const touches = [...state.touched].sort((a, b) => a - b);
  const showImage = deviceAllowed && (variant === 'A' || touches.length > 0);
  const decisions = [];
  if (!showImage) {
    state.slots.forEach((slot, i) => legend(ctx, slot, i, state.touched.has(i), true));
    const reason = !deviceAllowed ? (state.pending ? 'BINDING UNRESOLVED · NO IMAGE' : `${state.mode} · SEMANTIC FALLBACK`) : 'TOUCH AN ENCODER · DEVICE REVEAL';
    box(ctx, 0, 155, 960, 5, '#35433e');
    decisions.push(reason);
    ctx.restore(); return { showImage: false, decisions, mapping: null };
  }
  state.slots.forEach((slot, i) => legend(ctx, slot, i, state.touched.has(i)));
  const mapping = fit(state.observation.source, { x: 210, y: 40, width: 540, height: 116 });
  ctx.drawImage(sourceImage, mapping.source.x, mapping.source.y, mapping.source.width, mapping.source.height,
    mapping.x, mapping.y, mapping.width, mapping.height);
  if (!touches.length) {
    text(ctx, 'SAMPLER', 14, 54, 18, WHITE, 185);
    text(ctx, state.page, 14, 79, 12, MUTED, 185);
    text(ctx, 'Touch a knob', 760, 68, 16, ACCENT, 184);
    text(ctx, 'Number → value → location', 760, 94, 11, MUTED, 184);
  }
  for (const [n, i] of touches.entries()) {
    const slot = state.slots[i];
    const region = associatedRegion(state.observation, state.associations[i], i);
    const projected = projectRegion(mapping, region);
    decisions.push({ slot: i + 1, value: slot.value,
      location: projected ? 'controlled-fixture association' : 'unresolved: no graphical claim',
      projected });
    // Every touch remains visible in its own rail cell. Up to two enlarged side readouts;
    // additional touches never steal/retarget the first touched control or move the image.
    if (n < 2) {
      const x = n === 0 ? 14 : 760;
      text(ctx, `KNOB ${i + 1}`, x, 43, 11, ACCENT, 184);
      text(ctx, slot.target ?? slot.alias, x, 59, 17, WHITE, 184);
      text(ctx, slot.value, x, 83, 26, WHITE, 184);
      text(ctx, region ? 'Location verified in fixture' : 'Location not established', x, 126, 10, region ? ACCENT : MUTED, 184);
    }
    if (projected) {
      // Mark the observed TRIANGLE, not an invented center or size of the underlying control.
      const x = projected.x + projected.width / 2, y = projected.y + projected.height / 2;
      ctx.strokeStyle = ACCENT; ctx.lineWidth = 1.5;
      ctx.strokeRect(projected.x - 2, projected.y - 2, projected.width + 4, projected.height + 4);
      box(ctx, Math.max(mapping.x, x - 8), y - 22, 16, 16, '#dff6ec');
      text(ctx, i + 1, Math.max(mapping.x, x - 8) + 4, y - 21, 11, '#132f24', 12);
    }
  }
  ctx.restore(); return { showImage: true, decisions, mapping };
}
