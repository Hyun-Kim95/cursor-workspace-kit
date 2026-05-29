---
type: doc
project: cursor-workspace-kit
doc_lane: product-analytics
updated_at: 2026-05-29T00:00:00
tags: [docs, product-analytics, brownfield, vault-sync]
---

# brownfield-checklist — 기존 제품

운영 중 제품에 analytics를 **추가·정리·보완**할 때. Gate 1 **전면 재수행 없이** `.cursor/rules/60-delivery-gates.mdc`의 **간이 점검**(요구·화면·계약 영향)으로 진행한다.

## Phase 0 — 인벤토리 (코드 변경 전)

- [ ] 현재 도구: GA4 / PostHog / Mixpanel / 자체 로그 / 없음
- [ ] SDK 초기화 위치 (web layout, app bootstrap 등)
- [ ] 기존 이벤트 목록·네이밍 규칙 (스프레드시트·대시보드·코드 grep)
- [ ] identify·PII·동의 배anner 유무
- [ ] prod/staging 프로젝트 분리 여부
- [ ] [`policy-and-contract.md`](policy-and-contract.md) **as-is 매핑표** 작성 → `docs/requirements/product-analytics.md`

## Phase 1 — 갭만 보완 (최소 diff)

| 갭 | 조치 |
|----|------|
| analytics 없음 | PRD 측정 절 + greenfield Gate 2부터 |
| 이벤트명 혼재 | North Star만 kit `snake_case`로 **정렬** (일괄 rename은 별도 PR) |
| 이중 계측 | PRD에 주 SSOT 1개 + deprecate 일정 |
| PII 노출 | 해당 properties **제거** (breaking 아님) |
| staging=prod 키 | env 분리 |

- [ ] 기존 대시보드·마케팅 태그 **전면 교체하지 않음** (ADR 또는 deprecate 일정)
- [ ] 변경 범위를 PR/문서에 명시 (`document-change`)

## Phase 2 — 정합 (선택, 별도 PR)

- [ ] 이벤트 계약 v1로 문서화
- [ ] PRD North Star와 미계측 단계 갭 목록

## Gate · 검증

- [ ] 간이 점검: 이번 변경이 PRD·이벤트·프라이버시에 미치는 영향만 확인
- [ ] UI 변경 없으면 디자인 이중 목업 **생략 가능**
- [ ] North Star 퍼널 spot check + PII 없음
- [ ] `verify-change` 또는 `release-check` product-analytics 항목

## 하지 않는 것

- Gate 1 전체 PRD 재작성
- 전 화면 일괄 instrumentation
- mock-only 경로만 다시 만드는 것 (고객 E2E 단계 3 규칙)
