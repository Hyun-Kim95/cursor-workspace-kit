# Rules context notes

규칙 **편집 SSOT**는 `shared/rules/`, `shared/optional/`, `project-kit/.cursor/rules/`이다.  
이 워크스페이스의 [`.cursor/rules/`](../../.cursor/rules/)는 [`scripts/sync-rules.ps1`](../../scripts/sync-rules.ps1) 산출물이며 Cursor 로드용이다.

배포·중복 방지: [`rules-deploy.md`](rules-deploy.md) · 인벤토리: [`kit-inventory.md`](kit-inventory.md)

## 한 줄 요약 (파일 → 목적)

### shared/rules

| 파일 | 한 줄 목적 |
|------|------------|
| `product-ui-core-global.mdc` | 상태 UI·접근성·공통 UX 최소 원칙 |
| `emergent-rule-capture-global.mdc` | 운영 규칙 후보 수집·승인 후 SSOT 반영 |
| `working-principles.mdc` | 실행 계획·분담·HUMAN·DoD·커밋 안전·게이트 경계 |
| `20-web-vs-app.mdc` | 웹 테이블/명시 탐색 vs 앱 스크롤·리스트 |
| `30-table-pagination.mdc` | 테이블 필터·15건·하단 페이지네이션 |
| `40-dark-mode.mdc` | 다크/라이트·토큰·대비·전환 유지 |
| `50-index-css-contract.mdc` | 전역 스타일·Stitch 등 합의 |
| `65-design-gate.mdc` | 디자인 선행·이중 안·병렬 조건 |

### shared/optional

| 파일 | 한 줄 목적 |
|------|------------|
| `locale-ko.mdc` | 에이전트 응답 한국어 (선택) |

### project-kit/.cursor/rules

| 파일 | 한 줄 목적 |
|------|------------|
| `60-delivery-gates.mdc` | Gate 1~3, 병렬 조건, DoD |
| `64-context-organization.mdc` | 맥락 정리(3단) 러브릭; Gate/적용·HUMAN 권한은 60/70 |
| `70-client-lifecycle-default.mdc` | 고객 E2E·디자인 승인 시 구현 착수 승인 통합 |

### 기타

| 경로 | 한 줄 목적 |
|------|------------|
| `AGENTS.md` (루트) | 총괄·직접 처리 예외 SSOT |
| `docs/agent/delivery-loop-harness.md` | 고객 프로젝트 단계 3 이후 선택: 훅·테스트 루프 |

총괄 오케스트레이션과 **직접 처리 가능한 예외** 목록(SSOT)은 저장소 루트의 `AGENTS.md`를 본다.
