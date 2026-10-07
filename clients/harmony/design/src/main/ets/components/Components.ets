// Lifa ArkUI components (step 2). Same set and behaviour as web, Compose and SwiftUI.
// Touch targets follow the 48 vp guidance used on Android (LifaSize.touchMinAndroid); brief minimum is 44.
import { LifaColor, LifaRadius, LifaSize, LifaSpace, LifaTypography } from '../generated/LifaTokens';
import { LifaText } from '../support/Text';
import { formatZar, ValueBasis } from '../support/Format';
import { LifaIcon } from './Icon';

export enum ButtonVariant { Primary, Secondary, Text, Destructive, Dashed }

@Component
export struct LifaButton {
  @Prop text: string = '';
  @Prop variant: ButtonVariant = ButtonVariant.Primary;
  @Prop fullWidth: boolean = false;
  @Prop compact: boolean = false;
  @Prop loading: boolean = false;
  @Prop isEnabled: boolean = true;
  @Prop icon: string = '';
  onTap: () => void = () => {};

  private bg(): ResourceColor {
    switch (this.variant) {
      case ButtonVariant.Primary: return LifaColor.primary;
      case ButtonVariant.Secondary: return LifaColor.surface;
      case ButtonVariant.Destructive: return LifaColor.critical;
      default: return Color.Transparent;
    }
  }

  private fg(): ResourceColor {
    switch (this.variant) {
      case ButtonVariant.Primary: return LifaColor.onPrimary;
      case ButtonVariant.Destructive: return LifaColor.surface;
      case ButtonVariant.Dashed: return LifaColor.text;
      default: return LifaColor.primary;
    }
  }

  build() {
    Row({ space: LifaSpace.space2 }) {
      if (this.loading) {
        LoadingProgress().width(18).height(18).color(this.fg())
      } else if (this.icon.length > 0) {
        LifaIcon({ name: this.icon, color: this.fg(), iconSize: 20 })
      }
      Text(this.text)
        .attributeModifier(new LifaText(this.variant === ButtonVariant.Dashed ? LifaTypography.label : LifaTypography.button, this.fg()))
        .decoration({ type: this.variant === ButtonVariant.Text ? TextDecorationType.Underline : TextDecorationType.None })
        .textAlign(this.variant === ButtonVariant.Text ? TextAlign.Start : TextAlign.Center)
    }
    .justifyContent(this.variant === ButtonVariant.Text ? FlexAlign.Start : FlexAlign.Center)
    .width(this.fullWidth ? '100%' : 'auto')
    .constraintSize({ minHeight: this.compact || this.variant === ButtonVariant.Text ? LifaSize.touchMinAndroid : LifaSize.buttonHeight, minWidth: LifaSize.touchMinAndroid })
    .padding({ left: this.variant === ButtonVariant.Text ? 0 : (this.compact ? LifaSpace.space4 : LifaSpace.space6),
      right: this.variant === ButtonVariant.Text ? 0 : (this.compact ? LifaSpace.space4 : LifaSpace.space6), top: LifaSpace.space2, bottom: LifaSpace.space2 })
    .backgroundColor(this.bg())
    .borderRadius(LifaRadius.md)
    .border({
      width: this.variant === ButtonVariant.Secondary || this.variant === ButtonVariant.Dashed ? LifaSize.border : 0,
      color: LifaColor.lineStrong,
      style: this.variant === ButtonVariant.Dashed ? BorderStyle.Dashed : BorderStyle.Solid
    })
    .opacity(this.isEnabled ? 1 : 0.5)
    .enabled(this.isEnabled && !this.loading)
    .stateStyles({ pressed: { .opacity(0.85) } })
    .onClick(() => this.onTap())
    .accessibilityGroup(true)
    .accessibilityText(this.loading ? `${this.text}, loading` : this.text)
  }
}

@Component
export struct QuickActionTile {
  @Prop icon: string = '';
  @Prop label: string = '';
  onTap: () => void = () => {};

  build() {
    Column({ space: LifaSpace.space2 }) {
      LifaIcon({ name: this.icon, color: LifaColor.primary })
      Text(this.label).attributeModifier(new LifaText(LifaTypography.label, LifaColor.text)).textAlign(TextAlign.Center)
    }
    .layoutWeight(1)
    .padding({ top: LifaSpace.space4, bottom: LifaSpace.space4, left: LifaSpace.space2, right: LifaSpace.space2 })
    .constraintSize({ minHeight: LifaSize.touchMinAndroid })
    .backgroundColor(LifaColor.surface)
    .borderRadius(LifaRadius.md)
    .border({ width: LifaSize.border, color: LifaColor.line })
    .onClick(() => this.onTap())
    .accessibilityGroup(true)
  }
}

export enum BadgeTone { Plan, Neutral, Success, Warning, Critical }

@Component
export struct LifaBadge {
  @Prop text: string = '';
  @Prop tone: BadgeTone = BadgeTone.Neutral;
  @Prop uppercase: boolean = true;

  private colors(): ResourceColor[] {
    switch (this.tone) {
      case BadgeTone.Plan: return [LifaColor.goldSoft, LifaColor.goldText];
      case BadgeTone.Success: return [LifaColor.leafSoft, LifaColor.leafText];
      case BadgeTone.Warning: return [LifaColor.warningSoft, LifaColor.warningText];
      case BadgeTone.Critical: return [LifaColor.criticalSoft, LifaColor.critical];
      default: return [LifaColor.background, LifaColor.textMuted];
    }
  }

  build() {
    Text(this.uppercase ? this.text.toUpperCase() : this.text)
      .attributeModifier(new LifaText(this.uppercase ? LifaTypography.overline : LifaTypography.caption, this.colors()[1]))
      .padding({ left: LifaSpace.space2, right: LifaSpace.space2, top: 2, bottom: 2 })
      .backgroundColor(this.colors()[0])
      .borderRadius(LifaRadius.pill)
      .border({ width: this.tone === BadgeTone.Neutral ? LifaSize.border : 0, color: LifaColor.line })
  }
}

/** FRS principle 4: every figure shows whether it is declared, evidenced or estimated. */
@Component
export struct BasisBadge {
  @Prop basis: ValueBasis = ValueBasis.Declared;

  build() {
    LifaBadge({
      text: this.basis,
      tone: this.basis === ValueBasis.Evidenced ? BadgeTone.Success : this.basis === ValueBasis.Estimated ? BadgeTone.Warning : BadgeTone.Neutral,
      uppercase: false
    })
  }
}

@Component
export struct LabelledValue {
  @Prop label: string = '';
  @Prop cents: number = 0;
  @Prop basis: ValueBasis = ValueBasis.Declared;
  @Prop compact: boolean = false;

  build() {
    Column({ space: 2 }) {
      Text(this.label).attributeModifier(new LifaText(LifaTypography.caption, LifaColor.textMuted))
      Flex({ wrap: FlexWrap.Wrap, alignItems: ItemAlign.Center }) {
        Text(formatZar(this.cents, this.compact)).attributeModifier(new LifaText(LifaTypography.title2, LifaColor.text)).margin({ right: LifaSpace.space2 })
        BasisBadge({ basis: this.basis })
      }
    }
    .alignItems(HorizontalAlign.Start)
    .accessibilityGroup(true)
  }
}

@Component
export struct LifaCard {
  @BuilderParam content: () => void = defaultContent;

  build() {
    Column({ space: LifaSpace.space3 }) {
      this.content()
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding(LifaSpace.space4)
    .backgroundColor(LifaColor.surface)
    .borderRadius(LifaRadius.lg)
    .border({ width: LifaSize.border, color: LifaColor.line })
  }
}

@Builder
function defaultContent() {
}

function range(n: number): number[] {
  const out: number[] = [];
  for (let i = 0; i < n; i++) {
    out.push(i);
  }
  return out;
}

@Component
export struct LifaProgressBar {
  @Prop value: number = 0;
  @Prop max: number = 100;
  @Prop label: string = '';
  @Prop onHero: boolean = false;

  build() {
    Stack({ alignContent: Alignment.Start }) {
      Row()
        .width(`${Math.min(100, Math.max(0, this.value / this.max * 100))}%`)
        .height(LifaSize.progressHeight)
        .borderRadius(LifaRadius.pill)
        .backgroundColor(this.onHero ? LifaColor.heroAccent : LifaColor.leaf)
    }
    .width('100%')
    .height(LifaSize.progressHeight)
    .borderRadius(LifaRadius.pill)
    .backgroundColor(this.onHero ? LifaColor.heroInset : LifaColor.line)
    .accessibilityText(`${this.label}, ${Math.round(this.value / this.max * 100)} percent`)
  }
}

/** Wizard progress, for example "My will · Step 3 of 7" (FR-WIL-001). */
@Component
export struct StepProgress {
  @Prop current: number = 1;
  @Prop total: number = 7;

  build() {
    Row({ space: LifaSpace.space1 }) {
      ForEach(range(this.total), (i: number) => {
        Row().layoutWeight(1).height(4).borderRadius(LifaRadius.pill).backgroundColor(i < this.current ? LifaColor.primary : LifaColor.line)
      }, (i: number) => i.toString())
    }
    .width('100%')
    .accessibilityGroup(true)
    .accessibilityText(`Step ${this.current} of ${this.total}`)
  }
}

export interface HeroTile {
  label: string;
  value: string;
}

/** Home Legacy Score card (FR-SCR-002). */
@Component
export struct HeroScoreCard {
  @Prop score: number = 0;
  @Prop delta: string = '';
  @Prop tiles: HeroTile[] = [];

  build() {
    Column({ space: LifaSpace.space4 }) {
      Text('Legacy Score').attributeModifier(new LifaText(LifaTypography.label, LifaColor.onHeroMuted))
      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.End }) {
        Row() {
          Text(`${this.score}`).attributeModifier(new LifaText(LifaTypography.display, LifaColor.onHero))
          Text(' /100').attributeModifier(new LifaText(LifaTypography.title2, LifaColor.onHeroMuted))
        }
        .alignItems(VerticalAlign.Bottom)
        .accessibilityGroup(true)
        if (this.delta.length > 0) {
          Text(this.delta).attributeModifier(new LifaText(LifaTypography.label, LifaColor.heroPositive)).fontWeight(FontWeight.Bold)
        }
      }
      LifaProgressBar({ value: this.score, label: 'Legacy Score', onHero: true })
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.tiles, (t: HeroTile) => {
          Column() {
            Text(t.label).attributeModifier(new LifaText(LifaTypography.caption, LifaColor.onHeroMuted))
            Text(t.value).attributeModifier(new LifaText(LifaTypography.title2, LifaColor.onHero))
          }
          .alignItems(HorizontalAlign.Start)
          .flexGrow(1)
          .flexBasis(140)
          .margin({ right: LifaSpace.space3, bottom: LifaSpace.space3 })
          .padding(LifaSpace.space3)
          .borderRadius(LifaRadius.md)
          .backgroundColor(LifaColor.heroInset)
          .accessibilityGroup(true)
        }, (t: HeroTile) => t.label)
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding(LifaSpace.space5)
    .borderRadius(LifaRadius.xl)
    .backgroundColor(LifaColor.hero)
  }
}

/** Slim banner, for example "Monthly check-in is due · I'm still here" (FR-DMS-002). */
@Component
export struct LifaBanner {
  @Prop text: string = '';
  @Prop icon: string = '';
  @BuilderParam action: () => void = defaultContent;

  build() {
    Flex({ wrap: FlexWrap.Wrap, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
      Row({ space: LifaSpace.space3 }) {
        if (this.icon.length > 0) {
          LifaIcon({ name: this.icon, color: LifaColor.text, iconSize: 20 })
        }
        Text(this.text).attributeModifier(new LifaText(LifaTypography.body, LifaColor.text))
      }
      .flexShrink(1)
      this.action()
    }
    .width('100%')
    .padding({ left: LifaSpace.space4, right: LifaSpace.space4, top: LifaSpace.space3, bottom: LifaSpace.space3 })
    .borderRadius(LifaRadius.md)
    .backgroundColor(LifaColor.leafSoft)
  }
}

export enum CalloutTone { Info, Warning, Critical }

@Component
export struct LifaCallout {
  @Prop title: string = '';
  @Prop tone: CalloutTone = CalloutTone.Info;
  @Prop message: string = '';
  @BuilderParam action: () => void = defaultContent;

  private bg(): ResourceColor {
    return this.tone === CalloutTone.Warning ? LifaColor.warningSoft : this.tone === CalloutTone.Critical ? LifaColor.criticalSoft : LifaColor.leafSoft;
  }

  private borderColor(): ResourceColor {
    return this.tone === CalloutTone.Warning ? LifaColor.warning : this.tone === CalloutTone.Critical ? LifaColor.critical : LifaColor.leafSoft;
  }

  private tint(): ResourceColor {
    return this.tone === CalloutTone.Warning ? LifaColor.warningText : this.tone === CalloutTone.Critical ? LifaColor.critical : LifaColor.leafText;
  }

  private iconName(): string {
    return this.tone === CalloutTone.Warning ? 'triangle-alert' : this.tone === CalloutTone.Critical ? 'circle-alert' : 'info';
  }

  build() {
    Row({ space: LifaSpace.space3 }) {
      LifaIcon({ name: this.iconName(), color: this.tint(), iconSize: 22 })
      Column({ space: LifaSpace.space1 }) {
        Text(this.title).attributeModifier(new LifaText(LifaTypography.bodyStrong, LifaColor.text))
        if (this.message.length > 0) {
          Text(this.message).attributeModifier(new LifaText(LifaTypography.body, LifaColor.text))
        }
        this.action()
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
    .padding(LifaSpace.space4)
    .borderRadius(LifaRadius.lg)
    .backgroundColor(this.bg())
    .border({ width: LifaSize.border, color: this.borderColor() })
  }
}

export enum RowIndicator { None, Warning, Critical, Success }

/** List row, for example "Name an alternate guardian · Adds 3 points". Clickable rows get a chevron. */
@Component
export struct LifaListRow {
  @Prop title: string = '';
  @Prop subtitle: string = '';
  @Prop indicator: RowIndicator = RowIndicator.None;
  @Prop clickable: boolean = false;
  @BuilderParam leading: () => void = defaultContent;
  @BuilderParam trailing: () => void = defaultContent;
  onTap: () => void = () => {};

  build() {
    Row({ space: LifaSpace.space3 }) {
      if (this.indicator !== RowIndicator.None) {
        Circle({ width: 10, height: 10 })
          .fill(this.indicator === RowIndicator.Warning ? LifaColor.warning : this.indicator === RowIndicator.Critical ? LifaColor.critical : LifaColor.leaf)
          .accessibilityLevel('no')
      }
      this.leading()
      Flex({ wrap: FlexWrap.Wrap, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
        Column() {
          Text(this.title).attributeModifier(new LifaText(LifaTypography.bodyStrong, LifaColor.text))
          if (this.subtitle.length > 0) {
            Text(this.subtitle).attributeModifier(new LifaText(LifaTypography.label, LifaColor.textMuted))
          }
        }
        .alignItems(HorizontalAlign.Start)
        .flexShrink(1)
        this.trailing()
      }
      .layoutWeight(1)
      if (this.clickable) {
        LifaIcon({ name: 'chevron-right', color: LifaColor.textMuted, iconSize: 20 })
      }
    }
    .width('100%')
    .constraintSize({ minHeight: LifaSize.touchMinAndroid })
    .padding(LifaSpace.space4)
    .backgroundColor(LifaColor.surface)
    .borderRadius(LifaRadius.md)
    .border({ width: LifaSize.border, color: LifaColor.line })
    .onClick(() => { if (this.clickable) { this.onTap(); } })
    .accessibilityGroup(true)
  }
}

export enum AvatarTone { Green, Gold, Lavender }

/** Initials avatar. Decorative: the person's name is always shown next to it. */
@Component
export struct LifaAvatar {
  @Prop initials: string = '';
  @Prop tone: AvatarTone = AvatarTone.Green;

  build() {
    Text(this.initials)
      .attributeModifier(new LifaText(LifaTypography.label,
        this.tone === AvatarTone.Gold ? LifaColor.avatarGoldFg : this.tone === AvatarTone.Lavender ? LifaColor.avatarLavenderFg : LifaColor.avatarGreenFg))
      .fontWeight(FontWeight.Bold)
      .textAlign(TextAlign.Center)
      .width(LifaSize.avatar)
      .height(LifaSize.avatar)
      .borderRadius(LifaRadius.pill)
      .backgroundColor(this.tone === AvatarTone.Gold ? LifaColor.avatarGoldBg : this.tone === AvatarTone.Lavender ? LifaColor.avatarLavenderBg : LifaColor.avatarGreenBg)
      .accessibilityLevel('no')
  }
}

/** Mandatory disclosure (FRS 12.2, FR-WIL-018). Text comes from content and is rendered verbatim. */
@Component
export struct LifaDisclosure {
  @Prop text: string = '';

  build() {
    Text(this.text).attributeModifier(new LifaText(LifaTypography.caption, LifaColor.textMuted)).textAlign(TextAlign.Center).width('100%')
  }
}
