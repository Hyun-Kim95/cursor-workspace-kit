---
type: doc
project: cursor-workspace-kit
doc_lane: performance
updated_at: 2026-05-29T00:00:00
tags: [docs, performance, vault-sync]
---

# performance — 진입점

비기능 **성능 게이트**(웹·앱·API)를 **PRD에서 성능 게이트=예로 명시한 경우** 여기서 시작한다.

## 결정 트리

1. **PRD에 성능 게이트=아니오(또는 미명시)?** → 이 폴더 **스킵**
2. **신규 제품·성능 예산·측정이 없음?** → [`greenfield-checklist.md`](greenfield-checklist.md)
3. **이미 일부 지표·스크립트가 있음?** → [`brownfield-checklist.md`](brownfield-checklist.md)
4. **제품 SSOT:** `docs/requirements/perf-budget.json`(또는 팀 규칙 경로)에 [`perf-budget.template.json`](perf-budget.template.json)을 복사한 뒤 `platforms.web` / `platforms.app` / `platforms.api`의 `enabled`와 `budget`을 채운다.
5. **측정:** 제품이 구현한 `npm run perf:ci`(또는 동등) → `.cursor/state/perf-last.json`(권장). kit 스텁: [`scripts/perf/README.md`](../../scripts/perf/README.md)

## 플랫폼 분기 (조합 가능)

| 플랫폼 | `enabled` | 대표 지표 (문서·PLACEHOLDER) |
|--------|-----------|------------------------------|
| **web** | PRD에 웹 포함 시 | bundle gzip, Lighthouse Performance, LCP/INP/CLS |
| **app** | PRD에 배포 앱 포함 시 | binary size, cold start(선택) |
| **api** | PRD에 API/백엔드 포함 시 | p95/p99 latency, 5xx rate |

비활성 플랫폼은 `perf-last.json`에서 `skipped: true`로 둔다. **전체 `ok`** 는 **활성 플랫폼만 AND**.

## 문서 구성

| 파일 | 용도 |
|------|------|
| [`policy-and-contract.md`](policy-and-contract.md) | PRD 비기능·성능 절, `perf-last` 계약, brownfield 매핑표 |
| [`perf-budget.template.json`](perf-budget.template.json) | 예산 템플릿 (기본 전 플랫폼 `enabled: false`) |
| [`greenfield-checklist.md`](greenfield-checklist.md) | 신규: NFR → budget → perf:ci → 단계 6 루프 |
| [`brownfield-checklist.md`](brownfield-checklist.md) | 기존: 인벤토리 → 갭 보완 |
| [`release-checklist.md`](release-checklist.md) | 릴리스 3항 — `release-check` 스킬 참조 |

## Harness 연동 (선택)

| 도구 | 용도 |
|------|------|
| [`delivery-loop-harness.md`](../agent/delivery-loop-harness.md) | `lifecyclePhase: perf` + `Invoke-DeliveryLoop.ps1`로 `perf:ci` 반복 |
| [`harness-layer1.md`](../agent/harness-layer1.md) | `quality-gate` 짧은 체크 vs 긴 `perf:ci` 역할 분담 |
| [`docs/qa/perf-last.example.json`](../qa/perf-last.example.json) | 상태 파일 예시 |

**완료 선언 권고:** 제품에 `perf-last.json`이 있고 `ok: false`이면 검증·완료 선언을 하지 않는다(`quality-gate-last`와 동일 패턴, [`policy-and-contract.md`](policy-and-contract.md)).

## 관련 kit

- 선택 규칙: `shared/optional/23-performance-gate.mdc` (성능 게이트=예 제품/팀만 opt-in)
- 웹/앱 UX 분기: `shared/rules/20-web-vs-app.mdc` (본 폴더와 중복 정의하지 않음)
- 실패·재시도: `shared/rules/working-principles.mdc` **조사·소통·실패 대응**
- Gate: `project-kit/.cursor/rules/60-delivery-gates.mdc` (성능은 Gate 1 **필수 산출 아님**)
