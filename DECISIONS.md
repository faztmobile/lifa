# Decisions

Lightweight ADR log. Each entry has a date, a decision, the FR/NFR IDs it serves and a status.
Pending items live in `OPEN_QUESTIONS.md` until they are confirmed.

| # | Date | Decision | Serves | Status |
|---|---|---|---|---|
| D-001 | 2026-10-07 | Where the FRS and the screens disagree, the FRS wins. Each conflict is logged in OPEN_QUESTIONS §C. | Brief | Accepted |
| D-002 | 2026-10-07 | One monorepo (`faztmobile/lifa`) holds the OpenAPI specs, design tokens, backend, IaC and all five clients. | Brief | Accepted |
| D-003 | 2026-10-07 | API contract first: OpenAPI 3.1 specs are written and reviewed before client code, and typed clients are generated per platform. | Brief | Accepted |
| D-004 | 2026-10-07 | Clients never check plan names. They read entitlement keys and limits from the entitlement service. | FR-SUB-001 | Accepted |
| D-005 | 2026-10-07 | Web MFA uses WebAuthn passkeys as the primary method, with TOTP or SMS as fallback. SMS is never the sole factor for vault access. | FR-ONB-005, FRS 9.3 | Accepted |
| D-006 | 2026-10-07 | Step-up is required for vault access, release-rule changes, data export and account deletion: the union of FR-ONB-006, FRS 9.2 and the brief. | FR-ONB-006, FR-ONB-011 | Accepted |
| D-007 | 2026-10-07 | App-store purchases: Apple, Google and Huawei are merchant of record and issue the consumer receipt. Lifa issues VAT tax invoices for web card payments and add-ons sold on the web. | FR-SUB-002, FR-SUB-006 | Proposed |
