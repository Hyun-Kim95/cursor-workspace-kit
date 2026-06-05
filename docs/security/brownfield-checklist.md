---
type: doc
project: cursor-workspace-kit
doc_lane: security
updated_at: 2026-06-05T00:00:00
tags: [docs, security, brownfield, vault-sync]
---

# brownfield-checklist — 기존 제품

운영 중 제품에 보안 게이트를 **추가·정리**할 때. Gate 1 **전면 재수행 없이** `.cursor/rules/60-delivery-gates.mdc` **간이 점검**으로 진행.

## Phase 0 — 인벤토리 (코드 변경 전)

- [ ] 기존: gitleaks/trufflehog, npm audit, Dependabot, Semgrep/CodeQL, 없음
- [ ] CI job 이름·경로·실패 시 동작
- [ ] 인증·권한 문서·ADR 유무
- [ ] staging/prod TLS·보안 헤더·CORS 현황
- [ ] PII·로그·보존 정책 문서
- [ ] [`policy-and-contract.md`](policy-and-contract.md) **as-is 매핑표** → `docs/requirements/security-policy.json` 또는 PRD

## Phase 1 — 갭만 보완

| 갭 | 조치 |
|----|------|
| 정책 문서 없음 | PRD 보안 절 + `security-policy.json` 추가 |
| 스캔은 있으나 JSON 없음 | 기존 job 출력 → `security-last.json` 어댑터 |
| 일부 축만 있음 | 나머지 `enabled: false` 또는 갭 보완 계획 |
| 엄격 전환 | 6축 활성 + [`strict-axis-checklist.md`](strict-axis-checklist.md) 일정 |

- [ ] 기존 파이프라인 **전면 교체하지 않음**
- [ ] `document-change`로 범위·알려진 잔여 리스크 기록

## Phase 2 — 정합 (선택)

- [ ] `security:ci` 단일 진입점으로 통합
- [ ] `quality-gate.json`에 짧은 스캔 추가 ([`quality-gate.security.example.json`](../../project-kit/.cursor/quality-gate.security.example.json))
- [ ] ADR로 kit 축과 다른 도구명 유지 사유

## Gate · 검증

- [ ] 간이 점검: 이번 변경이 인증·권한·민감데이터·릴리스에 미치는 영향
- [ ] 활성 축 `security-last.json` spot check
- [ ] `verify-change` 또는 `release-check` security 항목

## 하지 않는 것

- Gate 1 전체 PRD 재작성
- 미사용 축 일괄 스캔 강제 (policy에 없는 축)
- 레거시 전체 pentest를 kit 기본 흐름에 포함
