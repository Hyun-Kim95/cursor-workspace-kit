---
type: doc
project: cursor-workspace-kit
doc_lane: qa
updated_at: 2026-04-21T21:51:12
tags: [docs, vault-sync]
---

# Stage 3 Entry Checklist (Design Selection -> Parallel Delivery)

디자인 선택 이후 3단계 착수 전에 PRD/디자인 기준 완성 여부를 확인하는 체크리스트다.

## 1) PRD 확정 여부

- [ ] PRD 문서 경로: ``
- [ ] PRD 버전/최종 수정 시각: ``
- [ ] 목표/핵심 흐름/범위(핵심·선택)/정책·예외/미확정 항목이 명시됨
- [ ] 원본 요구사항과 PRD 간 불일치 항목이 정리됨

## 2) 디자인 기준 확정 여부

- [ ] 선택안: `자체 목업` / `Stitch 기반` / `기타`
- [ ] 선택 근거(링크, 화면 ID, 에셋 ID): ``
- [ ] 주요 화면 상태(기본/로딩/빈/오류/권한) 반영 확인
- [ ] 웹/앱 대상 범위와 반응형 기준 확인
- [ ] 라이트/다크 모드 지원 및 전환 기능(토글/스위치) 반영 계획 확인

## 3) Gate 2 진입 준비 (API + 상태 UI)

- [ ] API 계약 확정(요청/응답 스키마, 인증·권한, 오류 포맷, 주요 상태 코드)
- [ ] 상태 UI 정의 확정(기본/로딩/빈/오류/권한)
- [ ] 화면 스펙과 API 계약의 용어/상태값 정합 확인
- [ ] FE/BE 병렬 진행 시 작업 분할과 인터페이스 책임 구분 완료

### 3b) 측정·분석 (선택 — PRD 측정=예일 때만)

- [ ] 이벤트 계약 v1 경로·버전: ``
- [ ] PRD North Star 퍼널과 이벤트 1:1 매핑 확인
- [ ] PII·동의 정책 PRD 반영 (`docs/product-analytics/policy-and-contract.md`)

### 3c) 보안 게이트 (선택 — PRD 보안 게이트=예일 때만)

- [ ] `docs/requirements/security-policy.json` 경로·티어(strict 권장): ``
- [ ] 활성 축(secrets/dependencies/sast/authz/transport/data) PRD·API 계약 정합
- [ ] 인증·권한·민감 데이터·로그 금지 필드 PRD 반영 (`docs/security/policy-and-contract.md`)
- [ ] `security:ci` 구현 계획·harness(`shellGuard` block, quality-gate 예시) 합의

## 4) 리스크/오픈 이슈

- [ ] 미확정 항목 목록 작성
- [ ] 리스크 항목과 대응 방안 작성
- [ ] 담당자/기한 지정

## 5) 승인 기록

- [ ] 작성자:
- [ ] 검토자:
- [ ] 승인 상태: `승인` / `수정 필요`
- [ ] 승인 코멘트:
- [ ] 승인 일시:

## 6) 구현 착수 (목업 금지·생성·소비)

상세: [`integration-consumption-gate.md`](integration-consumption-gate.md)

- [ ] **제품 구현 대상 경로**(앱 라우트·모듈·패키지): ``
- [ ] **첫 소비자 1곳**(앱·서비스·화면): ``
- [ ] **소비 경로**(import·라우트·호출·엔드포인트): ``
- [ ] **mock 전용 경로 사용:** `아니오`(기본) / `예`(사용자 명시 재목업·사유): ``
- [ ] **생성-only PR로 완료 선언:** `아니오`(기본) / `예`(소비 PR·담당·기한 문서화): ``
- [ ] API 연동·상태 UI(로딩·빈·오류·권한) 착수 확인
- [ ] 선택안을 스펙 SSOT로 두고, Gate 2·`parallel-delivery` / `start-feature` 진입 준비 완료

## Vault

- [[cursor-workspace-kit/docs/cursor-workspace-kit-docs-hub|Hub]]
- [[cursor-workspace-kit/docs/obsidian/dashboards/projects-overview|Dashboards]]
- [[cursor-workspace-kit/docs/obsidian/dashboards/commit-journal-overview|Commit journals (Dataview)]]

