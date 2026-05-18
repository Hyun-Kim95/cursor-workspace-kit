# Rules maintenance checklist

규칙을 수정할 때 아래를 짧게 확인한다.

**편집 위치:** `shared/rules/`, `shared/optional/`, `project-kit/.cursor/rules/` 만.  
**스킬:** `shared/skills/`, `project-kit/.cursor/skills/` 만.  
**에이전트:** `shared/agents/` 만.  
수정 후 `powershell -NoProfile -File scripts/sync-kit.ps1` 실행 (또는 `sync-rules.ps1` / `sync-skills.ps1` / `sync-agents.ps1` 개별).  
[`.cursor/rules/`](../../.cursor/rules/), [`.cursor/skills/`](../../.cursor/skills/), [`.cursor/agents/`](../../.cursor/agents/) 직접 편집 금지.

## shared/rules·optional을 바꿀 때
- [ ] 실행 계획/분담/미확정 의사결정 문구가 `AGENTS.md` 운영 원칙과 모순 없는지
- [ ] 출력/완료 판정 문구가 스킬 문서(`start-feature`, `client-project-lifecycle`)와 모순 없는지
- [ ] `docs/agent/kit-inventory.md` 표가 최신인지
- [ ] sync 실행 후 `.cursor/rules`에 반영됐는지

## `.cursor-kit.json` / harness를 바꿀 때
- [ ] `harness` 기본값·fail-open이 `AGENTS.md` 우선순위·`60` Gate·`70` HUMAN과 모순 없는지
- [ ] [`docs/agent/harness-layer1.md`](harness-layer1.md)·[`kit-inventory.md`](kit-inventory.md)·example JSON이 함께 갱신됐는지
- [ ] `Get-KitHarnessConfig` 변경 시 `scripts/Test-KitHarnessConfig.ps1` 실행
- [ ] harness 훅(`shared/hooks`) 변경 시 `sync-hooks.ps1` 후 `Test-GuardShellHarness.ps1` · `Test-QualityGateHarness.ps1` 실행

## `AGENTS.md`를 바꿀 때
- [ ] 우선순위 순서가 `60`·`70` 및 `shared/rules/working-principles.mdc`와 어긋나지 않는지
- [ ] **정책 출처(SSOT)** 절이 `working-principles.mdc`(계획/분담)와 본 파일(직접 처리 목록) 역할 분담과 어긋나지 않는지
- [ ] “직접 처리 가능한 예외” 섹션과 `60` Gate 1 적용 범위가 함께 읽혀도 되는지

## `65-design-gate`·`client-project-lifecycle`·`frontend-agent`를 바꿀 때
- [ ] **선택 후 목업 금지**·**제품 구현** 문구가 `70`·`60` Gate 2 비고·`stage3-entry-checklist`·`parallel-delivery` / `start-feature`와 모순 없는지
- [ ] `70`·lifecycle **HUMAN 우선**·디자인 승인=구현 착수 문구가 바뀌지 않았는지

## `60-delivery-gates.mdc`를 바꿀 때 (project-kit SSOT)
- [ ] Gate 1 면제 문구가 `AGENTS.md` **직접 처리 가능한 예외** 섹션(SSOT)만 가리키고, 목록 확장을 다른 파일로 새지 않았는지
- [ ] `AGENTS.md`의 게이트 요약·Gate 1 적용 범위 이해와 충돌 없는지
- [ ] `70-client-lifecycle-default.mdc`·`AGENTS.md` 고객 프로젝트 절차와 모순 없는지
- [ ] Gate 1 `비고`( `64` / `context-organization` )와 문구가 함께 읽혀도 Gate **조건**이 바뀌는 것이 아님이 분명한지
- [ ] project-kit 수정 후 sync 실행

## `64-context-organization.mdc`를 바꿀 때
- [ ] `60`의 Gate 1/2/3 **정의·적용**을 **복붙**하거나 완화하지 않았는지(경계·용어·권한만)
- [ ] `70`·`client-project-lifecycle` HUMAN **우선**·`context-organization` **선행**이 모순 없이 읽히는지
- [ ] User-level skill `context-organization`·`plan-feature`·`AGENTS`와 **중복** 정의 늪이 없는지

## 새 규칙 파일을 추가할 때
- [ ] SSOT 경로(`shared/` 또는 `project-kit/`)에만 추가
- [ ] `docs/agent/kit-inventory.md`·`rules-context-notes.md` 표에 행 추가
- [ ] `alwaysApply`·`description` 의도 명확한지
- [ ] sync 실행

## `.cursor/skills`에 `context-organization` 등 **선행 러브릭** 스킬을 바꿀 때
- [ ] `64`·`60`·`plan-feature`와 **Gate/조건**이 이중·모순 정의되지 않는지(위임·링크 위주)
- [ ] 고객 HUMAN: `70` + `client-project-lifecycle` **우선** 문장 유지

## 완료 루프 하네스(`delivery-loop`) 훅·스크립트를 바꿀 때
- [ ] `docs/agent/delivery-loop-harness.md`·`client-project-lifecycle`의 **선택** 절과 **HUMAN 비변** 문구가 모순 없는지
- [ ] 훅이 **차단(exit 1)** 으로 바뀌면 `working-principles.mdc` 출력/완료 규칙과 `AGENTS` 우선순위에 대한 운영 합의가 있는지

## User Rules UI와 중복
- [ ] 채널 B 사용 시 User Rules에 동일 블록이 남아 있지 않은지 ([`rules-deploy.md`](rules-deploy.md))

## shared/skills·agents를 바꿀 때
- [ ] `docs/agent/kit-inventory.md` 표가 최신인지
- [ ] `AGENTS.md`·`60`/`64`·`client-project-lifecycle`과 스킬 **이름**·Gate 참조가 모순 없는지
- [ ] `sync-kit.ps1` 실행 후 `.cursor/skills`·`.cursor/agents` 반영됐는지

## import-from-user-cursor 사용 시
- [ ] `client-project-lifecycle`이 project-kit SSOT를 덮지 않았는지 (스크립트 제외 목록)
- [ ] import 후 반드시 `sync-kit.ps1`

## 채널 B — ~/.cursor 중복
- [ ] kit과 동일 스킬·에이전트가 `~/.cursor`에 남아 있지 않은지 ([`skills-agents-deploy.md`](skills-agents-deploy.md))
