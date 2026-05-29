---
type: doc
project: cursor-workspace-kit
doc_lane: performance
updated_at: 2026-05-29T00:00:00
tags: [docs, performance, release, vault-sync]
---

# release-checklist — performance 릴리스 3항

PRD **성능 게이트=예**이고 활성 플랫폼이 있는 릴리스에서 `release-check` 스킬이 참조한다.

## 릴리스 3항

1. **perf-last 통과**
   - [ ] `.cursor/state/perf-last.json`(또는 팀 경로) `ok: true`
   - [ ] 활성 플랫폼(`enabled: true`) 각각 `ok: true`, `skipped: false`
   - [ ] `docs/requirements/perf-budget.json`과 `metrics` 키 정합

2. **환경·측정 조건**
   - [ ] PRD에 합의한 env(staging/prod canary)에서 측정
   - [ ] web: 측정 URL·인증·캐시 상태 문서화
   - [ ] api: 부하 시나리오·데이터 시드 일치

3. **회귀·리스크**
   - [ ] 이전 릴리스 대비 활성 지표 **악화 없음**(팀 정의; 없으면 baseline 기록)
   - [ ] 미달 시 known issue·후속 TODO를 릴리즈 노트에 명시

## 배포 후 모니터링 (권장)

- APM·에러율·Lighthouse CI trend
- `document-change`에 perf baseline 스냅샷 링크

## 관련

- SSOT: [`policy-and-contract.md`](policy-and-contract.md) §8
- 스킬: `shared/skills/release-check/SKILL.md`
