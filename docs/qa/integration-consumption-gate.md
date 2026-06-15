---
type: doc
project: cursor-workspace-kit
doc_lane: qa
updated_at: 2026-06-01T00:00:00
tags: [docs, vault-sync, gate]
---

# Integration Consumption Gate (생성·소비)

횡단 자산(공유 패키지·내부 SDK·디자인 토큰·kit 연동·대외 API 계약)에서 **「만들었다」와 「지정 소비자가 실제로 쓴다」** 를 분리하는 DoD 기준이다. Gate 1~3 **번호는 바꾸지 않는다** — 상세는 [`project-kit/.cursor/rules/60-delivery-gates.mdc`](../../project-kit/.cursor/rules/60-delivery-gates.mdc) Gate 1 비고·Gate 3, 본 문서가 **운영 SSOT**이다.

관련: 목업→제품 [`65-design-gate`](../../shared/rules/65-design-gate.mdc), stage3 [`stage3-entry-checklist.md`](stage3-entry-checklist.md), kit 온보딩 [`product-onboarding.md`](../agent/product-onboarding.md), ATDD-lite 소비 증거 [`atdd-lite-consumption-checklist.md`](atdd-lite-consumption-checklist.md)·[`atdd-lite-consumption-record-example.md`](atdd-lite-consumption-record-example.md).

## 용어

| 용어 | 의미 |
|------|------|
| **생성** | 아티팩트·모듈·패키지·스키마·submodule·sync 산출물이 **존재**하고 빌드·테스트·문서가 갖춰진 상태 |
| **소비** | Gate 1에서 정한 **첫 소비자**가 해당 자산을 **import·호출·라우트·배포 경로**에 연결해 **동작**하는 상태 |
| **첫 소비자** | 이번 변경의 **최소 1곳** 실제 사용처(앱·서비스·화면·Job·CLI 등) |
| **소비 증거** | 소비 경로(파일·라우트·엔드포인트)·PR/커밋·스모크·(kit) `/start` 후 실제 작업 기록 |

## 적용 범위

**적용(전체 또는 Gate 1 확장 체크 권장):**

- 신규 **횡단** 공유 패키지·workspace 패키지·내부 SDK
- **kit** submodule 추가·최초 `/start-setting`·채널 sync 도입
- 디자인 토큰·UI 키트를 **앱 전역**에 반영하는 변경
- **새 대외 API·계약**이 생기고, 호출·화면 연동이 이번 범위에 포함될 때
- API 스키마·OpenAPI만 있고 **호출·화면 연동이 없는** 상태로 “완료”를 주장하려 할 때

**과적용 방지(간이 점검으로 충분할 수 있음):**

- `AGENTS.md` **직접 처리 가능한 예외**(오탈자·문구·단일 파일 소규모 등)
- 기존 소비자가 이미 있는 패키지의 **패치·버그픽스**(소비 경로 변경 없음)
- 문서만 수정, 규칙/스킬 템플릿만 손보는 kit 레포 유지보수

연속 개발은 `60` Gate 1과 같이 **변경 범위에 대한 간이 점검**으로 대체할 수 있다. 이때도 **소비 경로가 바뀌면** 소비 증거를 갱신한다.

## Gate 1 — 착수 전 (첫 소비자)

PRD 또는 동등 문서에 다음을 **최소 1세트** 적는다 (`plan-feature`·`prd-agent`).

- **첫 소비자 1곳** (앱 이름·서비스·화면·모듈)
- **소비 경로** (예: `apps/web/src/routes/...`, `POST /api/v1/...`, 제품 `.cursor/skills/` 사용)
- **첫 세로 슬라이스** — 사용자 가치가 보이는 최소 플로우 1개
- **패키지·API·토큰 계약** 초안(버전·breaking·오류 형식)

## 생성 완료 vs Gate 3

| 단계 | 완료 정의 | Gate 3? |
|------|-----------|---------|
| **생성 완료** | 패키지 publish·CI green·README/계약 문서·submodule add·sync 1회 성공 | **아니오** |
| **소비 완료** | 첫 소비자에서 참조 + (UI면) 상태 UI 포함 동작 | Gate 2 통합 산출 |
| **Gate 3 DoD** | 요구·계약·소비 증거 일치 + `verify-change` / `qa-agent` | **예** |

**금지:** 생성 PR·publish·submodule add·sync만으로 기능 통합·kit 도입·횡단 자산 작업을 **완료**로 선언하지 않는다.

## Gate 2 — 병렬·통합

- `parallel-delivery` 조건(API·상태 UI·디자인 승인 등)은 기존과 동일.
- 횡단 패키지 작업은 계획에 **패키지 Owner**(backend-agent / design-system-agent)와 **소비 측**(frontend-agent / backend-agent)을 함께 적고, **같은 Gate 2 묶음**으로 착수한다.
- 병렬 가능하나 **소비 없이 생성만 닫는 것**은 금지. Integration Owner가 생성-only 머지 시 **Gate 3 미통과**로 추적한다.

## Gate 3 — 소비 증거 (DoD)

기존 Gate 3 항목에 더해, 본 범위에서는 다음이 **모두** 필요하다.

- Gate 1에 적은 **첫 소비자**에서 실제 참조·호출·연동
- **소비 증거** 기록(경로·PR 링크·스모크 결과·체크리스트)
- mock/스펙·submodule·sync만 존재하고 제품 경로에 없으면 **미충족** (`stage3-entry-checklist` §6과 정합)

## 역할

| 역할 | 책임 |
|------|------|
| `prd-agent` / `plan-feature` | Gate 1: 첫 소비자·소비 경로·세로 슬라이스 |
| `backend-agent` / `design-system-agent` | 생성·계약·버전 |
| `frontend-agent` | 앱/화면 소비·상태 UI |
| **Integration Owner** | 생성-only 머지 차단·소비 PR·기한 추적 |
| `qa-agent` / `verify-change` | 소비 경로 스모크·회귀 |

## 예외 — 생성만 먼저

팀이 **생성 PR을 먼저** 허용할 때만, PRD 또는 이슈에 **필수** 기록한다.

- 후속 **소비 PR** 링크 또는 이슈 번호
- 담당·기한
- Integration Owner

기한 내 소비가 없으면 Gate 3 미충족 상태를 유지한다.

## kit 연동 — 소비 증거 예시

**생성에 해당( Gate 3 아님):**

- `git submodule add` → `vendor/cursor-workspace-kit`
- `/start-setting` 성공·`.cursor-kit.json`·훅·첫 sync
- `.cursor/rules`·skills·agents **파일 존재**

**소비에 해당:**

- 제품 워크스페이스에서 **`/start <할 일>`** 후 작업에 스킬·규칙 반영
- [`.cursor/state/kit-start-last.json`](../../.cursor/state/kit-start-last.json) `ok: true` 확인(실패 시 구현·Gate 진행 중단 — `kit-start` 스킬)
- (권장) 제품 루트 `AGENTS.md`에 `/start`·상태 JSON 선독 규칙
- 실제 제품 코드·문서 경로 변경으로 워크플로가 **한 번이라도** 쓰인 증거

상세 절차: [`product-onboarding.md`](../agent/product-onboarding.md) **소비 확인** 절.

## 체크리스트 (요약)

- [ ] 첫 소비자 1곳 명시
- [ ] 소비 경로 명시
- [ ] 생성-only PR로 완료 선언하지 않음
- [ ] 소비 증거(경로·PR·스모크) 기록
- [ ] (kit) `/start` 후 실제 작업 1회 이상

stage3 병렬 착수 시: [`stage3-entry-checklist.md`](stage3-entry-checklist.md) §6.

## Vault

- [[cursor-workspace-kit/docs/cursor-workspace-kit-docs-hub|Hub]]
- [[cursor-workspace-kit/docs/obsidian/dashboards/projects-overview|Dashboards]]
