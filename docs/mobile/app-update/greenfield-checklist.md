---
type: doc
project: cursor-workspace-kit
doc_lane: mobile
updated_at: 2026-05-29T00:00:00
tags: [docs, mobile, app-update, greenfield, vault-sync]
---

# greenfield-checklist — 신규 앱

배포 모바일 앱을 **처음부터** 만들 때 버전 업데이트(권장/강제)를 포함하는 체크리스트.

## Gate 1 — 구현 착수 전

- [ ] [`policy-and-contract.md`](policy-and-contract.md)의 PRODUCT 칸·PRD 「앱 업데이트」절을 `docs/requirements/app-update.md`에 복사·채움
- [ ] `updateLevel` 정책, min/recommended 기준, API 실패 동작 **HUMAN 확정**
- [ ] API 초안: Query/Response 필드, 오류 형식
- [ ] [`ux-states.md`](ux-states.md)를 Gate 1 화면 스펙에 포함 (권장·강제·로딩·오류)
- [ ] 고객 E2E·UI 범위면 `65-design-gate`에 따라 권장/강제 화면 목업 준비

## Gate 2 — 병렬 구현

API 계약·디자인 승인 후:

| 담당 | 작업 |
|------|------|
| `backend-agent` | 버전 API 엔드포인트, min/latest 설정 소스(DB·env·관리 API) |
| `frontend-agent` | bootstrap 훅, 권장/강제 UI, 스토어 링크 |

`parallel-delivery` 조건은 `.cursor/rules/60-delivery-gates.mdc` Gate 2 그대로.

## Gate 3 — DoD

- [ ] cold start(또는 PRD에 합의한 시점)에 버전 API 호출
- [ ] 4케이스 검증: `none` / `recommended` / `required` / API down
- [ ] iOS·Android 각각 storeUrl·버전 소스 정확
- [ ] `verify-change` 또는 `qa-agent` 결과 기록
- [ ] `docs/requirements/app-update.md`와 구현·계약 일치

## 첫 스토어 릴리스 전

- [ ] 서버 `minSupported` ≤ 첫 배포 버전
- [ ] `release-check`의 app-update 3항 통과
