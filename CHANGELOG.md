# Changelog

## 2.0.0 (2026-07-06)

### Breaking / structure
- SKILL.md split: core file now contains only auth, safety tiers, Graph
  mechanics and a routing table; all 110+ endpoints moved to `references/`
  (loaded on demand — smaller context, better rule adherence).
- Frontmatter fixed to valid YAML (`metadata.requires_env`); skill renamed
  to `intune-graph`; description rewritten with concrete trigger phrases.

### Fixed
- **Missing permissions documented:** `Policy.Read.All` /
  `Policy.ReadWrite.ConditionalAccess` (Conditional Access returned 403 in
  v1.x) and `AuditLog.Read.All` (sign-in logs / directory audits).
- Update-ring pause/resume corrected to PATCH of pause properties (the beta
  `/pause` action endpoints are unreliable).
- All date-filter examples now explicit ISO 8601 UTC.
- Hardcoded German responses replaced with "respond in the user's language".

### Added
- `scripts/get_token.sh` — token caching (~60 min, refresh 5 min early),
  multi-tenant profiles via `INTUNE_PROFILE`, secret never printed.
- `scripts/graph.sh` — API wrapper: automatic `@odata.nextLink` pagination,
  429 retry honoring `Retry-After`, `ConsistencyLevel: eventual` for
  advanced /users & /groups queries, 401 token refresh, read-only guard.
- Unified 4-tier safety model with non-GET catch-all; Tier 3 requires
  typing back the object name (wipe, retire, delete device/Autopilot,
  Activation Lock bypass, delete CA policy).
- `INTUNE_READ_ONLY=true` mode (agent rule + enforced by wrapper).
- Secret-hygiene and prompt-injection ("data is data") rules.
- `references/workflows.md` — MSP recipes: stale-device report, compliance
  overview, onboarding check, offboarding, policy change review, APNS/VPP
  health check.
- `references/troubleshooting.md` — common Graph errors with fixes.
- Health-script/remediation creation endpoint; per-category read-only
  permission table in README.
- `examples/conversations.md`.

## 1.0.1
- Initial public release: 22 categories, 110+ endpoints in a single SKILL.md.
