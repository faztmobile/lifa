# 01. Scope: Release A (whole FRS, R1–R4)

Per D-026, every FRS release is built now as one "Release A". All FRs are in scope except FR-ONB-008
(multilingual UI, waived by D-013). The FRS 13.2 gates still decide **when each capability is switched on in
production**: each later-release capability ships behind a server-side release flag that operations enable only
after its gate passes (§3).

## 1. In scope, by FRS release of origin

| Module | R1 | R2 | R3 | R4 |
|---|---|---|---|---|
| Onboarding (FR-ONB) | 001, 002, 004–007, 011 | 003, 009 *(008 waived)* | — | 010 |
| Legacy Score (FR-SCR) | 001–006 | 007–009 | — | — |
| Will Builder (FR-WIL) | 001–012, 017, 018 | 013, 014 | 015, 016 | — |
| Assets (FR-AST) | 001–004, 007, 008, 010 | 005, 006, 009 | — | 011 (Could, interface only, D-035) |
| Family (FR-FAM) | 001–005, 008 | 006 | 007 | — |
| Vault (FR-VLT) | 001–005, 008, 009, 011 | 006, 007, 010 | — | — |
| Simulator (FR-SIM) | — | 001–003, 006 | 004, 005 | — |
| Liquidity (FR-LIQ) | — | 001–003 | 004 | — |
| Permissions (FR-PRM) | 001, 002, 005, 006 | 003, 004, 007 | — | — |
| Dead man's switch (FR-DMS) | — | 001–007 | — | — |
| Digital legacy (FR-DIG) | — | — | 001, 002, 004 | 003 (Could, D-034) |
| Emergency (FR-EMG) | 001, 002 | 003 | — | — |
| Trust planner (FR-TRS) | — | — | 001–003 | — |
| Activation (FR-ACT) | — | — | 001–006, 008 | 007 |
| Executor workspace (FR-EXE) | — | — | 001–013 | — |
| Wallet (FR-WAL) | 001 | 002, 003 | — | 004 |
| Marketplace (FR-MKT) | — | — | 001–008 | — |
| Subscriptions (FR-SUB) | 001–007 | — | — | 008 |
| AI adviser (FR-AI) | — | — | — | 001–006 |
| Notifications (FR-NTF) | 001, 004, 006 | 002, 003 | 005 | — |

All NFRs apply. NFR-LOC-001 is partly met: strings are externalised, ZAR and the SA date format are used, but only
English ships (D-013).

## 2. Deviations from the FRS and the brief

| Ref | Deviation | Decision |
|---|---|---|
| FR-ONB-008, NFR-LOC-001 | English-only UI | D-013 |
| FRS 13 | All four releases built together. Gates move from "before the release starts" to "before the feature's flag is switched on" | D-026 |
| Brief, step 4 | Android first, not web first | D-011 |
| FRS 8.2 | Components grouped into fewer deployables | D-020, D-031 |
| FR-AST-011 | Interface only until an aggregator is contracted (the FRS makes it conditional) | D-035 |
| Brief ("Build R1 only until I approve it") | Superseded by the owner's answers of 7 Oct 2026 | D-012, D-026 |

## 3. Launch gates and release flags (FRS 13.2)

Release flags are operational switches held in `config.release_flags`. They are separate from entitlements: a flag
says a capability is allowed to run at all, and an entitlement says which tier gets it. Switching a flag on in
production needs Compliance approval, which is recorded in the audit ledger.

| Flag | Covers | Gate before switching on in production |
|---|---|---|
| (always on) | R1 scope | All R1 Musts pass, incl. FRS 13.3 tests; attorney sign-off on will templates; POPIA impact assessment; pen test with no open critical/high findings; NFR-USE-001 usability test |
| `release.extraction` | FR-AST-005 | ≥ 95% field accuracy on the 500-statement set (vendor deferred, D-029) |
| `release.dms` | FR-DMS-* | End-to-end test incl. SIM-swap and travel-pause cases |
| `release.identity_verification` | FR-ONB-003 | Vendor contracted (D-029) |
| `release.simulation` | FR-SIM, FR-LIQ | Tax and cost rule tables approved by a tax practitioner (D-030) |
| `release.activation` | FR-ACT, death/incapacity release rules, FR-EMG-003 release | **Red-team exercise of false activation fails to activate**; four-eyes review operational with trained staff |
| `release.executor` | FR-EXE, Executor Pack | Executor checklist reviewed by a practising estates attorney; statutory config approved (D11) |
| `release.marketplace` | FR-MKT, FR-WIL-016, FR-LIQ-004 adviser link | At least 50 verified professionals listed; payment flow confirmed (B8) |
| `release.trusts` | FR-TRS, FR-WIL-015 | Trust templates attorney-approved |
| `release.digital_legacy` | FR-DIG | Platform guidance content published (FR-DIG-004) |
| `release.ai_adviser` | FR-AI | 300-question evaluation with zero answers classed as legal or product advice; crisis responses reviewed; no-retention contract signed (A10) |
| `release.group_codes` | FR-ONB-010, FR-SUB-008 | Promotion terms approved |
| *(waived)* | Five-language UI review | D-013 |

Clients read flags from `/v1/client-config` and hide entry points that are switched off. Servers enforce flags on
every route as well.
