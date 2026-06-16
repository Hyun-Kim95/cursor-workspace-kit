# cursor-workspace-kit

Cursor용 **에이전트·rules·skills·hooks** 템플릿 저장소입니다. 제품 앱 코드가 아니라, 다른 프로젝트에서 가져다 쓰는 **kit SSOT**입니다.

## kit 레포에서 작업 (템플릿 개발)

이 저장소를 **워크스페이스로 열어** rules·skills를 편집할 때:

```powershell
git clone https://github.com/Hyun-Kim95/cursor-workspace-kit.git
cd cursor-workspace-kit
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\sync-kit.ps1
```

Cursor에서 **이 폴더**를 연다. `sessionStart` 훅이 있으면 세션 시작 시 `sync-kit`이 자동 실행될 수 있다.

채팅 **`/start`** — 이 레포에서 `git pull` 후 sync. 상세: [`docs/agent/kit-start.md`](docs/agent/kit-start.md).

---

## 제품 레포에 kit 붙이기 (앱 프로젝트)

`dietManagement` 같은 **제품 레포**에 연동할 때. Cursor 워크스페이스는 **제품 폴더**를 연다 (kit 폴더가 아님).

**전체 절차(SSOT):** [`docs/agent/product-onboarding.md`](docs/agent/product-onboarding.md#처음부터-3단계-완전-빈-제품)

```powershell
# 1) kit 템플릿 clone (PC당 1회, 위와 동일)
git clone https://github.com/Hyun-Kim95/cursor-workspace-kit.git
cd cursor-workspace-kit

# 2) 제품 자동 설정 (1회) — sync-kit.ps1 이 아님
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\Invoke-KitStartSetting.ps1 -WorkspaceRoot D:\path\to\my-product
```

```text
# 3) Cursor에서 제품 폴더 연 뒤
/start-setting
# 이후 매일
/start <할 일>
```

| 구분 | kit 레포 | 제품 레포 |
|------|----------|-----------|
| 2단계 스크립트 | `sync-kit.ps1` | `Invoke-KitStartSetting.ps1` |
| Cursor로 여는 폴더 | `cursor-workspace-kit` | `my-product` |
| 매일 채팅 | `/start` (kit 레포 안) | `/start` (제품 레포 안) |

---

## SSOT 구조

| 경로 | 내용 |
|------|------|
| `shared/rules/`, `shared/skills/`, `shared/agents/` | 공통 rules·skills·agents |
| `project-kit/` | 고객 게이트 rules(60·64·70), `client-project-lifecycle` 스킬 |
| `AGENTS.md` | 오케스트레이션 |
| `.cursor/rules|skills|agents/` | **sync 산출물** — 직접 편집하지 말고 SSOT 수정 후 sync |

## 스크립트

| 스크립트 | 용도 |
|----------|------|
| `scripts/sync-kit.ps1` | kit 레포: rules + skills + agents 일괄 sync |
| `scripts/Invoke-KitStartSetting.ps1` | 제품 1회: submodule·훅·`.cursor-kit.json`·첫 sync |
| `scripts/Invoke-KitStart.ps1` | `/start`: git pull + sync |
| `scripts/sync-kit-product.ps1` | 제품 `.cursor/` 채널 A/B sync |
| `scripts/import-from-user-cursor.ps1 -Force` | `~/.cursor` → `shared/` (최초·재동기화) |
| `scripts/Test-KitHarnessConfig.ps1` | (선택) Layer 1 harness 설정 검증 |

선택 하네스(shell·품질 게이트): [`docs/agent/harness-layer1.md`](docs/agent/harness-layer1.md)  
작업 흐름(인터랙티브): [`docs/agent/workflow-overview.html`](docs/agent/workflow-overview.html)

문서에 나오는 PowerShell 예시는 Windows에서 훅과 동일하게 **`-ExecutionPolicy Bypass`** 를 붙인다.

## 배포 (채널 B — 로컬만)

- [`docs/agent/rules-deploy.md`](docs/agent/rules-deploy.md)
- [`docs/agent/skills-agents-deploy.md`](docs/agent/skills-agents-deploy.md)
- [`docs/agent/kit-inventory.md`](docs/agent/kit-inventory.md)
- [`docs/agent/enforcement-matrix.md`](docs/agent/enforcement-matrix.md) — 규칙·Gate **강제 수준** (항상/상황별/권장, 읽기용)

전역 `~/.cursor/skills`·`agents`·User Rules와 **중복되지 않게** 정리하세요.

## Obsidian (선택)

`_config/obsidian-repos.example.json`을 복사해 `_config/obsidian-repos.json`을 만든 뒤 로컬 경로를 수정합니다. (`obsidian-repos.json`은 git에 포함되지 않습니다.)

## 버전

[CHANGELOG.md](CHANGELOG.md) — `v0.1.0-rules`, `v0.2.0-skills-agents`, `v0.3.0-kit-start`
