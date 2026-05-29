# 운영 규칙 후보 (rule candidates)

작업 중·과거 대화에서 드러난 **운영 규칙 후보**를 수집하고, **사용자 승인 후**에만 `shared/rules`, `shared/skills`, `AGENTS.md` 등 SSOT에 반영한다.  
즉시 전역 규칙으로 확정하지 않는다 — [`emergent-rule-capture-global`](../../shared/rules/emergent-rule-capture-global.mdc).

## 신호 종류

| 종류 | 출처 | confidence | 설명 |
|------|------|------------|------|
| 명시적 | assistant 응답 `규칙 후보:` / `새 규칙` / `운영 규칙:` | high | [`rule-candidate-capture.ps1`](../../.cursor/hooks/rule-candidate-capture.ps1) |
| 암묵적 (실시간) | 사용자 프롬프트 보정 문구 | low | [`rule-signal-capture.ps1`](../../shared/hooks/rule-signal-capture.ps1) |
| 암묵적 (배치) | 과거 JSONL 집계 | medium | [`Invoke-TranscriptRuleMining.ps1`](../../scripts/agent/Invoke-TranscriptRuleMining.ps1) |

암묵적 신호 예: 「빠뜨렸어」「이것도 확인해줘」「여전히 틀렸어」 — 완료 전에 했어야 할 일(암묵적 DoD)을 사후에 드러냄.

## 저장 위치 (로컬, gitignore)

| 파일 | 용도 |
|------|------|
| `docs/agent/rule-candidates.ndjson` | pending/approved/rejected 후보 (한 줄 = JSON) |
| `docs/agent/rule-approvals.md` | 승인·반려 로그 |
| `.cursor/state/rule-mined-report.json` | 배치 마이닝 집계 |
| `.cursor/state/rule-mined-report.md` | 사람이 읽기 쉬운 요약 |

**커밋하지 않는다.** 리포트·ndjson에 경로·이메일·키가 섞일 수 있다.

## ndjson 필드 (확장 스키마)

기존 필드: `id`, `title`, `scope`, `target`, `target_path`, `rule_text`, `source`, `status`, `created_at`.

배치·신호 훅 추가 필드:

| 필드 | 설명 |
|------|------|
| `signal_type` | `omission` / `recheck` / `repeat_fail` / `scope_reopen` / `explicit_rule` |
| `confidence` | `high` / `medium` / `low` |
| `pattern_id` | [`rule-signal-patterns.json`](../../shared/hooks/rule-signal-patterns.json) id |
| `conversation_id` | 트랜스크립트 폴더 uuid |
| `project_slug` | `projects\<slug>` |
| `user_snippet` | redact 후 최대 120자 |
| `suggested_target` | `verify-change` / `release-check` / `working-principles` / `agents` / `bugfix-flow` |
| `cluster_key` | `signal_type|topic_id` (배치 집계) |
| `stats` | `{ "hits", "conversations" }` (배치만) |

### redact 규칙

배치·훅 공통 ([`RuleSignalCommon.ps1`](../../scripts/agent/RuleSignalCommon.ps1)):

- Windows/Unix 경로 → `[path]`
- 이메일 → `[email]`
- `sk-…` → `[secret]`
- `Bearer …` → `Bearer [redacted]`
- 스니펫 최대 120자

### rule_text 작성 (승격 시)

사용자 불만 문장을 그대로 넣지 않는다. **검증 가능한 의무**로 쓴다.

| 신호 (예) | rule_text (예) |
|-----------|----------------|
| sync 누락 | `shared/*` rules/skills/agents 수정 후 `sync-kit.ps1` 실행·결과 한 줄 보고 |
| 완료 오판 | 완료 선언 전 `.cursor/state/quality-gate-last.json`의 `ok` 확인 |
| UI 상태 누락 | UI 변경 시 로딩/빈/오류/권한·다크모드 spot check (`verify-change` 절차) |

## 채팅 명령 (터미널 없이)

### 배치 마이닝 (`/kit-rule-mine`)

PowerShell을 직접 열지 않아도 된다. 채팅 맨 앞에 입력하면 [`rule-mine-on-prompt.ps1`](../../.cursor/hooks/rule-mine-on-prompt.ps1)이 스크립트를 실행한다 (`/start`와 동일 패턴). **슬래시 목록**에는 스킬 **`kit-rule-mine`** ([`shared/skills/kit-rule-mine/`](../../shared/skills/kit-rule-mine/SKILL.md))을 선택해도 된다.

| 입력 | 동작 |
|------|------|
| `/kit-rule-mine` 또는 `/rule-mine` | 전체 projects 스캔 → `.cursor/state/rule-mined-report.md` |
| `/kit-rule-mine import` | 위 + `rule-candidates.ndjson` 병합 |
| `/kit-rule-mine 90` 또는 `규칙 마이닝 90일` | 최근 90일만 |
| `규칙 마이닝` | `/kit-rule-mine`과 동일 |

완료 후 `.cursor/state/rule-mine-last.json` 요약이 훅 메시지로 전달된다. 대량 스캔은 **수 분** 걸릴 수 있다(훅 timeout 300s).

### 후보 검토·승인

| 입력 | 동작 |
|------|------|
| `규칙 후보 목록` / `규칙 후보 목록 20` | pending 목록 (최대 N건) |
| `규칙 승인 #1` / `규칙 승인 최신` | 후보 승인·반영 |
| `규칙 반려 #1 사유: …` | 반려 기록 |

승인 시 [`rule-approval-gate.ps1`](../../.cursor/hooks/rule-approval-gate.ps1)이 `.cursor/rules/90-runtime-rule-*.mdc` 또는 `AGENTS.md`에 임시 반영할 수 있다.

## kit SSOT 승격 (권장)

**kit 템플릿 레포**에서는 승인 후 아래가 정식 경로다. `90-runtime-rule-*.mdc`는 제품 레포 임시용.

| `suggested_target` | 편집 위치 |
|--------------------|-----------|
| `verify-change` | [`shared/skills/verify-change/SKILL.md`](../../shared/skills/verify-change/SKILL.md) |
| `release-check` | [`shared/skills/release-check/SKILL.md`](../../shared/skills/release-check/SKILL.md) |
| `working-principles` | [`shared/rules/working-principles.mdc`](../../shared/rules/working-principles.mdc) (전역·소수) |
| `agents` | [`AGENTS.md`](../../AGENTS.md) 직접 처리 예외·우선순위만 |
| UI 도메인 | `30`/`40`/`50` 등 해당 규칙 |

편집 후: `powershell -NoProfile -File scripts/sync-kit.ps1`

점검: [`rules-maintenance-checklist.md`](rules-maintenance-checklist.md) — rule-candidates 승격 절.

## 배치 마이닝

**권장(터미널 없음):** 채팅에 `/kit-rule-mine` 또는 `/kit-rule-mine import`.

**수동(터미널·CI):**

```powershell
# 전체 Cursor projects (기본)
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/agent/Invoke-TranscriptRuleMining.ps1

# 최근 90일, 후보 ndjson 병합
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/agent/Invoke-TranscriptRuleMining.ps1 -SinceDays 90 -ImportToCandidates

# 테스트 fixture만
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/agent/Invoke-TranscriptRuleMining.ps1 `
  -TranscriptsRoot (Join-Path $PWD "scripts\agent\fixtures") -MaxFiles 10
```

상세: [`scripts/agent/README.md`](../../scripts/agent/README.md)

## 재측정

한 달 뒤 동일 스크립트를 재실행해 클러스터 `hits`가 줄었는지 본다. 줄지 않으면 SSOT 승격·스킬 체크리스트 보강을 검토한다.

## 관련

- [`harness-layer1.md`](harness-layer1.md) — 훅 슬롯
- [`kit-inventory.md`](kit-inventory.md) — 인벤토리
