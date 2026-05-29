---
type: doc
project: cursor-workspace-kit
doc_lane: mobile
updated_at: 2026-05-29T00:00:00
tags: [docs, mobile, app-update, contract, vault-sync]
---

# policy-and-contract — 앱 버전 업데이트

신규·기존 앱 프로젝트 **공통 SSOT**. 제품별 값은 아래 `<!-- PRODUCT -->` 칸을 채운 뒤 `docs/requirements/app-update.md`에 복사한다.

---

## 1. 정책

### updateLevel

| 값 | 의미 | UX |
|----|------|-----|
| `none` | 업데이트 안내 없음 | — |
| `recommended` | 권장 업데이트 | 닫기 가능, 앱 계속 사용 |
| `required` | 강제 업데이트 | 닫기 불가, 스토어 이동만 |

### 판단 규칙 (서버)

서버가 클라이언트 `version`·`build`와 설정값을 비교해 `updateLevel`을 결정한다.

| 조건 (예시) | updateLevel |
|-------------|-------------|
| `current < minSupported` | `required` |
| `current < recommendedBelow` (및 `>= minSupported`) | `recommended` |
| 그 외 | `none` |

<!-- PRODUCT: 아래 표를 제품에 맞게 채운다 -->

| 항목 | 제품 값 | 비고 |
|------|---------|------|
| 버전 비교 방식 | SemVer / build / 둘 다 | 예: iOS build, Android versionCode |
| `minSupportedVersion` | | 강제 기준 |
| `recommendedBelowVersion` | | 권장 기준 (없으면 latest만 사용) |
| 권장 팝업 재표시 | 세션당 1회 / N일 1회 / 버전당 1회 | PRD에 명시 |
| API 실패 시 동작 | fail-open / fail-closed | **미확정 시 PRD HUMAN** |

### API 실패 시 (미확정)

- **fail-open (기본 후보):** 네트워크·5xx·타임아웃 시 앱 사용 허용, 로그만 남김
- **fail-closed:** 특정 보안 이슈 시에만 — 사유를 PRD·ADR에 기록

<!-- PRODUCT: 선택 _______________ -->

---

## 2. API 계약 (서버 1개)

경로 예시: `GET /api/v1/app/version` (제품이 정함)

### Request (Query)

| 필드 | 필수 | 설명 |
|------|------|------|
| `platform` | Y | `ios` \| `android` |
| `version` | Y | 앱 SemVer (예: `1.2.3`) |
| `build` | 권장 | iOS CFBundleVersion / Android versionCode |

### Response 200 (JSON)

| 필드 | 타입 | 설명 |
|------|------|------|
| `updateLevel` | string | `none` \| `recommended` \| `required` |
| `message` | string | 사용자 안내 문구 |
| `storeUrl` | string | App Store / Play Store URL |
| `minSupportedVersion` | string | 강제 기준 (표시·디버그용) |
| `latestVersion` | string | 최신 권장 버전 (표시용) |

```json
{
  "updateLevel": "recommended",
  "message": "새 버전이 있습니다. 업데이트를 권장합니다.",
  "storeUrl": "https://apps.apple.com/app/idXXXXXXXX",
  "minSupportedVersion": "1.0.0",
  "latestVersion": "1.3.0"
}
```

### 오류

| 상황 | HTTP | 앱 동작 |
|------|------|---------|
| 잘못된 platform/version | 400 | PRD의 API 실패 정책 |
| 서버 오류 | 5xx | PRD의 API 실패 정책 |
| 타임아웃 / 오프라인 | — | PRD의 API 실패 정책 |

인증: 공개 GET 또는 앱 토큰 — **제품 PRD에 명시**.

---

## 3. PRD 붙여넣기용 — 「앱 업데이트」절

```markdown
## 앱 업데이트

### 목표
스토어에 새 버전이 있을 때 권장/강제 업데이트를 안내한다.

### 정책
- updateLevel: none | recommended | required
- minSupportedVersion: (값)
- recommendedBelowVersion: (값)
- 권장 팝업 재표시: (정책)
- API 실패 시: (fail-open / fail-closed + 사유)

### API
- GET (경로): /api/v1/app/version
- Query: platform, version, build
- Response: updateLevel, message, storeUrl, minSupportedVersion, latestVersion

### UX
- recommended: 닫기 가능 — ux-states.md 참고
- required: 닫기 불가 — ux-states.md 참고

### 미확정
- (HUMAN 전까지 비워 둘 항목)
```

---

## 4. brownfield — as-is 매핑표

기존 구현이 kit 표준과 다를 때 **전면 교체 전**에 채운다.

| kit 표준 필드 | 현재 구현 (as-is) | 일치 | 조치 |
|---------------|-------------------|------|------|
| `updateLevel` | | | |
| `storeUrl` | | | |
| `minSupportedVersion` | | | |
| `latestVersion` | | | |
| 엔드포인트 URL | | | |
| 버전 체크 시점 | cold start / … | | |

차이가 유지되어야 하면 `docs/decisions/` ADR에 사유를 남긴다.

---

## 5. 릴리스 점검 (요약)

`release-check`·`verify-change`에서 참조:

1. 스토어 배포 빌드 ≥ 서버 `minSupported` 설정과 일치하는지
2. 구버전 / recommended / required / API down 4케이스 QA
3. 스토어 URL·플랫폼 분기(ios/android) 정확성
