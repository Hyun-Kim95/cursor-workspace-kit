---
type: doc
project: cursor-workspace-kit
doc_lane: qa
updated_at: 2026-06-15
tags: [docs, atdd, qa, consumption]
---

# ATDD-lite 제품 소비 체크리스트

제품 레포에서 **신규 기능 1건**을 ATDD-lite로 완료할 때 남길 **증거 체크리스트**다.

정책 SSOT: [`atdd-lite.md`](atdd-lite.md) · Gate: [`60-delivery-gates.mdc`](../../project-kit/.cursor/rules/60-delivery-gates.mdc) · 기록 예시: [`atdd-lite-consumption-record-example.md`](atdd-lite-consumption-record-example.md)

## 적용 범위

- **적용:** 신규 기능·API 계약이 생기는 변경 ([`60`](../../project-kit/.cursor/rules/60-delivery-gates.mdc) Gate 1 적용 범위와 동일)
- **생략·경량:** [`AGENTS.md`](../../AGENTS.md) 직접 처리 예외, 핫픽스, brownfield·버그 → [`atdd-lite.md`](atdd-lite.md) 경량 ATDD

## 1) Gate 1 — PRD·수용 기준

- [ ] PRD(또는 동등 문서) 경로: ``
- [ ] PRD 버전/최종 수정: ``
- [ ] **수용 기준(AC)** `AC-01` 형식, 행위·계약·상태 중심 ([`acceptance-criteria.template.md`](acceptance-criteria.template.md))
- [ ] auto/manual 구분, 핵심 AC 3~7개 이상(또는 PRD 범위만큼)
- [ ] **첫 소비자 1곳:** `` (앱·화면·서비스)
- [ ] **소비 경로(예정):** `` (라우트·API·모듈)

## 2) Gate 2 — 계약·디자인·stage3

- [ ] [`stage3-entry-checklist.md`](stage3-entry-checklist.md) 완료(고객 E2E) 또는 Gate 2 동등 체크
- [ ] API 계약·상태 UI(기본/로딩/빈/오류/권한) 확정
- [ ] §3d ATDD-lite: PRD AC 목록 경로와 일치

## 3) RED — acceptance test (구현 전)

- [ ] AC ID ↔ 테스트 매핑표 작성
- [ ] E2E 경로 (`frontend-agent`): ``
- [ ] API/통합 경로 (`backend-agent`): ``
- [ ] 테스트 실행 명령: `` (예: `npm run test:e2e`, `npm test`)
- [ ] **RED 확인:** 각 auto AC에 대해 의도적 실패 또는 `test.todo` + AC ID 주석
- [ ] (선택) 실패 로그·스크린샷 경로: ``

| AC ID | 테스트 (describe/it) | RED 확인 |
|-------|----------------------|----------|
| AC-01 | | |
| AC-02 | | |

## 4) GREEN — 구현

- [ ] 제품 구현 경로(라우트·컴포넌트·API): ``
- [ ] FE 담당: `frontend-agent` / BE 담당: `backend-agent`
- [ ] auto AC acceptance test **전부 통과** (명령·일시 기록)

## 5) Gate 3 — 검증·handoff

[`agent-brief.md`](../agent/agent-brief.md) **9) Verifier Handoff** 형식:

- [ ] `artifactPaths`: 구현·PRD 경로
- [ ] `acceptanceTestPaths`: acceptance test 파일 목록
- [ ] `acIds`: `["AC-01", ...]`
- [ ] `rubricRef`: Gate 3, [`atdd-lite.md`](atdd-lite.md)
- [ ] `qa-agent` 독립 검증 → [`verify-change`](../../shared/skills/verify-change/SKILL.md)
- [ ] 검증 산출: `docs/qa/verify-{날짜 또는 slug}.md`

## 6) 소비 증거 ([`integration-consumption-gate.md`](integration-consumption-gate.md))

- [ ] **첫 소비자**에서 실제 참조·동작 확인
- [ ] **소비 경로** (import·라우트·엔드포인트): ``
- [ ] PR/커밋 또는 작업 기록: ``
- [ ] 테스트 통과 로그 요약(또는 CI 링크): ``

## 7) 완료 판정

- [ ] PRD auto AC ↔ 테스트 1:1, **미매핑 AC 0**
- [ ] manual AC는 `docs/qa/` 실행 기록 있음
- [ ] mock-only·생성-only로 완료 선언하지 않음

## Vault

- [[cursor-workspace-kit/docs/qa/atdd-lite|ATDD-lite]]
- [[cursor-workspace-kit/docs/cursor-workspace-kit-docs-hub|Hub]]
