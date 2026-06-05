# Agent Brief Template

## 0) Metadata (갱신 시 함께 수정)
- **Revision:** (예: v1, v2 또는 날짜)
- **Last updated:** (YYYY-MM-DD)
- **Owner:** (담당 또는 역할)
- **lifecyclePhase:** `mock` (단계 2·비교 목업) \| `implement` (디자인 선택 후·Gate 2+ 제품 구현)
- **Decisions this revision:** (이번 리비전에서 확정된 결약·결정을 3줄 이내로)

## 1) Goal
- 작업 목표를 한 문장으로 명확히 정의한다.

## 2) Scope
- 포함 범위:
  - 이번 작업에서 반드시 처리할 항목
- 비포함 범위:
  - 이번 작업에서 제외할 항목

## 3) Policies And Constraints
- 적용해야 할 규칙/정책
- 보안/권한/데이터 제약
- 성능/호환성/플랫폼 제약

## 4) Inputs
- 참고 문서 경로
- **선택안 링크/ID**(디자인 HUMAN 선택 후) + **제품 구현 경로**(라우트·모듈)
- 참고 코드/디자인 경로(목업은 스펙 근거만; `implement` 단계에서 mock-only만 다시 만들지 않음)
- 선행 조건(있다면): stage3 체크리스트, Gate 2

## 5) Expected Outputs
- 산출물 파일/모듈 (코드 변경 경로 또는 `docs/` SSOT md)
- **독립 검증 산출:** `docs/qa/verify-{날짜 또는 slug}.md` (`qa-agent` 채점·이슈 목록)
- 검증 결과(테스트/체크리스트)
- 사용자 전달용 요약

## 6) Done Criteria
- 기능/요구사항 충족 기준
- 상태 처리 기준(기본/로딩/빈/오류/권한)
- 회귀 위험 점검 기준
- **생성·검증 분리:** `qa-agent` **BLOCKER 0**, 불합격 항목 0 (판정은 메인이 재해석하지 않음)

## 7) Open Questions
- 현재 확정되지 않은 사항
- 작업 전에 확인이 필요한 의사결정

미결정이 스택·구조·도메인 등 **되돌리기 비싼 선택**에 닿으면, 여기에 **후보 옵션 2~3개**와 **추천 1개**(각 옵션 장단점 한 줄씩)를 적어 둔다. 사용자가 확정하면 **0) Metadata**의 `Decisions this revision`에 반영하고, Open Questions에서 해당 항목을 정리한다.

## 8) Handoff Notes
- 다음 담당자에게 전달할 핵심 변경점
- 알려진 제한/리스크

## 9) Verifier Handoff (생성·검증 분리)

메인이 산출을 마친 뒤 `qa-agent`에 넘길 때 아래만 전달한다. 생성 대화·작성 reasoning은 포함하지 않는다.

| 필드 | 내용 |
|------|------|
| `artifactPaths` | 검증 대상 파일·모듈 경로 (예: `docs/requirements/business-plan.md`, 변경된 `src/...`) |
| `rubricRef` | Gate 3, `docs/qa/reviewer-gate-rubric.md`, 작업별 체크리스트 경로 또는 요약 |
| `forbidden` | 금지 조건 (예: 칭찬·완화, 생성 맥락 참조, 산출물 수정) |

**코드 예:** 변경 파일 목록 + Gate 3·상태 UI 루브릭  
**문서 예:** `docs/requirements/business-plan.md` + 투자자 관점 체크리스트 + 항목별 0점 가능
