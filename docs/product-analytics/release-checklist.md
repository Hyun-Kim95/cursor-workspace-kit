---
type: doc
project: cursor-workspace-kit
doc_lane: product-analytics
updated_at: 2026-05-29T00:00:00
tags: [docs, product-analytics, release, vault-sync]
---

# release-checklist — product-analytics 릴리스 3항

PRD **측정=예**이고 analytics instrumentation이 포함된 릴리스에서 `release-check` 스킬이 참조한다.

## 릴리스 3항

1. **환경·키**
   - [ ] prod/staging analytics 키·host(또는 ingest URL)가 배포 환경 변수에 설정됨
   - [ ] prod 빌드에 staging 키·debug 모드가 **노출되지 않음**
   - [ ] `docs/requirements/product-analytics.md` env表와 실제 키 이름 일치

2. **프라이버시·동의**
   - [ ] PRD 수집/미수집表와 구현 일치 (email·token·free_text·payment_id **미포함**)
   - [ ] 동의 UI·opt-out이 PRD/HUMAN대로 동작 (해당 시)
   - [ ] identify는 내부 `user_id` 등 비PII만

3. **샘플 이벤트·퍼널**
   - [ ] North Star 퍼널 MVP 이벤트가 staging에서 1건 이상 수신됨
   - [ ] prod 배포 후(또는 canary) 핵심 이벤트 1건 spot check
   - [ ] `page_view`(또는 screen_view)와 퍼널 첫·마지막 단계 이벤트 연결 확인

## 배포 후 모니터링 (권장)

- 퍼널 이탈 단계, 이벤트 수신 중단(0건), SDK 오류 로그
- 출시 1~2주 후 PRD 측정 목표 대비 리뷰 (`document-change` TODO 가능)

## 관련

- SSOT: [`policy-and-contract.md`](policy-and-contract.md) §6
- 스킬: `shared/skills/release-check/SKILL.md`
