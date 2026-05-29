# Layer 1 harness (optional)

시스템 레벨 가드(shell·품질 검사) 설정 SSOT. **고객 E2E**([`70-client-lifecycle-default`](../../.cursor/rules/70-client-lifecycle-default.mdc), [`client-project-lifecycle`](../../.cursor/skills/client-project-lifecycle/SKILL.md))의 PRD·디자인 HUMAN·Gate를 **대체하지 않는다.** 단계 3 **제품 구현**·mock-only 금지 판정은 [`stage3-entry-checklist`](../qa/stage3-entry-checklist.md)·`65-design-gate`와 병행한다.

## 단계

| 단계 | 내용 | 상태 |
|------|------|------|
| 1 | `.cursor-kit.json` `harness` + [`Get-KitHarnessConfig`](../../scripts/Kit-HookCommon.ps1) | 구현됨 |
| 2 | `guard-shell.ps1`, `quality-gate.ps1`, `hooks.json` 슬롯, sync·온보딩 | 구현됨 |

## `.cursor-kit.json` — `harness`

예시: [`project-kit/.cursor-kit.json.example`](../../project-kit/.cursor-kit.json.example) (제품 온보딩 기본: `shellGuard.mode` **block**). kit 템플릿 레포 self: [`../../.cursor-kit.json`](../../.cursor-kit.json)는 개발 편의상 **warn**.

| 경로 | 설명 | 기본값 (블록 생략 시) |
|------|------|------------------------|
| `harness.shellGuard.mode` | `off` \| `warn` \| `block` | `off` (`kitRepoMode: self`이고 `mode` 미지정 시 `warn`) |
| `harness.shellGuard.patternsFile` | 차단 regex JSON | `.cursor/hooks/guard-shell.patterns.json` |
| `harness.shellGuard.logPath` | warn 모드 로그 | `.cursor/state/shell-guard.log` |
| `harness.qualityGate.mode` | `off` \| `warn` \| `block` | `off` |
| `harness.qualityGate.configFile` | lint/tsc 명령 정의 | `.cursor/quality-gate.json` |
| `harness.qualityGate.stateFile` | 마지막 실행 결과 | `.cursor/state/quality-gate-last.json` |
| `harness.qualityGate.runOn` | 훅 이벤트 목록 | `["afterAgentResponse"]` |

`Get-KitHarnessConfig -WorkspaceRoot <루트>`는 위 값을 정규화한 hashtable을 반환한다. 훅·스크립트는 이 함수만 사용한다.

### 파싱·fail-open

- `.cursor-kit.json` **없음** → 전부 `off`, `ParseOk: true`
- JSON **깨짐** → 전부 `off`, `ParseOk: false`, `ParseMessage`에 사유
- `mode`가 `off`/`warn`/`block` 외 → 해당 서브시스템만 `off` + `ParseMessage`에 경고
- 훅은 `Set-StrictMode -Version Latest` 환경에서 동작하며, JSON 선택 필드는 `Test-JsonPropertyPresent`로 읽는다.

## SSOT·sync

| SSOT | sync 산출물 |
|------|-------------|
| [`shared/hooks/guard-shell.ps1`](../../shared/hooks/guard-shell.ps1) | `.cursor/hooks/guard-shell.ps1` |
| [`shared/hooks/guard-shell.patterns.json`](../../shared/hooks/guard-shell.patterns.json) | `.cursor/hooks/guard-shell.patterns.json` |
| [`shared/hooks/quality-gate.ps1`](../../shared/hooks/quality-gate.ps1) | `.cursor/hooks/quality-gate.ps1` |

- kit 레포: [`scripts/sync-hooks.ps1`](../../scripts/sync-hooks.ps1) — `sync-kit.ps1` 마지막에 호출. 기존 Obsidian·`kit-start` 훅은 유지한다.
- 제품 채널 **B**: [`scripts/sync-kit-product.ps1`](../../scripts/sync-kit-product.ps1) — 위 3파일만 화이트리스트 복사 (`kit-start-on-prompt.ps1` 덮어쓰기 금지).
- 제품 채널 **A**·**B**: `/start` 시 harness 훅 3파일 + `kit-start-on-prompt.ps1` 복사. `hooks.json` 슬롯은 `/start-setting`.
- `/start-setting`: [`Invoke-KitStartSetting.ps1`](../../scripts/Invoke-KitStartSetting.ps1)의 `Ensure-HarnessHookScripts` / `Ensure-HarnessHooksJson`이 훅 파일·`hooks.json` 슬롯을 idempotent merge한다.

## Shell guard (`beforeShellExecution`)

- 이벤트: `beforeShellExecution` → [`guard-shell.ps1`](../../shared/hooks/guard-shell.ps1)
- stdin: `command` 또는 `tool_input.command`
- `mode: block` → 매칭 시 `permission: deny` + **exit 2** (Cursor 차단)
- `mode: warn` → 로그(`logPath`) 후 allow
- `mode: off` 또는 `ParseOk: false` → allow (fail-open)
- 패턴 SSOT: `guard-shell.patterns.json`. 로컬 추가: `.cursor/guard-shell.local.json` (gitignore, `patterns` 배열 merge)
- 초기 패턴: `git add -A|.|--all`, `git push --force`, `rm -rf` / `Remove-Item -Recurse -Force`, `git reset --hard`
- 훅 스크립트 크래시 시 allow (fail-open). `failClosed`는 hooks.json에 넣지 않는다.

### E2E (수동)

Cursor에서 에이전트가 `git add -A`를 실행하려 할 때, `shellGuard.mode: block`이면 차단 메시지가 보여야 한다.

## Rule signals (운영 규칙 후보)

- **명시적:** `afterAgentResponse` — [`rule-candidate-capture.ps1`](../../.cursor/hooks/rule-candidate-capture.ps1) (assistant `규칙 후보:` 등)
- **암묵적 (실시간):** `beforeSubmitPrompt` — [`rule-signal-capture.ps1`](../../shared/hooks/rule-signal-capture.ps1) (`rule-approval-gate` **뒤**, timeout 15s). 사용자 보정 문구만 기록, 기본은 조용히 `docs/agent/rule-candidates.ndjson`에 append
- **암묵적 (배치):** [`scripts/agent/Invoke-TranscriptRuleMining.ps1`](../../scripts/agent/Invoke-TranscriptRuleMining.ps1) — 로컬 `agent-transcripts` 집계 → `.cursor/state/rule-mined-report.*`
- **채팅 트리거:** `beforeSubmitPrompt` — [`rule-mine-on-prompt.ps1`](../../.cursor/hooks/rule-mine-on-prompt.ps1) (`/kit-rule-mine`, `규칙 마이닝`, timeout 300s)
- 패턴 SSOT: [`shared/hooks/rule-signal-patterns.json`](../../shared/hooks/rule-signal-patterns.json) (`sync-hooks.ps1`로 `.cursor/hooks/` 복사)
- 승인·SSOT 승격: [`rule-candidates.md`](rule-candidates.md) · [`rule-approval-gate.ps1`](../../.cursor/hooks/rule-approval-gate.ps1)

## Quality gate (`afterAgentResponse`)

- 이벤트: `afterAgentResponse` — `rule-candidate-capture` **뒤**, `quality-gate` (timeout 25s)
- 설정: [`project-kit/.cursor/quality-gate.json.example`](../../project-kit/.cursor/quality-gate.json.example) → 제품 `.cursor/quality-gate.json` (gitignore)
- `harness.qualityGate.mode: off` 또는 설정 파일 없음 → 조용히 skip
- `onlyWhen` (예: `deliveryLoopEnabled` + `lifecyclePhases`)이 있으면 [`.cursor/state/delivery-ralph.json`](../qa/delivery-loop-state.example.json) 조건을 만족할 때만 실행 — 기본 소음 방지
- 각 `commands[]`는 `cmd /c`로 `maxSeconds` 내 실행; 결과는 `quality-gate-last.json`
- 실패 시 `onFailure: warn` → stderr 3줄, exit 0. `harness.qualityGate.mode: block` + `onFailure: block` → exit 1 (에이전트 응답 롤백은 Cursor 버전에 따라 미지원일 수 있음 — 문서상 warn과 동일하게 취급 가능)
- 긴 테스트·전체 루프는 [`delivery-loop-harness.md`](delivery-loop-harness.md) · [`Invoke-DeliveryLoop.ps1`](../../scripts/delivery/Invoke-DeliveryLoop.ps1)

`guard-delivery-loop` ↔ `quality-gate-last` **필수 연동은 없음** (선택 보조).

## Performance gate (`perf-last`, 선택)

- SSOT: [`docs/performance/README.md`](../performance/README.md) — web / app / api `enabled`, **제품 미정 시 전부 false**
- 예산: `docs/requirements/perf-budget.json` (템플릿 [`perf-budget.template.json`](../performance/perf-budget.template.json))
- 산출: `.cursor/state/perf-last.json` (예시 [`perf-last.example.json`](../qa/perf-last.example.json))
- kit 스텁: [`scripts/perf/Invoke-PerfGate.ps1`](../../scripts/perf/Invoke-PerfGate.ps1) — 실측 없음, 계약·파일 쓰기만
- **긴 측정**(Lighthouse·k6·전체 `perf:ci`)은 quality-gate 훅(25s)이 아니라 `Invoke-DeliveryLoop.ps1` + `lifecyclePhase: perf` ([`delivery-loop-harness.md`](delivery-loop-harness.md))
- `quality-gate.json`에 짧은 smoke만 넣을 때 예 (제품 구현 후):

```json
{
  "id": "perf-smoke",
  "shell": "npm run perf:ci",
  "maxSeconds": 18,
  "required": false
}
```

- 완료 선언: `perf-last.ok: false` 시 완료 금지 **권고** (`docs/performance/policy-and-contract.md`). `AGENTS.md`·`quality-gate-last`와 동일 패턴, kit AGENTS 필수 변경 없음.

## 수동 검증

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/Test-KitHarnessConfig.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/Test-GuardShellHarness.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/Test-QualityGateHarness.ps1
```

`sync-kit.ps1` 후 `.cursor/hooks/`에 harness 3파일이 있어야 한다.

## 트러블슈팅

| 증상 | 확인 |
|------|------|
| block인데 명령이 통과됨 | `.cursor-kit.json` `ParseOk`, `harness.shellGuard.mode`, 훅이 최신 sync인지 |
| quality gate가 안 돈다 | `.cursor/quality-gate.json` 존재·`enabled`, `onlyWhen` vs `delivery-ralph.json` phase |
| 제품에 훅 파일 없음 | `/start`(채널 A·B sync) 또는 `/start-setting` · `hooks.json` 슬롯 |
| 한글 설정 깨짐 | `.cursor-kit.json` UTF-8 **BOM 없음** |

## 관련

- [`kit-start.md`](kit-start.md) — `.cursor-kit.json` 필드
- [`delivery-loop-harness.md`](delivery-loop-harness.md) — 검증 루프(선택)
- [`kit-inventory.md`](kit-inventory.md)
- [`product-onboarding.md`](product-onboarding.md) — 제품 harness 활성화
- [`docs/performance/README.md`](../performance/README.md) — 성능 게이트 템플릿
