# Rules context notes

규칙 **편집 SSOT**는 `shared/rules/`, `shared/optional/`, `project-kit/.cursor/rules/`이다.  
이 워크스페이스의 [`.cursor/rules/`](../../.cursor/rules/)는 [`scripts/sync-rules.ps1`](../../scripts/sync-rules.ps1) 산출물이며 Cursor 로드용이다.

배포·중복 방지: [`rules-deploy.md`](rules-deploy.md) · 인벤토리: [`kit-inventory.md`](kit-inventory.md) · **강제 수준(항상/상황별/권장):** [`enforcement-matrix.md`](enforcement-matrix.md)

## 한 줄 요약 (파일 → 목적)

### shared/rules

| 파일 | 한 줄 목적 |
|------|------------|
| `product-ui-core-global.mdc` | 상태 UI·접근성·공통 UX 최소 원칙 |
| `emergent-rule-capture-global.mdc` | 운영 규칙 후보 수집·승인 후 SSOT 반영 → 절차 [`rule-candidates.md`](rule-candidates.md) |
| `working-principles.mdc` | 실행 계획·분담·HUMAN·DoD·커밋 안전·게이트 경계·조사·소통·실패 대응·DB 운영 기본값 |
| `20-web-vs-app.mdc` | 웹 테이블/명시 탐색 vs 앱 스크롤·리스트·신규 모바일 스택 기본값 |
| `30-table-pagination.mdc` | 테이블 필터·15건·하단 페이지네이션 |
| `40-dark-mode.mdc` | 다크/라이트·토큰·대비·전환 유지 |
| `50-index-css-contract.mdc` | 전역 스타일·Stitch 등 합의 |
| `65-design-gate.mdc` | 디자인 선행·이중 안·병렬 조건 |

### shared/optional

| 파일 | 한 줄 목적 |
|------|------------|
| `locale-ko.mdc` | 에이전트 응답 한국어 (선택) |
| `21-app-version-update.mdc` | 모바일 앱 버전 업데이트 권장/강제 (선택) |
| `22-product-analytics.mdc` | 제품 분석·이벤트 추적 (선택, PRD 측정=예) |
| `23-performance-gate.mdc` | 성능 게이트 web/app/api (선택, PRD 성능 게이트=예) |
| `24-security-gate.mdc` | 보안 게이트 6축·strict (선택, PRD 보안 게이트=예) |

### project-kit/.cursor/rules

| 파일 | 한 줄 목적 |
|------|------------|
| `60-delivery-gates.mdc` | Gate 1~3, 병렬 조건, DoD, ATDD-lite |
| `64-context-organization.mdc` | 맥락 정리(3단) 러브릭; Gate/적용·HUMAN 권한은 60/70 |
| `70-client-lifecycle-default.mdc` | 고객 E2E·디자인 승인 시 구현 착수 승인 통합 |

### 기타

| 경로 | 한 줄 목적 |
|------|------------|
| `AGENTS.md` (루트) | 총괄·직접 처리 예외 SSOT |
| `docs/agent/delivery-loop-harness.md` | 고객 프로젝트 단계 3 이후 선택: 훅·테스트 루프 |
| `docs/qa/atdd-lite.md` | ATDD-lite SSOT (PRD AC → RED → GREEN) |
| `docs/qa/acceptance-criteria.template.md` | PRD 수용 기준(AC) 표 템플릿 |
| `docs/qa/atdd-lite-consumption-checklist.md` | 제품 레포 ATDD-lite 소비 증거 체크리스트 |
| `docs/qa/atdd-lite-consumption-record-example.md` | ATDD-lite 소비 기록 예시 |
| `docs/mobile/app-update/` | 앱 버전 업데이트 템플릿 (정책·API·체크리스트) |
| `docs/product-analytics/` | 제품 분석·이벤트 추적 템플릿 (PRD·계약·체크리스트) |
| `docs/performance/` | 성능 게이트 템플릿 (web/app/api·perf-budget·perf-last) |
| `docs/security/` | 보안 게이트 템플릿 (6축·security-policy·security-last·strict) |

총괄 오케스트레이션과 **직접 처리 가능한 예외** 목록(SSOT)은 저장소 루트의 `AGENTS.md`를 본다.
