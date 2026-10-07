// Lifa web components (step 2). Styling lives in ../lifa.css and uses only generated tokens.
// Native elements first: real <button>, <input type="radio|checkbox">, <label>, so keyboard and
// screen-reader behaviour comes from the browser (WCAG 2.2 AA, NFR-ACC-001).
import { useId, type ComponentPropsWithoutRef, type ReactNode } from 'react';
import { AlertTriangle, ChevronRight, CircleAlert, Info, type LucideIcon } from 'lucide-react';
import { formatZar, type ValueBasis } from '../format';

const cx = (...c: Array<string | false | undefined>) => c.filter(Boolean).join(' ');

export type ButtonVariant = 'primary' | 'secondary' | 'text' | 'destructive' | 'dashed';

export function Button({
  variant = 'primary', fullWidth, compact, loading, children, className, disabled, ...rest
}: ComponentPropsWithoutRef<'button'> & { variant?: ButtonVariant; fullWidth?: boolean; compact?: boolean; loading?: boolean }) {
  return (
    <button
      type="button"
      {...rest}
      disabled={disabled || loading}
      aria-busy={loading || undefined}
      className={cx('lifa-button', `lifa-button--${variant}`, fullWidth && 'lifa-button--full', compact && 'lifa-button--compact', className)}
    >
      {children}
    </button>
  );
}

export type BadgeTone = 'plan' | 'neutral' | 'success' | 'warning' | 'critical';
export function Badge({ tone = 'neutral', children }: { tone?: BadgeTone; children: ReactNode }) {
  return <span className={cx('lifa-badge', `lifa-badge--${tone}`)}>{children}</span>;
}

const basisLabel: Record<ValueBasis, string> = { declared: 'Declared', evidenced: 'Evidenced', estimated: 'Estimated' };
/** FRS principle 4: every figure is labelled declared, evidenced or estimated. */
export function BasisBadge({ basis }: { basis: ValueBasis }) {
  const tone: BadgeTone = basis === 'evidenced' ? 'success' : basis === 'estimated' ? 'warning' : 'neutral';
  return <span className={cx('lifa-badge', 'lifa-badge--basis', `lifa-badge--${tone}`)}>{basisLabel[basis]}</span>;
}

export function LabelledValue({ label, cents, basis, compact }: { label: string; cents: number; basis: ValueBasis; compact?: boolean }) {
  return (
    <div className="lifa-value">
      <span className="lifa-value__label">{label}</span>
      <span className="lifa-value__row">
        <span className="lifa-value__amount">{formatZar(cents, { compact })}</span>
        <BasisBadge basis={basis} />
      </span>
    </div>
  );
}

export function Card({ children, flush, as: Tag = 'section', ...rest }: { children: ReactNode; flush?: boolean; as?: 'section' | 'div' | 'article' } & ComponentPropsWithoutRef<'section'>) {
  return <Tag {...rest} className={cx('lifa-card', flush && 'lifa-card--flush', rest.className)}>{children}</Tag>;
}

export function ProgressBar({ value, max = 100, label, onHero }: { value: number; max?: number; label: string; onHero?: boolean }) {
  const pct = Math.max(0, Math.min(100, (value / max) * 100));
  return (
    <div className={cx('lifa-progress', onHero && 'lifa-progress--on-hero')} role="progressbar" aria-label={label} aria-valuemin={0} aria-valuemax={max} aria-valuenow={value}>
      <div className="lifa-progress__fill" style={{ width: `${pct}%` }} />
    </div>
  );
}

/** Wizard progress, for example "My will · Step 3 of 7" (FR-WIL-001). */
export function StepProgress({ current, total }: { current: number; total: number }) {
  return (
    <div>
      <span className="lifa-visually-hidden">Step {current} of {total}</span>
      <div className="lifa-steps" aria-hidden="true">
        {Array.from({ length: total }, (_, i) => <span key={i} className={cx('lifa-steps__seg', i < current && 'lifa-steps__seg--done')} />)}
      </div>
    </div>
  );
}

export function HeroScoreCard({ score, delta, tiles }: { score: number; delta?: string; tiles: Array<{ label: string; value: string }> }) {
  const headingId = useId();
  return (
    <section className="lifa-hero" aria-labelledby={headingId}>
      <h2 id={headingId} className="lifa-hero__label">Legacy Score</h2>
      <div className="lifa-hero__row">
        <p><span className="lifa-hero__score">{score}</span> <span className="lifa-hero__outof">/100</span></p>
        {delta && <p className="lifa-hero__delta">{delta}</p>}
      </div>
      <ProgressBar value={score} label="Legacy Score" onHero />
      <div className="lifa-hero__tiles">
        {tiles.map((t) => (
          <div className="lifa-hero__tile" key={t.label}>
            <p className="lifa-hero__tile-label">{t.label}</p>
            <p className="lifa-hero__tile-value">{t.value}</p>
          </div>
        ))}
      </div>
    </section>
  );
}

const calloutIcon: Record<'warning' | 'info' | 'critical', LucideIcon> = { warning: AlertTriangle, info: Info, critical: CircleAlert };
export function Callout({ tone = 'info', title, children, action }: { tone?: 'warning' | 'info' | 'critical'; title: string; children?: ReactNode; action?: ReactNode }) {
  const Icon = calloutIcon[tone];
  return (
    <div className={cx('lifa-callout', `lifa-callout--${tone}`)} role={tone === 'critical' ? 'alert' : undefined}>
      <Icon className="lifa-callout__icon" size={22} aria-hidden="true" />
      <div>
        <p className="lifa-callout__title">{title}</p>
        {children && <div className="lifa-callout__body">{children}</div>}
        {action && <div style={{ marginTop: 'var(--lifa-space-2)' }}>{action}</div>}
      </div>
    </div>
  );
}

export function Banner({ icon: Icon, children, action }: { icon?: LucideIcon; children: ReactNode; action?: ReactNode }) {
  return (
    <div className="lifa-banner">
      {Icon && <Icon size={20} aria-hidden="true" />}
      <p className="lifa-banner__text">{children}</p>
      {action}
    </div>
  );
}

export function ListRow({ title, subtitle, indicator, leading, trailing, onClick, href }: {
  title: string; subtitle?: string; indicator?: 'warning' | 'critical' | 'success'; leading?: ReactNode; trailing?: ReactNode; onClick?: () => void; href?: string;
}) {
  const content = (
    <>
      {indicator && <span className={cx('lifa-row__dot', `lifa-row__dot--${indicator}`)} aria-hidden="true" />}
      {leading}
      <span className="lifa-row__body">
        <span className="lifa-row__title" style={{ display: 'block' }}>{title}</span>
        {subtitle && <span className="lifa-row__subtitle" style={{ display: 'block' }}>{subtitle}</span>}
      </span>
      {trailing}
      {(onClick || href) && <ChevronRight className="lifa-row__chevron" size={20} aria-hidden="true" />}
    </>
  );
  if (href) return <a className="lifa-row" href={href}>{content}</a>;
  if (onClick) return <button type="button" className="lifa-row" onClick={onClick}>{content}</button>;
  return <div className="lifa-row">{content}</div>;
}

export function QuickActionTile({ icon: Icon, label, onClick }: { icon: LucideIcon; label: string; onClick?: () => void }) {
  return (
    <button type="button" className="lifa-tile" onClick={onClick}>
      <Icon size={24} aria-hidden="true" />
      {label}
    </button>
  );
}

export function TextField({ label, hint, hintOk, error, suffix, compact, hideLabel, ...input }: ComponentPropsWithoutRef<'input'> & {
  label: string; hint?: string; hintOk?: boolean; error?: string; suffix?: string; compact?: boolean; hideLabel?: boolean;
}) {
  const id = useId();
  const describedBy = [hint && `${id}-hint`, error && `${id}-error`].filter(Boolean).join(' ') || undefined;
  return (
    <div className={cx('lifa-field', error && 'lifa-field--invalid', compact && 'lifa-field--compact')}>
      <label htmlFor={id} className={hideLabel ? 'lifa-visually-hidden' : 'lifa-field__label'}>{label}</label>
      <div className="lifa-field__control">
        <input id={id} aria-invalid={error ? true : undefined} aria-describedby={describedBy} {...input} />
        {suffix && <span className="lifa-field__suffix" aria-hidden="true">{suffix}</span>}
      </div>
      {hint && <span id={`${id}-hint`} className={cx('lifa-field__hint', hintOk && 'lifa-field__hint--ok')}>{hint}</span>}
      {error && <span id={`${id}-error`} className="lifa-field__error">{error}</span>}
    </div>
  );
}

export type Option = { value: string; label: string; hint?: string };

/** Single choice as cards, for example "How are you married?" (FR-WIL-002). Native radios. */
export function OptionCards({ legend, name, options, value, onChange }: { legend: string; name: string; options: Option[]; value?: string; onChange: (v: string) => void }) {
  return (
    <fieldset className="lifa-options">
      <legend>{legend}</legend>
      {options.map((o) => (
        <label className="lifa-option" key={o.value}>
          <input type="radio" name={name} value={o.value} checked={value === o.value} onChange={() => onChange(o.value)} />
          <span className="lifa-option__text">
            <span>{o.label}</span>
            {o.hint && <span className="lifa-option__hint">{o.hint}</span>}
          </span>
        </label>
      ))}
    </fieldset>
  );
}

/** Segmented control (for example 30/60/90 days, Monthly/Yearly). Native radios: arrow keys work. */
export function SegmentedControl({ legend, name, options, value, onChange }: { legend: string; name: string; options: Option[]; value: string; onChange: (v: string) => void }) {
  return (
    <fieldset className="lifa-segmented">
      <legend>{legend}</legend>
      {options.map((o) => (
        <label key={o.value}>
          <input type="radio" name={name} value={o.value} checked={value === o.value} onChange={() => onChange(o.value)} />
          {o.label}
        </label>
      ))}
    </fieldset>
  );
}

export function Switch({ label, checked, onChange, description }: { label: string; checked: boolean; onChange: (v: boolean) => void; description?: string }) {
  const id = useId();
  return (
    <div className="lifa-toggle-row">
      <span>
        <span id={id} style={{ display: 'block' }}>{label}</span>
        {description && <span className="lifa-option__hint">{description}</span>}
      </span>
      <button type="button" role="switch" aria-checked={checked} aria-labelledby={id} className="lifa-switch" onClick={() => onChange(!checked)} />
    </div>
  );
}

export function Checkbox({ label, checked, onChange }: { label: string; checked: boolean; onChange: (v: boolean) => void }) {
  return (
    <label className="lifa-check">
      <input type="checkbox" checked={checked} onChange={(e) => onChange(e.target.checked)} />
      <span>{label}</span>
    </label>
  );
}

export function Avatar({ initials, tone = 'green' }: { initials: string; tone?: 'green' | 'gold' | 'lavender' }) {
  return <span className={cx('lifa-avatar', `lifa-avatar--${tone}`)} aria-hidden="true">{initials}</span>;
}

/** One person's residue share (FR-WIL-003). The input is labelled with the person's name. */
export function AllocationRow({ initials, tone, name, detail, value, onChange }: {
  initials: string; tone?: 'green' | 'gold' | 'lavender'; name: string; detail: string; value: string; onChange: (v: string) => void;
}) {
  return (
    <div className="lifa-allocation">
      <span className="lifa-allocation__person">
        <Avatar initials={initials} tone={tone} />
        <span>
          <span className="lifa-allocation__name">{name}</span>
          <span className="lifa-allocation__detail">{detail}</span>
        </span>
      </span>
      <TextField label={`Share for ${name}`} hideLabel compact suffix="%" inputMode="decimal" value={value} onChange={(e) => onChange(e.target.value)} />
    </div>
  );
}

export type TabItem = { key: string; label: string; href: string; icon: LucideIcon };
export function TabBar({ items, current }: { items: TabItem[]; current: string }) {
  return (
    <nav className="lifa-tabbar" aria-label="Main">
      <ul>
        {items.map(({ key, label, href, icon: Icon }) => (
          <li key={key}>
            <a href={href} aria-current={key === current ? 'page' : undefined}>
              <Icon size={24} aria-hidden="true" />
              {label}
            </a>
          </li>
        ))}
      </ul>
    </nav>
  );
}

/** Mandatory disclosure (FRS 12.2, FR-WIL-018). Text comes from content, rendered verbatim. */
export function Disclosure({ children }: { children: ReactNode }) {
  return <p className="lifa-disclosure">{children}</p>;
}
