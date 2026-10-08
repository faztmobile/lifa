// Captures the prototype screens (src/prototypes) at 390 × 844, 3× density, into docs/design/screens/prototypes.
// Run with the dev server up: `npx vite --port 4180 --strictPort`, then `node scripts/capture-prototypes.mjs`.
import { chromium } from '@playwright/test';
import { fileURLToPath } from 'node:url';
import { mkdirSync } from 'node:fs';

const out = fileURLToPath(new URL('../../../docs/design/screens/prototypes/', import.meta.url));
const ids = ['signup', 'home', 'will', 'assets', 'vault', 'emergency', 'checkin', 'activation', 'executor', 'plans'];
mkdirSync(out, { recursive: true });
const browser = await chromium.launch();
const page = await browser.newPage({ viewport: { width: 390, height: 844 }, deviceScaleFactor: 3, colorScheme: 'light', isMobile: true, hasTouch: true });
let failed = false;
for (const [i, id] of ids.entries()) {
  await page.goto(`http://localhost:4180/prototypes.html?screen=${id}`);
  await page.evaluate(() => document.fonts.ready);
  const overflow = await page.evaluate(() => { const m = document.querySelector('.proto__body'); return m ? m.scrollHeight - m.clientHeight : 0; });
  if (overflow > 0) { console.error(`${id}: content overflows the phone by ${overflow}px`); failed = true; }
  await page.screenshot({ path: `${out}${String(i + 1).padStart(2, '0')}-${id}.png` });
}
await browser.close();
process.exit(failed ? 1 : 0);
