// Presentation geometry only. This does NOT identify a device or assign a remote to a marker.
// Top-left image pixels -> one uniformly fitted image -> top-left 960x160 display pixels.
export const SCREEN = Object.freeze({ width: 960, height: 160 });

export function validRect(r) {
  return r && [r.x, r.y, r.width, r.height].every(Number.isFinite)
    && r.x >= 0 && r.y >= 0 && r.width > 0 && r.height > 0;
}

export function contains(outer, inner) {
  return validRect(outer) && validRect(inner)
    && inner.x >= outer.x && inner.y >= outer.y
    && inner.x + inner.width <= outer.x + outer.width
    && inner.y + inner.height <= outer.y + outer.height;
}

// The caller supplies an observed device rectangle, NOT a remembered window percentage.
// One scale is also used for marker positions: never independently fit annotations.
export function fit(source, viewport) {
  if (!validRect(source) || !contains({ x: 0, y: 0, ...SCREEN }, viewport)) return null;
  const scale = Math.min(viewport.width / source.width, viewport.height / source.height);
  const width = source.width * scale, height = source.height * scale;
  if (![scale, width, height].every(Number.isFinite) || scale <= 0) return null;
  return Object.freeze({ source: { ...source }, scale,
    x: viewport.x + (viewport.width - width) / 2,
    y: viewport.y + viewport.height - height, width, height });
}

export function projectRegion(mapping, region) {
  if (!mapping || !contains(mapping.source, region)) return null;
  return {
    x: mapping.x + (region.x - mapping.source.x) * mapping.scale,
    y: mapping.y + (region.y - mapping.source.y) * mapping.scale,
    width: region.width * mapping.scale, height: region.height * mapping.scale,
  };
}

// Conservative offline annotation rule: source and association must belong to this exact
// observation. A matching alias, value, RGB color, or waiting period is not a substitute.
// These IDs are supplied by the GENERATED fixture, not inferred live Bitwig revisions.
export function associatedRegion(observation, association, slot) {
  if (!observation || !association || observation.status !== 'verified'
      || !Number.isSafeInteger(slot) || slot < 0 || slot > 7
      || typeof observation.id !== 'string' || !observation.id
      || typeof observation.bindingRevision !== 'string' || !observation.bindingRevision
      || observation.id !== association.observationId
      || observation.bindingRevision !== association.bindingRevision
      || association.slot !== slot || association.candidates?.length !== 1) return null;
  const candidate = association.candidates[0];
  return contains(observation.source, candidate) ? { ...candidate } : null;
}
