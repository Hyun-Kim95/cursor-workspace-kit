# cursor-workspace-kit

Cursor용 **에이전트·rules·skills·hooks** 템플릿 저장소입니다. 제품 앱 코드가 아니라, 다른 프로젝트에서 가져다 쓰는 **kit SSOT**입니다.

## 빠른 시작

```powershell
git clone https://github.com/Hyun-Kim95/cursor-workspace-kit.git
cd cursor-workspace-kit
powershell -NoProfile -File scripts\sync-kit.ps1
```

Cursor에서 이 폴더를 워크스페이스로 엽니다. `sessionStart` 훅이 있으면 세션 시작 시 `sync-kit`이 자동 실행됩니다.

**채팅 `/start`:** 원격 kit `pull` 후 sync — [`docs/agent/kit-start.md`](docs/agent/kit-start.md). 제품 레포는 submodule + [`docs/agent/product-onboarding.md`](docs/agent/product-onboarding.md).

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
| `scripts/sync-kit.ps1` | rules + skills + agents 일괄 sync |
| `scripts/Invoke-KitStart.ps1` | `/start`: git pull + sync + `kit-start-last.json` |
| `scripts/sync-kit-product.ps1` | 제품 레포 채널 A/B sync |
| `scripts/import-from-user-cursor.ps1 -Force` | `~/.cursor` → `shared/` (최초·재동기화) |

## 배포 (채널 B — 로컬만)

- [`docs/agent/rules-deploy.md`](docs/agent/rules-deploy.md)
- [`docs/agent/skills-agents-deploy.md`](docs/agent/skills-agents-deploy.md)
- [`docs/agent/kit-inventory.md`](docs/agent/kit-inventory.md)

전역 `~/.cursor/skills`·`agents`·User Rules와 **중복되지 않게** 정리하세요.

## Obsidian (선택)

`_config/obsidian-repos.example.json`을 복사해 `_config/obsidian-repos.json`을 만든 뒤 로컬 경로를 수정합니다. (`obsidian-repos.json`은 git에 포함되지 않습니다.)

## 버전

[CHANGELOG.md](CHANGELOG.md) — `v0.1.0-rules`, `v0.2.0-skills-agents`
