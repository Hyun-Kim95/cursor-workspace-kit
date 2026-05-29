---
type: doc
project: cursor-workspace-kit
doc_lane: performance
updated_at: 2026-05-29T00:00:00
tags: [docs, performance, brownfield, vault-sync]
---

# brownfield-checklist — 기존 제품

운영 중 제품에 성능 게이트를 **추가·정리**할 때. Gate 1 **전면 재수행 없이** `.cursor/rules/60-delivery-gates.mdc` **간이 점검**으로 진행.

## Phase 0 — 인벤토리 (코드 변경 전)

- [ ] 기존 지표: Lighthouse CI, bundle size, APM, k6, 앱 size 리포트, 없음
- [ ] CI job 이름·경로
- [ ] staging/prod 측정 URL·인증
- [ ] [`policy-and-contract.md`](policy-and-contract.md) **as-is 매핑표** → `docs/requirements/perf-budget.json` 또는 PRD

## Phase 1 — 갭만 보완

| 갭 | 조치 |
|----|------|
| 예산 문서 없음 | PRD NFR + `perf-budget.json` 추가 |
| 측정은 있으나 JSON 없음 | 기존 job 출력 → `perf-last.json` 어댑터 |
| web만 있음 | app/api `enabled: false` 유지 |
| 임계값만 없음 | budget 숫자만 PRD HUMAN 확정 |

- [ ] 기존 파이프라인 **전면 교체하지 않음**
- [ ] `document-change`로 범위 기록

## Phase 2 — 정합 (선택)

- [ ] `perf:ci` 단일 진입점으로 통합
- [ ] ADR로 kit 키와 다른 지표명 유지 사유

## Gate · 검증

- [ ] 간이 점검: 이번 변경이 NFR·릴리스에 미치는 영향
- [ ] 활성 플랫폼 `perf-last.json` spot check
- [ ] `verify-change` 또는 `release-check` performance 항목

## 하지 않는 것

- Gate 1 전체 PRD 재작성
- 미사용 플랫폼(web/app/api) 일괄 측정 강제
