---
type: doc
project: cursor-workspace-kit
doc_lane: product-analytics
updated_at: 2026-05-29T00:00:00
tags: [docs, product-analytics, contract, vault-sync]
---

# policy-and-contract — 제품 분석·이벤트 추적

신규·기존 프로젝트 **공통 SSOT**. 제품별 값은 아래 `<!-- PRODUCT -->` 칸을 채운 뒤 `docs/requirements/product-analytics.md`에 복사한다.

---

## 1. PRD 「측정·분석」절 (템플릿)

Gate 1에서 **측정=예**일 때 PRD 또는 동등 문서에 포함한다. SDK 연동 완료는 Gate 1 필수가 **아님**.

### 측정 목표

<!-- PRODUCT: North Star 1~2문장 -->

### North Star 퍼널 (3~5단)

PRD 「사용자 흐름」과 1:1로 매핑한다.

| 단계 | 사용자 행동 | 대응 이벤트 (후보) |
|------|-------------|-------------------|
| 1 | | |
| 2 | | |
| 3 | | |

### 이벤트 후보 목록 (MVP)

처음 출시 전 **5~10개**만. 전 화면 계측은 Out of scope.

| 이벤트명 | 트리거 | 필수 속성 |
|----------|--------|-----------|
| `page_view` | 라우트/화면 진입 | `path` |
| | | |

### 수집 / 미수집

| 수집 (허용) | 미수집 (금지) |
|-------------|---------------|
| `user_id` (내부 ID) | email, name, phone |
| `platform`, `app_version`, `locale` | password, token, session secret |
| 퍼널 단계·기능 ID | free_text, UGC 본문 |
| | payment_id, card_last4 (`product-monetization-default` 기본 제외) |

### 동의·프라이버시

<!-- PRODUCT -->

| 항목 | 제품 값 | 비고 |
|------|---------|------|
| 동의 UI 필요 | 예 / 아니오 / 미확정 | EU·UK 사용자 등 |
| opt-out 제공 | | |
| 쿠키/로컬 저장 | | |
| 데이터 보관 기간 | | **미확정 시 PRD HUMAN** |

### 분석 도구

<!-- PRODUCT: PostHog / Plausible / GA4 / 자체 / 미확정 -->

| 항목 | 제품 값 |
|------|---------|
| 도구 | |
| prod 프로젝트/워크스pace | |
| staging 분리 | 예 / 아니오 |

---

## 2. 이벤트 계약 v1 (Gate 2 — 측정=예일 때)

API 계약과 동일하게 **버전·경로**를 문서에 남긴다. Gate 60 조건 추가가 아니라 **체크리스트·stage3**에서 확정한다.

**문서 경로 예:** `docs/requirements/product-analytics.md` § 이벤트 계약 v1

### 네이밍

- `snake_case`
- 동사_과거형: `signup_completed`, `item_published`
- 페이지뷰: `page_view` (또는 도구 기본 `$pageview`와 매핑表에 명시)

### identify

| 필드 | 정책 |
|------|------|
| `distinct_id` / `user_id` | 로그인 후 내부 ID만. email·전화번호 **금지** |
| anonymous | 로그인 전 anonymous id 유지, 로그인 시 alias 정책을 PRD에 명시 |

### 공통 속성 (모든 이벤트)

| 속성 | 필수 | 설명 |
|------|------|------|
| `platform` | Y | `web` / `ios` / `android` |
| `app_version` | Y | semver 또는 build |
| `locale` | N | `ko-KR` 등 |

### 이벤트 스키마

<!-- PRODUCT: PRD 퍼널表를 여기에 확정 -->

```json
{
  "event": "signup_completed",
  "properties": {
    "method": "email | oauth_google",
    "source": "landing | invite"
  }
}
```

### 서버 사이드 이벤트 (해당 시)

| 이벤트 | 발화 주체 | 비고 |
|--------|-----------|------|
| | `backend-agent` | 클라이언트와 중복 발화 금지 — PRD에 주체 명시 |

### 금지

- PII·결제 식별자를 properties에 넣지 않는다.
- PRD·계약에 없는 이벤트를 임의 추가하지 않는다(추가는 `start-feature` 범위).

---

## 3. 환경 변수 (레퍼런스 — PostHog 예시)

도구마다 이름이 다르다. 제품 SSOT에 **실제 키 이름**을 기록한다.

| 변수 | 환경 | 설명 |
|------|------|------|
| `NEXT_PUBLIC_POSTHOG_KEY` | web client | prod/staging 분리 |
| `NEXT_PUBLIC_POSTHOG_HOST` | web client | self-host 또는 `https://us.i.posthog.com` |
| `POSTHOG_API_KEY` | server (선택) | 서버 capture용 |

<!-- PRODUCT: 실제 env 키 목록 -->

---

## 4. PRD 붙여넣기 블록

`docs/requirements/product-analytics.md` 초안에 복사:

```markdown
## 측정·분석

### 적용 여부
측정=예 (선택 범위)

### 목표
(값)

### North Star 퍼널
(표)

### 이벤트 MVP
(표)

### 프라이버시·동의
(표)

### 도구
(값)

### 이벤트 계약
- 버전: v1
- 문서: docs/requirements/product-analytics.md

### 미확정
- (HUMAN 전까지)
```

---

## 5. brownfield — as-is 매핑표

기존 analytics가 kit 표준과 다를 때 **전면 교체 전**에 채운다.

| kit 표준 | 현재 구현 (as-is) | 일치 | 조치 |
|----------|-------------------|------|------|
| 이벤트명 `signup_completed` | | | |
| identify 정책 | | | |
| page_view / screen_view | | | |
| prod/staging 분리 | | | |
| 동의 배anner | | | |

**이중 계측:** GA4 + PostHog 등 병행 시 PRD에 **주 SSOT 도구** 하나를 명시하고, 나머지는 deprecate 일정 또는 역할 분리(마케팅 vs 제품)를 기록한다.

차이가 유지되어야 하면 `docs/decisions/` ADR에 사유를 남긴다.

---

## 6. 릴리스 점검 (요약)

`release-check`·`verify-change`에서 참조 — 상세: [`release-checklist.md`](release-checklist.md)

1. prod/staging analytics 키·host 누락·오타 없음
2. 동의·opt-out(필요 시) 및 PII 금지 속성 미포함
3. North Star 퍼널 핵심 이벤트 staging·prod 각 1건 이상 샘플 확인
