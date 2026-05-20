# Kit inventory

Kit SSOT는 Git에서 관리한다. **편집은 SSOT 경로만** 하고, 루트 `.cursor/` 아래 rules·skills·agents는 sync 산출물이다.

**동기화:** [`scripts/sync-kit.ps1`](../../scripts/sync-kit.ps1) (rules + skills + agents)

| 산출물 | SSOT | 스크립트 |
|--------|------|----------|
| [`.cursor/rules/`](../../.cursor/rules/) | `shared/rules/`, `shared/optional/`, `project-kit/.cursor/rules/` | `sync-rules.ps1` |
| [`.cursor/skills/`](../../.cursor/skills/) | `shared/skills/`, `project-kit/.cursor/skills/` | `sync-skills.ps1` |
| [`.cursor/agents/`](../../.cursor/agents/) | `shared/agents/` | `sync-agents.ps1` |

배포: [`rules-deploy.md`](rules-deploy.md), [`skills-agents-deploy.md`](skills-agents-deploy.md)

---

## shared/rules

| 파일 | 한 줄 목적 |
|------|------------|
| `product-ui-core-global.mdc` | 상태 UI·접근성·공통 UX |
| `emergent-rule-capture-global.mdc` | 운영 규칙 후보 수집 |
| `working-principles.mdc` | 실행 계획·분담·HUMAN·DoD |
| `20-web-vs-app.mdc` | 웹 vs 앱 UX |
| `30-table-pagination.mdc` | 테이블·필터·페이지네이션 |
| `40-dark-mode.mdc` | 다크/라이트·토큰 |
| `50-index-css-contract.mdc` | 전역 스타일·Stitch |
| `65-design-gate.mdc` | 디자인 선행·이중 안 |

## shared/optional

| 파일 | 한 줄 목적 |
|------|------------|
| `locale-ko.mdc` | 응답 한국어 (선택) |

## project-kit/.cursor/rules

| 파일 | 한 줄 목적 |
|------|------------|
| `60-delivery-gates.mdc` | Gate 1~3, 병렬, DoD |
| `64-context-organization.mdc` | 맥락 정리 경계 |
| `70-client-lifecycle-default.mdc` | 고객 E2E·디자인 승인=구현 착수 |

---

## shared/skills

| 폴더 | 용도 (요약) |
|------|-------------|
| `plan-feature` | 모호한 요청 → 요구·정책 정리 |
| `context-organization` | Gate 비변 선행 3단 러브릭 |
| `kit-start` | kit pull·sync (`/start`, `/kit-start` 훅; `start-feature`와 별개) |
| `start-setting` | 제품 1회 온보딩 (`/start-setting`, `/kit-start-setting` 훅; `kit-start`와 별개) |
| `start-feature` | Gate 1 후 구현·검증 |
| `parallel-delivery` | Gate 2 후 FE/BE 병렬 |
| `verify-change` | 구현 검증·회귀 |
| `document-change` | 변경 요약·문서 동기화 |
| `bugfix-flow` | 버그 수정 흐름 |
| `release-check` | 배포 전 점검 |
| `implementation-preflight` | (전역 import) 구현 전 점검 |
| `pre-implementation-research` | (전역 import) 구현 전 조사 |

상세 description은 각 `SKILL.md` frontmatter 참고.

## project-kit/.cursor/skills

| 폴더 | 용도 |
|------|------|
| `client-project-lifecycle` | 고객 E2E: PRD·이중 목업·디자인·구현·테스트 |

## shared/agents

| 파일 | 용도 |
|------|------|
| `frontend-agent.md` | UI·반응형·상태 UI |
| `backend-agent.md` | API·DB·인증·서버 |
| `prd-agent.md` | 요구·정책·범위 |
| `qa-agent.md` | 검증·회귀 |
| `docs-agent.md` | 문서화·인수인계 |
| `design-system-agent.md` | 토큰·테마·다크모드 |

---

## 루트·스크립트

| 경로 | SSOT |
|------|------|
| `AGENTS.md` | 오케스트레이션·직접 처리 예외·`/start` 규칙 |
| `.cursor-kit.json` | kit 경로·`kitRepoMode`·`channel`·`harness` (제품은 루트에 복사) — [`harness-layer1.md`](harness-layer1.md) |
| `scripts/import-from-user-cursor.ps1` | `~/.cursor` → `shared/` (일회/재동기화) |
| `scripts/sync-kit.ps1` | kit 레포 전체 sync (`self` 모드) |
| `scripts/sync-kit-product.ps1` | 제품 `.cursor/` 채널 A/B sync |
| `scripts/Invoke-KitStart.ps1` | `/start` 백엔드: (submodule 시 필요하면) `submodule update --init --remote` + pull + sync |
| [`product-onboarding.md`](product-onboarding.md#submodule-최신화--start-vs-submodule-update---remote) | submodule `--remote` 필요 여부·확인 체크리스트 |
| `scripts/Invoke-KitStartSetting.ps1` | `/start-setting` 백엔드: submodule·설정·훅·첫 sync |
| `scripts/Kit-HookCommon.ps1` | 훅 UTF-8 stdout · PS 5.1 JSON · `Get-KitHarnessConfig` · harness 헬퍼 |
| `scripts/sync-hooks.ps1` | `shared/hooks/*` → `.cursor/hooks/` (harness 3파일; kit 전용 훅 유지) |
| `scripts/Test-KitHarnessConfig.ps1` | Harness config 수동 검증 |
| `scripts/Test-GuardShellHarness.ps1` | Shell guard 훅 수동 검증 |
| `scripts/Test-QualityGateHarness.ps1` | Quality gate 훅 수동 검증 |
| `shared/hooks/` | harness 훅 SSOT (`guard-shell.ps1`, `guard-shell.patterns.json`, `quality-gate.ps1`) |

## 훅·상태

| 경로 | 용도 |
|------|------|
| `.cursor/hooks/kit-start-on-prompt.ps1` | `beforeSubmitPrompt` — `/start` 트리거 |
| `.cursor/hooks/guard-shell.ps1` | `beforeShellExecution` — shell guard |
| `.cursor/hooks/quality-gate.ps1` | `afterAgentResponse` — 짧은 lint/tsc |
| `.cursor/hooks/sync-kit-on-session.ps1` | `sessionStart` — 로컬 sync (fail-open) |
| `.cursor/state/kit-start-last.json` | 마지막 `/start` 결과 (에이전트·디버그) |
| `.cursor/state/kit-start-setting-last.json` | 마지막 `/start-setting` 온보딩 결과 |
| `.cursor/state/quality-gate-last.json` | 마지막 quality gate 결과 (로컬) |
| `.cursor/state/shell-guard.log` | shell guard warn 로그 (로컬) |

제품 레포 템플릿: `project-kit/.cursor-kit.json.example`, `project-kit/.cursor/hooks*`

## 버전

- Rules: `v0.1.0-rules`
- Skills·Agents: `v0.2.0-skills-agents`
- `/start`·제품 연동: `v0.3.0-kit-start` (CHANGELOG)
