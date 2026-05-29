---
type: doc
project: cursor-workspace-kit
doc_lane: performance
updated_at: 2026-05-29T00:00:00
tags: [docs, performance, greenfield, vault-sync]
---

# greenfield-checklist — 신규 제품

성능 게이트를 **처음부터** 설계할 때. PRD **성능 게이트=예**일 때만 적용.

## Gate 1 — 구현 착수 전

- [ ] [`policy-and-contract.md`](policy-and-contract.md) PRD 「비기능·성능」절을 작성
- [ ] [`perf-budget.template.json`](perf-budget.template.json) → `docs/requirements/perf-budget.json` 복사
- [ ] 포함 플랫폼만 `platforms.*.enabled: true` (web / app / api)
- [ ] PLACEHOLDER 예산 숫자 **HUMAN 확정** (미확정 항목 표시)
- [ ] `perf:ci` **구현 계획**만 PRD에 (Gate 1에서 CI 구현 필수 아님)

## Gate 2~5 — 구현 구간

- 기능 구현과 병행 가능. **단계 6 직전**까지 `perf-last.json`이 없어도 Gate 2 위반 아님.

## 단계 6 — 성능 루프 ([`client-project-lifecycle`](../../project-kit/.cursor/skills/client-project-lifecycle/SKILL.md))

1. 제품 `npm run perf:ci`(또는 [`Invoke-PerfGate.ps1`](../../scripts/perf/Invoke-PerfGate.ps1) 스텁 → 실측 스크립트로 교체) 구현
2. `.cursor/state/perf-last.json` 생성·갱신
3. `ok: false`이면 **원인 조사** 후 리팩터·재측정 (`working-principles` 조사·실패 대응)
4. (선택) `delivery-ralph.json` `lifecyclePhase: perf` + [`Invoke-DeliveryLoop.ps1`](../../scripts/delivery/Invoke-DeliveryLoop.ps1)

### web (enabled 시)

- [ ] production-like build 후 bundle / Lighthouse / CWV 측정
- [ ] `platforms.web.metrics`가 budget 이하

### app (enabled 시)

- [ ] release 빌드 크기(또는 팀 지표) 측정
- [ ] `platforms.app.metrics`가 budget 이하

### api (enabled 시)

- [ ] staging + 핵심 1시나리오 부하 (k6/autocannon 등)
- [ ] `platforms.api.metrics`가 budget 이하

## Gate 3 / DoD

- [ ] 활성 플랫폼 `perf-last.json` `ok: true`
- [ ] `docs/requirements/perf-budget.json`과 PRD·구현 일치
- [ ] [`release-checklist.md`](release-checklist.md) (릴리스 전)
