# Changelog

## [Unreleased]

### Added

- `docs/qa/integration-consumption-gate.md` — 생성·소비 DoD SSOT (횡단 자산·kit·공유 패키지)
- `60-delivery-gates` Gate 1 비고·Gate 3 소비 조건; `stage3-entry-checklist` §6·`product-onboarding` 소비 확인 절

### Changed

- `AGENTS.md`, `start-feature`·`parallel-delivery`·`kit-start`, frontend/backend-agent — integration-consumption-gate 링크
- `rules-maintenance-checklist` — integration·stage3·60 삼자 정합 점검

### Fixed

- `Invoke-GitNativeQuiet` in `Kit-HookCommon.ps1` — git fetch/pull stderr (`From https://...`) no longer aborts `/start` on PowerShell 5.1 with `$ErrorActionPreference Stop`

### Changed

- Channel A `sync-kit-product`: sync **`shared/agents`** to product `.cursor/agents` on `/start` (same as skills; no ReplaceAll wipe)

### Added

- `start-setting` skill + `/kit-start-setting` hook alias — slash autocomplete for product onboarding (distinct from `kit-start` / `start-feature`)
- `kit-start` skill + `/kit-start` hook alias — autocomplete distinct from `start-feature`
- `product-onboarding.md` — submodule `update --init --remote` when to use, verification checklist, vs daily `/start`
- `Invoke-KitStart.ps1` — auto `git submodule update --init --remote` when submodule kit is behind or stale (`Kit-HookCommon.ps1`)

### Changed

- `/start` on product: `sync-kit-product` refreshes `kit-start-on-prompt.ps1`; `/start-setting` overwrites hook (`updated` not `exists` only)
- Channel A `sync-kit-product`: sync **all** `shared/skills` + harness hook scripts on `/start` (not lifecycle-only)

### Added

- `Get-KitHarnessConfig` in `scripts/Kit-HookCommon.ps1` — parse `.cursor-kit.json` `harness` (fail-open, PS 5.1)
- `scripts/Test-KitHarnessConfig.ps1` — manual harness config verification
- `docs/agent/harness-layer1.md` — Layer 1 harness SSOT (config + stage 2 hooks)
- `harness` block in `project-kit/.cursor-kit.json.example` and kit root `.cursor-kit.json`
- Harness stage 2: `shared/hooks/guard-shell.ps1`, `guard-shell.patterns.json`, `quality-gate.ps1`
- `scripts/sync-hooks.ps1` — deploy harness hooks; wired in `sync-kit.ps1` and channel B `sync-kit-product.ps1`
- `scripts/Test-GuardShellHarness.ps1`, `scripts/Test-QualityGateHarness.ps1`
- `project-kit/.cursor/quality-gate.json.example`; `Invoke-KitStartSetting` merges harness hooks into product `hooks.json`
- `Resolve-HookProjectRoot`, `Write-HarnessLog`, `Get-QualityGateFileConfig`, shell/quality gate helpers in `Kit-HookCommon.ps1`
- `scripts/Invoke-KitStartSetting.ps1` — `/start-setting` one-shot product onboarding (submodule, config, hooks, first sync)
- Chat command `/start-setting` in `kit-start-on-prompt.ps1`

### Changed

- Post-design implementation clarity: `65-design-gate` 선택 후 절, `client-project-lifecycle` 단계 3, `70`/`60`, `parallel-delivery`·`start-feature`, `frontend-agent`·`design-system-agent`, `stage3-entry-checklist` 섹션 6, `agent-brief`, `AGENTS.md`, workflow HTML p3/p4
- `project-kit/.cursor-kit.json.example` — `harness.shellGuard.mode` default **block** for products; kit self `.cursor-kit.json` stays **warn**
- `.cursor/hooks.json` — `beforeShellExecution` (guard-shell), `afterAgentResponse` (quality-gate after rule-candidate-capture)
- `.gitignore` — `.cursor/quality-gate.json`, `.cursor/guard-shell.local.json`
- `AGENTS.md` — do not declare completion when `quality-gate-last.json` has `ok: false`
- `docs/agent/harness-layer1.md`, `delivery-loop-harness.md`, `product-onboarding.md`, `kit-inventory.md`, `rules-maintenance-checklist.md`
- `docs/agent/product-onboarding.md` — 「처음부터 3단계」(kit clone → `Invoke-KitStartSetting` → `/start-setting`) SSOT; harness 옵션 절
- `project-kit/README.md`, root `README.md`, `kit-start.md` — kit vs 제품 절차 분리, PowerShell `-ExecutionPolicy Bypass` 통일

## [0.3.0] - `/start` hook and product integration

### Added

- `scripts/Invoke-KitStart.ps1` — git fetch/pull, sync, `.cursor/state/kit-start-last.json`
- `scripts/sync-kit-product.ps1` — channel **A** (project-kit rules + lifecycle) / **B** (full shared + project-kit)
- `.cursor-kit.json` — kit 레포 `self` + channel B
- `.cursor/hooks/kit-start-on-prompt.ps1` — `beforeSubmitPrompt` (fail-closed)
- `project-kit/.cursor-kit.json.example`, `project-kit/.cursor/hooks.json.example`, `project-kit/.cursor/hooks/kit-start-on-prompt.ps1`
- `docs/agent/kit-start.md`, `docs/agent/product-onboarding.md`

### Changed

- `.cursor/hooks.json` — `/start` 훅을 `beforeSubmitPrompt` 맨 위에 등록 (timeout 120s)
- `AGENTS.md` — `/start` 시 `kit-start-last.json` 선독 규칙
- `project-kit/README.md`, `docs/agent/kit-inventory.md`, 루트 `README.md`

### Product onboarding

1. `git submodule add ... vendor/cursor-workspace-kit`
2. `.cursor-kit.json` (`channel: "A"` or `"B"`)
3. 제품 `.cursor/hooks` — `/start` 훅만 (kit Obsidian·delivery 훅 제외)

Git tag `v0.3.0-kit-start` (선택)

## [0.2.0] - Skills and Agents SSOT

### Added

- `shared/skills/` — 공통 스킬 SSOT (`import-from-user-cursor.ps1`로 `~/.cursor/skills`에서 가져옴)
- `shared/agents/` — 서브에이전트 6개 SSOT
- `project-kit/.cursor/skills/client-project-lifecycle/` — 고객 E2E 스킬 SSOT (기존 `.cursor/skills`에서 이동)
- `scripts/import-from-user-cursor.ps1`, `sync-skills.ps1`, `sync-agents.ps1`, `sync-kit.ps1`
- `docs/agent/skills-agents-deploy.md`

### Changed

- `.cursor/skills/`, `.cursor/agents/` — sync 산출물 (직접 편집 금지)
- `AGENTS.md`, `kit-inventory.md`, `project-kit/README.md`, `60`/`64` rules — `shared/skills`·agents 경로
- `backend-agent.md` 본문 제목 `# backend-agent`로 정규화

### Migration (kit 레포, 채널 B)

1. `powershell -NoProfile -File scripts/import-from-user-cursor.ps1 -Force`
2. `powershell -NoProfile -File scripts/sync-kit.ps1`
3. `~/.cursor/skills`·`~/.cursor/agents`에서 kit과 **중복** 항목 제거 — [`skills-agents-deploy.md`](docs/agent/skills-agents-deploy.md)
4. Git tag `v0.2.0-skills-agents` (선택)

### Not in this release

- hooks SSOT 분리

## [0.1.0] - Rules SSOT

### Added

- `shared/rules/` — 공통 rules SSOT (User Rules 원문 3블록 + 20~50, 65)
- `shared/optional/locale-ko.mdc` — 선택: 한국어 응답
- `project-kit/.cursor/rules/` — 60, 64, 70 게이트·고객 라이프사이클 SSOT
- `scripts/sync-rules.ps1` — SSOT → `.cursor/rules/` 동기화
- `docs/agent/kit-inventory.md`, `docs/agent/rules-deploy.md`
- `project-kit/README.md`

### Changed

- Rules **편집 위치**가 `.cursor/rules/`에서 `shared/`·`project-kit/`로 이동 (`.cursor/rules`는 sync 산출물)
- `AGENTS.md`, `docs/agent/rules-context-notes.md`, `rules-maintenance-checklist.md` — SSOT 경로 반영
- `65-design-gate` — 문서상 User-level 가정과 맞추기 위해 `shared/rules`로 분류

### Migration

1. `powershell -NoProfile -File scripts/sync-rules.ps1`
2. Cursor User Rules UI에서 기존 긴 블록 제거 (중복 방지) — [`docs/agent/rules-deploy.md`](docs/agent/rules-deploy.md)
3. Git tag `v0.1.0-rules` (선택)

### Not in this release

- Skills, agents, hooks SSOT 이동 (후속)
