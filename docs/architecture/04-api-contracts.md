# 04. API contracts

Contract first (D-003). The specs in `/api/openapi` are the source of truth. Server interfaces and all client
SDKs are generated from them, and CI fails if generated code drifts or a change breaks the contract.

## 4.1 Specs

| Spec | Root | Consumers | Operations |
|---|---|---|---|
| Public | `api/openapi/public/openapi.yaml` (plus `domains/*.yaml` and `components/common.yaml`) | Android GMS/HMS, iOS, HarmonyOS, web (through web-bff) | 210 operations on 156 paths, 30 tags |
| Back-office | `api/openapi/backoffice/openapi.yaml` | Internal console (D-014) | 19 |
| Webhooks | `api/openapi/webhooks/openapi.yaml` | Apple, Google (Pub/Sub), Huawei, Paystack, Clickatell | 5 |

The public spec is split by domain, so each domain file maps to one backend module (see the table in §4.4).

Validation: `npm run api:lint` runs Redocly CLI 2.59.0 (pinned) with the `recommended` ruleset and two custom rules:
- `operation-has-fr-ids`: every operation must carry `x-lifa-fr`.
- `step-up-header-present`: an operation with `x-lifa-step-up` must declare the `Lifa-Step-Up` header.

All three specs currently lint with no errors or warnings. Code-generation smoke tests on the bundle:
`openapi-typescript` 7.13.0 succeeds. OpenAPI Generator 7.17.0 (`kotlin`, `jvm-retrofit2` +
kotlinx.serialization) generates 30 API classes **that compile**. Getting there surfaced three rules, now
enforced by review:
1. **No free-form JSON objects** (`additionalProperties: true` or untyped `{}`). kotlinx.serialization cannot handle
   them. Opaque browser payloads such as WebAuthn travel as JSON strings (`contentMediaType: application/json`).
2. **No `const` on booleans** (the generator emits the wrong type). Use a plain boolean and validate on the server.
3. **One `apiKey` scheme per spec.** The browser↔web-bff cookie isn't part of the APIM-facing contract;
   web-bff documents it separately (D-021).

## 4.2 Conventions

| Topic | Rule |
|---|---|
| Versioning | URI major version (`/v1`). Additive changes only within v1; `oasdiff` breaking-change check on every PR. Clients below `minimumVersion` (from `/v1/client-config`) are forced to update. |
| Traceability | `x-lifa-fr: [FR-…]` on every operation; feeds `09-traceability.md` and the test matrix. |
| Release flags | Capabilities whose FRS 13.2 gate has not passed return 403 `release_disabled` (D-026). |
| Errors | RFC 9457 `application/problem+json` with a stable `code` enum. Clients switch on `code`, never on text. |
| Not found vs forbidden | A denied read of another person's item returns **404**, not 403, so that existence isn't revealed (FR-PRM-001). 403 is reserved for entitlement limits and the caller's own items. |
| Entitlements | `x-lifa-entitlement: <key>`. A violation returns 403 `entitlement_limit` / `entitlement_missing` with `entitlementKey` and `limit`, and clients show the upgrade prompt only then (FR-SUB-007). Safety functions (emergency card, will draft, intestate preview) never carry an entitlement gate. |
| Step-up | `x-lifa-step-up: <scope>` plus the `Lifa-Step-Up` header. A missing or stale token returns 401 `step_up_required` with `stepUpScope`. Clients run the platform biometric prompt and retry once. |
| Concurrency | `ETag` on reads; `If-Match` required on PATCH/PUT of editable resources (multi-device editing). 412 on mismatch. |
| Idempotency | `Idempotency-Key` (UUID) on creating POSTs and on anything that sends a message or costs money. Results are replayed for 24 h. |
| Money and figures | `Money{amountCents:int64, currency:"ZAR"}`. Displayed figures use `LabelledMoney` with `basis` (declared, evidenced or estimated) and `valueDate` (FRS principle 4, FR-AST-004). |
| Disclosures | Will, simulator and liquidity responses embed a `Disclosure` (FRS 12.2, FR-WIL-018, FR-SIM-006). Clients render it verbatim. |
| Warnings | Write responses can carry `warnings[]` (for example `possible_secret` for FR-VLT-011, or `minor_direct_heir`). Warnings never block; blocking findings are 422. |
| Async | PDFs, exports and extractions return `202 Job`. Poll `GET /v1/jobs/{id}`, or wait for a silent push. Outputs land in the vault. |
| Caching | Sensitive responses carry `Cache-Control: no-store`. Clients keep data only in the encrypted local cache (08). |
| Pagination | Cursor based (`cursor`, `limit` ≤ 100, `nextCursor`). |
| Dates | ISO 8601. Server time is UTC; display uses the SA date format (NFR-LOC-001). |
| Payload budget | Responses are designed for 3G (NFR-DAT-001): gzip/br at Front Door, no embedded images, list endpoints return summaries. |

## 4.3 Authentication on the wire

```
Authorization: DPoP <access token, Entra External ID, cnf.jkt = device key thumbprint>
DPoP: <proof JWT signed by device key: htm, htu, iat, jti, ath>
Lifa-Step-Up: <5-min token, scope + optional resource binding>      # only where required
```
Web: the browser sends the `__Host-lifa-session` cookie and `X-CSRF-Token` to web-bff. The BFF adds the bearer
and its own DPoP proof (BFF-held key) when it calls APIM. See 06 for the flows.

## 4.4 Spec ↔ module map

| Domain file | Module(s) | Deployable |
|---|---|---|
| `identity.yaml` | identity | lifa-identity |
| `commerce.yaml` | entitlement, billing | lifa-commerce |
| `score.yaml` | score | lifa-core |
| `estate.yaml` | estate, wallet | lifa-core |
| `will.yaml` | will (+ docgen) | lifa-core (+ workers) |
| `vault.yaml` | vault, extraction | lifa-protected |
| `access.yaml` | policy | lifa-protected |
| `protection.yaml` | emergency (card, package); lifecycle (check-in, verifier) | lifa-core; lifa-lifecycle |
| `simulation.yaml` | simulation | lifa-core |
| `activation.yaml` | lifecycle | lifa-lifecycle |
| `executor.yaml` | executor | lifa-executor |
| `legacy.yaml` | digital; trust | lifa-executor; lifa-marketplace |
| `marketplace.yaml` | marketplace | lifa-marketplace |
| `ai.yaml` | ai | lifa-ai |
| `platform.yaml` | notification, config | lifa-core |

APIM routes by path prefix to the deployables. Splitting by prefix keeps pool-B content endpoints
(`/v1/vault/**`, `/v1/shared/**`, `/v1/access/**`, `/v1/extractions/**`, `/v1/estate-files/**`, `/v1/digital-assets/**`, `/v1/activation-requests/**`) behind a separate APIM product with
stricter rate limits and WAF rules.

## 4.5 Code generation per platform

| Platform | Generator | Notes |
|---|---|---|
| Backend | OpenAPI Generator `kotlin-spring` (`interfaceOnly`, `useSpringBoot3`, `useBeanValidation`) | Controllers implement the generated interfaces. Contract tests (Spring MockMvc + `openapi4j` / `swagger-request-validator`) check every response against the spec. |
| Android | OpenAPI Generator `kotlin`, `jvm-retrofit2`, `kotlinx_serialization` | OkHttp interceptors add DPoP and step-up. The generator's 3.1 support is beta: nullable unions (`type: [x, 'null']`) are verified by the compile smoke test before adoption. |
| iOS | `swift-openapi-generator` (SPM build plugin) | URLSession transport with a pinning delegate and DPoP middleware. |
| Web, back office | `openapi-typescript` + `openapi-fetch` | Types only, plus a ~6 kB fetch wrapper (NFR-DAT-001). |
| HarmonyOS | `openapi-typescript` output post-processed to ArkTS-strict, plus a hand-written `@ohos.net.http` transport | ArkTS forbids `any`, index signatures on some types, and structural typing tricks. A codegen post-processor and a type-check job in `harmony.yml` keep it honest. This is the riskiest generator; see 08 §8.4. |
