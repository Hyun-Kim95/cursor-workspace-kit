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
| `working-principles.mdc` | 실행 계획·분담·HUMAN·DoD·조사·소통·실패 대응·DB 운영 기본값 |
| `encoding-utf8-global.mdc` | UTF-8 저장·읽기 (에이전트·GitHub 깨짐 방지) |
| `product-monetization-default.mdc` | 계획·PRD 기본: 사업자 없음, 수익 광고·후원만 |
| `20-web-vs-app.mdc` | 웹 vs 앱 UX·신규 모바일 스택 기본값 |
| `30-table-pagination.mdc` | 테이블·필터·페이지네이션 |
| `40-dark-mode.mdc` | 다크/라이트·토큰 |
| `50-index-css-contract.mdc` | 전역 스타일·Stitch |
| `65-design-gate.mdc` | 디자인 선행·이중 안 |

## shared/optional

| 파일 | 한 줄 목적 |
|------|------------|
| `locale-ko.mdc` | 응답 한국어 (선택) |
| `21-app-version-update.mdc` | 모바일 앱 버전 업데이트 권장/강제 (선택, 앱 있는 제품) |
| `22-product-analytics.mdc` | 제품 분석·이벤트 추적 (선택, PRD 측정=예) |
| `23-performance-gate.mdc` | 성능 게이트 web/app/api (선택, PRD 성능 게이트=예) |
| `24-security-gate.mdc` | 보안 게이트 6축·strict (선택, PRD 보안 게이트=예) |

## docs/mobile

| 경로 | 한 줄 목적 |
|------|------------|
| [`docs/mobile/app-update/`](../../docs/mobile/app-update/README.md) | 버전 업데이트 정책·API·UX·greenfield/brownfield 체크리스트 |

## docs/product-analytics

| 경로 | 한 줄 목적 |
|------|------------|
| [`docs/product-analytics/`](../../docs/product-analytics/README.md) | 제품 분석·이벤트 추적 정책·계약·greenfield/brownfield·릴리스 체크리스트 |

## docs/performance

| 경로 | 한 줄 목적 |
|------|------------|
| [`docs/performance/`](../../docs/performance/README.md) | 성능 게이트 web/app/api·perf-budget·perf-last·체크리스트 |
| [`scripts/perf/`](../../scripts/perf/README.md) | Invoke-PerfGate.ps1 스텁 (실측 없음) |

## docs/security

| 경로 | 한 줄 목적 |
|------|------------|
| [`docs/security/`](../../docs/security/README.md) | 보안 게이트 6축·security-policy·security-last·엄격 체크리스트 |
| [`scripts/security/`](../../scripts/security/README.md) | Invoke-SecurityGate.ps1 스텁 (실스캔 없음) |

## docs/qa

| 경로 | 한 줄 목적 |
|------|------------|
| [`docs/qa/stage3-entry-checklist.md`](../../docs/qa/stage3-entry-checklist.md) | 디자인 선택 후 Gate 2·제품 구현 착수 체크리스트 |
| [`docs/qa/atdd-lite.md`](../../docs/qa/atdd-lite.md) | ATDD-lite SSOT (PRD AC → RED → GREEN) |
| [`docs/qa/acceptance-criteria.template.md`](../../docs/qa/acceptance-criteria.template.md) | PRD 수용 기준(AC) 표 템플릿 |
| [`docs/qa/atdd-lite-consumption-checklist.md`](../../docs/qa/atdd-lite-consumption-checklist.md) | 제품 레포 ATDD-lite 소비 증거 체크리스트 |
| [`docs/qa/atdd-lite-consumption-record-example.md`](../../docs/qa/atdd-lite-consumption-record-example.md) | ATDD-lite 소비 기록 예시 (가상 제품) |
| [`docs/qa/integration-consumption-gate.md`](../../docs/qa/integration-consumption-gate.md) | 횡단 자산·kit·공유 패키지 생성·소비 DoD SSOT |
| [`docs/qa/reviewer-gate-rubric.md`](../../docs/qa/reviewer-gate-rubric.md) | 리뷰어 GATE 루브릭 (선택) |

## project-kit/.cursor/rules

| 파일 | 한 줄 목적 |
|------|------------|
| `60-delivery-gates.mdc` | Gate 1~3, 병렬, DoD, ATDD-lite |
| `64-context-organization.mdc` | 맥락 정리 경계 |
| `70-client-lifecycle-default.mdc` | 고객 E2E·디자인 승인=구현 착수 |

---

## shared/skills

| 폴더 | 용도 (요약) |
|------|-------------|
| `plan-feature` | 모호한 요청 → 요구·정책 정리 |
| `context-organization` | Gate 비변 선행 3단 러브릭 |
| `kit-start` | kit pull·sync (`/start`, `/kit-start` 훅; `start-feature`와 별개) |
| `kit-rule-mine` | 트랜스크립트 규칙 배치 마이닝 (`/kit-rule-mine` 훅; `kit-start`·`start-feature`와 별개) |
| `kit-work-log` | 날짜별 작업 일지 (`docs/work-log/`; `/kit-work-log`·`/work-log` 훅) |
| `start-setting` | 제품 1회 온보딩 (`/start-setting`, `/kit-start-setting` 훅; `kit-start`와 별개) |
| `start-feature` | Gate 1 후 ATDD-lite RED·구현·검증 |
| `parallel-delivery` | Gate 2 후 ATDD RED·FE/BE 병렬 |
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
| `scripts/Sync-KitProductHooks.ps1` | 제품 훅 스크립트·`hooks.json`·Obsidian post-commit (`/start` 시 호출) |
| `scripts/Invoke-KitStart.ps1` | `/start` 백엔드: (submodule 시 필요하면) `submodule update --init --remote` + pull + sync |
| [`product-onboarding.md`](product-onboarding.md#submodule-최신화--start-vs-submodule-update---remote) | submodule `--remote` 필요 여부·확인 체크리스트 |
| `scripts/Invoke-KitStartSetting.ps1` | `/start-setting` 백엔드: submodule·설정·훅·첫 sync |
| `scripts/Kit-HookCommon.ps1` | 훅 UTF-8 stdout · `Read/Write-KitUtf8File` · PS 5.1 JSON · harness 헬퍼 |
| `scripts/Ensure-ProductEncodingAssets.ps1` | 제품 루트 `.editorconfig`·`.gitattributes` (없을 때만) |
| `project-kit/.editorconfig`, `project-kit/.gitattributes` | 제품 인코딩 템플릿 |
| `scripts/sync-hooks.ps1` | `shared/hooks/*` → `.cursor/hooks/` (harness 5파일; kit 전용 훅 유지) |
| `scripts/Test-KitHarnessConfig.ps1` | Harness config 수동 검증 |
| `scripts/Test-GuardShellHarness.ps1` | Shell guard 훅 수동 검증 |
| `scripts/Test-QualityGateHarness.ps1` | Quality gate 훅 수동 검증 |
| [`scripts/agent/Invoke-TranscriptRuleMining.ps1`](../../scripts/agent/Invoke-TranscriptRuleMining.ps1) | 과거 JSONL 암묵적 보정 신호 배치 마이닝 |
| [`scripts/agent/Test-TranscriptRuleMining.ps1`](../../scripts/agent/Test-TranscriptRuleMining.ps1) | 마이닝 스모크 (fixture) |
| [`docs/agent/rule-candidates.md`](rule-candidates.md) | 운영 규칙 후보·승격·ndjson 스키마 |
| `shared/hooks/` | harness 훅 SSOT (`guard-shell`, `quality-gate`, `rule-signal-capture`, `rule-signal-patterns`) |

## 훅·상태

| 경로 | 용도 |
|------|------|
| `.cursor/hooks/kit-start-on-prompt.ps1` | `beforeSubmitPrompt` — `/start` 트리거 |
| `.cursor/hooks/guard-shell.ps1` | `beforeShellExecution` — shell guard |
| `.cursor/hooks/quality-gate.ps1` | `afterAgentResponse` — 짧은 lint/tsc |
| `.cursor/hooks/rule-signal-capture.ps1` | `beforeSubmitPrompt` — 암묵적 보정 신호 후보 |
| `.cursor/state/rule-mined-report.json` | 배치 마이닝 집계 (로컬, gitignore) |
| `.cursor/hooks/sync-kit-on-session.ps1` | `sessionStart` — 로컬 sync (fail-open) |
| `.cursor/state/kit-start-last.json` | 마지막 `/start` 결과 (에이전트·디버그) |
| `.cursor/state/kit-start-setting-last.json` | 마지막 `/start-setting` 온보딩 결과 |
| `.cursor/state/quality-gate-last.json` | 마지막 quality gate 결과 (로컬) |
| `.cursor/state/shell-guard.log` | shell guard warn 로그 (로컬) |

제품 레포 템플릿: `project-kit/.cursor-kit.json.example`, `project-kit/.cursor/hooks*`

## 인코딩·제품 전제

- UTF-8: [`encoding.md`](encoding.md) · `encoding-utf8-global.mdc` · `Ensure-ProductEncodingAssets.ps1`
- 수익·사업자 기본값: [`product-assumptions.md`](product-assumptions.md) · `product-monetization-default.mdc`

## 버전

- Rules: `v0.1.0-rules`
- Skills·Agents: `v0.2.0-skills-agents`
- `/start`·제품 연동: `v0.3.0-kit-start` (CHANGELOG)
