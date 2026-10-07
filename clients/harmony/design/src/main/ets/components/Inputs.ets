// Lifa ArkUI input components. Native TextInput, Radio, Toggle and Checkbox keep screen-reader roles correct.
import { LifaColor, LifaRadius, LifaSize, LifaSpace, LifaTypography } from '../generated/LifaTokens';
import { LifaText } from '../support/Text';
import { AvatarTone, LifaAvatar } from './Components';
import { LifaIcon } from './Icon';

/** Text field with a visible label (also its accessible text), hint and error. Border uses line-strong (3:1). */
@Component
export struct LifaTextField {
  @Prop label: string = '';
  @Prop value: string = '';
  @Prop hint: string = '';
  @Prop hintPositive: boolean = false;
  @Prop errorText: string = '';
  @Prop suffix: string = '';
  @Prop inputType: InputType = InputType.Normal;
  @Prop compact: boolean = false;
  @Prop showLabel: boolean = true;
  @State private focused: boolean = false;
  onValueChange: (v: string) => void = () => {};

  build() {
    Column({ space: LifaSpace.space1 }) {
      if (this.showLabel) {
        Text(this.label).attributeModifier(new LifaText(LifaTypography.label, LifaColor.text)).accessibilityLevel('no')
      }
      Row({ space: LifaSpace.space2 }) {
        TextInput({ text: this.value })
          .type(this.inputType)
          .layoutWeight(1)
          .backgroundColor(Color.Transparent)
          .padding(0)
          .fontFamily(LifaTypography.body.fontFamily)
          .fontSize(LifaTypography.body.fontSize)
          .fontColor(LifaColor.text)
          .caretColor(LifaColor.primary)
          .textAlign(this.compact ? TextAlign.End : TextAlign.Start)
          .onChange((v: string) => this.onValueChange(v))
          .onFocus(() => { this.focused = true; })
          .onBlur(() => { this.focused = false; })
          .accessibilityText(this.label)
          .accessibilityDescription(this.errorText.length > 0 ? this.errorText : this.hint)
        if (this.suffix.length > 0) {
          Text(this.suffix).attributeModifier(new LifaText(LifaTypography.body, LifaColor.textMuted)).accessibilityLevel('no')
        }
      }
      .width(this.compact ? 96 : '100%')
      .constraintSize({ minHeight: this.compact ? LifaSize.touchMinAndroid : LifaSize.inputHeight })
      .padding({ left: this.compact ? LifaSpace.space3 : LifaSpace.space4, right: this.compact ? LifaSpace.space3 : LifaSpace.space4 })
      .backgroundColor(LifaColor.surface)
      .borderRadius(LifaRadius.sm)
      .border({
        width: this.focused ? LifaSize.focusRing : LifaSize.border,
        color: this.focused ? LifaColor.focus : (this.errorText.length > 0 ? LifaColor.critical : LifaColor.lineStrong)
      })
      if (this.hint.length > 0) {
        Text(this.hint).attributeModifier(new LifaText(LifaTypography.caption, this.hintPositive ? LifaColor.leafText : LifaColor.textMuted))
      }
      if (this.errorText.length > 0) {
        Text(this.errorText).attributeModifier(new LifaText(LifaTypography.caption, LifaColor.critical))
      }
    }
    .alignItems(HorizontalAlign.Start)
  }
}

/** One person's residue share (FR-WIL-003). Wraps at large font sizes. */
@Component
export struct AllocationRow {
  @Prop initials: string = '';
  @Prop tone: AvatarTone = AvatarTone.Green;
  @Prop name: string = '';
  @Prop detail: string = '';
  @Prop value: string = '';
  onValueChange: (v: string) => void = () => {};

  build() {
    Flex({ wrap: FlexWrap.Wrap, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
      Row({ space: LifaSpace.space3 }) {
        LifaAvatar({ initials: this.initials, tone: this.tone })
        Column() {
          Text(this.name).attributeModifier(new LifaText(LifaTypography.bodyStrong, LifaColor.text))
          Text(this.detail).attributeModifier(new LifaText(LifaTypography.caption, LifaColor.textMuted))
        }
        .alignItems(HorizontalAlign.Start)
      }
      .flexShrink(1)
      .margin({ bottom: LifaSpace.space2 })
      LifaTextField({
        label: `Share for ${this.name}`, value: this.value, suffix: '%', inputType: InputType.NUMBER_DECIMAL,
        compact: true, showLabel: false, onValueChange: (v: string) => this.onValueChange(v)
      })
    }
    .width('100%')
  }
}

export interface ChoiceOption {
  value: string;
  label: string;
  hint?: string;
}

/** Single choice as cards, for example "How are you married?" (FR-WIL-002). Uses native Radio buttons. */
@Component
export struct OptionCards {
  @Prop legend: string = '';
  @Prop group: string = 'options';
  @Prop options: ChoiceOption[] = [];
  @Prop selected: string = '';
  onSelect: (v: string) => void = () => {};

  build() {
    Column({ space: LifaSpace.space3 }) {
      Text(this.legend).attributeModifier(new LifaText(LifaTypography.label, LifaColor.text))
      ForEach(this.options, (o: ChoiceOption) => {
        Row({ space: LifaSpace.space3 }) {
          Radio({ value: o.value, group: this.group })
            .checked(o.value === this.selected)
            .radioStyle({ checkedBackgroundColor: LifaColor.primary, uncheckedBorderColor: LifaColor.lineStrong })
            .onChange((isChecked: boolean) => { if (isChecked) { this.onSelect(o.value); } })
            .accessibilityText(o.label)
          Column() {
            Text(o.label).attributeModifier(new LifaText(LifaTypography.body, LifaColor.text))
            if (o.hint !== undefined) {
              Text(o.hint).attributeModifier(new LifaText(LifaTypography.caption, LifaColor.textMuted))
            }
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
        }
        .width('100%')
        .constraintSize({ minHeight: LifaSize.inputHeight })
        .padding({ left: LifaSpace.space4, right: LifaSpace.space4, top: LifaSpace.space3, bottom: LifaSpace.space3 })
        .backgroundColor(LifaColor.surface)
        .borderRadius(LifaRadius.md)
        .border({ width: o.value === this.selected ? 2 : LifaSize.border, color: o.value === this.selected ? LifaColor.primary : LifaColor.lineStrong })
        .onClick(() => this.onSelect(o.value))
      }, (o: ChoiceOption) => o.value)
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
  }
}

/** Segmented control (30/60/90 days; Monthly/Yearly). Wraps when labels do not fit at large font sizes. */
@Component
export struct LifaSegmentedControl {
  @Prop label: string = '';
  @Prop options: ChoiceOption[] = [];
  @Prop selected: string = '';
  onSelect: (v: string) => void = () => {};

  build() {
    Flex({ wrap: FlexWrap.Wrap }) {
      ForEach(this.options, (o: ChoiceOption) => {
        Text(o.label)
          .attributeModifier(new LifaText(LifaTypography.label, o.value === this.selected ? LifaColor.onPrimary : LifaColor.text))
          .fontWeight(o.value === this.selected ? FontWeight.Bold : FontWeight.Medium)
          .textAlign(TextAlign.Center)
          .flexGrow(1)
          .constraintSize({ minHeight: LifaSize.touchMinAndroid })
          .padding({ left: LifaSpace.space3, right: LifaSpace.space3 })
          .margin(2)
          .borderRadius(LifaRadius.sm)
          .backgroundColor(o.value === this.selected ? LifaColor.primary : Color.Transparent)
          .onClick(() => this.onSelect(o.value))
          .accessibilityText(o.value === this.selected ? `${o.label}, selected` : o.label)
      }, (o: ChoiceOption) => o.value)
    }
    .width('100%')
    .padding(2)
    .backgroundColor(LifaColor.background)
    .borderRadius(LifaRadius.md)
    .border({ width: LifaSize.border, color: LifaColor.lineStrong })
    .accessibilityDescription(this.label)
  }
}

/** Native switch; the whole row is the touch target. */
@Component
export struct LifaToggleRow {
  @Prop label: string = '';
  @Prop description: string = '';
  @Prop isOn: boolean = false;
  onToggle: (v: boolean) => void = () => {};

  build() {
    Row({ space: LifaSpace.space3 }) {
      Column() {
        Text(this.label).attributeModifier(new LifaText(LifaTypography.body, LifaColor.text))
        if (this.description.length > 0) {
          Text(this.description).attributeModifier(new LifaText(LifaTypography.caption, LifaColor.textMuted))
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      Toggle({ type: ToggleType.Switch, isOn: this.isOn })
        .selectedColor(LifaColor.primary)
        .switchPointColor(LifaColor.surface)
        .onChange((v: boolean) => this.onToggle(v))
        .accessibilityText(this.label)
    }
    .width('100%')
    .constraintSize({ minHeight: LifaSize.touchMinAndroid })
  }
}

@Component
export struct LifaCheckboxRow {
  @Prop label: string = '';
  @Prop isOn: boolean = false;
  onToggle: (v: boolean) => void = () => {};

  build() {
    Row({ space: LifaSpace.space3 }) {
      Checkbox({ name: this.label })
        .select(this.isOn)
        .selectedColor(LifaColor.primary)
        .unselectedColor(LifaColor.lineStrong)
        .onChange((v: boolean) => this.onToggle(v))
        .accessibilityText(this.label)
      Text(this.label).attributeModifier(new LifaText(LifaTypography.body, LifaColor.text)).accessibilityLevel('no')
    }
    .width('100%')
    .constraintSize({ minHeight: LifaSize.touchMinAndroid })
    .onClick(() => this.onToggle(!this.isOn))
  }
}

export interface TabItem {
  key: string;
  label: string;
  icon: string;
}

/** Bottom tab bar: Home, Will, Vault, Family, Account (brief). */
@Component
export struct LifaTabBar {
  @Prop items: TabItem[] = [];
  @Prop selected: string = '';
  onSelect: (key: string) => void = () => {};

  build() {
    Row() {
      ForEach(this.items, (t: TabItem) => {
        Column({ space: 2 }) {
          LifaIcon({ name: t.icon, color: t.key === this.selected ? LifaColor.primary : LifaColor.textMuted })
          Text(t.label)
            .attributeModifier(new LifaText(LifaTypography.caption, t.key === this.selected ? LifaColor.primary : LifaColor.textMuted))
            .fontWeight(t.key === this.selected ? FontWeight.Bold : FontWeight.Normal)
            .textAlign(TextAlign.Center)
        }
        .layoutWeight(1)
        .constraintSize({ minHeight: LifaSize.tabBarHeight })
        .justifyContent(FlexAlign.Center)
        .onClick(() => this.onSelect(t.key))
        .accessibilityGroup(true)
        .accessibilityText(t.key === this.selected ? `${t.label}, selected` : t.label)
      }, (t: TabItem) => t.key)
    }
    .width('100%')
    .backgroundColor(LifaColor.surface)
    .border({ width: { top: LifaSize.border }, color: LifaColor.line })
  }
}
