---
type: doc
project: cursor-workspace-kit
doc_lane: security
updated_at: 2026-06-05T00:00:00
tags: [docs, security, release, vault-sync]
---

# release-checklist — security 릴리스 3항

PRD **보안 게이트=예**이고 활성 축이 있는 릴리스에서 `release-check` 스킬이 참조한다.

## 릴리스 3항

1. **security-last 통과**
   - [ ] `.cursor/state/security-last.json`(또는 팀 경로) `ok: true`
   - [ ] 활성 축(`enabled: true`) 각각 `ok: true`, `skipped: false`
   - [ ] `blockers` 배열 비어 있음
   - [ ] `docs/requirements/security-policy.json`과 `checks`·`tier` 정합
   - [ ] 엄격: `manualReview.authz`·`manualReview.owasp` = `passed`

2. **유출·환경·권한**
   - [ ] 민감 정보가 코드/로그/문서/스크린샷에 노출되지 않음
   - [ ] 배포 env에 시크릿·키 오타·staging/prod 혼선 없음
   - [ ] 신규·변경 API·화면의 권한(401/403)이 PRD·계약과 일치
   - [ ] (측정=예) analytics 이벤트에 PII·토큰 없음

3. **잔여 리스크·대응**
   - [ ] MAJOR 이하 알려진 이슈는 릴리즈 노트·TODO에 명시
   - [ ] BLOCKER·high/critical CVE·시크릿 발견 0 (엄격 기본)
   - [ ] 침해·유출 대응 연락·로그 보존 경로 문서화 (팀 정의)

## 배포 후 모니터링 (권장)

- 의존성 CVE 알림(Dependabot 등)
- 인증 실패·403 급증, 비정상 API 패턴
- 시크릿 스캔 CI 실패 알림

## 관련

- SSOT: [`policy-and-contract.md`](policy-and-contract.md) §8
- 스킬: `shared/skills/release-check/SKILL.md`
- 엄격 수동: [`strict-axis-checklist.md`](strict-axis-checklist.md)
