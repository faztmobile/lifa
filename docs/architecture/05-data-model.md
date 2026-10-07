# 05. Logical data model (FRS §10 → modules)

Each module owns one Postgres schema. Cross-module references are **IDs only**: no foreign keys across schemas,
and consistency is kept by events. Every row carries `id uuid`, `created_at`, `updated_at`, `version` (optimistic
lock / ETag). Planning rows also carry `estate_id`.

## 5.1 Protection classes

| Class (FRS §10) | At rest | Logging | Read audit |
|---|---|---|---|
| Personal | Disk/TDE encryption. Contact data, ID numbers and account identifiers also get **field-level encryption** (AES-256-GCM, per-owner data key wrapped by the owner KEK). | IDs only; values redacted | On export |
| Special (estate state, health/death, children) | As Personal, plus field-level encryption on free text | IDs only | Every read by anyone other than the owner |
| Financial | As Personal; amounts in plain text (needed for queries); account identifiers field-encrypted | Amounts never logged | — |
| Legal (wills) | As Personal; free-text wishes field-encrypted | IDs only | Every read by anyone other than the owner |
| Security-relevant (grants, rules) | Plain text in `pg-b` (needed for evaluation); integrity via audit hash chain | Full, minus personal values | Every change |
| Documents | Envelope encryption: per-document data key (DEK), wrapped by the per-owner KEK in Managed HSM (FR-VLT-002) | Never content | Every read (FR-VLT-009) |

Field-level crypto lives in `platform/security` (`@Encrypted` JPA converter). Per-owner keys mean crypto-shredding
(§5.5) also makes database backups unreadable.

## 5.2 FRS §10 entities

| FRS entity | Module.table | Key columns (beyond FRS attributes) | Class | DB |
|---|---|---|---|---|
| User | `identity.users` | `entra_object_id`, `account_type (owner/invitee)`, `email_enc`, `mobile_enc`, `email_hash`/`mobile_hash` (HMAC for lookup), `locale`, `status`, `id_doc_type`, `id_number_enc`, `dob` | Personal | pg-a |
| Device | `identity.devices` | `public_key_jwk`, `jkt` (thumbprint), `platform`, `attestation_format`, `trust_level`, `last_seen_at`, `revoked_at` | Personal | pg-a |
| Consent | `identity.consents` (append-only) | `purpose`, `granted`, `notice_version`, `decided_at`, `channel` | Personal | pg-a |
| Estate | `estate.estates` | `owner_user_id`, `state`, `marital_status`, `marital_regime`, `spouse_person_id`, `domicile`, `household_id` | Special | pg-a |
| Person | `estate.persons` | `display_name`, `relationship`, `dob`, `id_number_enc`, `email_enc`, `mobile_enc`, `special_needs`, `deceased`, `minor` (derived, nightly), `linked_user_id`, `marketing_suppressed` | Personal/Special | pg-a |
| RoleGrant | `policy.role_grants` | `estate_id`, `person_id`, `grantee_user_id`, `role`, `scope jsonb`, `status`, `counts_toward_limit`, `invited_at`, `accepted_at`, `revoked_at` | Security | pg-b |
| ReleaseRule | `policy.release_rules` | `target_type`, `target_id`, `type`, `params jsonb`, `recipients uuid[]`, `effective_from_release` | Security | pg-b |
| Asset | `estate.assets` | `category`, `description_enc`, `institution`, `account_ref_enc`, `value_cents`, `value_date`, `value_basis`, `evidence`, `ownership`, `estate_side`, `share_pct`, `pays_by_nomination`, `nominee_person_id`, `read_only` | Financial | pg-a |
| Liability | `estate.liabilities` | `type`, `creditor`, `balance_cents`, `balance_date`, `basis`, `secured_asset_id`, `read_only` | Financial | pg-a |
| Will | `will.wills` | `kind (single/codicil/mirror/joint)`, `version`, `status`, `is_current_signed` (unique partial index per estate), `amends_will_id`, `template_set_version`, `signed_on`, `witnesses_enc`, `original_location_enc`, `stale_since` | Legal | pg-a |
| Allocation | `will.allocations` | `will_id`, `person_id`, `percent numeric(5,2)`, `alternate_person_id`. Check: sum = 100 at signing-pack time | Legal | pg-a |
| Bequest | `will.bequests` | `asset_id`, `person_id`, `share_pct`, `description_enc`, `condition`, `alternate_person_id` | Legal | pg-a |
| Nomination | `will.nominations` | `role (executor/guardian/trustee)`, `person_id` or `professional_name`, `order`. **Not counted as a grant (D-016)** | Legal | pg-a |
| Document | `vault.documents` | `owner_user_id`, `type`, `type_suggested`, `state (stored/held)`, `blob_ref`, `wrapped_dek`, `kek_version`, `size`, `media_type`, `sha256`, `expires_on`, `folder_id` | Special/Financial | pg-b |
| DigitalAsset | — (R3, reserved) | — | — | — |
| Scenario | `simulation.scenarios` | `changes jsonb`, `rule_table_version`, `result jsonb`, `computed_at` | Financial | pg-a |
| Score | `score.scores`, `score.score_history` | `total`, `domains jsonb`, `weights_version`, `computed_at`, `trigger` | Personal | pg-a |
| CheckIn | `lifecycle.checkin_settings`, `lifecycle.checkins` | `interval_days`, `grace_days`, `armed`, `paused_until`, `due_at`, `completed_at`, `channel` | Personal | pg-b |
| VerificationCase | `lifecycle.cases`, `lifecycle.case_reports`, `lifecycle.case_decisions`, `lifecycle.case_evidence` | `trigger`, `status`, `requester`, `evidence_refs` (blob in `lifecycle-evidence` storage account), `reviewer_ids`, `decision`, timestamps | Special | pg-b |
| EstateFile, Claim | — (R3, reserved) | — | — | — |
| Professional, Booking | — (R3, reserved) | — | — | — |
| Subscription | `billing.subscriptions` | `user_id`, `channel`, `product_id`, `original_transaction_id`/`purchase_token`, `status`, `period_end`, `grace_until`, `auto_renew` | Financial | pg-a |
| Entitlement | `entitlement.grants` | `user_id`, `feature_key`, `limit`, `source (plan/addon/trial/promo)`, `source_ref`, `valid_from`, `valid_to`; `entitlement.effective` (materialised per user, versioned) | Operational | pg-a |
| AuditEvent | `audit.events` (append-only) | `seq bigserial`, `stream (estate id or 'system')`, `actor`, `actor_kind`, `action`, `object_type`, `object_id`, `outcome`, `at`, `prev_hash`, `hash`, `evidence_ref` | Security | pg-ledger |

## 5.3 Entities added for Release A

| Entity | Module.table | Why | FR |
|---|---|---|---|
| MobileVerification, OtpAttempt | `identity.otp_*` | OTP state, velocity limits, SIM-swap result | ONB-001, FRS 9.2 Fraud |
| StepUpChallenge | `identity.step_up_challenges` | Nonce, scope, resource binding, single use | ONB-006 |
| WebAuthnCredential | `identity.webauthn_credentials` | Web step-up | ONB-005 |
| IdentityVerification | `identity.id_verifications` | Vendor session and result | ONB-003 |
| Invitation | `identity.invitations` | Token hash, expiry, grant ID, state | FAM-008, ONB-009, NTF-006 |
| AccountClosure | `identity.closures` | 30-day window, per-module purge checklist | ONB-011 |
| Household | `estate.households`, `estate.household_members`, `estate.shared_deletion_requests` | Linked spouses, two-owner delete | PRM-007, SCR-009, WIL-014 |
| ValueHistory | `estate.value_history` | Value refresh and history | AST-009 |
| NetWorthSnapshot | `wallet.snapshots` | Monthly trend | WAL-002 |
| AssessmentResponse | `score.assessment_responses` | Answers by definition version | SCR-001 |
| LifeEvent | `score.life_events` | Rescore prompts | SCR-008 |
| ScoreAction | `score.actions` (cache) | Prioritised list | SCR-004 |
| Folder | `vault.folders` | Grouping and release-rule target | VLT-007 |
| DocumentLink | `vault.document_links` | Document → asset, person, role chain | VLT-005, AST-010 |
| ScanResult, Quarantine | `vault.scan_results`, `vault.quarantine` | Malware outcome (hash only for rejects) | VLT-008 |
| QuotaUsage | `vault.quota_usage` | Bytes per owner (or per household on Family) | VLT-003 |
| ExtractionJob | `extraction.jobs` | Transient fields + confidence, purged at 7 days | AST-005 |
| EmergencyCard, WidgetToken | `emergency.cards`, `emergency.widget_tokens` | Field selection, lock-screen subset, token hash per device | EMG-001/002, D-017 |
| EmergencyPackage | `emergency.packages` | Contacts and instructions (release rule lives in policy) | EMG-003 |
| Verifier | `lifecycle.verifiers` | Person ID, contact channel; not a RoleGrant (OPEN_QUESTIONS D10) | DMS-003..005 |
| StoreEvent | `billing.store_events` | Raw signed notifications, idempotency | SUB-002 |
| Invoice, AddonOrder | `billing.invoices`, `billing.addon_orders` | VAT invoices for Paystack sales | SUB-006 |
| NotificationPreference, PushRegistration, InboxItem, DeliveryLog | `notification.*` | Channels, generic push payloads, content behind unlock | NTF-001, 004 |
| Outbox / Inbox | `<module>.outbox`, `<module>.inbox` | Transactional events, idempotent consumers | D-025 |
| ConfigVersion | `content` (repo) + `config.versions` (runtime) | Weights, rule tables, templates, plans with effective dates and approver | NFR-MNT-001/002 |

## 5.4 Key invariants (enforced in the database and in services)

| Invariant | Enforcement | FR / test |
|---|---|---|
| Residue totals exactly 100% before a signing pack | Service validation; 422 with the exact AT-WIL-01 text | FR-WIL-003, AT-WIL-01 |
| No asset bequeathed in full to two people | `sum(share_pct) per (will, asset) ≤ 100` | FR-WIL-004 |
| Exactly one current signed will per estate | Partial unique index `(estate_id) WHERE is_current_signed` | FR-WIL-012 |
| A draft never replaces a signed will in the score | Score reads `is_current_signed` only | FR-WIL-012 |
| Signed wills and documents are never deleted on downgrade | No delete path; `read_only` flag instead | FR-SUB-004, AT-SUB-01 |
| Free cap: 15 assets + liabilities, 10 people | Entitlement check in a `SELECT … FOR UPDATE` on a per-estate counter row (no races) | FR-AST-003, FR-FAM-002 |
| Witness ≠ beneficiary (or their spouse) | Blocking check at signing-pack generation and at execution recording | FR-WIL-008, AT-WIL-02 |
| Minor flag follows date of birth | Nightly job plus on-read derivation; emits `person.minor-status-changed` | FR-FAM-004, AT-FAM-01 |
| Audit is append-only | `audit` role has INSERT only; a trigger rejects UPDATE/DELETE; hash chain; daily anchor to immutable blob | NFR-AUD-001 |
| A frozen estate is read-only | Every write path checks `estate.state = living` (409 `estate_frozen`) | FR-ACT-005 (R3 ready) |

## 5.5 Retention and deletion (FRS 12.3)

| Data | Mechanism |
|---|---|
| Account closure | Day 0: `identity.closures` row; sessions and devices revoked; marketing suppressed. Day 30: `account.deletion-executed` → each module hard-deletes rows for the owner and confirms; vault deletes blobs and **deletes the owner KEK** in Managed HSM (crypto-shred). Purge completes after the HSM soft-delete retention (set to 7 days, OPEN_QUESTIONS A8). |
| Will versions | Kept while the account is open; signed versions are never auto-deleted. |
| Audit events | 7 years rolling (NFR-AUD-001). Actor and object IDs of deleted owners stay, but their personal values were never in the ledger. |
| Verification case evidence | 5 years after decision, in the `lifecycle-evidence` account with a time-based immutability policy. |
| Billing and invoices | 5 years from the end of the tax year (statutory), outside the crypto-shred scope; minimal fields only. |
| Backups | 35 days (Postgres PITR). Crypto-shred makes deleted owners' encrypted fields and documents unreadable in them. |
| Extraction jobs | 7 days or on confirmation, whichever is first. |

## 5.6 Entity-relationship overview

```mermaid
erDiagram
  USER ||--o| ESTATE : owns
  USER ||--o{ DEVICE : binds
  USER ||--o{ CONSENT : records
  ESTATE ||--o{ PERSON : has
  ESTATE ||--o{ ASSET : has
  ESTATE ||--o{ LIABILITY : has
  ESTATE ||--o{ WILL : has
  ESTATE ||--o{ DOCUMENT : has
  ESTATE ||--o{ SCENARIO : has
  ESTATE ||--|| SCORE : has
  ESTATE ||--o| CHECKIN_SETTINGS : has
  ESTATE ||--o{ VERIFICATION_CASE : has
  WILL ||--o{ ALLOCATION : has
  WILL ||--o{ BEQUEST : has
  WILL ||--o{ NOMINATION : has
  BEQUEST }o--|| ASSET : gives
  ALLOCATION }o--|| PERSON : to
  NOMINATION }o--|| PERSON : names
  PERSON ||--o{ ROLE_GRANT : holds
  ROLE_GRANT }o--o| USER : "accepted by"
  RELEASE_RULE }o--|| DOCUMENT : guards
  DOCUMENT }o--o{ ASSET : evidences
  LIABILITY }o--o| ASSET : "secured against"
  USER ||--o{ SUBSCRIPTION : pays
  SUBSCRIPTION ||--o{ ENTITLEMENT : drives
```
