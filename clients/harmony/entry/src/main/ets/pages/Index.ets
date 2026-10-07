import { common, ConfigurationConstant } from '@kit.AbilityKit';
import {
  AllocationRow, AvatarTone, BadgeTone, BasisBadge, ButtonVariant, CalloutTone, ChoiceOption, HeroScoreCard, HeroTile,
  LabelledValue, LifaAvatar, LifaBadge, LifaBanner, LifaButton, LifaCallout, LifaCard, LifaCheckboxRow, LifaColor,
  LifaDisclosure, LifaListRow, LifaProgressBar, LifaSegmentedControl, LifaSpace, LifaTabBar, LifaText, LifaTextField,
  LifaToggleRow, LifaTypography, OptionCards, QuickActionTile, RowIndicator, StepProgress, TabItem, ValueBasis, formatDate
} from '@lifa/design';

interface Person {
  initials: string;
  name: string;
  detail: string;
  tone: AvatarTone;
}

/**
 * Component gallery (step 2). Mirrors the web, Android and iOS galleries. Text size follows the system font-size
 * setting (fp units); the theme control switches the app colour mode. Sample people and figures are fictional.
 */
@Entry
@Component
struct Index {
  @State theme: string = 'System';
  @State regime: string = 'in_community';
  @State interval: string = '30';
  @State billing: string = 'yearly';
  @State pause: boolean = false;
  @State tab: string = 'home';
  @State mobile: string = '+27 82 555 0143';
  @State idNumber: string = '8702145800087';
  @State email: string = 'thandi@';
  @State shares: string[] = ['50', '20', '20', '10'];
  @State cardFields: boolean[] = [true, true, true, false];
  private people: Person[] = [
    { initials: 'SM', name: 'Sipho Mokoena', detail: 'Spouse', tone: AvatarTone.Green },
    { initials: 'LM', name: 'Lerato Mokoena', detail: 'Daughter · 12 years', tone: AvatarTone.Gold },
    { initials: 'KM', name: 'Kabelo Mokoena', detail: 'Son · 25 years', tone: AvatarTone.Green },
    { initials: 'HC', name: 'Hope Children’s Home', detail: 'Charity', tone: AvatarTone.Lavender }
  ];
  private fieldNames: string[] = ['Contacts and executor', 'Where my will is kept', 'Children and guardian', 'Funeral wishes'];
  private themes: ChoiceOption[] = [{ value: 'System', label: 'System' }, { value: 'Light', label: 'Light' }, { value: 'Dark', label: 'Dark' }];
  private regimes: ChoiceOption[] = [
    { value: 'not_married', label: 'Not married' }, { value: 'in_community', label: 'In community of property' },
    { value: 'accrual', label: 'Out of community, with accrual' }, { value: 'no_accrual', label: 'Out of community, no accrual' },
    { value: 'customary', label: 'Customary marriage' }
  ];
  private intervals: ChoiceOption[] = [{ value: '30', label: '30 days' }, { value: '60', label: '60 days' }, { value: '90', label: '90 days' }];
  private billings: ChoiceOption[] = [{ value: 'monthly', label: 'Monthly' }, { value: 'yearly', label: 'Yearly · save 17%' }];
  private tabs: TabItem[] = [
    { key: 'home', label: 'Home', icon: 'house' }, { key: 'will', label: 'Will', icon: 'file-text' }, { key: 'vault', label: 'Vault', icon: 'lock' },
    { key: 'family', label: 'Family', icon: 'users' }, { key: 'account', label: 'Account', icon: 'user' }
  ];
  private tiles: HeroTile[] = [{ label: 'Estimated net estate', value: 'R8.92m' }, { label: 'Signed will', value: 'Version 2' }];

  private total(): number {
    let sum = 0;
    this.shares.forEach((s: string) => { const n = Number.parseInt(s); sum += Number.isNaN(n) ? 0 : n; });
    return sum;
  }

  private setTheme(v: string): void {
    this.theme = v;
    const ctx = getContext(this) as common.UIAbilityContext;
    const mode = v === 'Dark' ? ConfigurationConstant.ColorMode.COLOR_MODE_DARK
      : v === 'Light' ? ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT : ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET;
    ctx.getApplicationContext().setColorMode(mode);
  }

  @Builder sectionTitle(title: string) {
    Text(title).attributeModifier(new LifaText(LifaTypography.title2, LifaColor.text))
  }

  @Builder stillHere() {
    LifaButton({ text: 'I’m still here', variant: ButtonVariant.Text })
  }

  @Builder guardianFund() {
    LifaButton({ text: 'Learn about the Guardian’s Fund', variant: ButtonVariant.Text })
  }

  build() {
    Scroll() {
      Column({ space: LifaSpace.space8 }) {
        Column({ space: LifaSpace.space3 }) {
          Text('Lifa design system').attributeModifier(new LifaText(LifaTypography.title1, LifaColor.text)).id('gallery-title')
          Text('Component gallery · HarmonyOS').attributeModifier(new LifaText(LifaTypography.caption, LifaColor.textMuted))
          LifaSegmentedControl({ label: 'Theme', options: this.themes, selected: this.theme, onSelect: (v: string) => this.setTheme(v) })
        }
        .alignItems(HorizontalAlign.Start)

        Column({ space: LifaSpace.space4 }) {
          this.sectionTitle('Typography')
          LifaCard() {
            Text('YOUR LEGACY SCORE').attributeModifier(new LifaText(LifaTypography.overline, LifaColor.textMuted))
            Text('72').attributeModifier(new LifaText(LifaTypography.display, LifaColor.text))
            Text('Who inherits the rest?').attributeModifier(new LifaText(LifaTypography.title1, LifaColor.text))
            Text('Needs your attention').attributeModifier(new LifaText(LifaTypography.title2, LifaColor.text))
            Text('Name an alternate guardian').attributeModifier(new LifaText(LifaTypography.title3, LifaColor.text))
            Text('Everything not left as a specific gift is your residue. Shares must add up to exactly 100%.').attributeModifier(new LifaText(LifaTypography.body, LifaColor.text))
            Text('Lerato is under 18').attributeModifier(new LifaText(LifaTypography.bodyStrong, LifaColor.text))
            Text('Lifa is not a law firm or financial adviser.').attributeModifier(new LifaText(LifaTypography.caption, LifaColor.textMuted))
            Text('Fallback glyphs: Ṱhavhudzwi Muḓau · Ḽivhuwani Ṅemaṋozwi').attributeModifier(new LifaText(LifaTypography.body, LifaColor.text))
          }
        }
        .alignItems(HorizontalAlign.Start)

        Column({ space: LifaSpace.space3 }) {
          this.sectionTitle('Buttons')
          LifaButton({ text: 'Start my free will', fullWidth: true }).id('primary-button')
          LifaButton({ text: 'Go to my plan', variant: ButtonVariant.Secondary, fullWidth: true })
          LifaButton({ text: 'Add a testamentary trust clause', variant: ButtonVariant.Text })
          Row({ space: LifaSpace.space3 }) {
            LifaButton({ text: 'Close account', variant: ButtonVariant.Destructive, compact: true })
            LifaButton({ text: 'Saving', compact: true, loading: true })
            LifaButton({ text: 'Disabled', compact: true, isEnabled: false })
          }
          LifaButton({ text: 'Add a beneficiary', variant: ButtonVariant.Dashed, fullWidth: true, icon: 'plus' })
        }
        .alignItems(HorizontalAlign.Start)

        Column({ space: LifaSpace.space3 }) {
          this.sectionTitle('Badges and evidence labels')
          Flex({ wrap: FlexWrap.Wrap }) {
            LifaBadge({ text: 'Plus', tone: BadgeTone.Plan }).margin(4)
            LifaBadge({ text: 'Accepted', tone: BadgeTone.Success }).margin(4)
            LifaBadge({ text: 'Invite sent', tone: BadgeTone.Warning }).margin(4)
            LifaBadge({ text: 'Not chosen yet' }).margin(4)
            LifaBadge({ text: 'Overdue', tone: BadgeTone.Critical }).margin(4)
            BasisBadge({ basis: ValueBasis.Evidenced }).margin(4)
            BasisBadge({ basis: ValueBasis.Declared }).margin(4)
            BasisBadge({ basis: ValueBasis.Estimated }).margin(4)
          }
          LabelledValue({ label: 'Estimated net estate', cents: 892000000, basis: ValueBasis.Estimated })
          LabelledValue({ label: 'Household net worth', cents: 892000000, basis: ValueBasis.Declared, compact: true })
        }
        .alignItems(HorizontalAlign.Start)

        Column({ space: LifaSpace.space3 }) {
          this.sectionTitle('Cards')
          LifaBanner({ text: 'Monthly check-in is due', icon: 'heart' }) { this.stillHere() }
          HeroScoreCard({ score: 72, delta: '+28 since September', tiles: this.tiles })
          Row({ space: LifaSpace.space3 }) {
            QuickActionTile({ icon: 'file-text', label: 'Will' })
            QuickActionTile({ icon: 'house', label: 'Assets' })
            QuickActionTile({ icon: 'chart-line', label: 'Simulate' })
            QuickActionTile({ icon: 'credit-card', label: 'Card' })
          }
        }

        Column({ space: LifaSpace.space3 }) {
          this.sectionTitle('List rows')
          LifaListRow({ title: 'Name an alternate guardian', subtitle: 'Adds 3 points', indicator: RowIndicator.Warning, clickable: true })
          LifaListRow({ title: 'Passport expires in 41 days', subtitle: `Upload the new one before ${formatDate(2026, 11, 17)}`, indicator: RowIndicator.Warning, clickable: true })
          LifaListRow({ title: 'Sipho Mokoena', subtitle: 'Executor' })
        }
        .alignItems(HorizontalAlign.Start)

        Column({ space: LifaSpace.space3 }) {
          this.sectionTitle('Progress')
          StepProgress({ current: 3, total: 7 })
          LifaProgressBar({ value: 3.2, max: 10, label: 'Vault storage used' })
        }
        .alignItems(HorizontalAlign.Start)

        Column({ space: LifaSpace.space3 }) {
          this.sectionTitle('Text fields')
          LifaTextField({ label: 'Mobile number', value: this.mobile, inputType: InputType.PhoneNumber, onValueChange: (v: string) => { this.mobile = v; } })
          LifaTextField({ label: 'South African ID number', value: this.idNumber, hint: 'ID number format is valid', hintPositive: true, inputType: InputType.Number,
            onValueChange: (v: string) => { this.idNumber = v; } })
          LifaTextField({ label: 'Email', value: this.email, errorText: 'Enter an email address like name@example.com', inputType: InputType.Email,
            onValueChange: (v: string) => { this.email = v; } })
          LifaCard() {
            ForEach(this.people, (p: Person, i: number) => {
              AllocationRow({ initials: p.initials, tone: p.tone, name: p.name, detail: p.detail, value: this.shares[i],
                onValueChange: (v: string) => { const next = [...this.shares]; next[i] = v; this.shares = next; } })
            }, (p: Person) => p.initials)
            Row({ space: LifaSpace.space3 }) {
              LifaProgressBar({ value: Math.min(this.total(), 100), label: 'Residue allocated' }).layoutWeight(1)
              Text(`${this.total()}% allocated`).attributeModifier(new LifaText(LifaTypography.label, LifaColor.leafText)).fontWeight(FontWeight.Bold)
            }
          }
          if (this.total() !== 100) {
            LifaCallout({ title: `Allocations total ${this.total()}%; they must total 100%`, tone: CalloutTone.Critical }).id('residue-error')
          }
          LifaCallout({ title: 'Lerato is under 18', tone: CalloutTone.Warning,
            message: 'A minor can’t take an inheritance directly. Without a trust, her share may go to the Guardian’s Fund until she turns 18.' }) {
            this.guardianFund()
          }
          LifaCallout({ title: 'Stored in South Africa', tone: CalloutTone.Info, message: 'Your documents are encrypted with your own key.' })
        }
        .alignItems(HorizontalAlign.Start)

        Column({ space: LifaSpace.space3 }) {
          this.sectionTitle('Choices')
          OptionCards({ legend: 'How are you married?', group: 'regime', options: this.regimes, selected: this.regime, onSelect: (v: string) => { this.regime = v; } })
          LifaSegmentedControl({ label: 'Ask me every', options: this.intervals, selected: this.interval, onSelect: (v: string) => { this.interval = v; } })
          LifaSegmentedControl({ label: 'Billing period', options: this.billings, selected: this.billing, onSelect: (v: string) => { this.billing = v; } })
          LifaCard() {
            LifaToggleRow({ label: 'Pause while I travel', description: 'Up to 180 days', isOn: this.pause, onToggle: (v: boolean) => { this.pause = v; } }).id('pause-toggle')
            ForEach(this.fieldNames, (name: string, i: number) => {
              LifaCheckboxRow({ label: name, isOn: this.cardFields[i], onToggle: (v: boolean) => { const next = [...this.cardFields]; next[i] = v; this.cardFields = next; } })
            }, (name: string) => name)
          }
        }
        .alignItems(HorizontalAlign.Start)

        Column({ space: LifaSpace.space3 }) {
          this.sectionTitle('Navigation')
          LifaTabBar({ items: this.tabs, selected: this.tab, onSelect: (k: string) => { this.tab = k; } })
          this.sectionTitle('Disclosures')
          LifaDisclosure({ text: 'Lifa is not a law firm and does not give legal advice.' })
          LifaDisclosure({ text: 'Education only. Lifa does not recommend financial products.' })
        }
        .alignItems(HorizontalAlign.Start)
      }
      .padding(LifaSpace.space4)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(LifaColor.background)
    .id('gallery')
  }
}
