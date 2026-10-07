import { font } from '@kit.ArkUI';
import { LIFA_FONT_FILES } from '../generated/LifaTokens';

/** Registers the bundled Sora and DM Sans fonts. Each weight is its own family name (for example 'Sora-Bold'). */
export function registerLifaFonts(): void {
  LIFA_FONT_FILES.forEach((name: string) => {
    font.registerFont({ familyName: name, familySrc: $rawfile(`fonts/${name}.ttf`) });
  });
}
