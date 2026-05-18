# `/start` · `/start-setting` — kit 연동 명령

**제품 레포 처음 연결(kit clone → PowerShell 1회 → 채팅):** [`product-onboarding.md`](product-onboarding.md#처음부터-3단계-완전-빈-제품)

채팅에 **`/start`** 로 시작하면, 훅이 kit `fetch`/`pull` 후 제품(또는 kit) `.cursor/`에 sync한다.

## 문법

| 명령 | 용도 | 빈도 |
|------|------|------|
| `/start-setting` | submodule·설정·훅·첫 sync **자동 온보딩** | 제품 레포 **1회** (또는 재설정) |
| `/start <지시>` | kit `pull` + sync 후 작업 | **매일** |

예:

```text
/start-setting
/start docs/requirements에 PRD 초안 작성
```

- `/start` 접두어는 **kit 갱신 트리거**이며, 에이전트는 갱신 요약을 확인한 뒤 **뒤쪽 지시만** 수행한다.
- [`AGENTS.md`](../../AGENTS.md) — 에이전트는 `.cursor/state/kit-start-last.json`을 먼저 읽는다.

## 동작 요약

| 단계 | 설명 |
|------|------|
| 1 | `beforeSubmitPrompt` → `kit-start-on-prompt.ps1` |
| 2 | [`scripts/Invoke-KitStart.ps1`](../../scripts/Invoke-KitStart.ps1) |
| 3 | `.cursor-kit.json`에 따라 git pull 대상·sync 범위 결정 |
| 4 | `.cursor/state/kit-start-last.json` 기록 |
| 5 | 실패 시 `continue: false` + `user_message` (**fail-closed**) |

## `.cursor-kit.json`

| 필드 | 설명 | 기본값 |
|------|------|--------|
| `kitPath` | kit 루트 (submodule 상대 경로 또는 `.`) | `vendor/cursor-workspace-kit` |
| `kitRepoMode` | `self` \| `submodule` \| `embedded` | `submodule` |
| `remote` | git remote 이름 | `origin` |
| `branch` | pull 브랜치 | `main` |
| `channel` | `A` \| `B` — 제품 sync 범위 | `B` |
| `harness` | (선택) shell·품질 게이트 설정 — [`harness-layer1.md`](harness-layer1.md) | 생략 시 off (`self`만 shellGuard 미지정 시 warn) |

### kitRepoMode

| 모드 | git pull 위치 | sync |
|------|---------------|------|
| **self** | 워크스페이스 루트 (kit 레포) | `sync-kit.ps1` |
| **submodule** | `kitPath` 폴더 | `sync-kit-product.ps1` |
| **embedded** | 워크스페이스 루트 (`shared/` 존재) | `sync-kit-product.ps1` |

## 채널 A / B (제품)

[`sync-kit-product.ps1`](../../scripts/sync-kit-product.ps1) — [`skills-agents-deploy.md`](skills-agents-deploy.md)와 동일 개념.

| channel | 제품 `.cursor/` 반영 | 전역 `~/.cursor` |
|---------|----------------------|------------------|
| **A** | `project-kit` rules(60·64·70) + `client-project-lifecycle` 스킬만 | skills·agents·공통 rules **유지** |
| **B** | `shared/` + `project-kit/` 전부 → rules·skills·agents | 중복 제거 권장 |

**이중 적용 방지 (A):** 제품 `.cursor/skills`에 `plan-feature` 등 공통 스킬을 넣지 않는다.

## Submodule (권장)

```powershell
git submodule add https://github.com/Hyun-Kim95/cursor-workspace-kit.git vendor/cursor-workspace-kit
```

clone: `git clone --recurse-submodules ...` 또는 `git submodule update --init`.

## kit 레포 vs 제품 레포 훅

| 레포 | hooks |
|------|--------|
| **cursor-workspace-kit** | sessionStart sync, Obsidian, delivery, **`/start`** |
| **제품** | **`/start` 훅만** (`project-kit/.cursor/hooks.json.example`) |

## sessionStart vs `/start`

| | sessionStart (`sync-kit-on-session`) | `/start` |
|--|--------------------------------------|----------|
| 시점 | 세션 시작 | 프롬프트 제출 직전 |
| git pull | 없음 (로컬 SSOT → `.cursor`) | **있음** (원격 최신) |
| 실패 | fail-open (세션 계속) | **fail-closed** |

## 수동 실행

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/Invoke-KitStart.ps1 -WorkspaceRoot .
```

## Windows PowerShell 5.1 · UTF-8

Cursor 훅은 Windows에서 기본 `powershell`(5.1)로 실행된다.

| 항목 | 조치 |
|------|------|
| `ConvertFrom-Json -Depth` | **사용 금지** (PS 7+ 전용). `scripts/Kit-HookCommon.ps1`의 `Read-HookStdinJson` 사용 |
| 한글 오류 깨짐 (`Ű` 등) | 훅 stdout을 **UTF-8**로 출력 (`Write-HookJson` / `Initialize-KitHookConsole`) |
| Cursor에 보이는 메시지 | 훅 catch는 가능하면 **영문** 안내 + `kit-start-last.json`(UTF-8 저장) 참조 |

`매개 변수 이름 'Depth'...` 가 깨져 보여도 본문은 위 Depth 오류일 수 있다. kit를 pull한 뒤 `Kit-HookCommon.ps1`이 있는지 확인한다.

## 관련 문서

- [product-onboarding.md](product-onboarding.md) — 제품 1회 설정·채널 A 마이그레이션
- [kit-inventory.md](kit-inventory.md) — 스크립트·상태 파일 목록
