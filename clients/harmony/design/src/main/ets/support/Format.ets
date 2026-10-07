// Same rules as web format.ts, Android Format.kt and iOS Format.swift.

export enum ValueBasis { Declared = 'Declared', Evidenced = 'Evidenced', Estimated = 'Estimated' }

function groupThousands(n: number): string {
  const s = Math.round(n).toString();
  let out = '';
  for (let i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 === 0) {
      out += ',';
    }
    out += s.charAt(i);
  }
  return out;
}

function trim(n: number): string {
  return (Math.round(n * 100) / 100).toString();
}

/** "R8,920,000", "−R2,230,000"; compact: "R8.92m", "R510k". */
export function formatZar(cents: number, compact: boolean = false): string {
  const rands = Math.round(cents / 100);
  const sign = rands < 0 ? '−' : '';
  const a = Math.abs(rands);
  if (compact && a >= 1000000) {
    return `${sign}R${trim(a / 1000000)}m`;
  }
  if (compact && a >= 1000) {
    return `${sign}R${trim(a / 1000)}k`;
  }
  return `${sign}R${groupThousands(a)}`;
}

const MONTHS: string[] = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

/** "17 Nov 2026" (SA date format, NFR-LOC-001). */
export function formatDate(year: number, month: number, day: number): string {
  return `${day} ${MONTHS[month - 1]} ${year}`;
}
