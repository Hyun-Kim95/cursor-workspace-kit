---
type: doc
project: cursor-workspace-kit
doc_lane: mobile
updated_at: 2026-05-29T00:00:00
tags: [docs, mobile, app-update, vault-sync]
---

# app-update — 진입점

모바일 앱 **버전 업데이트(권장/강제)** 도입 시 여기서 시작한다.

## 결정 트리

1. **배포된 모바일 앱이 없나?** → 이 폴더 **스킵**
2. **기존 버전 체크/업데이트 안내가 없나?** → [`greenfield-checklist.md`](greenfield-checklist.md)
3. **이미 일부 구현이 있나?** → [`brownfield-checklist.md`](brownfield-checklist.md)
4. **제품 SSOT:** `docs/requirements/app-update.md`에 [`policy-and-contract.md`](policy-and-contract.md) 값·as-is 매핑을 복사해 채운다. kit 템플릿 갱신 시 **필수 필드 diff만** 수동 반영한다.

## 문서 구성

| 파일 | 용도 |
|------|------|
| [`policy-and-contract.md`](policy-and-contract.md) | 정책·API 계약·PRD 절·brownfield 매핑표 (신규·기존 공통 SSOT) |
| [`greenfield-checklist.md`](greenfield-checklist.md) | 신규 앱: Gate 1~3 순서 |
| [`brownfield-checklist.md`](brownfield-checklist.md) | 기존 앱: 인벤토리 → 갭 보완 → (선택) 정합 |
| [`ux-states.md`](ux-states.md) | 권장/강제 UI 상태 (디자인 게이트용) |

## 관련 kit

- 선택 규칙: `shared/optional/21-app-version-update.mdc` (앱 있는 제품/팀만 opt-in)
- 웹/앱 UX 분기: `shared/rules/20-web-vs-app.mdc`
- Gate: `project-kit/.cursor/rules/60-delivery-gates.mdc`
