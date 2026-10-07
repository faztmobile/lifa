// Display formatting for South African users (NFR-LOC-001). Amounts are ZAR cents from the API.
export type ValueBasis = 'declared' | 'evidenced' | 'estimated';

const whole = new Intl.NumberFormat('en-US', { maximumFractionDigits: 0 });

/** "R8,920,000", "−R2,230,000"; compact: "R8.92m", "R510k" (as in the UI reference screens). */
export function formatZar(cents: number, { compact = false }: { compact?: boolean } = {}): string {
  const rands = Math.round(cents / 100);
  const sign = rands < 0 ? '−' : '';
  const abs = Math.abs(rands);
  if (compact && abs >= 1_000_000) return `${sign}R${trim(abs / 1_000_000)}m`;
  if (compact && abs >= 1_000) return `${sign}R${trim(abs / 1_000)}k`;
  return `${sign}R${whole.format(abs)}`;
}

const trim = (n: number) => (Math.round(n * 100) / 100).toString();

const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
/** "17 Nov 2026" from an ISO date (yyyy-mm-dd), without time-zone shifts. */
export function formatDate(iso: string): string {
  const [y, m, d] = iso.split('-').map(Number);
  return `${d} ${months[m - 1]} ${y}`;
}
