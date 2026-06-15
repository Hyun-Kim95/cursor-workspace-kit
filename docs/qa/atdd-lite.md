---
type: doc
project: cursor-workspace-kit
doc_lane: qa
updated_at: 2026-06-15
tags: [docs, atdd, qa]
---

# ATDD-lite

Acceptance Test-Driven Development의 **경량** 운영 방식이다. Gherkin/Cucumber 전면 도입이 아니라 **PRD `AC-xx` 수용 기준 ↔ 자동화 테스트 1:1 매핑**을 기본으로 한다.

규칙 SSOT: [`project-kit/.cursor/rules/60-delivery-gates.mdc`](../../project-kit/.cursor/rules/60-delivery-gates.mdc) (sync 후 `.cursor/rules/60-delivery-gates.mdc`)

## 정의

| 용어 | 의미 |
|------|------|
| AC | Acceptance Criteria. PRD의 `AC-01` 형식 수용 기준 |
| RED | acceptance test가 **의도적으로 실패**하거나 `test.todo` + AC ID 주석만 있는 상태 |
| GREEN | 구현 후 해당 acceptance test가 **통과** |
| ATDD-lite | Gate 2 후 RED → 구현 → Gate 3에서 AC 커버리지·통과 확인 |

## Gate에서의 위치

```mermaid
flowchart LR
  G1[Gate1_PRD_AC]
  G2[Gate2_계약_디자인]
  RED[AcceptanceTest_RED]
  IMPL[구현_GREEN]
  G3[Gate3_AC커버리지]

  G1 --> G2 --> RED --> IMPL --> G3
```

- **Gate 1:** PRD에 AC 섹션 필수. [`acceptance-criteria.template.md`](acceptance-criteria.template.md) 참고.
- **Gate 2:** API·디자인·상태 UI 고정 **후**, 제품 구현 **전** acceptance test RED.
- **Gate 3:** AC 대비 자동화 테스트 통과, 미매핑 AC 없음(수동 AC는 `manual` + 실행 기록).

**금지:** Gate 1 HUMAN·디자인 승인 **전** acceptance test 대량 작성.

## AC 작성 원칙

- **행위·계약·상태** 중심 (로그인 성공, 404 시 빈 상태, API 403 등).
- **픽셀·레이아웃** 검증은 AC에 넣지 않는다 (디자인 게이트·플래키 테스트 방지).
- 각 AC: ID, 시나리오(Given-When-Then 또는 체크리스트), 대상(화면/API/권한), 상태, 자동/수동.

## RED → GREEN 절차

1. PRD AC 목록 확정 (Gate 1).
2. Gate 2 통과 (계약·디자인·stage3 체크리스트).
3. AC별 acceptance test 스켈레톤 작성 → **RED 확인**.
4. `frontend-agent` / `backend-agent`로 구현 → **GREEN**.
5. `qa-agent` + `verify-change`로 AC↔테스트 매핑·미커버 AC 점검.

최소 커버리지: 핵심 AC **3~7개** (PRD에 더 많으면 그만큼).

## AC ↔ 테스트 매핑 예시

### Playwright (E2E)

```typescript
// e2e/login.spec.ts
// AC-01: 로그인 성공 시 대시보드로 이동
test('AC-01 logged-in user sees dashboard', async ({ page }) => {
  await page.goto('/login');
  await page.fill('[name=email]', 'user@example.com');
  await page.fill('[name=password]', 'secret');
  await page.click('button[type=submit]');
  await expect(page).toHaveURL('/dashboard');
});
```

### API (Vitest + supertest 예시)

```typescript
// tests/api/items.test.ts
// AC-02: 비인증 GET /api/items → 401
describe('AC-02', () => {
  it('returns 401 without auth', async () => {
    const res = await request(app).get('/api/items');
    expect(res.status).toBe(401);
  });
});
```

AC ID는 `describe`/`test` 이름 또는 파일 상단 주석에 **반드시** 포함한다.

## 수동 AC

자동화 비용이 큰 AC는 PRD에 `manual` 표기하고, `docs/qa/`에 실행 일시·결과·실행자를 기록한다.

## unit TDD와의 관계

- **ATDD-lite:** acceptance test 우선 (기본).
- **unit TDD:** 복잡 도메인·순수 로직에만 **국소적** 적용. 전역 unit TDD 강제 없음.

## 경량 ATDD (brownfield·버그)

- Gate 1 전면 재수행 대신 변경 범위 간이 점검.
- `bugfix-flow`: 재현 **acceptance 또는 unit test 1개** 선작성(가능 시) → 수정 → 회귀 검토.

## 제품 첫 소비 (kit 문서)

kit 레포 자체는 **정책·체크리스트**를 제공하고, 실제 acceptance test·구현은 **제품 레포**에서 수행한다.

- 체크리스트: [`atdd-lite-consumption-checklist.md`](atdd-lite-consumption-checklist.md)
- 채운 기록 예시: [`atdd-lite-consumption-record-example.md`](atdd-lite-consumption-record-example.md) (AC 예시: [`example-feature-notifications-ac.md`](../requirements/example-feature-notifications-ac.md))
- 소비 증거 용어: [`integration-consumption-gate.md`](integration-consumption-gate.md)

## 안티패턴

| 안티패턴 | 이유 |
|----------|------|
| 픽셀·스냅샷을 AC에 넣음 | 디자인 변경마다 깨짐 |
| Gate 2 전 대량 테스트 작성 | 계약·디자인 미확정으로 폐기 비용 |
| Gherkin/Cucumber 의무화 | 팀·스택 부담, kit는 ID 매핑만 요구 |
| RED 없이 구현만 | 수용 기준 drift |
| 구현 후에만 시나리오 최초 작성 | ATDD 이점 상실 |

## 관련 문서

- [`acceptance-criteria.template.md`](acceptance-criteria.template.md) — PRD AC 표 템플릿
- [`atdd-lite-consumption-checklist.md`](atdd-lite-consumption-checklist.md) — 제품 레포 소비 체크리스트
- [`atdd-lite-consumption-record-example.md`](atdd-lite-consumption-record-example.md) — 소비 기록 예시
- [`stage3-entry-checklist.md`](stage3-entry-checklist.md) — §3d ATDD-lite
- [`reviewer-gate-rubric.md`](reviewer-gate-rubric.md) — PRD 이행도·수용 기준 축

## Vault

- [[cursor-workspace-kit/docs/cursor-workspace-kit-docs-hub|Hub]]
