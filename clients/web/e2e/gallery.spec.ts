import { expect, test } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

// NFR-ACC-001: WCAG 2.2 AA on web. axe covers automated checks; the other tests cover reflow,
// text resize and focus visibility, which axe cannot judge.
const WCAG = ['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'wcag22aa'];

for (const scheme of ['light', 'dark'] as const) {
  test(`no axe violations in ${scheme} mode`, async ({ page }, info) => {
    await page.emulateMedia({ colorScheme: scheme });
    await page.goto('/');
    await expect(page.getByRole('heading', { name: 'Lifa design system' })).toBeVisible();
    await page.evaluate(() => document.fonts.ready);
    const results = await new AxeBuilder({ page }).withTags(WCAG).analyze();
    expect(results.violations.map((v) => `${v.id}: ${v.nodes.length} node(s) – ${v.help}`)).toEqual([]);
    await page.screenshot({ path: `test-results/screens/gallery-${info.project.name}-${scheme}.png`, fullPage: true });
  });
}

test('explicit dark theme overrides a light OS setting', async ({ page }) => {
  await page.emulateMedia({ colorScheme: 'light' });
  await page.goto('/');
  await page.getByRole('group', { name: 'Theme' }).getByLabel('Dark').check({ force: true });
  const bg = await page.evaluate(() => getComputedStyle(document.body).backgroundColor);
  expect(bg).toBe('rgb(15, 26, 21)');
});

test('content reflows at 320 px with 200% text (WCAG 1.4.4, 1.4.10)', async ({ page }) => {
  await page.setViewportSize({ width: 320, height: 800 });
  await page.goto('/');
  await page.getByRole('group', { name: 'Text size' }).getByLabel('200%').check({ force: true });
  const overflow = await page.evaluate(() => document.documentElement.scrollWidth - window.innerWidth);
  expect(overflow).toBeLessThanOrEqual(0);
  const results = await new AxeBuilder({ page }).withTags(WCAG).analyze();
  expect(results.violations.map((v) => v.id)).toEqual([]);
});

test('keyboard focus is visible (WCAG 2.4.7)', async ({ page }) => {
  await page.goto('/');
  const button = page.getByRole('button', { name: 'Start my free will' });
  await button.focus();
  await page.keyboard.press('Shift+Tab');
  await page.keyboard.press('Tab');
  await expect(button).toBeFocused();
  const outline = await button.evaluate((el) => getComputedStyle(el).outlineStyle);
  expect(outline).toBe('solid');
});

test('touch targets are at least 44 px (brief)', async ({ page }) => {
  await page.goto('/');
  const small = await page.$$eval('button, a, input[type=checkbox], .lifa-segmented label, .lifa-option', (els) =>
    els.map((el) => el.getBoundingClientRect()).filter((r) => r.width > 0 && Math.min(r.width, r.height) < 44 - 0.5)
      .map((r) => `${Math.round(r.width)}x${Math.round(r.height)}`));
  // Checkboxes are 22 px but sit inside a 44 px label row, which is the touch target.
  const rows = await page.$$eval('.lifa-check', (els) => els.map((el) => el.getBoundingClientRect().height));
  expect(rows.every((h) => h >= 44)).toBe(true);
  expect(small.filter((s) => s !== '22x22')).toEqual([]);
});

test('segmented control follows native radio keyboard behaviour', async ({ page }) => {
  await page.goto('/');
  const group = page.getByRole('group', { name: 'Ask me every' });
  await group.getByLabel('30 days').focus();
  await page.keyboard.press('ArrowRight');
  await expect(group.getByLabel('60 days')).toBeChecked();
});

test('residue total updates and blocks at 110% (AT-WIL-01 copy)', async ({ page }) => {
  await page.goto('/');
  await page.getByLabel('Share for Sipho Mokoena').fill('60');
  await page.getByLabel('Share for Lerato Mokoena').fill('50');
  await page.getByLabel('Share for Kabelo Mokoena').fill('0');
  await page.getByLabel('Share for Hope Children’s Home').fill('0');
  await expect(page.getByText('Allocations total 110%; they must total 100%')).toBeVisible();
});
