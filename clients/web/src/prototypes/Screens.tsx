// Prototype screens for the end-to-end demo (one per mobile journey). Built only from design-system
// components and tokens; people and figures are fictional. These are not the shipped app (step 4).
import type { ReactNode } from 'react';
import {
  BatteryFull, Bell, Car, ChartLine, ChevronLeft, Circle, CircleCheck, CreditCard, FileText, Fingerprint,
  Folder, Heart, House, IdCard, Landmark, Lock, ShieldCheck, Signal, User, Users, Wifi,
} from 'lucide-react';
import {
  AllocationRow, Avatar, Badge, BasisBadge, Banner, Button, Callout, Card, Checkbox, Disclosure, HeroScoreCard,
  LabelledValue, ListRow, ProgressBar, QuickActionTile, SegmentedControl, StepProgress, Switch, TabBar, TextField, type TabItem,
} from '../design/components';
import { formatZar } from '../design/format';

const noop = () => {};
const tabs: TabItem[] = [
  { key: 'home', label: 'Home', href: '#', icon: House },
  { key: 'will', label: 'Will', href: '#', icon: FileText },
  { key: 'vault', label: 'Vault', href: '#', icon: Lock },
  { key: 'family', label: 'Family', href: '#', icon: Users },
  { key: 'account', label: 'Account', href: '#', icon: User },
];

function Phone({ title, back, tab, children, overlay }: { title?: string; back?: boolean; tab?: string; children: ReactNode; overlay?: ReactNode }) {
  return (
    <div className="proto">
      <div className="proto__status" aria-hidden="true">
        <span>9:41</span>
        <span className="proto__status-icons"><Signal size={16} /><Wifi size={16} /><BatteryFull size={20} /></span>
      </div>
      {title && (
        <header className="proto__header">
          {back && <span className="proto__back"><ChevronLeft size={26} aria-hidden="true" /></span>}
          <h1 className="proto__title">{title}</h1>
        </header>
      )}
      <main className="proto__body">{children}</main>
      {tab && <div className="proto__tabbar"><TabBar items={tabs} current={tab} /></div>}
      {overlay}
    </div>
  );
}

const Amount = ({ cents, basis }: { cents: number; basis: 'declared' | 'evidenced' | 'estimated' }) => (
  <span style={{ display: 'grid', justifyItems: 'end', gap: 2 }}><span className="proto__amount">{formatZar(cents, { compact: true })}</span><BasisBadge basis={basis} /></span>
);

// 1 · Sign up: verify the mobile number (FR-ONB-002)
function SignUp() {
  return (
    <Phone title="Verify your mobile" back>
      <StepProgress current={2} total={4} />
      <p className="proto__lead">We sent a 6-digit code to your phone. We also check that the number hasn’t recently moved to a new SIM.</p>
      <TextField label="Mobile number" defaultValue="+27 82 555 0143" hint="Number format is valid" hintOk readOnly />
      <div className="proto__stack">
        <span className="lifa-field__label">Code from the SMS</span>
        <div className="proto__otp" aria-hidden="true">
          {['4', '8', '1', '7', '', ''].map((d, i) => <span key={i} className={i === 4 ? 'is-active' : undefined}>{d}</span>)}
        </div>
        <span className="proto__caption">Didn’t get it? You can ask for a new code in 0:42</span>
      </div>
      <div className="proto__spacer" />
      <Callout tone="info" title="This phone will be your key">Lifa ties your account to this device. Signing in somewhere new needs an extra check, and we tell your other devices.</Callout>
      <Button fullWidth>Verify</Button>
    </Phone>
  );
}

// 2 · Home and the Legacy Score (FR-SCR-002, FR-SCR-003, FR-DMS-002)
function Home() {
  return (
    <Phone tab="home">
      <div className="proto__row" style={{ paddingTop: 'var(--lifa-space-2)' }}>
        <div>
          <p className="proto__caption">Good morning</p>
          <p className="proto__h1">Thandi</p>
        </div>
        <span className="proto__spacer" />
        <Bell size={24} aria-label="Inbox" />
      </div>
      <Banner icon={Heart} action={<Button variant="text">I’m still here</Button>}>Monthly check-in is due</Banner>
      <HeroScoreCard score={72} delta="+28 since September" tiles={[{ label: 'Estimated net estate', value: 'R8.92m' }, { label: 'Signed will', value: 'Version 2' }]} />
      <div className="lifa-tiles">
        <QuickActionTile icon={FileText} label="Will" />
        <QuickActionTile icon={House} label="Assets" />
        <QuickActionTile icon={ChartLine} label="Simulate" />
        <QuickActionTile icon={CreditCard} label="Card" />
      </div>
      <p className="proto__section">Needs your attention</p>
      <ListRow title="Name an alternate guardian" subtitle="Adds 3 points" indicator="warning" onClick={noop} />
    </Phone>
  );
}

// 3 · Will builder: divide the residue (FR-WIL-003, FR-WIL-007)
function Will() {
  return (
    <Phone title="My will · Step 3 of 7" back>
      <StepProgress current={3} total={7} />
      <div className="proto__stack" style={{ gap: 'var(--lifa-space-1)' }}>
        <p className="proto__h1">Who inherits the rest?</p>
        <p className="proto__lead">Everything not left as a specific gift is your residue. Shares must add up to exactly 100%.</p>
      </div>
      <Card>
        <div className="proto__stack">
          <AllocationRow initials="SM" name="Sipho Mokoena" detail="Spouse" value="50" onChange={noop} />
          <AllocationRow initials="LM" tone="gold" name="Lerato Mokoena" detail="Daughter · 12 years" value="20" onChange={noop} />
          <AllocationRow initials="KM" name="Kabelo Mokoena" detail="Son · 25 years" value="20" onChange={noop} />
          <AllocationRow initials="HC" tone="lavender" name="Hope Children’s Home" detail="Charity" value="10" onChange={noop} />
          <div className="lifa-progress-row"><ProgressBar value={100} label="Residue allocated" /><span className="lifa-progress-row__label">100% allocated</span></div>
        </div>
      </Card>
      <Callout tone="warning" title="Lerato is under 18" action={<Button variant="text">Learn about the Guardian’s Fund</Button>}>
        Without a trust, her share may go to the Guardian’s Fund until she turns 18.
      </Callout>
      <div className="proto__spacer" />
      <div className="proto__row"><Button variant="secondary" style={{ flex: "none" }}>Back</Button><Button fullWidth>Next: specific gifts</Button></div>
    </Phone>
  );
}

// 4 · Assets and debts (FR-AST-001..004, FRS principle 4)
function Assets() {
  const rows: Array<[typeof Landmark, string, string, number, 'declared' | 'evidenced' | 'estimated']> = [
    [House, 'Family home, Midrand', 'Property · joint', 420_000_000, 'evidenced'],
    [House, 'Flat, Durban North', 'Property', 110_000_000, 'evidenced'],
    [Landmark, 'Retirement annuity', 'Investment', 304_000_000, 'declared'],
    [Landmark, 'Savings account', 'Bank', 41_000_000, 'evidenced'],
    [Car, 'Toyota Fortuner', 'Vehicle', 52_000_000, 'estimated'],
  ];
  const visible = rows.slice(0, 4); // the fifth row sits below the fold
  return (
    <Phone title="Assets and debts" tab="family">
      <Card>
        <div className="proto__stack">
          <LabelledValue label="Estimated net estate" cents={892_000_000} basis="estimated" />
          <div className="proto__row proto__caption"><span>Assets {formatZar(927_000_000)}</span><span>·</span><span>Debts {formatZar(-35_000_000)}</span></div>
        </div>
      </Card>
      <p className="proto__section">Assets · 5 of 15 on Free</p>
      <div className="lifa-list">
        {visible.map(([Icon, t, sub, cents, basis]) => (
          <ListRow key={t} leading={<Icon size={22} aria-hidden="true" />} title={t} subtitle={sub} trailing={<Amount cents={cents} basis={basis} />} onClick={noop} />
        ))}
      </div>
      <Button variant="dashed" fullWidth>+ Add an asset or debt</Button>
    </Phone>
  );
}

// 5 · Vault with the biometric step-up sheet (FR-VLT-001..004, FR-ONB-006)
function Vault() {
  const sheet = (
    <>
      <div className="proto__scrim" />
      <div className="proto__sheet" role="dialog" aria-label="Confirm it’s you">
        <span className="proto__sheet-icon"><Fingerprint size={40} aria-hidden="true" /></span>
        <p className="proto__h1">Confirm it’s you</p>
        <p className="proto__lead">Opening documents needs your fingerprint or face. Every time a document is opened, it’s recorded.</p>
        <Button fullWidth>Use fingerprint</Button>
        <Button variant="text">Cancel</Button>
      </div>
    </>
  );
  return (
    <Phone title="Vault" tab="vault" overlay={sheet}>
      <Card>
        <div className="proto__stack">
          <div className="proto__row"><span className="proto__section">Storage</span><span className="proto__spacer" /><span className="proto__caption">3.2 of 10 GB</span></div>
          <ProgressBar value={3.2} max={10} label="Storage used" />
        </div>
      </Card>
      <div className="lifa-list">
        <ListRow leading={<IdCard size={22} aria-hidden="true" />} title="Identity" subtitle="4 documents · passport expires in 41 days" indicator="warning" onClick={noop} />
        <ListRow leading={<FileText size={22} aria-hidden="true" />} title="Will and estate" subtitle="3 documents" onClick={noop} />
        <ListRow leading={<Folder size={22} aria-hidden="true" />} title="Property" subtitle="6 documents" onClick={noop} />
      </div>
      <Callout tone="info" title="Stored in South Africa">Your documents are encrypted with your own key.</Callout>
    </Phone>
  );
}

// 6 · Emergency card and who sees what (FR-EMG-001..002, FR-PRM-001, D-017)
function Emergency() {
  return (
    <Phone title="Emergency card" back>
      <div className="proto__widget" aria-label="Lock-screen preview">
        <span className="proto__widget-label">Lifa · Emergency</span>
        <span className="proto__section">Thandi Mokoena</span>
        <span>Call Sipho Mokoena · +27 82 555 0198</span>
        <span>Executor: Nomsa Dlamini</span>
      </div>
      <Card>
        <Switch label="Show on my lock screen" description="Anyone holding your phone can see it" checked onChange={noop} />
        <p className="proto__section" style={{ marginTop: 'var(--lifa-space-2)' }}>Show on the card</p>
        <Checkbox label="Contacts and executor" checked onChange={noop} />
        <Checkbox label="Where my will is kept" checked={false} onChange={noop} />
        <Checkbox label="Funeral wishes" checked={false} onChange={noop} />
      </Card>
      <p className="proto__section">People who can see your plan</p>
      <div className="lifa-list">
        <ListRow leading={<Avatar initials="SM" />} title="Sipho Mokoena" subtitle="Emergency contact" trailing={<Badge tone="success">Accepted</Badge>} />
        <ListRow leading={<Avatar initials="ND" tone="gold" />} title="Nomsa Dlamini" subtitle="Executor" trailing={<Badge tone="warning">Invite sent</Badge>} />
      </div>
    </Phone>
  );
}

// 7 · Check-in (FR-DMS-001..003)
function CheckIn() {
  return (
    <Phone title="Check-ins" tab="account">
      <div className="proto__checkin">
        <p>Are you OK, Thandi?</p>
        <p>Your monthly check-in is due. One tap tells Lifa you’re well.</p>
        <Button fullWidth>I’m still here</Button>
      </div>
      <SegmentedControl legend="Ask me every" name="interval" value="30" onChange={noop}
        options={[{ value: '30', label: '30 days' }, { value: '60', label: '60 days' }, { value: '90', label: '90 days' }]} />
      <Switch label="Pause while I travel" description="Up to 180 days" checked={false} onChange={noop} />
      <p className="proto__section">If you don’t answer</p>
      <div className="lifa-list">
        <ListRow leading={<Avatar initials="SM" />} title="Sipho Mokoena" subtitle="Verifier · asked to confirm you’re safe" />
        <ListRow leading={<Avatar initials="ND" tone="gold" />} title="Nomsa Dlamini" subtitle="Verifier" />
      </div>
      <Disclosure>Lifa never declares a death. A missed check-in only starts a human review.</Disclosure>
    </Phone>
  );
}

// 8 · Activation notice to the owner (FR-ACT-004, FR-DMS-006)
function Activation() {
  return (
    <Phone>
      <div className="proto__stack" style={{ paddingTop: 'var(--lifa-space-6)', justifyItems: 'center', textAlign: 'center' }}>
        <span className="proto__sheet-icon" style={{ background: 'var(--lifa-color-critical-soft)', color: 'var(--lifa-color-critical)' }}><ShieldCheck size={40} aria-hidden="true" /></span>
        <p className="proto__h1">Someone has asked to open your estate plan</p>
        <p className="proto__lead">Lifa received a report and supporting documents. Two of our team reviewed it. Your plan will open to the people you chose in:</p>
        <p className="lifa-hero__score" style={{ color: 'var(--lifa-color-critical)' }}>71 h 12 m</p>
      </div>
      <Callout tone="critical" title="If you’re reading this, you’re OK">Signing in cancels the request. Nothing has been shared yet.</Callout>
      <div className="proto__spacer" />
      <Button fullWidth>I’m still here, cancel this</Button>
      <Button variant="secondary" fullWidth>Contact Lifa support</Button>
    </Phone>
  );
}

// 9 · Executor workspace (FR-EXE-001..008)
function Executor() {
  const tasks: Array<[string, boolean]> = [
    ['Get certified copies of the death certificate', true],
    ['Find the original signed will', true],
    ['Notify banks and insurers · 3 of 5', false],
    ['Value the property', false],
    ['Send an update to beneficiaries', false],
  ];
  return (
    <Phone title="Estate of T. Mokoena" back>
      <Card>
        <div className="proto__stack">
          <div className="proto__row"><span className="proto__section">Checklist</span><span className="proto__spacer" /><span className="proto__caption">4 of 12 done</span></div>
          <ProgressBar value={4} max={12} label="Checklist progress" />
        </div>
      </Card>
      <Card>
        {tasks.map(([t, done]) => (
          <div className="proto__task" key={t}>
            {done ? <CircleCheck className="proto__task-done" size={24} aria-hidden="true" /> : <Circle className="proto__task-open" size={24} aria-hidden="true" />}
            <span>{done ? <s>{t}</s> : t}</span>
          </div>
        ))}
      </Card>
      <p className="proto__section">Coming up</p>
      <div className="lifa-list">
        <ListRow title="Letter to Standard Bank" subtitle="Draft ready to send" indicator="warning" onClick={noop} />
        <ListRow title="Beneficiary update" subtitle="Last sent 12 days ago" indicator="success" onClick={noop} />
      </div>
      <Disclosure>Lifa organises the work. It doesn’t act on the executor’s behalf.</Disclosure>
    </Phone>
  );
}

// 10 · Plans (FR-SUB-001..003). Prices come from the store catalogue at runtime.
function Plans() {
  return (
    <Phone title="Plans" back>
      <SegmentedControl legend="Billing period" name="billing" value="yearly" onChange={noop}
        options={[{ value: 'monthly', label: 'Monthly' }, { value: 'yearly', label: 'Yearly · save 17%' }]} />
      <div className="proto__plan">
        <div className="proto__row"><span className="proto__section">Free</span><span className="proto__spacer" /><Badge>Current</Badge></div>
        <ul><li>One will draft, 15 assets, 10 people</li><li>500 MB vault</li></ul>
      </div>
      <div className="proto__plan is-selected">
        <div className="proto__row"><span className="proto__section">Plus</span><span className="proto__spacer" /><Badge tone="plan">14-day trial</Badge></div>
        <ul><li>Will history, codicils, minor warnings</li><li>10 GB vault with expiry reminders</li><li>3 trusted people, release rules, check-ins</li></ul>
        <span className="proto__caption">Price shown from the app store</span>
      </div>
      <div className="proto__plan">
        <div className="proto__row"><span className="proto__section">Family</span></div>
        <ul><li>Two adults, linked plans, 50 GB shared</li><li>Mirror wills, trust clauses</li></ul>
      </div>
      <div className="proto__spacer" />
      <Button fullWidth>Start free trial</Button>
      <Disclosure>Billed by the app store. Cancel any time in your store settings.</Disclosure>
    </Phone>
  );
}

const screens: Record<string, () => ReactNode> = {
  signup: SignUp, home: Home, will: Will, assets: Assets, vault: Vault, emergency: Emergency,
  checkin: CheckIn, activation: Activation, executor: Executor, plans: Plans,
};
export const prototypeIds = Object.keys(screens);

export function PrototypeScreen({ id }: { id: string }) {
  const Screen = screens[id] ?? Home;
  return <Screen />;
}

