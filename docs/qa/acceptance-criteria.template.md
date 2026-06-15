---
type: doc
project: cursor-workspace-kit
doc_lane: qa
updated_at: 2026-06-15
tags: [docs, atdd, prd, template]
---

# Acceptance Criteria Template (PRD 붙여넣기용)

PRD 또는 동등 범위 문서에 아래 섹션을 복사해 사용한다. 상세: [`atdd-lite.md`](atdd-lite.md)

## 수용 기준 (Acceptance Criteria)

| ID | 시나리오 | 대상 | 상태 | 자동/수동 | 비고 |
|----|----------|------|------|-----------|------|
| AC-01 | Given 비로그인 사용자 When `/login`에서 유효 자격 증명 제출 Then `/dashboard`로 이동 | 화면 | 기본 | auto | E2E |
| AC-02 | Given 인증 헤더 없음 When `GET /api/items` Then `401` + 오류 본문 형식 계약 준수 | API | 오류 | auto | |
| AC-03 | Given 목록 API 빈 배열 When 목록 화면 로드 Then 빈 상태 UI 문구 표시 | 화면 | 빈 | auto | |
| AC-04 | Given 권한 없는 역할 When 관리 메뉴 접근 Then 권한 제한 UI | 화면 | 권한 | manual | 스테이징 수동 1회 |

### 작성 규칙

- ID는 `AC-01`부터 연속 번호.
- **행위·계약·상태**만 기술 (픽셀·색상·간격 금지).
- `auto`: Gate 2 후 acceptance test RED → Gate 3 GREEN 필수.
- `manual`: PRD에 `manual` 표기 + `docs/qa/` 실행 기록.

### AC ↔ 테스트 매핑 (Gate 2 직후 작성)

| AC ID | 테스트 파일·describe/it | RED 확인 |
|-------|-------------------------|----------|
| AC-01 | `e2e/login.spec.ts` — `AC-01 logged-in user sees dashboard` | 실패 확인 |
| AC-02 | `tests/api/items.test.ts` — `AC-02` | 실패 확인 |

## Vault

- [[cursor-workspace-kit/docs/cursor-workspace-kit-docs-hub|Hub]]
