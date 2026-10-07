// Component gallery (step 2): every token and component, in light and dark, at several text sizes.
// Specimens use content from the UI reference screens. Sample people and figures are fictional.
import { useEffect, useState } from 'react';
import {
  Bell, CreditCard, FileText, Heart, House, LineChart, Lock, Plus, User, Users,
} from 'lucide-react';
import {
  AllocationRow, Avatar, Badge, Banner, BasisBadge, Button, Callout, Card, Checkbox, Disclosure, HeroScoreCard, LabelledValue,
  ListRow, OptionCards, ProgressBar, QuickActionTile, SegmentedControl, StepProgress, Switch, TabBar, TextField,
} from '../design/components';
import { lifaColors } from '../design/generated/tokens';
import { formatDate } from '../design/format';

type Theme = 'system' | 'light' | 'dark';
const textSizes = [100, 150, 200] as const;

function Section({ id, title, children }: { id: string; title: string; children: React.ReactNode }) {
  return (
    <section aria-labelledby={id} className="gallery-section">
      <h2 id={id} className="lifa-type-title-2">{title}</h2>
      {children}
    </section>
  );
}

export function Gallery() {
  const [theme, setTheme] = useState<Theme>('system');
  const [textSize, setTextSize] = useState<string>('100');
  const [regime, setRegime] = useState('in_community');
  const [interval, setInterval] = useState('30');
  const [billing, setBilling] = useState('yearly');
  const [pause, setPause] = useState(false);
  const [fields, setFields] = useState({ contacts: true, will: true, children: true, funeral: false });
  const [shares, setShares] = useState({ sm: '50', lm: '20', km: '20', hc: '10' });

  useEffect(() => {
    const root = document.documentElement;
    if (theme === 'system') delete root.dataset.theme; else root.dataset.theme = theme;
  }, [theme]);
  useEffect(() => { document.documentElement.style.fontSize = `${textSize}%`; }, [textSize]);

  const total = Object.values(shares).reduce((s, v) => s + (Number(v) || 0), 0);
  const tabs = [
    { key: 'home', label: 'Home', href: '#home', icon: House },
    { key: 'will', label: 'Will', href: '#will', icon: FileText },
    { key: 'vault', label: 'Vault', href: '#vault', icon: Lock },
    { key: 'family', label: 'Family', href: '#family', icon: Users },
    { key: 'account', label: 'Account', href: '#account', icon: User },
  ];

  return (
    <div className="gallery">
      <header className="gallery-header">
        <div style={{ display: 'flex', alignItems: 'center', gap: 'var(--lifa-space-3)' }}>
          <img src="/lifa-icon.png" alt="" width={44} height={44} style={{ borderRadius: 'var(--lifa-radius-sm)' }} />
          <div>
            <h1 className="lifa-type-title-1">Lifa design system</h1>
            <p className="lifa-type-caption" style={{ color: 'var(--lifa-color-text-muted)' }}>Component gallery · web</p>
          </div>
        </div>
        <div className="gallery-controls">
          <SegmentedControl legend="Theme" name="theme" value={theme} onChange={(v) => setTheme(v as Theme)}
            options={[{ value: 'system', label: 'System' }, { value: 'light', label: 'Light' }, { value: 'dark', label: 'Dark' }]} />
          <SegmentedControl legend="Text size" name="textsize" value={textSize} onChange={setTextSize}
            options={textSizes.map((s) => ({ value: String(s), label: `${s}%` }))} />
        </div>
      </header>

      <main className="gallery-main">
        <Section id="colours" title="Colours">
          <p className="lifa-type-caption gallery-muted">Semantic tokens. Every text and control pairing is checked for WCAG contrast in both modes.</p>
          <div className="gallery-swatches">
            {Object.keys(lifaColors.light).map((k) => (
              <div key={k} className="gallery-swatch">
                <span className="gallery-swatch__chip" style={{ background: `var(--lifa-color-${k.replace(/[A-Z]/g, (c) => `-${c.toLowerCase()}`)})` }} />
                <span className="lifa-type-caption">{k}</span>
              </div>
            ))}
          </div>
        </Section>

        <Section id="type" title="Typography">
          <Card>
            <p className="lifa-type-overline gallery-muted">Your legacy score</p>
            <p className="lifa-type-display">72</p>
            <p className="lifa-type-title-1">Who inherits the rest?</p>
            <p className="lifa-type-title-2">Needs your attention</p>
            <p className="lifa-type-title-3">Name an alternate guardian</p>
            <p className="lifa-type-body">Everything not left as a specific gift is your residue. Shares must add up to exactly 100%.</p>
            <p className="lifa-type-body-strong">Lerato is under 18</p>
            <p className="lifa-type-label">Mobile number</p>
            <p className="lifa-type-caption gallery-muted">Lifa is not a law firm or financial adviser.</p>
            <p className="lifa-type-body">Fallback glyphs: Ṱhavhudzwi Muḓau · Ḽivhuwani Ṅemaṋozwi</p>
          </Card>
        </Section>

        <Section id="buttons" title="Buttons">
          <div className="gallery-stack">
            <Button fullWidth>Start my free will</Button>
            <Button variant="secondary" fullWidth>Go to my plan</Button>
            <div className="gallery-row">
              <Button variant="secondary">Back</Button>
              <Button style={{ flex: 1 }}>Next: specific gifts</Button>
            </div>
            <div className="gallery-row">
              <Button variant="text">Add a testamentary trust clause</Button>
              <Button variant="destructive" compact>Close account</Button>
              <Button loading compact>Saving</Button>
              <Button disabled compact>Disabled</Button>
            </div>
            <Button variant="dashed" fullWidth><Plus size={20} aria-hidden="true" />Add a beneficiary</Button>
          </div>
        </Section>

        <Section id="badges" title="Badges and evidence labels">
          <div className="gallery-row">
            <Badge tone="plan">Plus</Badge>
            <Badge tone="success">Accepted</Badge>
            <Badge tone="warning">Invite sent</Badge>
            <Badge tone="neutral">Not chosen yet</Badge>
            <Badge tone="critical">Overdue</Badge>
            <BasisBadge basis="evidenced" />
            <BasisBadge basis="declared" />
            <BasisBadge basis="estimated" />
          </div>
          <div className="gallery-row">
            <LabelledValue label="Estimated net estate" cents={892_000_000} basis="estimated" />
            <LabelledValue label="Property · 2" cents={530_000_000} basis="evidenced" />
            <LabelledValue label="Household net worth" cents={892_000_000} basis="declared" compact />
          </div>
        </Section>

        <Section id="cards" title="Cards">
          <Banner icon={Heart} action={<Button variant="text" compact>I’m still here</Button>}>Monthly check-in is due</Banner>
          <HeroScoreCard score={72} delta="+28 since September" tiles={[{ label: 'Estimated net estate', value: 'R8.92m' }, { label: 'Signed will', value: 'Version 2' }]} />
          <div className="lifa-tiles">
            <QuickActionTile icon={FileText} label="Will" />
            <QuickActionTile icon={House} label="Assets" />
            <QuickActionTile icon={LineChart} label="Simulate" />
            <QuickActionTile icon={CreditCard} label="Card" />
          </div>
        </Section>

        <Section id="lists" title="List rows">
          <ul className="lifa-list">
            <li><ListRow indicator="warning" title="Name an alternate guardian" subtitle="Adds 3 points" onClick={() => {}} /></li>
            <li><ListRow indicator="warning" title="Passport expires in 41 days" subtitle={`Upload the new one before ${formatDate('2026-11-17')}`} onClick={() => {}} /></li>
            <li><ListRow leading={<Avatar initials="SM" />} title="Sipho Mokoena" subtitle="Executor" trailing={<Badge tone="success">Accepted</Badge>} /></li>
            <li><ListRow leading={<Avatar initials="ND" tone="gold" />} title="Nomsa Dlamini" subtitle="Guardian for Lerato" trailing={<Badge tone="warning">Invite sent</Badge>} /></li>
            <li><ListRow leading={<Avatar initials="HC" tone="lavender" />} title="Hope Children’s Home" subtitle="Charity" /></li>
          </ul>
        </Section>

        <Section id="progress" title="Progress">
          <p className="lifa-type-caption gallery-muted">My will · Step 3 of 7</p>
          <StepProgress current={3} total={7} />
          <ProgressBar value={3.2} max={10} label="Vault storage used" />
          <p className="lifa-type-caption gallery-muted">3.2 of 10 GB</p>
        </Section>

        <Section id="inputs" title="Text fields">
          <div className="gallery-stack">
            <TextField label="Mobile number" inputMode="tel" autoComplete="tel" defaultValue="+27 82 555 0143" />
            <TextField label="South African ID number" inputMode="numeric" defaultValue="8702145800087" hint="ID number format is valid" hintOk />
            <TextField label="Email" type="email" defaultValue="thandi@" error="Enter an email address like name@example.com" />
          </div>
          <Card>
            <ul className="lifa-list">
              {([['sm', 'Sipho Mokoena', 'Spouse', 'green'], ['lm', 'Lerato Mokoena', 'Daughter · 12 years', 'gold'], ['km', 'Kabelo Mokoena', 'Son · 25 years', 'green'], ['hc', 'Hope Children’s Home', 'Charity', 'lavender']] as const).map(([key, name, rel, tone]) => (
                <li key={key}>
                  <AllocationRow initials={key.toUpperCase()} tone={tone} name={name} detail={rel} value={shares[key]} onChange={(v) => setShares({ ...shares, [key]: v })} />
                </li>
              ))}
            </ul>
            <div className="lifa-progress-row" style={{ marginTop: 'var(--lifa-space-4)' }}>
              <ProgressBar value={Math.min(total, 100)} label="Residue allocated" />
              <span className="lifa-progress-row__label" aria-live="polite">{total}% allocated</span>
            </div>
          </Card>
          {total !== 100 && <Callout tone="critical" title={`Allocations total ${total}%; they must total 100%`} />}
          <Callout tone="warning" title="Lerato is under 18" action={<Button variant="text" compact>Learn about the Guardian’s Fund</Button>}>
            A minor can’t take an inheritance directly. Without a trust, her share may go to the Guardian’s Fund until she turns 18.
          </Callout>
          <Callout tone="info" title="Stored in South Africa">Your documents are encrypted with your own key.</Callout>
        </Section>

        <Section id="choices" title="Choices">
          <OptionCards legend="How are you married?" name="regime" value={regime} onChange={setRegime} options={[
            { value: 'not_married', label: 'Not married' },
            { value: 'in_community', label: 'In community of property' },
            { value: 'accrual', label: 'Out of community, with accrual' },
            { value: 'no_accrual', label: 'Out of community, no accrual' },
            { value: 'customary', label: 'Customary marriage' },
          ]} />
          <SegmentedControl legend="Ask me every" name="interval" value={interval} onChange={setInterval}
            options={[{ value: '30', label: '30 days' }, { value: '60', label: '60 days' }, { value: '90', label: '90 days' }]} />
          <SegmentedControl legend="Billing period" name="billing" value={billing} onChange={setBilling}
            options={[{ value: 'monthly', label: 'Monthly' }, { value: 'yearly', label: 'Yearly · save 17%' }]} />
          <Card>
            <Switch label="Pause while I travel" description="Up to 180 days" checked={pause} onChange={setPause} />
            <p className="lifa-type-label" style={{ marginTop: 'var(--lifa-space-3)' }}>Show on the card</p>
            <Checkbox label="Contacts and executor" checked={fields.contacts} onChange={(v) => setFields({ ...fields, contacts: v })} />
            <Checkbox label="Where my will is kept" checked={fields.will} onChange={(v) => setFields({ ...fields, will: v })} />
            <Checkbox label="Children and guardian" checked={fields.children} onChange={(v) => setFields({ ...fields, children: v })} />
            <Checkbox label="Funeral wishes" checked={fields.funeral} onChange={(v) => setFields({ ...fields, funeral: v })} />
          </Card>
        </Section>

        <Section id="nav" title="Navigation">
          <TabBar items={tabs} current="home" />
          <div className="gallery-row">
            <Button variant="secondary" compact aria-label="Notifications"><Bell size={20} aria-hidden="true" /></Button>
          </div>
        </Section>

        <Section id="disclosures" title="Disclosures">
          <Disclosure>Lifa is not a law firm and does not give legal advice.</Disclosure>
          <Disclosure>Education only. Lifa does not recommend financial products.</Disclosure>
        </Section>
      </main>
    </div>
  );
}
