---
type: doc
project: cursor-workspace-kit
doc_lane: requirements
updated_at: 2026-06-15
tags: [docs, prd, atdd, example]
---

# 예시: 알림 설정 기능 PRD (AC 조각)

본 문서는 [`docs/qa/acceptance-criteria.template.md`](../qa/acceptance-criteria.template.md) 소비 예시다. 전체 PRD가 아닌 **수용 기준 섹션**만 포함한다.  
소비 기록 예시: [`atdd-lite-consumption-record-example.md`](../qa/atdd-lite-consumption-record-example.md)

## 목표 (요약)

로그인 사용자가 앱 내 알림 on/off를 설정하고, 설정이 저장·반영된다.

## 수용 기준 (Acceptance Criteria)

| ID | 시나리오 | 대상 | 상태 | 자동/수동 | 비고 |
|----|----------|------|------|-----------|------|
| AC-01 | Given 로그인 사용자 When 설정에서 알림 토글 off Then API `PATCH /api/me/preferences` 호출 후 UI가 off 상태 유지 | 화면+API | 기본 | auto | E2E 또는 통합 |
| AC-02 | Given 비로그인 When `GET /api/me/preferences` Then `401` | API | 오류 | auto | |
| AC-03 | Given 저장 API 500 When 토글 변경 Then 오류 메시지 표시·이전 값 복원 | 화면 | 오류 | auto | |

### AC ↔ 테스트 매핑 (Gate 2 직후)

| AC ID | 테스트 | RED |
|-------|--------|-----|
| AC-01 | `e2e/settings-notifications.spec.ts` — `AC-01 toggle off persists` | 실패 확인 |
| AC-02 | `tests/api/preferences.test.ts` — `AC-02` | 실패 확인 |
| AC-03 | `e2e/settings-notifications.spec.ts` — `AC-03 server error restores toggle` | 실패 확인 |

## Vault

- [[cursor-workspace-kit/docs/qa/atdd-lite|ATDD-lite]]
- [[cursor-workspace-kit/docs/cursor-workspace-kit-docs-hub|Hub]]
