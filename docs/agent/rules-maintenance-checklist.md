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

## `integration-consumption-gate`·`60` Gate 3·stage3·kit 온보딩을 바꿀 때
- [ ] **생성/소비**·**첫 소비자**·**소비 증거** 용어가 `docs/qa/integration-consumption-gate.md`·`60` Gate 1 비고·Gate 3 불릿·`stage3-entry-checklist` §6·`product-onboarding` 소비 확인 절에서 **삼자 정합**인지
- [ ] mock-only 금지·제품 구현 경로 문구와 **생성-only 금지**가 모순 없이 읽히는지
- [ ] kit **4단계 소비 확인**과 **(선택) 5단계 AGENTS** 번호·역할이 `product-onboarding`에서 혼동 없는지
- [ ] `AGENTS.md` 게이트 요약·`start-feature`·`parallel-delivery`·`kit-start`·frontend/backend-agent 링크가 문서 SSOT를 가리키는지

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

## `21-app-version-update`·`docs/mobile/app-update`를 바꿀 때
- [ ] `20-web-vs-app`·스택/탐색 UX와 **중복 정의**하지 않았는지 (21은 버전 업데이트만)
- [ ] `60` Gate **조건**을 복붙·완화하지 않았는지 (brownfield는 **간이 점검** 링크만)
- [ ] `plan-feature`·`start-feature`·`release-check`·`verify-change`·`client-project-lifecycle` 링크가 docs 진입점과 일치하는지
- [ ] optional 배치: 앱 없는 제품에서 강제 적용 문구가 없는지 ([`rules-deploy.md`](rules-deploy.md))

## `22-product-analytics`·`docs/product-analytics`를 바꿀 때
- [ ] `product-monetization-default`·PII·결제 ID 배제와 **중복·모순** 없는지
- [ ] `60` Gate **조건**을 복붙·완화하지 않았는지 (brownfield는 **간이 점검** 링크만)
- [ ] `plan-feature`·`start-feature`·`release-check`·`verify-change`·`client-project-lifecycle`·`stage3-entry-checklist` 링크가 docs 진입점과 일치하는지
- [ ] optional 배치: PRD 측정=아니오·미명시 제품에서 강제 적용 문구가 없는지 ([`rules-deploy.md`](rules-deploy.md))

## `23-performance-gate`·`docs/performance`를 바꿀 때
- [ ] `20-web-vs-app`·UX 분기와 **중복 정의**하지 않았는지 (23은 측정·예산·perf-last만)
- [ ] `60` Gate **조건**을 복붙·완화하지 않았는지 (brownfield는 **간이 점검** 링크만)
- [ ] `plan-feature`·`start-feature`·`release-check`·`verify-change`·`client-project-lifecycle` 링크가 docs 진입점과 일치하는지
- [ ] `perf-last` 계약이 `docs/qa/perf-last.example.json`·`Invoke-PerfGate.ps1`과 일치하는지
- [ ] optional 배치: PRD 성능 게이트=아니오·미명시 제품에서 강제 적용 문구가 없는지 ([`rules-deploy.md`](rules-deploy.md))

## User Rules UI와 중복
- [ ] 채널 B 사용 시 User Rules에 동일 블록이 남아 있지 않은지 ([`rules-deploy.md`](rules-deploy.md))

## rule-candidates 승격 (배치·신호 훅 후보 → SSOT)

- [ ] 후보 `rule_text`가 **검증 가능한 의무** 문장인지(사용자 불만 문장 그대로 아님)
- [ ] `suggested_target`에 맞는 **SSOT 경로**만 편집 (`shared/skills`, `shared/rules`, `AGENTS.md` 직접 처리 예외 등) — [`rule-candidates.md`](rule-candidates.md)
- [ ] kit 템플릿 레포에서는 `.cursor/rules/90-runtime-rule-*.mdc` 대신 `shared/*` + `sync-kit.ps1` 우선
- [ ] `docs/agent/kit-inventory.md`·해당 스킬 Gate 참조가 모순 없는지

## shared/skills·agents를 바꿀 때
- [ ] `docs/agent/kit-inventory.md` 표가 최신인지
- [ ] `AGENTS.md`·`60`/`64`·`client-project-lifecycle`과 스킬 **이름**·Gate 참조가 모순 없는지
- [ ] `sync-kit.ps1` 실행 후 `.cursor/skills`·`.cursor/agents` 반영됐는지

## import-from-user-cursor 사용 시
- [ ] `client-project-lifecycle`이 project-kit SSOT를 덮지 않았는지 (스크립트 제외 목록)
- [ ] import 후 반드시 `sync-kit.ps1`

## 채널 B — ~/.cursor 중복
- [ ] kit과 동일 스킬·에이전트가 `~/.cursor`에 남아 있지 않은지 ([`skills-agents-deploy.md`](skills-agents-deploy.md))
