---
type: doc
project: cursor-workspace-kit
doc_lane: security
updated_at: 2026-06-05T00:00:00
tags: [docs, security, contract, vault-sync]
---

# policy-and-contract — 보안 게이트

신규·기존 프로젝트 **공통 SSOT**. 제품별 값은 `<!-- PRODUCT -->` 칸을 채운 뒤 `docs/requirements/security-policy.json`(또는 팀 규칙 경로)에 복사한다.

---

## 1. PRD 「비기능·보안」절 (템플릿)

Gate 1에서 **보안 게이트=예**일 때 PRD 또는 동등 문서에 포함한다. `security:ci` 구현 완료는 Gate 1 **필수 아님** — 티어·활성 축·권한 모델 설계만 PRD에 가능.

### 적용 여부

<!-- PRODUCT: 보안 게이트=예 / 아니오 -->

### 티어

| 티어 | 설명 |
|------|------|
| **strict** (엄격, 권장) | 6축 모두 활성, 4B 보안 축 필수, high/critical CVE·시크릿 0, 수동 OWASP 점검 |
| standard | 팀이 선택한 축만 활성, 4B 보안 축 권장 |

<!-- PRODUCT: strict / standard -->

### 활성 축

| 축 | enabled | 비고 |
|----|---------|------|
| secrets | false | 저장소·히스토리·로그 시크릿 |
| dependencies | false | CVE·취약 패키지 |
| sast | false | 정적 분석·위험 패턴 |
| authz | false | 인증·권한·세션·IDOR |
| transport | false | TLS·보안 헤더·CORS·쿠키 |
| data | false | PII·암호화·마스킹·보존 |

### 위협·민감 데이터 (PLACEHOLDER)

<!-- PRODUCT: 제품별 정의 -->

| 항목 | 정의 |
|------|------|
| 인증 방식 | (세션/JWT/OAuth/…) |
| 권한 모델 | (역할·리소스·스코프) |
| 민감 데이터 | (PII, 토큰, 결제 ID 등) |
| 로그 금지 필드 | password, token, session secret, … |
| 데이터 보존·삭제 | (기간·요청 삭제) |

### 미확정

- (HUMAN 전까지)

---

## 2. security-policy.json (제품 SSOT)

kit 템플릿: [`security-policy.template.json`](security-policy.template.json)

- `tier: strict` 이면 **6축 `enabled: true`** 를 기본으로 둔다.
- `checks.*.policy`는 제품·도구에 맞게 추가 가능. kit는 **최소 키**만 예시.

### 엄격(strict) 기본 임계값 (PLACEHOLDER)

| 축 | policy 키 | 엄격 기본 |
|----|-----------|-----------|
| secrets | `maxFindings` | 0 |
| dependencies | `auditLevel` | high (critical·high 0) |
| sast | `maxBlockerFindings` | 0 |
| authz | `manualReviewRequired` | true |
| transport | `tlsRequired`, `securityHeadersRequired` | true |
| data | `piiInLogsAllowed` | false |

---

## 3. security-last.json 계약

**권장 경로:** `.cursor/state/security-last.json` (gitignore 권장)

**예시:** [`docs/qa/security-last.example.json`](../qa/security-last.example.json)

### 스키마 (요약)

| 필드 | 설명 |
|------|------|
| `ok` | **활성** 축의 `checks.*.ok`가 모두 true이고 `blockers`가 비어 있을 때만 true |
| `version` | 계약 버전 (1) |
| `tier` | `strict` \| `standard` |
| `updatedAt` | ISO 8601 권장 |
| `command` | 마지막 스캔 명령 (예: `npm run security:ci`) |
| `checks` | 축별 결과 |
| `blockers` | (선택) 출시 불가 이슈 요약 문자열 배열 |
| `manualReview` | (선택) 수동 점검 상태 `authz`, `owasp` 등 |

### 축 객체

| 필드 | 설명 |
|------|------|
| `enabled` | policy와 동일 — 이번 실행에 게이트 대상인지 |
| `skipped` | `enabled: false`이면 true |
| `ok` | 해당 축 정책 통과 |
| `findings` | (선택) 발견 건수·요약 |
| `failures` | (선택) 미달 항목 목록 |

### 집계 규칙

1. `enabled: false` → `skipped: true`, `ok: true` (전체 ok 계산에서 제외)
2. `enabled: true` → `skipped: false`, policy·도구 결과로 `ok` 설정
3. 루트 `ok` = 활성 축의 `ok` **AND** ∧ `blockers` **비어 있음**
4. **엄격:** `manualReview.authz`·`manualReview.owasp`가 `passed`가 아니면 `ok: false` (제품 harness 권고)

---

## 4. 측정 명령 (제품 구현)

kit는 **도구 중립**. 제품이 다음을 구현한다.

| 명령 예 | 역할 |
|---------|------|
| `npm run security:ci` | 활성 축 스캔 순 실행 후 `security-last.json` 갱신 |
| kit 스텁 | [`scripts/security/Invoke-SecurityGate.ps1`](../../scripts/security/Invoke-SecurityGate.ps1) — 계약·파일 쓰기만 (실스캔 없음) |

### security:ci 최소 구성 (엄격·Node 예)

```json
"scripts": {
  "security:deps": "npm audit --audit-level=high",
  "security:secrets": "gitleaks detect --source . --verbose",
  "security:sast": "semgrep scan --config auto --error",
  "security:ci": "npm run security:deps && npm run security:secrets && npm run security:sast"
}
```

스택이 다르면 동등 명령으로 교체한다. **수동 축**(authz, transport, data)은 [`strict-axis-checklist.md`](strict-axis-checklist.md) 결과를 `manualReview`·`docs/qa/security-axis-*.md`에 기록한다.

**에이전트 동작:** `security-last.json`·스캔 로그로 원인 조사 후 수정 (`working-principles` **조사·소통·실패 대응**). 추측 패치 금지.

---

## 5. 완료·검증·출시 선언 (권고)

제품·팀 harness에 다음을 **권고**한다.

- `.cursor/state/security-last.json`이 존재하고 `ok: false`이면 **완료·검증 완료·출시 준비** 선언을 하지 않는다.
- `quality-gate-last.json`·`perf-last.json`과 함께 해석할 수 있다.
- 엄격 티어: 단계 4B 보안 축·[`release-checklist.md`](release-checklist.md) 미통과 시 출시 불가.

---

## 6. PRD 붙여넣기 블록

```markdown
## 비기능·보안

### 보안 게이트
보안 게이트=예
티어: strict

### 활성 축
- secrets: true
- dependencies: true
- sast: true
- authz: true
- transport: true
- data: true

### 위협·민감 데이터
(인증·권한·민감 데이터·로그 금지 필드)

### 측정
- 명령: npm run security:ci (제품 구현)
- 산출: .cursor/state/security-last.json
- 수동: docs/security/strict-axis-checklist.md

### 미확정
-
```

---

## 7. brownfield — as-is 매핑표

| kit 축 | 현재 as-is | 일치 | 조치 |
|--------|------------|------|------|
| secrets 스캔 | | | |
| deps audit / Dependabot | | | |
| SAST / CodeQL | | | |
| 인증·권한 문서 | | | |
| TLS·보안 헤더 | | | |
| PII·로그 정책 | | | |

차이 유지 시 `docs/decisions/` ADR에 사유를 남긴다.

---

## 8. 릴리스 점검 (요약)

[`release-checklist.md`](release-checklist.md) — `release-check`·`verify-change` 참조.

1. 활성 축 `security-last.json` `ok: true`, `blockers` 없음
2. 엄격: 수동 OWASP·authz 점검 `passed`
3. 민감 정보 코드/로그/문서·환경 변수 노출 없음
