# Changelog

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
