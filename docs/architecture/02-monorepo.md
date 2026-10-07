# 02. Monorepo layout

One repository, several native build systems. There is no meta-build tool (Nx, Bazel). Each tree
builds with its platform's standard tool, and GitHub Actions uses path filters to decide what to
run. This is the boring option: every platform team uses the tooling its platform documents.

```
lifa/
├── api/
│   ├── openapi/
│   │   ├── public/                 # Client-facing API (all five clients)
│   │   │   ├── openapi.yaml        # root: info, servers, security, tags, path refs
│   │   │   ├── paths/*.yaml        # one file per domain
│   │   │   └── components/*.yaml   # schemas, parameters, responses, security
│   │   ├── backoffice/openapi.yaml # internal console API
│   │   └── webhooks/openapi.yaml   # inbound: App Store, Play RTDN, Huawei IAP, Paystack, Clickatell
│   ├── redocly.yaml                # lint rules (incl. custom x-lifa-* checks)
│   └── generated/                  # git-ignored; produced by `make api`
├── design/
│   ├── tokens/tokens.json          # single source (step 2)
│   ├── fonts/                      # Sora, DM Sans (OFL), bundled per platform
│   └── generators/                 # Style Dictionary config → SwiftUI, Compose, ArkUI, CSS
├── content/                        # versioned, compliance-approved configuration (NFR-MNT-001/002)
│   ├── will-templates/<set-version>/   # attorney-approved clauses (OPEN_QUESTIONS D5)
│   ├── assessment/<version>.yaml       # readiness questions (FR-SCR-001)
│   ├── executor/<version>/             # checklist, deadlines, institution lists (FR-EXE, [VERIFY])
│   ├── knowledge-base/<version>/       # AI adviser articles + eval set (FR-AI-001, 13.2)
│   ├── guidance/                       # digital-platform guidance (FR-DIG-004)
│   ├── score-weights/<version>.yaml    # FR-SCR-002 (D-018)
│   ├── rule-tables/<effective-date>/   # tax/cost tables, [VERIFY] until approved (D9)
│   ├── entitlements/plans.yaml         # plan → feature-key limits (FR-SUB-001)
│   ├── disclosures/                    # FRS 12.2 mandatory text
│   └── strings/en/                     # externalised UI strings (ICU)
├── backend/                        # Gradle (Kotlin DSL), one build
│   ├── settings.gradle.kts
│   ├── gradle/libs.versions.toml   # all versions pinned here
│   ├── platform/                   # shared libraries (no domain logic)
│   │   ├── web/                    # problem+json, idempotency, ETag, pagination
│   │   ├── security/               # token + DPoP + step-up filters, field crypto
│   │   ├── entitlement-client/
│   │   ├── policy-client/
│   │   ├── audit-client/           # outbox + synchronous write path
│   │   ├── events/                 # Service Bus outbox/inbox
│   │   └── testing/                # Testcontainers fixtures, contract-test harness
│   ├── modules/                    # one per FRS 8.2 component (03-modules…)
│   │   ├── identity/  entitlement/  billing/  policy/  audit/
│   │   ├── score/  will/  estate/  wallet/  vault/  extraction/
│   │   ├── simulation/  lifecycle/  notification/  docgen/  emergency/
│   │   ├── executor/  digital/  trust/  marketplace/  ai/
│   │   └── backoffice/
│   └── apps/                       # Spring Boot entry points = deployables
│       ├── lifa-core/  lifa-identity/  lifa-commerce/
│       ├── lifa-protected/  lifa-lifecycle/  lifa-audit/  lifa-workers/
│       ├── lifa-executor/  lifa-marketplace/  lifa-ai/
│       └── web-bff/  backoffice-bff/
├── clients/
│   ├── android/                    # Gradle; flavours gms + hms
│   │   ├── app/  core/{api,design,security,data}/
│   │   ├── feature/{onboarding,score,will,estate,family,vault,emergency,plans,activation,executor,digital,trusts,marketplace,adviser,...}/
│   │   ├── provider/{billing,push,location}/{gms,hms}/
│   │   └── widget/                 # Glance emergency card
│   ├── web/                        # Vite + React + TanStack Query (pnpm)
│   ├── ios/                        # Xcode project + SPM packages, WidgetKit extension
│   ├── harmony/                    # DevEco project (ArkTS), service widget
│   └── backoffice/                 # Vite + React (internal)
├── infra/
│   ├── terraform/
│   │   ├── modules/                # aks, apim, frontdoor, postgres, blob, servicebus, hsm, monitor, sentinel
│   │   └── envs/{dev,staging,prod,dr}/
│   └── k8s/                        # Helm charts per deployable, Istio policies
├── tests/
│   ├── acceptance/                 # FRS 13.3 AT-* scenarios, API level
│   ├── contract/                   # schema conformance against running services
│   └── e2e/                        # Playwright (web); device suites live in each client
├── docs/architecture/  docs/compliance/  docs/runbooks/
├── .github/workflows/              # per-tree workflows, path-filtered
├── DECISIONS.md  OPEN_QUESTIONS.md
└── Makefile                        # `make api`, `make tokens`, `make lint`
```

## Build and code generation

| Artifact | Tool (versions pinned at step 3) | Output |
|---|---|---|
| Spec lint and bundle | `@redocly/cli` | `api/generated/public.bundled.yaml` |
| Kotlin server interfaces | OpenAPI Generator `kotlin-spring` (interfaceOnly, Spring 6 / Jakarta) | backend `:api-public` module |
| Kotlin client (Android) | OpenAPI Generator `kotlin` (`jvm-retrofit2` + kotlinx.serialization) | `clients/android/core/api` |
| Swift client (iOS) | Apple `swift-openapi-generator` (SPM plugin) | build-time |
| TypeScript client (web, back office) | `openapi-typescript` + `openapi-fetch` | `clients/*/src/api/schema.d.ts` |
| ArkTS client (HarmonyOS) | Types from `openapi-typescript`, post-processed to ArkTS-strict rules (no `any`, no structural typing tricks), plus a hand-written `@ohos.net.http` transport | `clients/harmony/.../api` (risk: no official generator; see 08) |

Generated code is never edited by hand. CI regenerates it and fails on drift.

## CI layout (GitHub Actions)

| Workflow | Trigger paths | Runner | Gates |
|---|---|---|---|
| `api.yml` | `api/**` | ubuntu | lint, bundle, breaking-change diff vs `main` (oasdiff) |
| `backend.yml` | `backend/**`, `api/**`, `content/**` | ubuntu | ktlint, detekt, unit, ArchUnit boundaries, Testcontainers integration, contract tests, SAST (CodeQL), dependency scan |
| `android.yml` | `clients/android/**`, `api/**`, `design/**` | ubuntu (+ emulator) | lint, unit, Compose UI tests, both flavours assembled, R8 mapping archived |
| `infra.yml` | `infra/**` | ubuntu | `terraform fmt/validate`, tflint, checkov, plan on PR, apply on protected env with approval |
| `web.yml`, `ios.yml`, `harmony.yml` | their trees | ubuntu / macOS / self-hosted DevEco | added in client order (D-011) |
| `content.yml` | `content/**` | ubuntu | schema validation; blocks merge of any `[VERIFY]` value to a `release/*` branch |

Content approvals: CODEOWNERS routes `content/will-templates/**` to the attorney reviewer group
and `content/rule-tables/**` to Compliance (NFR-MNT-001, FRS 12.4).
