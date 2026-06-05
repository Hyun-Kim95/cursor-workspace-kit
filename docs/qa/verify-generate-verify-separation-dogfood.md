# 독립 검증: 생성·검증 분리 dogfood

**대상:** `docs/qa/dogfood-generate-verify-separation.md`  
**일자:** 2026-06-05  
**검증기:** qa-agent (독립 검증기 계약)

## 판정 요약

| 구분 | 결과 |
|------|------|
| dogfood 표 6건 SSOT 주장 | 합격 |
| rubric 9항 | 8/9 (조건부 불합격) |
| BLOCKER | 0 |

`checkedItems: 8/9`  
`uncheckedIds: ["C1-self-verify-prohibition"]` — `verify-change` 사용 시점 문구 수정 후 재검증 권고

## 이슈

### MAJOR-1 (수정함)

`verify-change` 사용 시점 「PR 전 셀프 리뷰」가 self-verify 금지와 충돌 → 「PR 전 점검 (생성·검증 분리: qa-agent 독립 검증 후…)」로 변경.

### MAJOR-2 (2단계에서 수정함)

`parallel-delivery` 절차 4를 `start-feature`와 동일한 생성·검증 분리로 정렬.

### MAJOR-3 (2단계에서 수정함)

`client-project-lifecycle` 단계 3·4·4B에 Verifier Handoff·self-verify 금지 반영.

### MINOR (2단계에서 수정함)

- handoff 필드명 `forbidden` 단일화 (`verify-change`·`qa-agent`)
- `release-check` 절차 6 cross-reference 추가

### 재검증

2단계 반영 후 rubric 9/9 목표. `parallel-delivery`·`lifecycle`·`release-check` 실파일 대조 권고.
- `start-feature` 절차 8~10 상대 순서 보강 여지

## 긍정 확인

- 표 6경로 변경 실재 확인
- kit SSOT에 「패턴 2」 번호 없음
- `shared/` ↔ `.cursor/` sync 일치
