#!/usr/bin/env node
// WCAG 2.2 contrast check for every pair in design/tokens/contrast-pairs.json, in light and dark (NFR-ACC-001).
// Exits 1 if any pair is below its minimum. Run by CI (design.yml) and by `npm run tokens:test`.
import { readFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import StyleDictionary from 'style-dictionary';

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), '../..');
const sd = new StyleDictionary({
  source: [join(ROOT, 'design/tokens/tokens.json')],
  usesDtcg: true,
  log: { verbosity: 'silent' },
  platforms: { raw: { transforms: [] } },
});
const t = await sd.exportPlatform('raw');
const { pairs } = JSON.parse(readFileSync(join(ROOT, 'design/tokens/contrast-pairs.json'), 'utf8'));

export function luminance(hex) {
  const h = hex.replace('#', '');
  const [r, g, b] = [0, 2, 4].map((i) => parseInt(h.slice(i, i + 2), 16) / 255)
    .map((c) => (c <= 0.03928 ? c / 12.92 : ((c + 0.055) / 1.055) ** 2.4));
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}
export function ratio(a, b) {
  const [hi, lo] = [luminance(a), luminance(b)].sort((x, y) => y - x);
  return (hi + 0.05) / (lo + 0.05);
}

let failures = 0;
const rows = [];
for (const mode of ['light', 'dark']) {
  for (const p of pairs) {
    const fg = t.color[mode][p.fg]?.$value;
    const bg = t.color[mode][p.bg]?.$value;
    if (!fg || !bg) throw new Error(`unknown token in pair ${p.fg} on ${p.bg}`);
    if (fg.length > 7 || bg.length > 7) throw new Error(`pair ${p.fg} on ${p.bg} uses a translucent colour`);
    const r = ratio(fg, bg);
    const ok = r >= p.min;
    if (!ok) failures++;
    rows.push(`${ok ? 'pass' : 'FAIL'}  ${mode.padEnd(5)}  ${r.toFixed(2).padStart(5)} ≥ ${p.min}  ${p.fg} on ${p.bg}`);
  }
}
console.log(rows.join('\n'));
console.log(`\n${rows.length - failures}/${rows.length} pairs pass`);
if (failures) process.exit(1);
