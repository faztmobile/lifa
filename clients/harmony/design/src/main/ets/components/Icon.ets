import { LIFA_ICONS } from '../generated/LifaIcons';
import { LifaSize } from '../generated/LifaTokens';

/** Lucide icon drawn as stroked paths, so the colour follows the theme. Decorative by default. */
@Component
export struct LifaIcon {
  @Prop name: string = 'info';
  @Prop color: ResourceColor = Color.Black;
  @Prop iconSize: number = LifaSize.icon;
  @Prop label: string = '';

  build() {
    Shape() {
      ForEach(LIFA_ICONS[this.name] ?? [], (d: string) => {
        Path().commands(d)
      }, (d: string) => d)
    }
    .viewPort({ x: 0, y: 0, width: 24, height: 24 })
    .width(this.iconSize)
    .height(this.iconSize)
    .fill(Color.Transparent)
    .stroke(this.color)
    .strokeWidth(2)
    .strokeLineCap(LineCapStyle.Round)
    .strokeLineJoin(LineJoinStyle.Round)
    .accessibilityLevel(this.label.length > 0 ? 'yes' : 'no')
    .accessibilityText(this.label)
  }
}
