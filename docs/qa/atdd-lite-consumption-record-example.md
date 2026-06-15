---
type: doc
project: cursor-workspace-kit
doc_lane: qa
updated_at: 2026-06-15
tags: [docs, atdd, qa, consumption, example]
---

# ATDD-lite 소비 기록 예시 (example-app)

본 문서는 [`atdd-lite-consumption-checklist.md`](atdd-lite-consumption-checklist.md)를 **채운 샘플**이다.  
AC 출처: [`example-feature-notifications-ac.md`](../requirements/example-feature-notifications-ac.md) (kit 예시 PRD 조각).

**주의:** `example-app`·아래 경로는 **가상 제품** PLACEHOLDER다. 실제 제품 레포에서 동일 형식으로 기록한다.

## 메타

| 항목 | 값 |
|------|-----|
| 제품 | `example-app` |
| 기능 | 알림 설정 on/off |
| PRD | `docs/requirements/notifications-settings.md` |
| kit AC 예시 | [`example-feature-notifications-ac.md`](../requirements/example-feature-notifications-ac.md) |
| 기록 일시 | 2026-06-15 (예시) |

## 1) Gate 1

- PRD 경로: `docs/requirements/notifications-settings.md`
- AC: AC-01 ~ AC-03 ([`example-feature-notifications-ac.md`](../requirements/example-feature-notifications-ac.md))
- 첫 소비자: `example-app` 웹 설정 화면 `/settings/notifications`
- 소비 경로: `src/routes/settings/notifications.tsx`, `PATCH/GET /api/me/preferences`

## 2) Gate 2

- stage3 체크리스트: `docs/qa/stage3-notifications-2026-06-15.md` (가상)
- API: `GET/PATCH /api/me/preferences` 스키마·401/500 확정
- 상태 UI: 토글 기본/로딩/오류(500) 정의

## 3) RED

| AC ID | 테스트 | RED 요약 |
|-------|--------|----------|
| AC-01 | `e2e/settings-notifications.spec.ts` — `AC-01 toggle off persists` | 라우트·API 미구현 → `expect(toggle).toBeChecked()` 실패 |
| AC-02 | `tests/api/preferences.test.ts` — `AC-02` | 엔드포인트 없음 → 404 (기대 401) |
| AC-03 | `e2e/settings-notifications.spec.ts` — `AC-03 server error restores toggle` | 오류 UI 없음 → assertion 실패 |

```bash
npm run test:e2e -- settings-notifications   # 2 failed (AC-01, AC-03)
npm test -- preferences                       # 1 failed (AC-02)
```

## 4) GREEN

| AC ID | 구현 경로 | 담당 |
|-------|-----------|------|
| AC-01 | `src/routes/settings/notifications.tsx`, `src/api/preferences.ts` | frontend-agent |
| AC-02 | `src/server/routes/preferences.ts` | backend-agent |
| AC-03 | `src/routes/settings/notifications.tsx` (오류 복원) | frontend-agent |

```bash
npm run test:e2e -- settings-notifications   # 2 passed
npm test -- preferences                       # 1 passed
```

## 5) Gate 3 — Verifier Handoff (예시)

```json
{
  "artifactPaths": [
    "docs/requirements/notifications-settings.md",
    "src/routes/settings/notifications.tsx",
    "src/server/routes/preferences.ts"
  ],
  "acceptanceTestPaths": [
    "e2e/settings-notifications.spec.ts",
    "tests/api/preferences.test.ts"
  ],
  "acIds": ["AC-01", "AC-02", "AC-03"],
  "rubricRef": "Gate 3, docs/qa/atdd-lite.md",
  "forbidden": "생성 reasoning, 완화, 산출물 수정"
}
```

검증 산출: `docs/qa/verify-2026-06-15-notifications.md` (가상)

- AC 커버리지: 3/3
- 미매핑 AC: 없음
- 판정: Gate 3 충족 (예시)

## 6) 소비 증거

- 첫 소비자: `example-app` — `/settings/notifications`에서 토글·API 연동 동작
- 소비 경로: `src/routes/settings/notifications.tsx` → `PATCH /api/me/preferences`
- PR/커밋: `feat/notifications-settings-atdd` (가상)
- 테스트: 위 GREEN 명령 전부 통과 (2026-06-15)

## Vault

- [[cursor-workspace-kit/docs/qa/atdd-lite-consumption-checklist|소비 체크리스트]]
- [[cursor-workspace-kit/docs/cursor-workspace-kit-docs-hub|Hub]]
