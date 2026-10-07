import { describe, it, expect } from '@ohos/hypium';
import { abilityDelegatorRegistry, Component, Driver, MatchPattern, ON } from '@kit.TestKit';
import { Want } from '@kit.AbilityKit';
import { formatZar } from '@lifa/design';

// ArkUI tests for the gallery (step 2): launch, key components present, switch toggles, and formatting parity.
export default function galleryTest() {
  describe('LifaGallery', () => {
    it('formats ZAR like the other platforms', 0, () => {
      expect(formatZar(892000000)).assertEqual('R8,920,000');
      expect(formatZar(892000000, true)).assertEqual('R8.92m');
      expect(formatZar(51000000, true)).assertEqual('R510k');
    });

    it('launches the gallery and toggles the travel pause switch', 0, async () => {
      const delegator = abilityDelegatorRegistry.getAbilityDelegator();
      const want: Want = { bundleName: 'za.co.lifa', abilityName: 'EntryAbility' };
      await delegator.startAbility(want);
      const driver = Driver.create();
      await driver.delayMs(1500);
      const title: Component = await driver.findComponent(ON.id('gallery-title'));
      expect(title !== null).assertTrue();
      const button: Component = await driver.findComponent(ON.id('primary-button'));
      const rect = await button.getBounds();
      expect(rect.bottom - rect.top >= vp2px(48)).assertTrue(); // bounds are px; 48 vp touch target
      const toggle: Component = await driver.scrollSearch(ON.type('Toggle'));
      const before = await toggle.isChecked();
      await toggle.click();
      expect(await toggle.isChecked()).assertEqual(!before);
      await driver.screenCap('/data/storage/el2/base/cache/gallery.png');
    });
  });
}
