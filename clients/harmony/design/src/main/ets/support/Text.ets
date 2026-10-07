// Text styling for ArkUI. @Extend functions cannot be exported, so styles are applied with an AttributeModifier.
import { LifaTextStyle } from '../generated/LifaTokens';

/** Usage: Text('Hello').attributeModifier(new LifaText(LifaTypography.body, LifaColor.text)) */
export class LifaText implements AttributeModifier<TextAttribute> {
  private style: LifaTextStyle;
  private color: ResourceColor;

  constructor(style: LifaTextStyle, color: ResourceColor) {
    this.style = style;
    this.color = color;
  }

  applyNormalAttribute(instance: TextAttribute): void {
    instance.fontFamily(this.style.fontFamily)
      .fontWeight(this.style.fontWeight)
      .fontSize(this.style.fontSize) // fp: follows the system font size (NFR-ACC-001)
      .lineHeight(this.style.lineHeight)
      .letterSpacing(this.style.letterSpacing)
      .fontColor(this.color);
  }
}
