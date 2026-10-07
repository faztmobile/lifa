# 08. Platform mapping

Build order (D-011): **Android GMS + HMS → web → iOS → HarmonyOS NEXT.** Every client renders the same screens from
the same API and the same design tokens (step 2). Core flows are native, with no web views (brief). The only
exceptions are the Paystack hosted page (web) and the vendor liveness capture in FR-ONB-003, if the vendor offers only a hosted flow.

## 8.1 Capability matrix

| Capability | iOS | Android GMS | Android HMS | HarmonyOS NEXT | Web |
|---|---|---|---|---|---|
| UI | SwiftUI | Jetpack Compose (Material 3, custom theme) | same code | ArkUI | React + Vite |
| Auth (OIDC + PKCE) | MSAL iOS (native auth) | MSAL Android | MSAL Android (no GMS dependency) | System-browser OIDC + PKCE, AppAuth-style (no MSAL, A9) | web-bff (D-021) |
| Biometric unlock and step-up | LocalAuthentication + Secure Enclave key (`.biometryCurrentSet`) | BiometricPrompt + Keystore key `setUserAuthenticationRequired` | same | User Authentication Kit + HUKS key with auth access control | WebAuthn passkeys; TOTP fallback |
| Secure key storage | Keychain + Secure Enclave | Android Keystore, StrongBox if present | Android Keystore | HUKS | Non-extractable WebCrypto keys (only for the CSRF binding); tokens stay in the BFF |
| Attestation | App Attest | Play Integrity | HMS Safety Detect (SysIntegrity) | Device certificate / Device Security Kit | n/a |
| Push | APNs | FCM | Huawei Push Kit | Push Kit | Web Push (optional, later) |
| Billing | StoreKit 2 (`appAccountToken`) | Play Billing (`obfuscatedAccountId`) | Huawei IAP (`developerPayload`) | IAP Kit | Paystack hosted checkout |
| Emergency card widget | WidgetKit lock-screen and home widgets (App Group + shared Keychain for the widget token) | Glance widget | Glance widget | Service widget (form) | Printable card (PDF) |
| Encrypted cache | GRDB + SQLCipher | Room + SQLCipher | same | RelationalStore (encrypted) | memory only |
| Secure screens | Blur in the app switcher; `isSecureTextEntry` overlay trick to block screenshots of the vault | `FLAG_SECURE` | same | `setWindowPrivacyMode` | n/a |
| Certificate pinning | URLSession delegate (SPKI) | OkHttp `CertificatePinner` | same | `@ohos.net.http` certificate pinning | n/a (browser) |
| Root/jailbreak signals | Jailbreak heuristics + App Attest | Play Integrity verdict + heuristics | Safety Detect + heuristics | Device Security Kit | n/a |
| File picking and camera | PhotosPicker, VisionKit document scanner | Photo Picker, ML Kit document scanner (GMS) | Photo Picker, HMS ML Kit document scanning | Picker, camera kit | `<input type=file>` |
| Fonts | Sora, DM Sans bundled | bundled | bundled | bundled | self-hosted WOFF2 (no Google Fonts at runtime) |
| Dynamic type, dark mode | Dynamic Type, `colorScheme` | font scale, `isSystemInDarkTheme` | same | font scale, dark mode | `rem` + `prefers-color-scheme` |
| UI tests | XCUITest | Compose UI tests (+ Robolectric) | same, on the HMS flavour | ArkUI tests (Hypium) | Playwright |

## 8.2 Android product flavours

One codebase, two flavours (`gms`, `hms`) in a `distribution` dimension. Only these sit behind interfaces, each with
one implementation per flavour injected by Hilt:

```kotlin
interface BillingProvider     // Play Billing  | Huawei IAP
interface PushProvider        // FCM           | HMS Push Kit
interface IntegrityProvider   // Play Integrity| HMS Safety Detect
interface DocumentScanner     // ML Kit (GMS)  | HMS ML Kit
interface LocationProvider    // Fused         | HMS Location  (only if needed; R1/R2 has no location feature)
```
- Source sets: `src/gms/…`, `src/hms/…`. The `hms` flavour must have **no** `com.google.android.gms` or Firebase dependency. A Gradle dependency-check task fails the build if one appears.
- Two application IDs are not required; one ID (`za.co.lifa`) is distributed through both stores. `BuildConfig.CHANNEL` tells billing which `Channel` to report.
- Huawei AppGallery Connect config (`agconnect-services.json`) and Google config (`google-services.json`) are injected in CI from Key Vault secrets, never committed.
- Account Kit (Huawei ID) is **not** used for sign-in (D8). Identity is Entra on both flavours.
- Minimum SDK 29 (Android 10, NFR-DEV-001).

## 8.3 Module structure (Android)

```
:app                          single activity, navigation graph, flavour wiring
:core:api                     generated client + DPoP/step-up OkHttp interceptors
:core:security                device key, biometric, pinning, integrity, encrypted DB
:core:design                  generated theme (tokens) + component library
:core:data                    repositories, offline cache, sync
:core:entitlements            EntitlementSet flow; `requires(key)` UI helper (no plan names)
:feature:onboarding|score|will|estate|family|vault|access|emergency|checkin|simulation|plans|account
:provider:billing:{gms,hms}  :provider:push:{gms,hms}  :provider:integrity:{gms,hms}
:widget                       Glance emergency card
```
iOS mirrors this with SPM packages (`LifaAPI`, `LifaSecurity`, `LifaDesign`, `Feature*`), and HarmonyOS with HAR modules.

## 8.4 HarmonyOS NEXT notes and risks

- A separate native client (it does not run APKs). ArkTS's strict typing and its `@ohos.net.http` client mean the API layer is generated types plus a hand-written transport (04 §4.5).
- No MSAL: OIDC through the system browser with PKCE. Confirm Entra's redirect support (A9).
- CI needs DevEco command-line tools on a self-hosted runner (D-010). Signing certificates come from AppGallery Connect.
- Store review and SDK availability move quickly. Every Kit and API version is pinned in `oh-package.json5`, and its minimum API level is recorded in DECISIONS when it is chosen.

## 8.5 Web

- SPA served from Front Door, with a strict CSP (`default-src 'self'`, no third-party scripts on authenticated pages, FRS 9.1). The Paystack checkout is a top-level redirect, not an embedded iframe.
- web-bff (Kotlin, Spring) holds tokens in an encrypted Redis session. The cookie is `__Host-lifa-session` (HttpOnly, Secure, SameSite=Strict) with a double-submit CSRF token.
- Responsive layouts: phone layouts follow the 25 screens; tablet and desktop use a two-pane layout with left navigation in place of the bottom tab bar.
- WCAG 2.2 AA (NFR-ACC-001), checked with axe in Playwright on every screen.
