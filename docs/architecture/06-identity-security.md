# 06. Identity, entitlements and security controls

## 6.1 Sign-up and verification (FR-ONB-001..004, 007)

```mermaid
sequenceDiagram
  participant App
  participant Entra as Entra External ID
  participant ID as lifa-identity
  participant SMS as Clickatell
  App->>Entra: native-auth sign-up (email + password), PKCE
  Entra-->>App: email OTP challenge
  App->>Entra: email OTP
  Entra-->>App: tokens (account status: pending)
  App->>ID: POST /devices (P-256 public key + attestation)
  App->>ID: POST /me/mobile-verification
  ID->>SMS: SIM-swap check + OTP
  App->>ID: POST /me/mobile-verification/confirm
  App->>ID: PUT /me/consents (notice version, per purpose)
  App->>ID: PUT /me/identity-document (Luhn + DOB, age ≥ minimum)
  ID-->>App: account active; will generation unlocked
```

- An account is `active` only when email, mobile and the planning consent are all recorded. Other consents are optional and default to off: marketing is opt-in (NFR-PRV-002).
- The minimum testamentary age is configuration (`content/…/legal.yaml`, initially 16 per FR-ONB-004) and is checked at will creation as well as at sign-up.
- The sign-up disclosure (FRS 12.2) and the Information Officer contact come from `content/disclosures/`.

## 6.2 Tokens, sessions and device binding (FR-ONB-005/006, D-022)

| Item | Value |
|---|---|
| Access token | Entra, 10 min, audience `api.lifa.co.za`, DPoP-bound (`cnf.jkt`) |
| Refresh token | Entra, rotating, 14-day sliding / 90-day absolute; revoked on device removal |
| Device key | P-256, non-exportable: iOS Secure Enclave (`kSecAttrTokenIDSecureEnclave`); Android Keystore with `setIsStrongBoxBacked(true)` when available; HarmonyOS HUKS; web-bff server-side key |
| DPoP proof | Every request; `jti` replay cache 5 min (Redis); clock skew ±60 s |
| Step-up token | 5 min, single scope, optionally bound to one resource ID and to the device `jkt`; issued only after a biometric-gated signature (mobile) or a WebAuthn / TOTP assertion (web) |
| App unlock | Biometric or device PIN on every cold start and after 5 min in the background (FR-ONB-005). Unlock releases the local cache key; it is not a server call. |
| New-device login | Entra MFA + OTP to the verified email; all other devices are notified; the device starts at `reduced` trust until both verifications pass |
| Risk-based step-up | New device, new country (Front Door geo), impossible travel → forced step-up on the next sensitive call (FRS 9.2) |

Step-up scopes (D-006): `vault.read`, `vault.write`, `release.write`, `grant.write`, `device.manage`,
`account.export`, `account.delete`, `widget.enable`. Revoking a grant needs **no** step-up, so removing access is
never harder than granting it.

## 6.3 Device integrity and graceful degradation

| Signal | Source | Effect |
|---|---|---|
| Attestation failure, or root/jailbreak detected | App Attest / Play Integrity / HMS Safety Detect / HarmonyOS device cert, plus on-device heuristics | Device `trust_level = reduced`: planning (score, will draft, family, assets) keeps working; vault content, document upload, the lock-screen widget and export are blocked, with an explanation. This is graceful degradation: an owner on a rooted phone can still make a will (FR-SUB-007 spirit). |
| Debugger or hooking framework detected | Platform checks | Session ends; the owner must re-authenticate |
| Emulator | Attestation | Allowed in non-production builds only |

Certificate pinning: SPKI SHA-256 pins for the API hosts, two current and one next; baked into the app and refreshed
through `/v1/client-config` (signed response). A pin failure blocks all API calls and reports to telemetry (no
personal data). Front Door certificates are customer-managed through Key Vault so the pins stay stable.

## 6.4 Entitlements (FR-SUB-001, D-004)

`content/entitlements/plans.yaml` maps plans, add-ons and trials to feature keys. The entitlement service
materialises one versioned `EntitlementSet` per user. Feature code checks keys, never plan names, and so do the
clients (the `badge` field is display-only). Values below come from FRS 2.3. Anything the FRS leaves open is marked.

| Feature key | Free | Plus | Family | FR |
|---|---|---|---|---|
| `ast.max_records` (assets + liabilities) | 15 | ∞ | ∞ | AST-003 |
| `ast.statement_extraction` | – | ✓ | ✓ | AST-005 |
| `ast.joint_separate` | – | – | ✓ | AST-006 |
| `fam.max_people` | 10 | ∞ | ∞ | FAM-002 |
| `fam.conflict_detection` | – | ✓ | ✓ | FAM-006 |
| `wil.max_drafts` | 1 (D-015) | ∞ | ∞ | WIL-012 |
| `wil.versioning` (history, choose current) | – | ✓ | ✓ | WIL-012 |
| `wil.minor_warning` | – | ✓ | ✓ | WIL-007 |
| `wil.codicils` | – | ✓ | ✓ | WIL-013 |
| `wil.mirror` | – | – | ✓ | WIL-014 |
| `scr.history`, `scr.life_events` | – | ✓ | ✓ | SCR-007/008 |
| `scr.household` | – | – | ✓ | SCR-009 |
| `vlt.storage_bytes` | 500 MB | 10 GB | 50 GB shared | VLT-003 |
| `vlt.extra_storage_blocks` | – | add-on, 10 GB each | add-on | 2.4 |
| `vlt.expiry_tracking` | – | ✓ | ✓ | VLT-006 |
| `vlt.estate_pack` | add-on | ✓ | ✓ | VLT-010 |
| `prm.max_role_holders` | 1 (emergency contact only) | 3 | ∞ | PRM-002 |
| `prm.allowed_roles` | [emergency_contact] | all | all | PRM-002 |
| `prm.release_rules` | – | ✓ | ✓ | PRM-003, VLT-007 |
| `household.link` | – | – | ✓ (2 adults) | PRM-007 |
| `sim.baseline` | – | ✓ | ✓ | SIM-001 |
| `sim.max_scenarios` | 0 | 1 | ∞ | SIM-002 |
| `sim.side_by_side` | – | – | ✓ (≤ 4) | SIM-003 |
| `liq.view_level` | gap_flag | gap_amount | breakdown | LIQ-003 |
| `dms.enabled` | – | ✓ | ✓ | DMS-001 |
| `dms.max_verifiers` | – | 3 *(proposed, D10)* | ∞ | DMS-003 |
| `dms.multi_verifier` (2 verifiers or certificate) | – | – | ✓ | DMS-005 |
| `emg.package` | – | ✓ | ✓ | EMG-003 |
| `wal.monthly_tracking` | – | ✓ | ✓ | WAL-002/003 |
| `onb.identity_verification` | – | ✓ | ✓ | ONB-003 |
| `executor.workspace_months` | 0 | 24 | 24 | ACT-006 (recorded now for R3) |
| `trial.plus_days` | 14 (once) | – | – | SUB-003 |

Downgrade (FR-SUB-004): items above the new limit are flagged `read_only` (oldest kept editable). Nothing is ever
deleted. Payment failure (FR-SUB-005): 14-day grace with retries (store grace periods are honoured), then Free.

Channel reconciliation (FR-SUB-002): one `billing.subscriptions` row per channel purchase, linked to the Lifa user
through `appAccountToken` (Apple), `obfuscatedAccountId` (Google) or `developerPayload` (Huawei), or the Paystack
customer code. If two channels are active at once, the highest tier wins and the owner is told how to cancel the
other. Store notifications are the source of truth; client verification only speeds up the first grant.

## 6.5 Key hierarchy (FR-VLT-002, FRS 9.2)

```
Managed HSM (South Africa North; DR replica South Africa West)
 ├─ root-kek (dual control: two Security Officers for rotate/backup/restore)
 ├─ owner-kek/<ownerId>  (AES-256, wrapKey/unwrapKey only, pool-B workload identity only, yearly rotation)
 │    ├─ wraps document DEKs           → vault.documents.wrapped_dek
 │    └─ wraps the owner field DEK     → identity.users.field_dek_wrapped  (cached unwrapped ≤ 5 min in memory)
 └─ service keys: audit-signing (ES256), widget-token signing, step-up token signing
```
- Pool A services decrypt owner fields through `policy-client` → `vault.unwrapFieldKey` (pool B), which checks the
  caller's workload identity and the request's subject. Unwrapped keys are held in memory only.
- Rotation re-wraps DEKs lazily (`kek_version`). Old KEK versions stay active for unwrap until re-wrap completes.
- Crypto-shred deletes `owner-kek/<ownerId>`. Scale and cost are open (OPEN_QUESTIONS A8); the fallback is described in threat model V-K3.

## 6.6 Secret detection (FR-VLT-011)

`platform/security/SecretScanner` runs on every free-text field and on extracted text of uploads (PDF text layer
and DOCX; OCR text in R2). Detectors:
- BIP-39 sequences (12/15/18/21/24 words from the English list, with checksum).
- Extended keys (`xprv`, `yprv`, `zprv`), WIF private keys, 64-hex private keys, PEM `PRIVATE KEY` blocks.
- Credential patterns (`password:`, `pin:`, `pwd=` near a value), and 4–6-digit PINs next to bank or card words.

A hit returns a `possible_secret` warning. For uploads, the document stays `held` until the owner confirms or deletes
it. The matched text is never logged, only the detector name.

## 6.7 Client-side data protection

| Platform | Local cache | Never stored |
|---|---|---|
| iOS | SQLite (GRDB) encrypted with SQLCipher, key in the Keychain (`WhenUnlockedThisDeviceOnly`), wrapped by a Secure Enclave key; document bytes in memory only, or a `completeFileProtection` temp file deleted on close | Tokens outside the Keychain; document content in backups (`isExcludedFromBackup`) |
| Android | Room + SQLCipher, key wrapped by a Keystore key requiring user authentication; `FLAG_SECURE` on vault and will screens | Tokens in SharedPreferences (the Keystore-backed store only); `allowBackup=false` |
| HarmonyOS | RelationalStore with encryption (`encrypt: true`), key in HUKS with user-auth access control | Same rules |
| Web | No persistent estate cache; TanStack Query memory cache only; nothing in localStorage or IndexedDB besides UI preferences | Tokens (they stay in web-bff, D-021) |

Analytics: product events only (screen and action names, plan badge, app version). No estate content, names,
amounts or IDs (NFR-PRV-002), self-hosted in Azure SA North (Application Insights with PII redaction).
Push payloads: generic title "You have a Lifa reminder" plus an opaque inbox ID (FR-NTF-004, AT-NTF-01).

## 6.8 Platform security baseline (FRS 9.2)

| Control | Implementation |
|---|---|
| Edge | Front Door Premium + WAF (OWASP managed rules, bot manager on `/me/mobile-verification*`, sign-in and step-up); DDoS Protection |
| Gateway | APIM: JWT validation, per-user and per-IP rate limits, separate product for pool-B routes, signs a forwarded-claims header that services verify |
| Mesh | AKS Istio add-on, STRICT mTLS, `AuthorizationPolicy` per workload (03 §3.2) |
| Secrets | Key Vault + Workload Identity; no secrets in images or env files |
| Privileged access | Entra PIM, JIT AKS and DB access with approval, session recording through Bastion; break-glass accounts alerting in Sentinel |
| Detection | Sentinel analytics: mass document reads, release-rule churn, staff case access, OTP velocity, many failed step-ups |
| SDLC | CodeQL, detekt, dependency review + Dependabot, Trivy image scan, checkov for Terraform, MobSF on mobile builds, DAST (ZAP) on staging |
