---
type: doc
project: cursor-workspace-kit
doc_lane: product-analytics
updated_at: 2026-05-29T00:00:00
tags: [docs, product-analytics, vault-sync]
---

# product-analytics — 진입점

제품 분석·사용자 행동 추적(퍼널·이벤트)을 **PRD에서 측정=예로 명시한 경우** 여기서 시작한다.

## 결정 트리

1. **PRD에 측정·분석=아니오(또는 미명시)?** → 이 폴더 **스킵**
2. **기존 analytics(GA4·PostHog·자체 로그)가 없나?** → [`greenfield-checklist.md`](greenfield-checklist.md)
3. **이미 일부 구현·혼재가 있나?** → [`brownfield-checklist.md`](brownfield-checklist.md)
4. **제품 SSOT:** `docs/requirements/product-analytics.md`에 [`policy-and-contract.md`](policy-and-contract.md) 값·as-is 매핑을 복사해 채운다. kit 템플릿 갱신 시 **필수 필드 diff만** 수동 반영한다.

## 문서 구성

| 파일 | 용도 |
|------|------|
| [`policy-and-contract.md`](policy-and-contract.md) | PRD 「측정·분석」절·이벤트 계약·프라이버시·brownfield 매핑표 (신규·기존 공통 SSOT) |
| [`greenfield-checklist.md`](greenfield-checklist.md) | 신규: PRD 측정 절 → Gate 2 이벤트 계약 → MVP instrumentation |
| [`brownfield-checklist.md`](brownfield-checklist.md) | 기존: 인벤토리 → 이중 계측 정리 → 갭 보완 |
| [`release-checklist.md`](release-checklist.md) | 릴리스 3항 (env·동의·샘플 이벤트·PII) — `release-check` 스킬이 참조 |

## 관련 kit

- 선택 규칙: `shared/optional/22-product-analytics.mdc` (측정=예 제품/팀만 opt-in)
- 수익·PII 기본: `shared/rules/product-monetization-default.mdc` (결제 ID 등 기본 스키마 제외)
- Gate: `project-kit/.cursor/rules/60-delivery-gates.mdc` (analytics는 Gate 1 **필수 산출 아님**)

## 도구

PostHog·Plausible·GA4 등 **도구 중립**. 레퍼런스 env 예시는 `policy-and-contract.md`에만 둔다.
