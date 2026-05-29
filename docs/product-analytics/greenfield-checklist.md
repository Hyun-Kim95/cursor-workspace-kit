---
type: doc
project: cursor-workspace-kit
doc_lane: product-analytics
updated_at: 2026-05-29T00:00:00
tags: [docs, product-analytics, greenfield, vault-sync]
---

# greenfield-checklist — 신규 제품

사용자 행동 측정을 **처음부터** 포함하는 체크리스트. PRD에서 **측정=예**일 때만 적용.

## Gate 1 — 구현 착수 전

- [ ] [`policy-and-contract.md`](policy-and-contract.md) PRD 「측정·분석」절을 `docs/requirements/product-analytics.md`에 복사·채움
- [ ] North Star 퍼널 3~5단과 PRD 사용자 흐름 **1:1 매핑**
- [ ] MVP 이벤트 5~10개 후보·수집/미수집·동의 정책 **HUMAN 확정**(미확정 항목 표시)
- [ ] 분석 도구 선택 또는 **미확정** 기록 (PostHog 등 레퍼런스만 kit에 있음)
- [ ] SDK 연동은 Gate 1 **필수 아님** — 설계만 PRD에

## Gate 2 — 병렬 구현 (측정=예)

API·디자인 Gate 2와 함께 **이벤트 계약 v1** 확정:

- [ ] `docs/requirements/product-analytics.md` § 이벤트 계약 v1 작성
- [ ] `docs/qa/stage3-entry-checklist.md` 선택 블록(측정·분석) 작성

| 담당 | 작업 |
|------|------|
| `frontend-agent` | SDK 초기화, `page_view`, North Star 퍼널 `capture`, identify(로그인 후) |
| `backend-agent` | (해당 시) 서버 사이드 이벤트 — 계약상 주체 명시된 것만 |

`parallel-delivery` 조건은 `.cursor/rules/60-delivery-gates.mdc` Gate 2 그대로. 이벤트 계약은 Gate 2 **체크리스트 위임**이며 Gate 60 문구 변경 아님.

## Gate 3 — DoD

- [ ] PRD 퍼널表의 MVP 이벤트가 구현·발화됨
- [ ] properties에 PII·결제 ID 없음 (spot check)
- [ ] staging에서 debug/verbose off 또는 prod 키 미노출
- [ ] `verify-change` 또는 `qa-agent` 결과 기록
- [ ] `docs/requirements/product-analytics.md`와 구현·계약 일치

## 첫 릴리스 전

- [ ] [`release-checklist.md`](release-checklist.md) 릴리스 3항 통과
- [ ] (출시 후) PostHog 등에서 퍼널·대시보드 1회 설정 — 운영 TODO로 `document-change`에 남겨도 됨
