---
type: doc
project: cursor-workspace-kit
doc_lane: security
updated_at: 2026-06-05T00:00:00
tags: [docs, security, strict, vault-sync]
---

# strict-axis-checklist — 엄격 보안 축 (4B)

PRD **보안 게이트=예** + **티어 strict**일 때 `client-project-lifecycle` 단계 4B **코드 품질·보안 축** SSOT. `qa-agent`·`backend-agent` 협업.

산출: `docs/qa/security-axis-{날짜}.md` — 각 항목 **PASS / FAIL / N/A**, 심각도 **BLOCKER / MAJOR / MINOR**.

---

## A. 자동 스캔 (security:ci)

| ID | 항목 | 엄격 기준 | 도구 예 |
|----|------|-----------|---------|
| A1 | 저장소 시크릿 | 0건 | gitleaks, trufflehog |
| A2 | 의존성 CVE | critical·high 0 | npm audit, pip-audit |
| A3 | 정적 분석 blocker | 0건 | Semgrep, CodeQL, eslint-plugin-security |

실패 시 `security-last.json` `ok: false`, `blockers`에 요약.

---

## B. 인증·권한 (authz) — 수동

| ID | 항목 | 점검 |
|----|------|------|
| B1 | 인증 필수 경로 | 미인증 시 401/리다이렉트, 민감 API 노출 없음 |
| B2 | 권한 검사 | 서버 측 검사(클라이언트 UI만으로 허용 금지) |
| B3 | IDOR | 타 사용자 리소스 ID 변경 시 403/404 |
| B4 | 세션·토큰 | 만료·로그아웃·탈취 시 무효화 경로 |
| B5 | 비밀번호·자격증명 | 평문 저장·로그 출력 없음 |

---

## C. 입력·주입·XSS (OWASP)

| ID | 항목 | 점검 |
|----|------|------|
| C1 | SQL/NoSQL injection | 파라미터화·ORM·입력 검증 |
| C2 | XSS | 출력 이스케이프·CSP·dangerouslySetInnerHTML 최소화 |
| C3 | CSRF | 상태 변경 요청에 토큰·SameSite 등 |
| C4 | 파일 업로드 | 확장자·MIME·크기·저장 경로 |
| C5 | SSRF (해당 시) | URL allowlist·내부 IP 차단 |

---

## D. 전송·헤더 (transport)

| ID | 항목 | 점검 |
|----|------|------|
| D1 | TLS | prod HTTPS 강제, mixed content 없음 |
| D2 | 보안 헤더 | HSTS, CSP, X-Frame-Options 등 (스택별) |
| D3 | CORS | origin 과다 허용 없음 |
| D4 | 쿠키 | HttpOnly, Secure, SameSite (세션 사용 시) |

---

## E. 데이터·로그 (data)

| ID | 항목 | 점검 |
|----|------|------|
| E1 | PII 분류 | PRD 민감 데이터 목록과 저장·전송 일치 |
| E2 | 로그·이벤트 | password/token/session secret 미기록 |
| E3 | 암호화 | 저장 시 at-rest (팀 정책) |
| E4 | 보존·삭제 | 계정 삭제·데이터 요청 흐름 (해당 시) |

---

## F. 운영·침해 대응 (엄격 권장)

| ID | 항목 | 점검 |
|----|------|------|
| F1 | 시크릿 로테이션 | 유출 시 교체 절차 문서화 |
| F2 | 감사 로그 | 권한 변경·관리자 동작 기록 (해당 시) |
| F3 | rate limit | 로그인·공개 API 남용 완화 (해당 시) |

---

## 완료 기준 (엄격)

- A1~A3 자동 **PASS**
- B~E에서 **BLOCKER 0**
- `manualReview` in `security-last.json`: `{ "authz": "passed", "owasp": "passed" }`
- 리포트에 미해결 MAJOR와 완화 계획 명시

## BLOCKER 예시

- 저장소·히스토리에 API 키·비밀번호
- critical CVE 미패치
- 인증 없이 PII 조회 가능
- 운영 env 시크릿이 git 추적
