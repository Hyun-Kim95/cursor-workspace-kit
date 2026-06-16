# Kit 강제 수준 매트릭스 (읽기용 인덱스)

kit 규칙·스킬·훅이 **언제 무엇을 강제하는지**를 한곳에서 훑기 위한 문서다.

**역할:** 읽기용 인덱스·온보딩 요약. Gate 정의·예외 목록·절차의 **SSOT는 아니다.**

| 강제 수준 | 의미 |
|-----------|------|
| **항상** | 거의 모든 작업에 적용. 예외는 사용자 명시 지시·`AGENTS.md` 직접 처리 예외 등 |
| **상황별** | 적용 조건(신규 기능, UI, 고객 E2E, harness 설정 등)이 맞을 때만 |
| **권장** | kit가 기대하지만, 미충족만으로 절차 위반으로 단정하지 않음 |

**충돌 시 우선순위:** [`AGENTS.md`](../../AGENTS.md) 규칙 우선순위 절 → 개별 rule/skill SSOT.

규칙 파일 한 줄 목적: [`rules-context-notes.md`](rules-context-notes.md) · 인벤토리: [`kit-inventory.md`](kit-inventory.md)

---

## 1. 항상 강제

### 작업 방식

| 항목 | SSOT |
|------|------|
| 작업 전 실행 계획 제시 | [`shared/rules/working-principles.mdc`](../../shared/rules/working-principles.mdc) |
| 요청 범위만 최소 수정 | 동일 |
| 불확실 시 단정 금지·가정/확인 필요 표시 | 동일 |
| 되돌리기 비싼 선택은 확정 전 구현 금지 | 동일 · [`AGENTS.md`](../../AGENTS.md) 미확정 |
| 실패 시 무작위 재시도 전 원인 조사 | `working-principles.mdc` |

### 우선순위·승인

| 항목 | SSOT |
|------|------|
| 사용자 명시 지시 우선 (안전·보안 예외) | [`AGENTS.md`](../../AGENTS.md) 규칙 우선순위 |
| HUMAN 승인 구간에서 승인 전 다음 산출물 금지 | `working-principles.mdc` · 각 스킬 HUMAN 절 |
| 충돌 애매 시 확인 질문 1~2개 | `AGENTS.md` · `working-principles.mdc` |

### SSOT·편집

| 항목 | SSOT |
|------|------|
| `.cursor/rules|skills|agents`는 sync 산출물 — SSOT 수정 후 sync | [`kit-inventory.md`](kit-inventory.md) · [`rules-deploy.md`](rules-deploy.md) |
| Rules/Skills/Agents 중복 정의 금지 | [`AGENTS.md`](../../AGENTS.md) |
| 새 운영 규칙은 후보만 — 승인 후 SSOT 반영 | [`shared/rules/emergent-rule-capture-global.mdc`](../../shared/rules/emergent-rule-capture-global.mdc) · [`rule-candidates.md`](rule-candidates.md) |

### 파일·인코딩

| 항목 | SSOT |
|------|------|
| 텍스트 UTF-8 (BOM 없음 기본) | [`shared/rules/encoding-utf8-global.mdc`](../../shared/rules/encoding-utf8-global.mdc) · [`encoding.md`](encoding.md) |
| 깨진 한글 추측 복구 금지 | `encoding-utf8-global.mdc` |

### 계획·범위 기본 전제

| 항목 | SSOT |
|------|------|
| 사업자 없음, 수익 광고·후원 수준 기본 | [`shared/rules/product-monetization-default.mdc`](../../shared/rules/product-monetization-default.mdc) · [`product-assumptions.md`](product-assumptions.md) |
| 유료·세무·PG 흐름 기본 설계에 넣지 않음 | 동일 |

### kit 운영·완료 선언

| 항목 | SSOT |
|------|------|
| `/start` kit pull·sync 실패 시 작업 차단 (fail-closed) | [`AGENTS.md`](../../AGENTS.md) · [`kit-start.md`](kit-start.md) |
| 로컬 dev 서버 작업 마무리 시 기본 종료 | [`shared/rules/dev-server-cleanup-global.mdc`](../../shared/rules/dev-server-cleanup-global.mdc) |
| 생성·검증 분리 — self-verify 금지, `qa-agent` 독립 검증 | [`AGENTS.md`](../../AGENTS.md) · [`verify-change`](../../shared/skills/verify-change/SKILL.md) |
| `quality-gate-last.json`의 `ok: false`이면 완료·검증 완료 선언 금지 | [`AGENTS.md`](../../AGENTS.md) · [`harness-layer1.md`](harness-layer1.md) |

---

## 2. 상황별 강제

### Gate 1 — 구현 착수 전

**적용:** 신규 기능, 새 대외 API·계약 변경  
**면제:** 문서만 수정, 오탈자·단일 파일 소규모 수정, [`AGENTS.md` 직접 처리 예외](../../AGENTS.md#직접-처리-가능한-예외), brownfield 유지보수·버그(간이 점검)

| 필수 산출 | SSOT |
|-----------|------|
| PRD 또는 동등 범위 문서 | [`project-kit/.cursor/rules/60-delivery-gates.mdc`](../../project-kit/.cursor/rules/60-delivery-gates.mdc) |
| 수용 기준 (AC-01 형식) | 동일 · [`docs/qa/atdd-lite.md`](../qa/atdd-lite.md) |
| 화면 목업 또는 동등 스펙 | `60` |
| API 계약 초안 | `60` |

**스킬:** [`plan-feature`](../../shared/skills/plan-feature/SKILL.md) · [`start-feature`](../../shared/skills/start-feature/SKILL.md)

### Gate 2 — 프론트·백 병렬

**적용:** UI + API 동시 구현 (`parallel-delivery`)

| 조건 | SSOT |
|------|------|
| API 계약 확정 | `60` |
| 상태 UI·목업/스펙 정합 | `60` · [`65-design-gate`](../../shared/rules/65-design-gate.mdc) |
| 디자인 승인 | `65` · [`70-client-lifecycle-default`](../../project-kit/.cursor/rules/70-client-lifecycle-default.mdc) |
| 이중 디자인안 범위 시 A/B 선택 기록 | `65` |
| 구현 직전 ATDD-lite **RED** | [`docs/qa/atdd-lite.md`](../qa/atdd-lite.md) · `60` |

**스킬:** [`parallel-delivery`](../../shared/skills/parallel-delivery/SKILL.md) · [`docs/qa/stage3-entry-checklist.md`](../qa/stage3-entry-checklist.md)

### Gate 3 — 작업 완료 (DoD)

**적용:** 해당 기능/변경을 완료로 볼 때

| 조건 | SSOT |
|------|------|
| 요구·구현·문서·계약 일치 | `60` |
| PRD AC 대비 자동화 테스트 통과 | `60` · [`atdd-lite.md`](../qa/atdd-lite.md) |
| 상태 처리 (기본/로딩/빈/오류/권한) | `60` · [`product-ui-core-global`](../../shared/rules/product-ui-core-global.mdc) |
| 횡단 자산·kit·공유 패키지 **소비 증거** | [`docs/qa/integration-consumption-gate.md`](../qa/integration-consumption-gate.md) |

**스킬:** [`verify-change`](../../shared/skills/verify-change/SKILL.md)

### 디자인 게이트

**적용:** UI 포함 신규·변경, 프론트/백 병렬 예정

| 조건 | SSOT |
|------|------|
| 디자인 승인 전 코드 구현 금지 | [`65-design-gate.mdc`](../../shared/rules/65-design-gate.mdc) |
| 화면·상태·반응형·다크모드 스펙 | `65` |
| 이중 안: A/B 동시 제시 → HUMAN 선택 | `65` · [`AGENTS.md`](../../AGENTS.md) |
| 선택 후 목업 전용 경로만 재구현 금지 (기본) | `65` · `stage3-entry-checklist` |

### 고객 E2E

**적용:** 고객 요구 붙여넣기, 처음부터 PRD→목업→구현, 엔드투엔드 요청  
**미적용:** 단순 버그·소규모 수정, 사용자가 PRD 생략·스킬 무시를 명시한 경우

| 조건 | SSOT |
|------|------|
| PRD 승인 전 구현·목업(2A/2B) 금지 | [`70-client-lifecycle-default.mdc`](../../project-kit/.cursor/rules/70-client-lifecycle-default.mdc) |
| PRD·디자인 등 HUMAN 구간에서 멈춤 | `70` · [`client-project-lifecycle`](../../project-kit/.cursor/skills/client-project-lifecycle/SKILL.md) |
| 디자인 승인 = 구현 착수 승인 | `70` |
| 선택 후 stage3 → Gate 2 → ATDD RED → 제품 구현 | lifecycle 스킬 단계 3 |

### UI·플랫폼 규칙

| 규칙 | 적용 조건 | SSOT |
|------|-----------|------|
| `20-web-vs-app` | UI 있는 프로젝트 | [`shared/rules/20-web-vs-app.mdc`](../../shared/rules/20-web-vs-app.mdc) |
| `30-table-pagination` | 웹 테이블 목록 화면 | [`shared/rules/30-table-pagination.mdc`](../../shared/rules/30-table-pagination.mdc) |
| `40-dark-mode` | UI 있는 프로젝트 | [`shared/rules/40-dark-mode.mdc`](../../shared/rules/40-dark-mode.mdc) |
| `50-index-css-contract` | 전역 스타일 작업 | [`shared/rules/50-index-css-contract.mdc`](../../shared/rules/50-index-css-contract.mdc) |

> `20`·신규 스택 기본값: **brownfield 유지보수에는 자동 강제하지 않음** (`20` 적용 대상 절).

### 선택적 게이트 (PRD에서 해당 항목 = 예)

| 규칙 | PRD 조건 | SSOT |
|------|----------|------|
| `21-app-version-update` | 모바일 앱 있음 | [`shared/optional/21-app-version-update.mdc`](../../shared/optional/21-app-version-update.mdc) · [`docs/mobile/app-update/`](../mobile/app-update/README.md) |
| `22-product-analytics` | 측정 = 예 | [`shared/optional/22-product-analytics.mdc`](../../shared/optional/22-product-analytics.mdc) · [`docs/product-analytics/`](../product-analytics/README.md) |
| `23-performance-gate` | 성능 게이트 = 예 | [`shared/optional/23-performance-gate.mdc`](../../shared/optional/23-performance-gate.mdc) · [`docs/performance/`](../performance/README.md) |
| `24-security-gate` | 보안 게이트 = 예 | [`shared/optional/24-security-gate.mdc`](../../shared/optional/24-security-gate.mdc) · [`docs/security/`](../security/README.md) |

### Harness (훅 실차단)

**적용:** `.cursor-kit.json`의 `harness.*.mode`가 `warn` 또는 `block`일 때

| 서브시스템 | `block` 시 | SSOT |
|------------|------------|------|
| `shellGuard` | 위험 shell 명령 차단 | [`harness-layer1.md`](harness-layer1.md) |
| `qualityGate` | lint/tsc 등 실패 시 완료 선언 차단 | 동일 |
| `devServerCleanup` | 등록 dev 서버 포트 정리 (`kill`) | 동일 · `dev-server-cleanup-global` |

제품 온보딩 기본: `shellGuard.mode: block`. kit 템플릿 레포 self 모드는 개발 편의상 `warn`인 경우가 많다.

### ATDD-lite 시점

| 시점 | 강제 | SSOT |
|------|------|------|
| Gate 2 직전 | acceptance test **RED** | [`atdd-lite.md`](../qa/atdd-lite.md) |
| Gate 3 | PRD AC 대비 **GREEN** | 동일 |
| Gate 1 HUMAN·디자인 승인 전 | acceptance test 대량 작성 **금지** | `60` · `atdd-lite.md` |

---

## 3. 권장

### 작업·분담

| 항목 | SSOT |
|------|------|
| 중대형 작업에 Owner·순서·완료 기준·Integration Owner | `working-principles.mdc` · [`AGENTS.md`](../../AGENTS.md) |
| UI+API 역할 분담 (`frontend-agent` + `backend-agent` 등) | [`AGENTS.md`](../../AGENTS.md) 역할 분담 |
| 서브에이전트 handoff 시 agent-brief | [`agent-brief.md`](agent-brief.md) |

### 문서·전달

| 항목 | SSOT |
|------|------|
| 구현 후 변경 요약 (`document-change` / `docs-agent`) | [`document-change`](../../shared/skills/document-change/SKILL.md) · `60` Gate 3 |
| 정책·API·플로우 변경 시 문서 반영 우선 | `60` 문서 반영 운영 |
| 세션 마무리 작업 일지 | [`kit-work-log`](../../shared/skills/kit-work-log/SKILL.md) · [`docs/work-log/`](../work-log/README.md) |

### 디자인·품질·배포

| 항목 | SSOT |
|------|------|
| 이중 디자인안 A/B 병렬 동시 작성 (순차는 예외 사유) | `65` |
| 배포 전 `release-check` | [`release-check`](../../shared/skills/release-check/SKILL.md) |
| 고객 E2E 리뷰어 GATE (단계 4D, 팀 정책) | [`docs/qa/reviewer-gate-rubric.md`](../qa/reviewer-gate-rubric.md) |
| delivery-loop harness (단계 3 이후 선택) | [`delivery-loop-harness.md`](delivery-loop-harness.md) |

### DB·인프라 (신규 프로젝트 기본값)

| 항목 | SSOT |
|------|------|
| 로컬 PostgreSQL 시작 | `working-principles.mdc` DB 운영 기본값 |
| 검증 후 Railway 반영 | 동일 (brownfield 자동 강제 아님) |

### Dev 서버 예외 유지

| 항목 | SSOT |
|------|------|
| 서버 남길 때 `dev-server-keep: <포트> - <이유>` | `dev-server-cleanup-global.mdc` |

---

## 4. 빠른 판단표

| 질문 | 판정 |
|------|------|
| 오탈자·문구·단일 파일 소규모만? | **항상**만 해당. Gate 대부분 **면제** ([`AGENTS.md` 직접 처리 예외](../../AGENTS.md#직접-처리-가능한-예외)) |
| 신규 화면 + API? | Gate 1 → 디자인 → Gate 2 → ATDD RED → 병렬 → Gate 3 |
| 고객 요구 전체 붙여넣기? | `70` + `client-project-lifecycle` — PRD·디자인 HUMAN에서 **멈춤** |
| 「바로 구현해」 명시? | 사용자 지시 **우선** — Gate 완화 가능 |
| PRD에 성능/보안/측정/앱버전 = 예? | 해당 optional rule **추가 적용** |
| kit submodule만 추가? | 생성만으로 Gate 3 미충족 — **소비 증거** 필요 |
| UI 없는 CLI·백엔드만? | `20`~`40`·`65` 대부분 **미적용** |
| harness 미설정·`mode: off`? | 훅 **실차단 없음** — 에이전트 규칙만 적용 |

---

## 5. 읽는 순서 (온보딩)

1. [`README.md`](../../README.md) · [`AGENTS.md`](../../AGENTS.md) — 전체 그림
2. **본 문서** — 강제 수준 한눈에
3. [`rules-context-notes.md`](rules-context-notes.md) — 파일별 한 줄 목적
4. [`60-delivery-gates.mdc`](../../project-kit/.cursor/rules/60-delivery-gates.mdc) + [`atdd-lite.md`](../qa/atdd-lite.md) — Gate·완료 SSOT
5. [`workflow-overview.html`](workflow-overview.html) — 흐름 시각화

---

## 6. 유지보수

- Gate 정의·예외 목록·절차를 **본 문서에 복붙해 SSOT화하지 않는다.** 변경은 각 rule/skill SSOT에서만 한다.
- rule·Gate·harness·직접 처리 예외를 바꿀 때 [`rules-maintenance-checklist.md`](rules-maintenance-checklist.md)와 함께 **본 문서 표·판단표가 여전히 맞는지** 확인한다.
- 신규 rule/skill이 강제 수준에 영향을 주면 본 문서 해당 절에 **행 추가**한다.
