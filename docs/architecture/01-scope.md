# 01. Scope: Release A (R1 + R2)

Per D-012, R1 and R2 ship together. The tables below list every FR whose FRS release is R1 or R2.
Anything tagged R3 or R4 is out of scope. Its data shapes may be reserved, but no endpoint or UI is built for it.

## In scope

| Module | R1 | R2 |
|---|---|---|
| Onboarding, identity (FR-ONB) | 001, 002, 004, 005, 006, 007, 011 | 003, 009 (008 waived, D-013) |
| Legacy Score (FR-SCR) | 001–006 | 007, 008, 009 |
| Will Builder (FR-WIL) | 001–012, 017, 018 | 013, 014 |
| Assets (FR-AST) | 001–004, 007, 008, 010 | 005, 006, 009 |
| Family (FR-FAM) | 001–005, 008 | 006 |
| Vault (FR-VLT) | 001–005, 008, 009, 011 | 006, 007, 010 |
| Simulator (FR-SIM) | — | 001, 002, 003, 006 |
| Liquidity (FR-LIQ) | — | 001, 002, 003 |
| Permissions (FR-PRM) | 001, 002, 005, 006 | 003, 004, 007 |
| Dead man's switch (FR-DMS) | — | 001–007 |
| Emergency (FR-EMG) | 001, 002 | 003 |
| Wallet (FR-WAL) | 001 | 002, 003 |
| Subscriptions (FR-SUB) | 001–007 | — |
| Notifications (FR-NTF) | 001, 004, 006 | 002, 003 |

All NFRs apply. NFR-LOC-001 is partly met: strings are externalised, ZAR currency and SA date
formats are used, but only English ships (D-013).

## Out of scope (R3/R4) but designed for

| Item | Why it shapes Release A |
|---|---|
| FR-ACT activation (R3) | Estate state machine, `VerificationCase`, release-rule evaluation and the threat model are designed now (D-023, threat model §3). |
| FR-EXE executor workspace (R3) | `EstateFile` is reserved. Entitlement `executor.workspace_months` is recorded at payment time, so FR-SUB-005 ("rights persist if paid-up at death") can be honoured later. |
| FR-NTF-005 marketing suppression (R3) | The `marketing_suppressed` flag on contacts exists from day one, because marketing consent (FR-ONB-007) is in Release A. |
| FR-DIG, FR-TRS, FR-MKT, FR-AI, FR-WAL-004, FR-SIM-004/005, FR-WIL-015/016, FR-LIQ-004 | Entry points hidden (OPEN_QUESTIONS C6, C12). |

## Deviations from FRS and brief

| Ref | Deviation | Decision |
|---|---|---|
| FR-ONB-008, NFR-LOC-001 | English-only UI | D-013 |
| FRS 13 | R1 and R2 merged | D-012 |
| Brief, step 4 | Android first, not web first | D-011 |
| FR-PRM-003 | Death and incapacity rules configurable but inert until R3 | D-023 (to confirm) |
| FRS 8.2 | Components grouped into fewer deployables | D-020 |

## Launch gates (FRS 13.2) carried into Release A

- All R1 and R2 "Must" FRs pass, including the acceptance tests in FRS 13.3.
- Attorney sign-off on will templates (single, codicil and mirror).
- POPIA impact assessment complete. Information Officer registered (FRS 12.4).
- Penetration test with no open critical/high findings (NFR-SEC-002).
- NFR-USE-001 usability test (20 users).
- Statement extraction ≥ 95% field accuracy on a 500-statement set (OPEN_QUESTIONS B7).
- Dead man's switch tested end to end, including SIM-swap and travel-pause cases.
- Tax rule tables reviewed by a tax practitioner (OPEN_QUESTIONS D9).
- *Waived:* five-language native-speaker review (D-013).
