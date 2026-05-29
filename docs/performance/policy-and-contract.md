---
type: doc
project: cursor-workspace-kit
doc_lane: performance
updated_at: 2026-05-29T00:00:00
tags: [docs, performance, contract, vault-sync]
---

# policy-and-contract — 성능 게이트

신규·기존 프로젝트 **공통 SSOT**. 제품별 값은 `<!-- PRODUCT -->` 칸을 채운 뒤 `docs/requirements/perf-budget.json`(또는 팀 규칙 경로)에 복사한다.

---

## 1. PRD 「비기능·성능」절 (템플릿)

Gate 1에서 **성능 게이트=예**일 때 PRD 또는 동등 문서에 포함한다. `perf:ci` 구현 완료는 Gate 1 **필수 아님** — 예산·플랫폼 enabled 설계만 PRD에 가능.

### 적용 여부

<!-- PRODUCT: 성능 게이트=예 / 아니오 -->

### 활성 플랫폼

| 플랫폼 | enabled | 비고 |
|--------|---------|------|
| web | false | 웹 UI·빌드 산출물 |
| app | false | 스토어 배포 모바일 앱 |
| api | false | HTTP/RPC 백엔드 |

### 목표 (PLACEHOLDER)

<!-- PRODUCT: 제품별 숫자 -->

| 플랫폼 | 지표 | 목표 | 측정 환경 |
|--------|------|------|-----------|
| web | Lighthouse Performance | ≥ __ | staging URL |
| web | main bundle (gzip KB) | ≤ __ | CI build |
| app | release binary (MB) | ≤ __ | release build |
| api | p95 latency (ms) | ≤ __ | staging + 1 시나리오 |

### 미확정

- (HUMAN 전까지)

---

## 2. perf-budget.json (제품 SSOT)

kit 템플릿: [`perf-budget.template.json`](perf-budget.template.json)

- `platforms.*.enabled: true` 인 플랫폼만 측정·게이트 대상
- `budget` 키는 제품·도구에 맞게 추가 가능. kit는 **최소 키**만 예시

---

## 3. perf-last.json 계약

**권장 경로:** `.cursor/state/perf-last.json` (gitignore 권장)

**예시:** [`docs/qa/perf-last.example.json`](../qa/perf-last.example.json)

### 스키마 (요약)

| 필드 | 설명 |
|------|------|
| `ok` | **활성** 플랫폼(`enabled: true`)의 `platforms.*.ok`가 모두 true일 때만 true |
| `version` | 계약 버전 (1) |
| `updatedAt` | ISO 8601 권장 |
| `command` | 마지막 측정 명령 (예: `npm run perf:ci`) |
| `platforms.web \| app \| api` | 플랫폼별 결과 |

### 플랫폼 객체

| 필드 | 설명 |
|------|------|
| `enabled` | budget과 동일 — 이번 실행에 게이트 대상인지 |
| `skipped` | `enabled: false`이면 true (측정 생략) |
| `ok` | 해당 플랫폼 예산 통과 |
| `metrics` | 실측값 (도구 중립 key-value) |
| `failures` | (선택) 미달 항목 목록 |

### 집계 규칙

1. `enabled: false` → `skipped: true`, `ok: true` (전체 ok 계산에서 제외)
2. `enabled: true` → `skipped: false`, `metrics`와 `budget` 비교 후 `ok` 설정
3. 루트 `ok` = 활성 플랫폼의 `ok` **AND**

---

## 4. 측정 명령 (제품 구현)

kit는 **도구 중립**. 제품이 다음을 구현한다.

| 명령 예 | 역할 |
|---------|------|
| `npm run perf:ci` | web/app/api 스크립트 순 실행 후 `perf-last.json` 갱신 |
| kit 스텁 | [`scripts/perf/Invoke-PerfGate.ps1`](../../scripts/perf/Invoke-PerfGate.ps1) — 계약·파일 쓰기만 (실측 없음) |

**에이전트 동작:** `perf-last.json`·빌드/부하 로그로 원인 조사 후 수정 (`working-principles` **조사·소통·실패 대응**). 추측 최적화 금지.

---

## 5. 완료·검증 선언 (권고)

제품·팀 harness에 다음을 **권고**한다 (kit `AGENTS.md` 필수 변경 아님).

- `.cursor/state/perf-last.json`이 존재하고 `ok: false`이면 **완료·검증 완료·출시 준비** 선언을 하지 않는다.
- `quality-gate-last.json`의 `ok: false`와 함께 해석할 수 있다.

---

## 6. PRD 붙여넣기 블록

```markdown
## 비기능·성능

### 성능 게이트
성능 게이트=예 (선택 범위)

### 활성 플랫폼
- web: false
- app: false
- api: false

### 예산 (요약)
(표 또는 perf-budget.json 링크)

### 측정
- 명령: npm run perf:ci (제품 구현)
- 산출: .cursor/state/perf-last.json

### 미확정
-
```

---

## 7. brownfield — as-is 매핑표

| kit 예산 키 | 현재 as-is | 일치 | 조치 |
|-------------|------------|------|------|
| web.bundleMainKbGzipMax | | | |
| web.lighthousePerformanceMin | | | |
| api.p95MsMax | | | |
| 측정 스크립트/CI job | | | |

차이 유지 시 `docs/decisions/` ADR에 사유를 남긴다.

---

## 8. 릴리스 점검 (요약)

[`release-checklist.md`](release-checklist.md) — `release-check`·`verify-change` 참조.

1. 활성 플랫폼 `perf-last.json` `ok: true`
2. staging(또는 PRD 합의 env)에서 측정
3. 회귀: 이전 릴리스 대비 활성 지표 악화 없음(팀 정의)
