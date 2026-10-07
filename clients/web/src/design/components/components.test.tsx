import { describe, expect, it } from 'vitest';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { useState } from 'react';
import { BasisBadge, ProgressBar, Switch, TextField } from './index';
import { formatDate, formatZar } from '../format';

describe('format', () => {
  it('formats ZAR like the reference screens', () => {
    expect(formatZar(892_000_000)).toBe('R8,920,000');
    expect(formatZar(-223_000_000)).toBe('−R2,230,000');
    expect(formatZar(892_000_000, { compact: true })).toBe('R8.92m');
    expect(formatZar(51_000_000, { compact: true })).toBe('R510k');
  });
  it('formats SA dates without time-zone drift', () => {
    expect(formatDate('2026-11-17')).toBe('17 Nov 2026');
  });
});

describe('components', () => {
  it('TextField links label, hint and error', () => {
    render(<TextField label="Email" hint="We verify it" error="Enter an email" />);
    const input = screen.getByLabelText('Email');
    expect(input.getAttribute('aria-invalid')).toBe('true');
    expect(input.getAttribute('aria-describedby')?.split(' ')).toHaveLength(2);
  });

  it('Switch toggles aria-checked', async () => {
    function Harness() { const [on, setOn] = useState(false); return <Switch label="Pause while I travel" checked={on} onChange={setOn} />; }
    render(<Harness />);
    const sw = screen.getByRole('switch', { name: 'Pause while I travel' });
    expect(sw.getAttribute('aria-checked')).toBe('false');
    await userEvent.click(sw);
    expect(sw.getAttribute('aria-checked')).toBe('true');
  });

  it('ProgressBar exposes its value', () => {
    render(<ProgressBar value={72} label="Legacy Score" />);
    expect(screen.getByRole('progressbar', { name: 'Legacy Score' }).getAttribute('aria-valuenow')).toBe('72');
  });

  it('BasisBadge labels every figure (FRS principle 4)', () => {
    render(<BasisBadge basis="estimated" />);
    expect(screen.getByText('Estimated')).toBeTruthy();
  });
});
