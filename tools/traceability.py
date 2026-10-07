#!/usr/bin/env python3
"""Generate docs/architecture/09-traceability.md from the bundled OpenAPI specs.

Every Release A FR (docs/architecture/01-scope.md) must be realised by at least one API operation
(x-lifa-fr) or by an entry in NON_API below. `--check` exits non-zero when an FR is untraced,
so CI can enforce it (api.yml).

Usage: python3 -I tools/traceability.py [--check]   (run `npm run api:bundle` first)
"""
import re
import sys
from collections import defaultdict
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parent.parent
SPECS = {
    "public": ROOT / "api/generated/public.bundled.yaml",
    "backoffice": ROOT / "api/generated/backoffice.bundled.yaml",
    "webhooks": ROOT / "api/generated/webhooks.bundled.yaml",
}
OUT = ROOT / "docs/architecture/09-traceability.md"

# Release A scope, kept in sync with 01-scope.md (whole FRS, D-026; FR-ONB-008 waived by D-013).
SCOPE = {
    "ONB": [1, 2, 3, 4, 5, 6, 7, 9, 10, 11],
    "SCR": list(range(1, 10)),
    "WIL": list(range(1, 19)),
    "AST": list(range(1, 12)),
    "FAM": list(range(1, 9)),
    "VLT": list(range(1, 12)),
    "SIM": list(range(1, 7)),
    "LIQ": [1, 2, 3, 4],
    "PRM": list(range(1, 8)),
    "DMS": list(range(1, 8)),
    "DIG": [1, 2, 3, 4],
    "EMG": [1, 2, 3],
    "TRS": [1, 2, 3],
    "ACT": list(range(1, 9)),
    "EXE": list(range(1, 14)),
    "WAL": [1, 2, 3, 4],
    "MKT": list(range(1, 9)),
    "SUB": list(range(1, 9)),
    "AI": list(range(1, 7)),
    "NTF": list(range(1, 7)),
}

MODULE = {
    "ONB": "identity", "SCR": "score", "WIL": "will (+docgen)", "AST": "estate", "FAM": "estate",
    "VLT": "vault", "SIM": "simulation", "LIQ": "simulation", "PRM": "policy", "DMS": "lifecycle", "DIG": "digital", "TRS": "trust", "ACT": "lifecycle",
    "EXE": "executor", "MKT": "marketplace", "AI": "ai",
    "EMG": "emergency", "WAL": "wallet", "SUB": "entitlement, billing", "NTF": "notification",
}

# FRs realised (wholly or partly) outside a request/response operation.
NON_API = {
    "FR-SCR-006": "Event consumer: estate.changed / will.signed → rescore",
    "FR-FAM-004": "Nightly job: minor-status recompute → person.minor-status-changed",
    "FR-WIL-017": "Nightly job: 3-year staleness; life-event.declared consumer",
    "FR-AST-009": "Weekly job: value-age check → reminder",
    "FR-VLT-006": "Daily job: expiry reminders at 60/30/7 days",
    "FR-DMS-002": "Scheduler: check-in requests by push, email and SMS; any session counts",
    "FR-DMS-003": "Scheduler: escalation to all owner channels, then verifiers",
    "FR-PRM-005": "Policy obligation notify-owner → access.occurred → notification",
    "FR-PRM-006": "grant.revoked → cache epoch bump (≤ 60 s)",
    "FR-SUB-005": "Hourly job: payment retry and downgrade after 14 days",
    "FR-NTF-002": "Daily job: annual Legacy Review prompt",
    "FR-NTF-003": "Rules engine: life-event, expiry, staleness and value-refresh prompts",
    "FR-NTF-004": "Notification dispatcher: generic push titles only",
    "FR-NTF-006": "Invitation templates without estate details",
    "FR-ONB-011": "Hourly job: deletion after 30 days and crypto-shred",
    "FR-AST-011": "AccountAggregatorProvider interface only, until a provider is contracted (D-035)",
    "FR-ACT-004": "Notice timer: 72-hour 'Is this a mistake?' to every owner channel",
    "FR-ACT-005": "activation.completed: freeze estate, evaluate every release rule, notify recipients",
    "FR-ACT-006": "activation.completed consumer: executor workspace (paid plan) or Executor Pack offer",
    "FR-EXE-004": "Daily job: deadline reminders",
    "FR-EXE-011": "Daily job: 5-year retention and deletion",
    "FR-MKT-002": "Daily job: annual re-verification",
    "FR-NTF-005": "activation.completed consumer: marketing suppression for the deceased's contacts and estate-file members",
    "FR-AI-005": "Redaction API in lifa-core; no-retention provider contract (A10)",
}

ACCEPTANCE = {
    "FR-WIL-003": "AT-WIL-01", "FR-WIL-008": "AT-WIL-02", "FR-FAM-004": "AT-FAM-01",
    "FR-DMS-005": "AT-DMS-01", "FR-DMS-006": "AT-ACT-01", "FR-ACT-001": "AT-ACT-01", "FR-PRM-006": "AT-PRM-01",
    "FR-SUB-004": "AT-SUB-01", "FR-NTF-004": "AT-NTF-01", "FR-ACT-003": "red-team (13.2)",
    "FR-AI-003": "300-question eval (13.2)",
}

METHODS = {"get", "put", "post", "patch", "delete"}


def collect():
    ops = defaultdict(list)
    for name, path in SPECS.items():
        spec = yaml.safe_load(path.read_text())
        for route, item in spec.get("paths", {}).items():
            for method, op in item.items():
                if method not in METHODS:
                    continue
                for fr in op.get("x-lifa-fr", []):
                    tag = "" if name == "public" else f" [{name}]"
                    ops[fr].append(f"`{op['operationId']}` {method.upper()} {route}{tag}")
    return ops


def main():
    check = "--check" in sys.argv
    ops = collect()
    rows, missing = [], []
    for mod, nums in SCOPE.items():
        for n in nums:
            fr = f"FR-{mod}-{n:03d}"
            realised = ops.get(fr, [])
            other = NON_API.get(fr)
            if not realised and not other:
                missing.append(fr)
            cell = "<br>".join(realised) if realised else "—"
            tests = ["unit", "contract" if realised else None, ACCEPTANCE.get(fr)]
            rows.append(
                f"| {fr} | {MODULE[mod]} | {cell} | {other or ''} | {', '.join(t for t in tests if t)} |"
            )
    nfr = sorted(k for k in ops if k.startswith("NFR-"))
    text = [
        "# 09. Traceability (generated)",
        "",
        "Generated by `tools/traceability.py` from the bundled specs. Do not edit by hand.",
        "CI runs it with `--check`, which fails if a Release A FR has neither an operation nor a non-API realisation.",
        "UI tests per platform (XCUITest, Compose UI, ArkUI, Playwright) are added per screen in step 4.",
        "",
        f"In-scope FRs: **{len(rows)}** of the FRS's 155 (FR-ONB-008 waived, D-013). Untraced: **{len(missing)}**{(' (' + ', '.join(missing) + ')') if missing else ''}.",
        "",
        "| FR | Module | API operations | Non-API realisation | Tests |",
        "|---|---|---|---|---|",
        *rows,
        "",
        "## NFRs referenced by operations",
        "",
        "| NFR | Operations |",
        "|---|---|",
        *[f"| {k} | {'<br>'.join(ops[k])} |" for k in nfr],
        "",
    ]
    OUT.write_text("\n".join(text))
    print(f"wrote {OUT.relative_to(ROOT)}: {len(rows)} FRs, {len(missing)} untraced")
    if check and missing:
        sys.exit(1)


if __name__ == "__main__":
    main()
