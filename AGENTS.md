# AGENTS

## 목적

이 프로젝트의 메인 에이전트는 요청을 분석하고, 적절한 Rules, Skills, Subagents를 선택해 작업을 진행한다.

이 파일은 총괄 오케스트레이션만 담당한다.
세부 정책은 `.cursor/rules/`( [`scripts/sync-kit.ps1`](scripts/sync-kit.ps1) 중 rules; SSOT는 `shared/rules/`, `project-kit/.cursor/rules/`), 작업 절차는 [`shared/skills/`](shared/skills/)(sync 후 `.cursor/skills/`) 및 [`project-kit/.cursor/skills/client-project-lifecycle/`](project-kit/.cursor/skills/client-project-lifecycle/), 역할별 전문 범위는 [`shared/agents/`](shared/agents/)(sync 후 `.cursor/agents/`)에서 관리한다.

## 정책 출처(SSOT)

- 실행 계획 형식, 라이트/풀 선택, 분담 임계치·서브 타입 매핑·재계획: [`shared/rules/working-principles.mdc`](shared/rules/working-principles.mdc)가 SSOT다.
- **직접 처리 가능한 예외**의 목록(아래 해당 섹션)은 **본 파일이 SSOT**다. 다른 규칙·스킬은 목록을 늘리지 않고 이 섹션을 가리킨다.

## 운영 원칙

- 공통 작업 원칙(계획/출력/커밋 안전/완료 보고)은 `shared/rules/working-principles.mdc`를 기본으로 적용한다.
- 이 파일은 오케스트레이션, 역할 분담, 우선순위, 직접 처리 예외 목록 같은 **프로젝트 로컬 SSOT**만 다룬다.
- 실행 계획 상세 형식과 재계획 트리거는 `shared/rules/working-principles.mdc`를 따른다.
- UI가 포함된 신규 기능은 디자인 산출물(화면/상태/반응형/다크모드) 승인 전 코드 구현 또는 병렬구현을 시작하지 않는다.
- 사용자가 "다음 작업"을 물었을 때 UI 변경 범위의 디자인 산출물이 없으면 구현보다 디자인 작업을 우선 제안한다.
- 이중 디자인안을 요구하는 범위에서는 안 A(로컬 목업)와 안 B(Stitch 또는 동등 도구)를 준비하고, 비교표와 선택 사유를 기록한 뒤에만 구현으로 넘어간다.
- 이중 디자인안 범위의 기본 순서는 **A/B 병렬 동시 작성 → 동시 제시·비교 → HUMAN 선택/승인**이며, 승인 전 구현으로 넘어가지 않는다.
- `start-feature`·`plan-feature`·`parallel-delivery`·`verify-change`·`document-change`·`bugfix-flow`·`release-check`·`context-organization` 등 공통 스킬은 `shared/skills/`(sync 후 `.cursor/skills/`)를 우선 사용한다.
- 고객 프로젝트형 게이트/승인 흐름은 `.cursor/rules/60-delivery-gates.mdc`, `.cursor/rules/70-client-lifecycle-default.mdc`를 따른다.
- UI 병렬구현은 디자인 승인 + API 계약 고정이 완료된 뒤에만 허용한다.
- 같은 내용을 Rules, Skills, Agents 파일에 중복 정의하지 않는다.
- 규칙이 많을 때의 초점 맞추기·한 줄 요약은 `docs/agent/rules-context-notes.md`를 참고한다. **항상/상황별/권장 강제 수준**은 읽기용 [`docs/agent/enforcement-matrix.md`](docs/agent/enforcement-matrix.md)를 참고한다(SSOT 아님).
- 규칙·스킬·에이전트 파일을 고칠 때의 정합 점검은 `docs/agent/rules-maintenance-checklist.md`를 참고한다. SSOT·배포는 `docs/agent/kit-inventory.md`, `docs/agent/rules-deploy.md`, `docs/agent/skills-agents-deploy.md`를 본다.
- 텍스트 파일(문서·설정·소스)은 `shared/rules/encoding-utf8-global.mdc`와 `docs/agent/encoding.md`에 따라 **UTF-8(BOM 없음 기본)** 로 저장한다.
- 계획·PRD·범위 정리 시 수익·사업자 전제는 `shared/rules/product-monetization-default.mdc`와 `docs/agent/product-assumptions.md`를 따른다(기본: 사업자 없음, 광고·후원만).

## 규칙 우선순위 (충돌 시)

아래 순서를 기본으로 해석한다(위가 더 우선).

1. 사용자가 대화에서 **명시한 지시**(범위·예외·긴급도 포함)
2. **안전·보안·민감정보** 보호(유출 방지, 권한, 비밀 커밋 방지 등)
3. `.cursor/rules/70-client-lifecycle-default.mdc`에 따른 **고객 프로젝트 흐름** 중 스킬이 정한 **HUMAN·승인·멈춤** 구간
4. `.cursor/rules/60-delivery-gates.mdc`의 **Gate** 조건(신규 기능·대외 API 등에 적용; Gate 1 적용 범위는 해당 파일의 설명을 따른다)
5. `shared/rules/working-principles.mdc`의 **실행 계획/출력 계약** 형식
6. 그 외 제품 UI·스타일·테이블 등 나머지 `.cursor/rules/`

**충돌 시 행동:** 우선순위를 스스로 판단하기 어렵거나 구현이 멈출 수 있으면, **구현을 잠시 멈추고** 짧은 **확인 질문 1~2개**를 먼저 한다.

## 역할 분담 기준

- UI, 반응형, 마크업, 화면 동작, 스타일, 접근성: `frontend-agent`
- API, DB, 서비스, 인증, 권한, 파일 처리: `backend-agent`
- 요구사항 정리, 정책 설계, 화면/기능 범위 정의: `prd-agent`
- 구현 결과 검증, 회귀 점검, 체크리스트 기반 확인: `qa-agent`
- 작업 내역 정리, 변경사항 문서화, README/인수인계: `docs-agent`
- 디자인 토큰, 테마, 다크모드, 컴포넌트 일관성: `design-system-agent`

위 이름은 **역할·전문 범위·체크리스트**를 가리킨다. 실행 환경에 별도 서브에이전트 세션이 없을 수 있으며, 그 경우 **메인 에이전트가 동일 범위를 수행**한다. 실행 계획에는 그대로 **담당(역할)**과 **그 역할을 택한 이유**를 적는다.

서브에이전트·병렬 작업 시 컨텍스트를 맞추려면 `docs/agent/agent-brief.md` 템플릿을 쓴다. 요구사항 변경, API 계약 변경, 병렬 중 상대방 산출물이 바뀌면 해당 브리프의 메타·관련 섹션을 **갱신**한다.

## 재사용 최소 복사 세트

다른 프로젝트에 동일 규칙을 적용할 때는 아래를 최소 세트로 복사한다. 상세는 `project-kit/README.md`, `docs/agent/rules-deploy.md`.

- `AGENTS.md` (운영 원칙·역할 분담·우선순위·**직접 처리 예외 목록 SSOT**)
- `project-kit/.cursor/rules/60-delivery-gates.mdc`, `70-client-lifecycle-default.mdc` (고객 프로젝트형; 64 권장)
- 공통 UX·작업 원칙: `shared/rules/` 전체를 User Rules 또는 제품 `.cursor/rules`에 배포

## 게이트/병렬/완료 기준

- Gate 1~3, 병렬 조건, DoD는 `.cursor/rules/60-delivery-gates.mdc`를 SSOT로 따른다. **ATDD-lite**(PRD AC → Gate 2 후 RED acceptance test → 구현 GREEN) 상세: [`docs/qa/atdd-lite.md`](docs/qa/atdd-lite.md).
- 디자인 승인과 구현 착수 승인 통합 규칙은 `.cursor/rules/70-client-lifecycle-default.mdc`를 따른다.
- 고객 E2E에서 **디자인 선택 후**는 [`docs/qa/stage3-entry-checklist.md`](docs/qa/stage3-entry-checklist.md) → Gate 2 → **ATDD-lite RED** → 구현(`parallel-delivery` / `start-feature`)이며, **선택 후 mock-only 재목업은 기본 금지**(예외는 사용자 명시·문서 기록).
- **횡단 자산**(공유 패키지·kit·내부 SDK 등)은 **생성**과 **소비** 완료를 분리한다. Gate 3·소비 증거: [`docs/qa/integration-consumption-gate.md`](docs/qa/integration-consumption-gate.md).
- 본 파일에는 게이트 세부 불릿을 중복 정의하지 않는다.
- 검증 구간에서 [`.cursor/state/quality-gate-last.json`](.cursor/state/quality-gate-last.json)이 있고 `ok`가 `false`이면 해당 변경에 대해 **완료·검증 완료 선언을 하지 않는다** ([`docs/agent/harness-layer1.md`](docs/agent/harness-layer1.md)).

## `/start-setting` (제품 레포 1회 온보딩)

사용자 메시지가 **`/start-setting` 또는 `/kit-start-setting`으로 시작**하거나 스킬 **`start-setting`** 으로 온보딩이 요청되면(예: `/start-setting`):

1. 훅이 [`scripts/Invoke-KitStartSetting.ps1`](scripts/Invoke-KitStartSetting.ps1)을 실행한다 — submodule 추가(필요 시), `.cursor-kit.json`, `/start` 훅, `hooks.json`, 첫 sync까지 자동.
2. **먼저** [`.cursor/state/kit-start-setting-last.json`](.cursor/state/kit-start-setting-last.json)을 읽고 요약을 확인한다.
3. 훅이 없을 때는 kit clone에서 수동 1회: `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/Invoke-KitStartSetting.ps1 -WorkspaceRoot <제품경로>`

이후 일상 작업은 **`/start <할 일>`** 또는 **`/kit-start <할 일>`**(자동완성·스킬 `kit-start`)을 사용한다. **`start-feature`·`kit-start`와 혼동하지 않는다.**

과거 대화에서 운영 규칙 후보를 배치 집계할 때는 스킬 **`kit-rule-mine`** 또는 **`/kit-rule-mine`**(·`/rule-mine`)을 사용한다. 상세: [`docs/agent/rule-candidates.md`](docs/agent/rule-candidates.md).

## `/start` · `/kit-start` (kit 최신화)

사용자 메시지가 **`/start` 또는 `/kit-start`로 시작**하거나 스킬 **`kit-start`** 로 kit 갱신이 요청되면(예: `/start docs/requirements에 PRD 초안`):

1. 훅이 [`scripts/Invoke-KitStart.ps1`](scripts/Invoke-KitStart.ps1)을 실행해 kit GitHub `fetch`/`pull` 및 sync를 수행한다. 실패 시 프롬프트는 **차단**(fail-closed)된다.
2. **먼저** [`.cursor/state/kit-start-last.json`](.cursor/state/kit-start-last.json)을 읽고 `ok`, `message`, `pulled`, `channel` 등 pull·sync 요약을 한 줄로 확인한다.
3. 그다음 **접두어(`/start`, `/kit-start`) 뒤에 이어진 지시만** 수행한다(접두어 자체는 작업 지시가 아님).

제품 레포·채널 A/B·submodule 설정: [`docs/agent/kit-start.md`](docs/agent/kit-start.md), [`docs/agent/product-onboarding.md`](docs/agent/product-onboarding.md).

## `/kit-wiki` · `/kit-wiki-ask` (LLM 위키)

AI 대화·리서치·결정을 `docs/wiki/`(LLM 위키)로 정제 저장하고 다시 꺼내 쓰는 지식 관리. 스킬 **`kit-wiki`**.

- **`/kit-wiki <자료/주제>`** — 정제 저장(ingest) + **증분 lint**. 노트는 `docs/wiki/<topic>.md`, 원본은 `docs/wiki/_raw/`(gitignore). redaction(경로/이메일/키 마스킹) 필수.
- **`/kit-wiki lint`** — `docs/wiki/` 전체 정합성 점검만.
- **`/kit-wiki-ask <질문>`** — 위키 기반 **읽기 전용** 답변(파일 미수정).
- 커밋은 사용자 명시 시에만(`_raw/`는 커밋 금지).

**`kit-rule-mine`과 경계:** `kit-wiki`는 **지식**(무엇을 결정했나)을 쌓고, `kit-rule-mine`은 **규칙 후보**(에이전트가 어떻게 일할지)를 모아 HUMAN 승인 후 `shared/rules`로 승격한다. 위키 노트는 규칙이 아니다. 상세: [`docs/wiki/README.md`](docs/wiki/README.md).

## 기본 진입 규칙

- 고객사 **전체 프로젝트(엔드투엔드)** 대화는 사용자가 스킬 이름을 말하지 않아도 `.cursor/rules/70-client-lifecycle-default.mdc`에 따라 `client-project-lifecycle`을 따른다(PRD·디자인 등 HUMAN 구간에서 멈춤). 단, **디자인 승인 완료 시점은 구현 착수 승인으로 간주**하며 구현 시작에 대한 중복 승인을 추가로 요구하지 않는다. 구현 이후 **다축 검증·리뷰어 GATE**는 해당 스킬 **단계 4B~4D(선택)** 및 `docs/qa/reviewer-gate-rubric.md`를 참고한다.
- 고객사 신규 프로젝트를 **요구 붙여넣기 → PRD 승인 → 이중 목업 → 디자인 승인(=구현 착수 승인) → ATDD-lite RED → 병렬 구현 → 테스트·성능** 순으로 끝까지 진행하려면 `client-project-lifecycle`을 우선 고려한다.
- 신규 기능 요청이면 `start-feature`를 우선 고려한다. (Gate 1 통과 후; UI+API 병렬이면 Gate 2 → **ATDD-lite RED** 후 `parallel-delivery` 병행)
- 버그 수정 요청이면 `bugfix-flow`를 우선 고려한다.
- 요구사항이 모호하거나 기획 정리가 먼저 필요하면 `plan-feature`를 우선 고려한다. (같은 선행을 3단 러브릭으로 쪼개려면 `context-organization`을 쓸 수 있으며, 둘 다 `60`·`70`·`75`·`AGENTS`에 종속이고, 러프한 아이디어/기획·스펙 부재일 때는 `plan-feature`·`context-organization` → Gate 1 충족 시 `start-feature` 순을 따른다.)
- 구현 후 품질 확인이 필요하면 `verify-change`를 사용한다. (Gate 3 종료 검증)
- **생성·검증 분리(기본):** 메인이 산출(코드·`docs/` 문서) → `qa-agent` 독립 검증(파일·루브릭만 handoff, [`docs/agent/agent-brief.md`](docs/agent/agent-brief.md) 9절) → 메인은 판정 인용만. self-verify·검증 완료 선언은 메인 금지. 상세: `start-feature`·`verify-change`·`qa-agent`.
- 변경사항 공유나 문서 정리가 필요하면 `document-change`를 사용한다. (병렬 중 계약 변경 시에도 수시 적용)
- 세션·하루 마무리 시 작업 일지가 필요하면 `kit-work-log` 또는 `/kit-work-log`를 사용한다. (`docs/work-log/YYYY-MM-DD.md`)
- 대화·리서치·결정을 지식으로 정제·축적하거나(`/kit-wiki`) 위키 기반으로 다시 꺼내 쓰려면(`/kit-wiki-ask`) `kit-wiki`를 사용한다. (`docs/wiki/`; 규칙 후보 수집인 `kit-rule-mine`과 다름)
- 배포 전 확인이 필요하면 `release-check`를 사용한다.

## 직접 처리 가능한 예외

(SSOT: 이 목록만 확장·수정한다. 라이트 템플릿 적합 여부 등은 `shared/rules/working-principles.mdc`에서 본 섹션을 참조한다.)

아래와 같은 매우 작은 작업은 메인 에이전트가 직접 처리할 수 있다.

- 오탈자 수정
- 문구 수정
- 주석 수정
- 단순 링크 수정
- 명백한 단일 파일 소규모 스타일 조정

## 다중 작업 처리 원칙

하나의 요청에 여러 관심사가 섞여 있으면 역할별로 나눠 처리한다.
예:

- 화면 + API 변경: `frontend-agent` + `backend-agent`
- 기능 추가 + 요구사항 애매함: `plan-feature` 후 `start-feature`
- 고객사 전체 프로젝트 라이프사이클: `client-project-lifecycle`
- Gate 2 충족 → **ATDD-lite RED** 후 UI+API 동시 진행: `parallel-delivery` (`frontend-agent` + `backend-agent`)
- 구현 완료 + QA 필요: `verify-change`
- 수정 완료 + 전달 문서 필요: `document-change`

## 분담 임계치

- 분담 판단/서브 타입 매핑은 `shared/rules/working-principles.mdc`를 SSOT로 따른다.

## 금지사항

- Rules에 적힌 전역 정책을 Skills에 반복해서 장황하게 복붙하지 않는다.
- Agent 파일에 프로젝트 전역 정책을 중복 정의하지 않는다.
- 충분한 근거 없이 구조를 전면 개편하지 않는다.
- 필요한 기준 파일이 없는데도 임의로 설계를 확정하지 않는다.
- 웹/앱 차이를 무시하고 동일 UX를 강제하지 않는다.

