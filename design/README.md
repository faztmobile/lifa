# Lifa design system (step 2)

One token file, generated themes for every client, the same component set on each platform, and a gallery screen on each.

```
design/tokens/tokens.json           single source (W3C Design Tokens format)
design/tokens/contrast-pairs.json   WCAG pairs checked in light and dark
design/icons/icons.json             Lucide 1.52.0 subset (ISC), shared by all clients
design/fonts/                       Sora 600/700 and DM Sans 400/500/700 (OFL), TTF + WOFF2
design/brand/                       app icon reference (see OPEN_QUESTIONS G1)
design/generators/build.mjs         → Compose, SwiftUI, ArkUI, CSS (Style Dictionary 5.6.0 + small templates)
design/generators/contrast.mjs      contrast gate
```

| Command | What it does |
|---|---|
| `npm run tokens:build` | Regenerates every platform's tokens, icons and font copies |
| `npm run tokens:check` | Fails if any generated file is stale (CI: design.yml) |
| `npm run tokens:test` | WCAG contrast check: 78/78 pairs pass (39 pairs × light/dark) |

## Generated outputs

| Client | Tokens | Icons | Fonts |
|---|---|---|---|
| Android GMS + HMS (Compose) | `clients/android/core/design/.../generated/LifaTokens.kt` | `res/drawable/lifa_ic_*.xml` + `LifaIcons.kt` | `res/font/*.ttf` |
| iOS (SwiftUI) | `clients/ios/LifaDesign/Sources/LifaDesign/Generated/LifaTokens.swift` | `Resources/Icons.xcassets` (template SVG) + `LifaIcons.swift` | `Resources/Fonts/*.ttf` |
| HarmonyOS NEXT (ArkUI) | `clients/harmony/design/.../generated/LifaTokens.ets` + `resources/{base,dark}/element/color.json` | `LifaIcons.ets` (path data drawn with Shape/Path) | `resources/rawfile/fonts/*.ttf` |
| Web + back office (CSS) | `clients/web/src/design/generated/tokens.css` (+ `tokens.ts`) | `lucide-react` (same set) | `public/fonts/*.woff2` |

Dark mode: every semantic colour has a dark value. Android and iOS resolve at runtime; HarmonyOS uses the `dark`
resource qualifier; CSS follows `prefers-color-scheme` unless `data-theme` is set.
Text scaling: type sizes are `sp` (Android), Dynamic Type-relative (iOS), `fp` (HarmonyOS) and `rem` (web).

## Colour decisions (D-043)

The brief's palette is used as given. Contrast testing showed three brand colours cannot carry text or control
boundaries on light surfaces, so accessible variants were added. **The brand colours stay for fills, icons and progress.**

| Brand colour | Problem on cream #F6F3EC | Variant added for text/boundaries |
|---|---|---|
| leaf #3E8A5A | 3.8:1 (text needs 4.5) | `leaf-text` #2F6E47, 5.5:1 |
| warning #A3620E | 4.4:1 | `warning-text` #8A520B, 5.8:1 |
| line #E4DED1 | 1.3:1 (input borders need 3:1, WCAG 1.4.11) | `line-strong` #7E8781, 3.3:1 |
| gold #D9B373 | 1.8:1 | decorative only; `gold-text` #7A5A1E (brand) for text |

All dark values are derived and tested to the same pairs.

## Fonts and the Tshivenda glyph gap (D-039)

Sora and DM Sans do **not** include ḓ ḽ ṅ ṋ ṱ (Tshivenda) or ŉ. The UI is English-only (D-013), but people's names
in the family tree, will and emergency card can contain them. Each platform falls back per glyph: web through the
font stack (`… "Noto Sans", system-ui`), Android/iOS/HarmonyOS through system font fallback. Every gallery shows a
fallback specimen ("Ṱhavhudzwi Muḓau") to check rendering. Will PDFs (Typst, D-019) must embed a font with full
coverage (proposed: Noto Sans/Serif); see OPEN_QUESTIONS G5.

## Components

The same 22 components exist on every platform, with the same props and behaviour.

| Component | Web | Compose | SwiftUI | ArkUI | Accessibility behaviour |
|---|---|---|---|---|---|
| Button (primary, secondary, text, destructive, dashed; loading) | `Button` | `LifaButton` | `LifaButton` / `LifaButtonStyle` | `LifaButton` | 56 high; compact 44 (web/iOS) or 48 (Android/HarmonyOS); loading announced |
| Badge, BasisBadge | `Badge`, `BasisBadge` | `LifaBadge`, `BasisBadge` | same | same | Text, never colour alone |
| LabelledValue | ✓ | ✓ | ✓ | ✓ | Amount + declared/evidenced/estimated (FRS principle 4) |
| Card | ✓ | `LifaCard` | `LifaCard` | `LifaCard` | — |
| HeroScoreCard | ✓ | ✓ | ✓ | ✓ | Heading + progress value |
| Banner | ✓ | `LifaBanner` | `LifaBanner` | `LifaBanner` | Wraps at large text |
| Callout (info, warning, critical) | ✓ | `LifaCallout` | `LifaCallout` | `LifaCallout` | Critical is announced (alert / live region / announcement) |
| ListRow | ✓ | `LifaListRow` | `LifaListRow` | `LifaListRow` | One focusable element; chevron when actionable |
| QuickActionTile | ✓ | ✓ | ✓ | ✓ | — |
| ProgressBar, StepProgress | ✓ | ✓ | ✓ | ✓ | progressbar role/value; "Step 3 of 7" |
| TextField | ✓ | `LifaTextField` | `LifaTextField` | `LifaTextField` | Label = accessible name; hint/error described |
| AllocationRow | ✓ | ✓ | ✓ | ✓ | Field named "Share for {person}"; wraps |
| OptionCards | ✓ (native radios) | ✓ (selectable, RadioButton role) | ✓ (Selected trait) | ✓ (native Radio) | One choice in a named group |
| SegmentedControl | ✓ (native radios) | ✓ | `LifaSegmentedControl` | `LifaSegmentedControl` | Wraps/stacks when labels do not fit |
| Switch / ToggleRow | ✓ (`role=switch`) | `LifaSwitchRow` | `LifaToggleRow` (native Toggle) | `LifaToggleRow` (native) | Whole row is the target |
| Checkbox row | ✓ (native) | `LifaCheckboxRow` | `LifaCheckboxRow` | `LifaCheckboxRow` (native) | Checked state announced |
| Avatar | ✓ | `LifaAvatar` | `LifaAvatar` | `LifaAvatar` | Hidden (name shown beside it) |
| TabBar | ✓ (`nav`, `aria-current`) | `LifaTabBar` (Tab role) | `LifaTabBar` | `LifaTabBar` | Selected state announced |
| Disclosure | ✓ | `LifaDisclosure` | `LifaDisclosure` | `LifaDisclosure` | Verbatim legal text (FRS 12.2) |
| Icon | `lucide-react` | `LifaIcon` | `LifaIcon.view()` | `LifaIcon` | Decorative unless labelled |

Formatting helpers are identical everywhere: `formatZar` ("R8,920,000", compact "R8.92m") and `formatDate`
("17 Nov 2026").

## Galleries

| Client | Where | Run |
|---|---|---|
| Web | `clients/web` (opens on the gallery) | `cd clients/web && npm ci && npm run dev` |
| Android | `:app` opens `LifaGallery` (both flavours) | `./gradlew :app:installGmsDebug` |
| iOS | `LifaApp` opens `LifaGalleryView` | `xcodegen generate && open Lifa.xcodeproj` |
| HarmonyOS | `entry` → `pages/Index` | DevEco Studio, or `hvigorw assembleHap` |

Each gallery has theme controls (system/light/dark) and text-size controls (web 100–200%, Android font scale,
iOS Dynamic Type up to AX3; HarmonyOS follows the system font size).

## Verification status

| Client | Built and tested here | Tests | Status |
|---|---|---|---|
| Tokens | ✓ | contrast 78/78; drift check; icon conversion pixel-identical to Lucide (24/24) | **Pass** |
| Web | ✓ | Playwright + axe 16/16 (phone + desktop: WCAG 2.2 AA light/dark, reflow at 320 px and 200% text, focus visible, 44 px targets, radio keys, AT-WIL-01 text); Vitest 6/6 | **Pass** |
| Android | ✗ — Google Maven (`dl.google.com`) blocked; ✓ in CI | Robolectric + Compose UI: 48 dp sweep, switch role, AT-WIL-01 text; Roborazzi light/dark/200%; store screenshots of the real gms and hms apps; hms has no Google services; format | **Pass** in CI (`android.yml`) |
| iOS | ✗ — no Xcode on Linux; ✓ in CI | Swift Testing (format, bundled fonts); XCUITest: full `performAccessibilityAudit` except Dynamic Type at default size, Dynamic Type + clipped text + contrast at AX-XXXL; screenshots light, dark, AX-XXXL; switch toggles | See note below (`ios.yml`, macOS) |
| HarmonyOS | ✗ — no DevEco/SDK | Hypium + UiTest: launch, 48 vp button, switch toggles, format | **First run in CI** (self-hosted DevEco runner) |

Tests run on the web found and fixed: a 52×32 switch target, inputs/grids that would not shrink at 200% text,
segmented controls that would not wrap, and centred text buttons. The same fixes were applied in the native
components (rows wrap, stacked fallbacks, 48 dp row targets).

Native screenshots found and fixed (7–8 Oct 2026): the iOS gallery forced the default text size, so it ignored
the system Dynamic Type setting; at AX-XXXL, button rows, quick actions, share fields, the tab bar and swatches
broke words. They now stack or adapt at accessibility sizes (`LifaAdaptiveStack`, `QuickActionGrid`,
`@ScaledMetric` field width, icon-only tab bar with the Large Content Viewer).

**iOS audit note.** At the default size the Dynamic Type audit, which raises the text size while the app runs,
reports "Dynamic Type font sizes are partially unsupported" on a different element each run (a swatch label,
then a segment label). Screenshots show no truncation, and the same audit passes when the app launches at
AX-XXXL. The default-size audit therefore runs every check except Dynamic Type. To revisit on a device with
Accessibility Inspector before release.

## Prototype screens

`clients/web/prototypes.html` renders one prototype screen per mobile journey (sign-up, home and score, will,
assets, vault step-up, emergency card, check-in, activation notice, executor checklist, plans), built only from the
design-system components and tokens. They are references for step 4, not the shipped apps. Regenerate the PNGs in
`docs/design/screens/prototypes/` with `npx vite --port 4180 --strictPort` and `node scripts/capture-prototypes.mjs`
(fails if any screen overflows 390 × 844). People and figures are fictional; plan prices are not shown because they
come from the store catalogue.
