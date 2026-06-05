---
type: doc
project: cursor-workspace-kit
doc_lane: security
updated_at: 2026-06-05T00:00:00
tags: [docs, security, greenfield, vault-sync]
---

# greenfield-checklist — 신규 제품

보안 게이트를 **처음부터** 설계할 때. PRD **보안 게이트=예**일 때만 적용.

## Gate 1 — 구현 착수 전

- [ ] [`policy-and-contract.md`](policy-and-contract.md) PRD 「비기능·보안」절 작성
- [ ] 티어 **strict** 확정 (엄격) 또는 standard + 사유
- [ ] [`security-policy.template.json`](security-policy.template.json) → `docs/requirements/security-policy.json` 복사
- [ ] 엄격: 6축 모두 `checks.*.enabled: true`
- [ ] 인증·권한·민감 데이터·로그 금지 필드 **HUMAN 확정**
- [ ] `security:ci` **구현 계획**만 PRD에 (Gate 1에서 CI 구현 필수 아님)
- [ ] `.gitignore`에 `.env`, 키·자격증명 패턴 반영
- [ ] harness `shellGuard.mode: block` ([`harness-layer1.md`](../agent/harness-layer1.md))

## Gate 2~4 — 구현 구간

- API 계약에 인증·권한·401/403·오류 포맷 고정 (`60-delivery-gates.mdc`)
- `security-last.json`이 없어도 Gate 2 위반 아님 (측정은 구현 후)

## 단계 4B — 보안 축 (엄격: 필수)

엄격 티어는 **생략 불가**(사용자 명시 예외만).

1. [`strict-axis-checklist.md`](strict-axis-checklist.md) 수행
2. 자동: `npm run security:ci` → `.cursor/state/security-last.json`
3. 산출: `docs/qa/security-axis-{날짜}.md` (BLOCKER / MAJOR / MINOR)
4. BLOCKER 있으면 단계 4C 루프

### 축별 (enabled 시)

- [ ] **secrets:** gitleaks 등 0건
- [ ] **dependencies:** high/critical 0 (또는 policy 임계값)
- [ ] **sast:** blocker 0
- [ ] **authz:** 수동 점검 passed
- [ ] **transport:** TLS·헤더·CORS·쿠키 점검 passed
- [ ] **data:** PII 로그·마스킹·보존 passed

## Gate 3 / DoD

- [ ] 활성 축 `security-last.json` `ok: true`, `blockers` 없음
- [ ] 엄격: `manualReview.authz`·`manualReview.owasp` = `passed`
- [ ] `docs/requirements/security-policy.json`과 PRD·구현 일치
- [ ] [`release-checklist.md`](release-checklist.md) (릴리스 전)
