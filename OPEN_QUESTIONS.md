# Open questions

Status key: **OPEN** (blocks or shapes work), **PROPOSED** (default chosen, awaiting confirmation), **CLOSED** (answered; see the linked decision).
Sources: FRS v0.1 (7 Oct 2026), 25-screen UI reference, the engineering brief, and the owner's answers of 7 Oct 2026.

## A. Architecture

| # | Question | Answer / proposed default | Status |
|---|---|---|---|
| A1 | Backend language | Kotlin + Spring Boot (D-008) | CLOSED |
| A2 | Identity provider and residency | Entra External ID (D-009). **Action for the owner:** file Microsoft's written residency confirmation (tenant region, and which data such as MFA phone numbers, logs and telemetry stays in South Africa) in `docs/compliance/`. | CLOSED, evidence needed |
| A3 | IaC and CI | Terraform + GitHub Actions, Android first (D-010, D-011) | CLOSED |
| A4 | Family tier in the first release | Yes: R1 and R2 are built together as "Release A" (D-012) | CLOSED |
| A5 | UI languages | English only (D-013). Deviation from FR-ONB-008 and NFR-LOC-001. | CLOSED |
| A6 | Back-office console | Included (D-014) | CLOSED |
| A7 | **New.** Release A includes the dead man's switch and death/incapacity release rules (R2), but activation (FR-ACT) is R3 and gated on a red-team test. Proposed: verification cases open and Operations can review them, but no activation or release happens until R3 (D-023). Until then the UI tells the family that Lifa Operations will contact them. Is this acceptable, or should FR-ACT move into Release A? | Activation built now (D-027), switched on after the red-team gate (D-026) | CLOSED |
| A8 | **New.** Azure Key Vault Managed HSM per-owner keys: FRS 9.1 calls for one key-encryption key (KEK) per owner. At 150k–600k owners, Managed HSM key-count limits and per-operation cost must be confirmed with Microsoft. Fallback: three-tier hierarchy (HSM root, then a per-owner KEK stored wrapped in a dedicated Postgres table that is excluded from long-lived backups, then data keys). See threat-model V-K3. | Confirmed by the owner (D-028) | CLOSED |
| A9 | **New.** HarmonyOS NEXT has no Microsoft MSAL library, so it will use plain OIDC with PKCE through the system browser. Please confirm with Microsoft that Entra External ID permits this redirect scheme for HarmonyOS. | Proposed | OPEN |

## B. Vendors

| # | Need | Answer | Status |
|---|---|---|---|
| B1 | Web card payments | Paystack (D-019) | CLOSED |
| B2 | SMS + SIM-swap check | Clickatell (D-019). Confirm that the SIM-swap API covers Vodacom, MTN, Cell C and Telkom. | CLOSED |
| B3 | Email | Azure Communication Services Email (D-019). Confirm that the data location can be set to South Africa or Africa. | CLOSED |
| B4 | Malware scanning | ClamAV (D-019) | CLOSED |
| B5 | PDF rendering | Typst (D-019) | CLOSED |
| B6 | **New (R2, FR-ONB-003).** Identity verification provider (ID document scan + liveness, linked to Home Affairs). Options: Smile ID, VerifyNow, or a DHA-linked bureau (XDS, TransUnion). Paid. | Integrate later (D-029) | DEFERRED |
| B7 | **New (R2, FR-AST-005).** Statement OCR and extraction. Options: Azure AI Document Intelligence (confirm availability in South Africa North), or self-hosted (Tesseract plus a layout model) in pool B. Must reach ≥95% field accuracy on the 500-statement test set (13.2). Who supplies the 500 statements, and with what consent? | Integrate later (D-029) | DEFERRED |

## C. FRS vs screen conflicts (the FRS wins). Updated for Release A (R1 + R2)

| # | Screen | Conflict | Release A handling |
|---|---|---|---|
| C1 | Home | The check-in banner (FR-DMS, R2), the score trend (FR-SCR-007, R2) and the Simulate tile (FR-SIM, R2) are now **in scope**. | Built as designed. Each element is gated by entitlement keys. |
| C2 | Home, Vault | Passport expiry (FR-VLT-006, R2) is now in scope. | Built |
| C3 | Residue step | "Add a testamentary trust clause" is FR-WIL-015 (Family) | Now in scope (D-026): the link opens trust-clause drafting on Family, and the upgrade prompt otherwise |
| C4 | Check what we found | Extraction (FR-AST-005) and joint/separate split (FR-AST-006) are now in scope. | Built. Depends on B7. |
| C5 | Release rules, Who sees what | FR-PRM-003, FR-PRM-004 and FR-VLT-007 are now in scope. | Built. Death and incapacity rules stay inert until R3 (A7). |
| C6 | Digital legacy, Ask Lifa, Find a professional, Activation, Executor workspace, Beneficiary view, Wallet goals, "Use scenario B for a new draft" | Now in scope (D-026) | Built as designed, each behind its release flag |
| C7 | Plans | Family is shown as purchasable | Now correct (A4) |
| C8 | Family tree roles | — | D-016 |
| C9 | Review and sign, "Draft 2" | On Free there is only one draft (D-015), so the label shows "Draft" without a number on Free. | Built per D-015 |
| C10 | Emergency card on the lock screen | — | D-017 |
| C11 | **New.** Liquidity screen | It shows Family-level detail (full breakdown). FR-LIQ-003 tiers the view: Free sees yes/no, Plus sees the gap amount, Family sees the breakdown. | The API returns only the fields the caller's tier allows; the server enforces this. |
| C12 | "Ways families close a gap" on the liquidity screen | FR-LIQ-004 now in scope | Built, including "Talk to a licensed adviser" (marketplace, FR-MKT-007) |

## D. Product and legal

| # | Question | Status |
|---|---|---|
| D1 | Free will: is the D-015 interpretation right? A new signing on Free supersedes the previous signed version, which is kept but not shown. | CLOSED (D-015 confirmed) |
| D2 | Score weights 25/20/20/20/15 | CLOSED (D-018) |
| D3 | Do will nominations count toward the trusted-person limit? You answered "Yes" to a two-part question. I've taken it as agreement with my proposal, so **nominations don't count** (D-016). Please confirm. | CLOSED (D-016 confirmed) |
| D4 | Emergency-card lock-screen defaults | CLOSED (D-017) |
| D5 | Attorney-approved will templates exist. **Action:** please add them, including the codicil (FR-WIL-013) and mirror-will (FR-WIL-014) templates and the template-set version, to `content/will-templates/` or share them. Until then, development uses placeholders that production builds refuse. | DEFERRED (D-030) |
| D6 | Signing-pack legal wording (witnesses 14 or older, sign every page) | Covered by the attorney templates once delivered |
| D7 | Readiness question bank (FR-SCR-001, at most 20 questions). This wasn't answered. Should I draft 18 questions mapped to the five score domains for your review? | DEFERRED (D-030) |
| D8 | No social sign-in in Release A | PROPOSED |
| D9 | **New (R2).** Tax and cost rule tables (estate duty abatement and rates, spousal deduction, CGT on death, executor tariff, Master's fees, conveyancing) for FR-SIM and FR-LIQ. I won't invent figures. The schema ships with `[VERIFY]` values that a tax practitioner must fill in and Compliance must approve (NFR-MNT-001, FRS 12.4). Who is the tax practitioner? | DEFERRED (D-030) |
| D10 | **New (R2).** Dead-man's-switch verifiers: how many can be named on Plus? FR-DMS-005 implies at least two on Family. Proposed: up to 3 on Plus, unlimited on Family. Verifiers would also not count as role holders, because they see nothing (FR-DMS-003). | PROPOSED |

## F. New with full scope (R3 + R4, D-026)

| # | Question | Proposed default | Status |
|---|---|---|---|
| A10 | LLM provider for the AI adviser | OpenAI models, preferably through Azure OpenAI in South Africa North (D-036). Remaining: confirm the chosen model is available in that region, otherwise contract the OpenAI API with zero data retention plus a s72 agreement. | CLOSED (route to confirm) |
| A11 | Activation SLA and staffing | Two Operations reviewers; alert at 1 business day (D-038). A backup reviewer is recommended. | CLOSED |
| B8 | Marketplace payments | Paystack split payments with subaccounts (D-037). Legal confirmation still advised. | CLOSED |
| B9 | Professional listing subscriptions (FR-MKT-008) | Paystack subscriptions on the web portal | PROPOSED |
| B10 | Courier and safe-custody partner (add-on, FRS 2.4) | Manual operations queue behind `CourierProvider` until contracted | DEFERRED |
| B11 | Account aggregator (FR-AST-011, Could) | Interface only (D-035) | DEFERRED |
| D11 | Statutory and configuration values for the executor workspace: the Master's direction threshold (FR-EXE-002), reporting and advertising deadlines (FR-EXE-004), institution document lists (FR-EXE-005). | `[VERIFY]` config, filled by Compliance (D-030) | DEFERRED |
| D12 | AI knowledge base articles and the 300-question evaluation set (FRS 13.2) | Supplied later (D-030) | DEFERRED |
| D13 | Support and grief resources for FR-AI-006 and the activation screens | Supplied later | DEFERRED |
| D14 | Executor Pack price (R1,499 once or R199/month while the estate is open, FRS 2.4) and attorney-review fee ranges are planning values | Held in `content/entitlements/plans.yaml` as configuration | PROPOSED |

## E. Known delivery constraints

- iOS builds and XCUITest need macOS/Xcode, and HarmonyOS NEXT needs DevEco/hvigor. Neither runs in this Linux session, so that code is verified in CI on matching runners.
- Global edge and push services (Front Door, APNs, FCM with Google Pub/Sub for Play RTDN, Huawei Push) process traffic outside South Africa. This is acceptable only because their payloads carry no personal or estate data (FR-NTF-004, NFR-PRV-001). See threat model T-X1.
