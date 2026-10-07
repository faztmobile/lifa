# Open questions

Status key: **OPEN** (blocks or shapes work), **PROPOSED** (default chosen, awaiting confirmation), **CLOSED**.
Sources: FRS v0.1 (7 Oct 2026), 25-screen UI reference, the engineering brief.

## A. Decisions needed before step 1 (architecture)

| # | Question | Proposed default | Status |
|---|---|---|---|
| A1 | Backend language and framework. The brief does not name one. | Kotlin + Spring Boot 3 (JVM 21). It shares the Android team's language and the generated Kotlin client, and has mature OIDC, Postgres and Service Bus support. Alternatives: .NET 8/10 (most Azure-native), or TypeScript/NestJS (shares the web toolchain). | OPEN |
| A2 | Identity provider. NFR-PRV-001 requires personal data to stay in South Africa. Microsoft Entra External ID does not guarantee SA-only residency for directory data. | Self-host Keycloak (pinned LTS) on AKS in South Africa North, behind APIM. We own MFA, device binding and step-up flows. | OPEN |
| A3 | IaC and CI/CD | Terraform (azurerm, pinned) + GitHub Actions (the repo is on GitHub). iOS jobs need macOS runners. HarmonyOS jobs need DevEco command-line tools on a self-hosted runner. | OPEN |
| A4 | Does R1 sell the **Family** tier? FR-SUB-002 (R1) says "sell Plus and Family". FRS 13 and the brief say R1 ships "Free and Plus". Most Family features (FR-WIL-014, FR-AST-006, FR-PRM-007, FR-SIM-002) are R2 or later. | R1 sells Free and Plus only. The Family entitlement keys exist in the model but are not purchasable. FR-SUB-002 is partly deferred, and this is logged as a deviation. | OPEN |
| A5 | UI languages in R1. The brief says UI strings ship in five languages. FR-ONB-008 is *Should/R2*, and NFR-LOC-001 says "five launch languages by R2". | R1 externalises all strings (ICU MessageFormat) and ships English. The other four locales go in as pseudo-locales for layout testing. Translations ship in R2 after native-speaker review (13.2). | OPEN |
| A6 | Is a **back-office console** in R1? FRS 8.2 lists one, but the brief names only five clients. R1 still needs support, account-recovery, deletion-window and malware-quarantine handling. | Minimal internal web console in R1 (support lookup by metadata only, no content). Full verification/activation console in R3. | OPEN |

## B. Vendor choices (the brief says not to add paid SDKs without asking)

| # | Need | Options | Status |
|---|---|---|---|
| B1 | Web card payments, hosted page, VAT invoices (FR-SUB-002/006) | Peach Payments, PayFast, Paystack (SA). | OPEN |
| B2 | SMS OTP with SIM-swap check (FRS 9.3) | Clickatell, BulkSMS, or Infobip (SIM-swap API). | OPEN |
| B3 | Transactional email | Azure Communication Services Email (data location must be checked), or SendGrid / Mailjet. | OPEN |
| B4 | Malware scanning (FR-VLT-008) | Microsoft Defender for Storage malware scanning (Azure-native, in-region), or ClamAV in-cluster. Proposed: ClamAV in the isolated pool, so no file content leaves our boundary. | PROPOSED |
| B5 | Will PDF rendering (FR-WIL-010, NFR-PRF-003) | Server-side, either Typst or headless-Chromium HTML-to-PDF. Proposed: Typst (deterministic and fast). | PROPOSED |

## C. FRS vs screen conflicts (the FRS wins; screens are adjusted for R1)

| # | Screen | Conflict | R1 handling |
|---|---|---|---|
| C1 | Home | The check-in banner ("Monthly check-in is due") is the dead man's switch, FR-DMS-* (R2). "+28 since September" is score history, FR-SCR-007 (R2). The "Simulate" tile is FR-SIM (R2). | Hidden behind entitlement and release flags in R1. |
| C2 | Home, Vault | "Passport expires in 41 days" is expiry tracking, FR-VLT-006 (R2). | Hidden in R1. |
| C3 | Residue step | "Add a testamentary trust clause" is FR-WIL-015 (Family, R3). | Keep the FR-WIL-007 minor warning (Plus, R1). Replace the link with educational text about the Guardian's Fund. |
| C4 | Statement extraction ("Check what we found") | FR-AST-005 is R2. The "Joint estate" ownership toggle is FR-AST-006 (Family, R2). | R1 reuses this form layout for **manual** asset entry, without extraction or a joint/separate split. |
| C5 | Release rule sheet, "Who sees what, and when" | FR-PRM-003 and FR-PRM-004 are R2. FR-VLT-007 is R2. R1 has deny-by-default ABAC (FR-PRM-001), revocation (FR-PRM-006) and access notifications (FR-PRM-005). | R1 ships the step-up prompt and the access notification ("Sipho opened your emergency card"). Release-rule editing waits for R2. Vault rows show no release labels. |
| C6 | Digital legacy, If I died today, Liquidity, Check-in, Family Wallet goals, Ask Lifa, Find a professional, Activation, Executor workspace, Beneficiary view | R2–R4 features | Not built in R1. Only the FR-WAL-001 net-worth snapshot (R1) appears, on the estate screen. |
| C7 | Plans | Shows the Family tier as purchasable (see A4). | Free and Plus only, unless A4 changes. |
| C8 | Family tree | Shows several accepted or pending role invitations. On Free, FR-PRM-002 allows **one** emergency contact. | Will nominations (executor, guardian) are `Nomination` records and do **not** count toward the role-grant limit. Only access `RoleGrant`s count. **Confirm (Q-D3).** |
| C9 | Review and sign | "Draft 2". Free gets "Draft, signing pack". Unlimited revisions and versions are Plus (FR-WIL-012). | See Q-D1. |
| C10 | Emergency card "Add to lock screen" vs FR-NTF-004 | FR-NTF-004 forbids estate content in lock-screen *notifications*. The card widget (FR-EMG-001) deliberately shows owner-chosen fields on the lock screen. | Treated as distinct. The widget is opt-in, shows only the fields chosen under FR-EMG-002, defaults to contacts only, and warns before "where my will is kept" is added. **Confirm (Q-D4).** |

## D. Product and legal questions (no rules or figures are invented; config uses `[VERIFY]` placeholders)

| # | Question | Status |
|---|---|---|
| D1 | What exactly does Free allow for will drafts: one editable draft that is overwritten, or a capped number of saved drafts? And is a second *signed* version allowed on Free? | OPEN |
| D2 | Legacy Score domain weights. The screens imply Will 25 / Assets 20 / Protection 20 / Family 20 / Documents 15. The FRS 13.5 says weights are still to be defined. I'll seed these as `[VERIFY]` configuration (FR-SCR-002). | PROPOSED |
| D3 | See C8: do will nominations count toward the Free/Plus trusted-person limits? | OPEN |
| D4 | See C10: emergency-card lock-screen defaults. | OPEN |
| D5 | The attorney-approved will clause templates (FR-WIL-009) do not exist yet. I'll build with clearly marked placeholder templates that cannot be used in production builds. When will templates arrive? | OPEN |
| D6 | Signing-pack legal content (witness age 14+, signing every page) is shown on screen. I'll hold it as `[VERIFY]` content pending attorney sign-off (13.2). | PROPOSED |
| D7 | Readiness questions (FR-SCR-001, at most 20; the screen shows 18). Is there a question bank, or should I draft one for review? | OPEN |
| D8 | Social sign-in (Apple / Google / Huawei ID via HMS Account Kit). FR-ONB-001 specifies mobile + email + password only. Proposed: no social sign-in in R1. Adding Google or Huawei login would also oblige us to offer Sign in with Apple on iOS. | PROPOSED |

## E. Known delivery constraints

- Native iOS builds and XCUITest need macOS/Xcode. HarmonyOS NEXT needs DevEco Studio / hvigor. Neither runs in this Linux cloud session, so iOS and HarmonyOS code is written here and verified in CI on the appropriate runners.
- Global edge and push services (Front Door, APNs, FCM, Huawei Push) handle traffic outside South Africa. This is acceptable only because payloads hold no personal or estate data (FR-NTF-004, NFR-PRV-001). This will be documented in the threat model.
