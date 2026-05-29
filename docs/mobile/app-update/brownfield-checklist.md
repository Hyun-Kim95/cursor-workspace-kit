---
type: doc
project: cursor-workspace-kit
doc_lane: mobile
updated_at: 2026-05-29T00:00:00
tags: [docs, mobile, app-update, brownfield, vault-sync]
---

# brownfield-checklist — 기존 앱

운영 중 앱에 버전 업데이트 정책을 **추가·보완**할 때. Gate 1 **전면 재수행 없이** `.cursor/rules/60-delivery-gates.mdc`의 **간이 점검**(요구·화면·계약 영향)으로 진행한다.

## Phase 0 — 인벤토리 (코드 변경 전)

- [ ] 앱 버전 읽는 위치 (예: `pubspec.yaml`, `Info.plist`, `build.gradle`)
- [ ] 기존 버전 체크: API / Remote Config / 스토어만 / 없음
- [ ] 기존 UI: 권장·강제 구분, 닫기 가능 여부
- [ ] [`policy-and-contract.md`](policy-and-contract.md) **as-is 매핑표** 작성 → `docs/requirements/app-update.md`

## Phase 1 — 갭만 보완 (최소 diff)

| 갭 | 조치 |
|----|------|
| API 없음 | 엔드포인트 **추가** (기존 라우트 구조 유지) |
| API 있음, 필드 부족 | `updateLevel` 등 **필드 보강** |
| UI 없음 | bootstrap **한 곳**에 훅 + 모달 |
| 강제만 / 권장만 | 부족한 `updateLevel` 분기 추가 |

- [ ] 기존 로직 **전면 교체하지 않음**
- [ ] 변경 범위를 PR/문서에 명시 (`document-change`)

## Phase 2 — 정합 (선택, 별도 PR)

- [ ] kit 표준 필드명·URL로 통일 (또는 ADR로 차이 유지 기록)
- [ ] PRD·계약 문서 사후 정리

## Gate · 검증

- [ ] 간이 점검: 이번 변경이 요구·API·화면에 미치는 영향만 확인
- [ ] UI 변경 없으면 디자인 이중 목업 **생략 가능**
- [ ] UI 변경 있으면 [`ux-states.md`](ux-states.md)만 최소 반영
- [ ] 4케이스: none / recommended / required / API down
- [ ] `verify-change` 또는 `release-check` app-update 항목

## 하지 않는 것

- Gate 1 전체 PRD 재작성
- 기존 버전 체크 **전면 재설계**
- mock-only 경로만 다시 만드는 것 (고객 E2E 단계 3 규칙)
