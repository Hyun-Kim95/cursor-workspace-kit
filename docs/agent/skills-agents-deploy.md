# Skills·Agents 배포 가이드

스킬·서브에이전트 **편집 SSOT**는 Git의 `shared/skills/`, `shared/agents/`, `project-kit/.cursor/skills/`이다.  
인벤토리: [`kit-inventory.md`](kit-inventory.md)

## 이 kit 레포에서 작업할 때 (채널 B)

**User `~/.cursor/skills`·`~/.cursor/agents`와 중복하지 않고**, 워크스페이스 `.cursor/skills`·`.cursor/agents`만 사용한다.

1. SSOT를 수정한다 (`shared/` 또는 `project-kit/.cursor/skills/`).
2. 동기화:

```powershell
powershell -NoProfile -File scripts/sync-kit.ps1
```

3. Cursor 워크스페이스를 다시 로드한다.

**kit 레포:** `.cursor/hooks.json`의 `sessionStart` → `sync-kit-on-session.ps1`이 세션 시작 시 `sync-kit`을 실행한다(fail-open).

**주의:** [`.cursor/skills/`](../../.cursor/skills/), [`.cursor/agents/`](../../.cursor/agents/)는 sync **산출물**이다. 직접 편집하지 않는다.

## 전역에서 SSOT로 가져오기 (import)

다른 PC에서 `~/.cursor`만 최신일 때, 또는 전역에서 다시 당겨올 때:

```powershell
powershell -NoProfile -File scripts/import-from-user-cursor.ps1 -Force
powershell -NoProfile -File scripts/sync-kit.ps1
```

- **가져옴:** `~/.cursor/skills/*` (폴더별), `~/.cursor/agents/*.md`
- **제외:** `client-project-lifecycle` (project-kit SSOT), `skills-cursor` (Cursor 내장)

## 채널 B — 전역 정리 (kit 레포용, 1회)

1. `import-from-user-cursor.ps1 -Force` → `sync-kit.ps1` (위)
2. 이 레포를 연 채팅에서 스킬·에이전트가 로드되는지 확인
3. **중복 제거** — kit와 **동일한** 항목을 전역에서 제거:
   - `~/.cursor/skills/` 아래: `plan-feature`, `start-feature`, `parallel-delivery`, `verify-change`, `document-change`, `bugfix-flow`, `release-check`, `context-organization` 및 import로 shared에 넣은 기타 공통 스킬
   - `~/.cursor/agents/*.md` 6개 (frontend, backend, prd, qa, docs, design-system)
4. **유지:** `~/.cursor/skills-cursor/`, 다른 제품 레포가 전역 skills를 쓰는 경우(채널 A)

## 채널 A — 다른 제품 레포

| 위치 | 내용 |
|------|------|
| `~/.cursor/agents` | (선택) 비워 두어도 됨 — `/start`가 제품에 반영 |
| `~/.cursor/skills` | (선택) 비워 두어도 됨 — 제품이 SSOT |
| 제품 `.cursor/skills/` | `/start` → **`shared/skills` 전체** + `client-project-lifecycle` |
| 제품 `.cursor/agents/` | `/start` → **`shared/agents` 6개** (`frontend-agent` 등) |
| 제품 `.cursor/rules/` | `/start` → `project-kit` 60·64·70 |

kit 풀세트를 제품에 넣을 때는 `shared/`, `project-kit/`, `scripts/sync-kit.ps1` 복사 후 sync. 채널 B는 제품에 rules·agents까지 전부 복사.

## 신규 제품 레포 최소 세트

- `AGENTS.md`
- `project-kit/.cursor/rules/` (60, 64, 70)
- 공통: `shared/rules` + `shared/skills` + `shared/agents` (User 전역 또는 제품 `.cursor` + sync)

Rules만: [`rules-deploy.md`](rules-deploy.md)
