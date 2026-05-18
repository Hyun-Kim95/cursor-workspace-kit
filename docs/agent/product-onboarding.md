# 제품 레포 온보딩 — kit submodule + `/start`

제품 앱 레포에 [cursor-workspace-kit](https://github.com/Hyun-Kim95/cursor-workspace-kit)을 붙이고, 채팅 `/start`로 rules·스킬을 최신화하는 절차이다.

## 빠른 경로: `/start-setting` (권장)

**Git 저장소인 제품 레포**를 Cursor로 연 뒤 채팅에 한 줄:

```text
/start-setting
```

자동 처리(가능한 범위):

1. `git submodule add` → `vendor/cursor-workspace-kit` (없을 때만)
2. 루트 `.cursor-kit.json` (채널 A 기본)
3. `.cursor/hooks/kit-start-on-prompt.ps1` + `hooks.json`
4. 첫 `Invoke-KitStart` sync

결과: [`.cursor/state/kit-start-setting-last.json`](../.cursor/state/kit-start-setting-last.json) (생성 후 확인)

**훅이 아직 없을 때(완전 빈 제품 레포):** kit을 clone해 둔 PC에서 1회만:

```powershell
cd D:\path\to\cursor-workspace-kit
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\Invoke-KitStartSetting.ps1 -WorkspaceRoot D:\path\to\my-product
```

이후 제품 워크스페이스에서 `/start-setting`·`/start` 모두 사용 가능.

---

## 1회 설정 (수동)

### 1. Submodule 추가

제품 레포 루트에서:

```powershell
git submodule add https://github.com/Hyun-Kim95/cursor-workspace-kit.git vendor/cursor-workspace-kit
git commit -m "chore: add cursor-workspace-kit submodule"
```

팀원 clone:

```powershell
git clone --recurse-submodules <product-repo-url>
# 또는
git submodule update --init
```

### 2. `.cursor-kit.json`

[`project-kit/.cursor-kit.json.example`](../../project-kit/.cursor-kit.json.example)를 제품 루트에 복사:

```json
{
  "kitPath": "vendor/cursor-workspace-kit",
  "kitRepoMode": "submodule",
  "remote": "origin",
  "branch": "main",
  "channel": "A"
}
```

- **채널 A** — 전역 `~/.cursor/skills`·`agents` 유지, `/start`는 게이트 rules + lifecycle만 갱신.
- **채널 B** — 전역 비우고 kit 전체를 제품 `.cursor/`에 sync.

### 3. `/start` 훅 (제품에만)

1. [`project-kit/.cursor/hooks/kit-start-on-prompt.ps1`](../../project-kit/.cursor/hooks/kit-start-on-prompt.ps1) → `<product>/.cursor/hooks/`
2. [`project-kit/.cursor/hooks.json.example`](../../project-kit/.cursor/hooks.json.example) 내용을 제품 `.cursor/hooks.json`에 병합 (`beforeSubmitPrompt` 맨 위 권장).

**대안** — hooks.json에 직접:

```json
"command": "powershell -NoProfile -ExecutionPolicy Bypass -File vendor/cursor-workspace-kit/scripts/Invoke-KitStart.ps1 -WorkspaceRoot ."
```

### 4. AGENTS.md

kit [`AGENTS.md`](../../AGENTS.md)를 참고해 제품용으로 조정. `/start` 규칙(상태 파일 선독)을 포함하는 것을 권장한다.

### 5. 첫 sync

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File vendor/cursor-workspace-kit/scripts/Invoke-KitStart.ps1 -WorkspaceRoot .
```

또는 채팅: `/start 오늘 작업: ...`

---

## 기존 레포 — 채널 A (같은 PC, 전역 skills 유지)

현재: `~/.cursor/skills`·`agents` + 제품 `.cursor/rules` 일부.

| 항목 | 조치 |
|------|------|
| 전역 skills·agents | **그대로** — `/start`가 대체하지 않음 |
| User Rules | 그대로 (또는 `shared/rules`와 중복 점검) |
| 제품 `.cursor/rules` | `/start` 시 **60·64·70**만 submodule `project-kit`에서 갱신 |
| submodule | 레포마다 1회 `git submodule add` |
| hooks | 제품에 `/start` 훅만 추가 (Obsidian·delivery 훅은 kit 레포 전용) |
| `.cursor-kit.json` | `"channel": "A"` |
| 제품 `.cursor/skills` | **lifecycle만** — `plan-feature` 등 공통 스킬 폴더 넣지 않음 |

### 채널 A → B 전환 (선택, 레포별)

1. `.cursor-kit.json` → `"channel": "B"`
2. `~/.cursor/skills`·`agents`에서 kit과 겹치는 항목 제거 — [`skills-agents-deploy.md`](skills-agents-deploy.md)
3. `/start` 또는 `Invoke-KitStart.ps1` 실행

---

## kit 레포 자체

루트 [`.cursor-kit.json`](../../.cursor-kit.json): `kitRepoMode: "self"`, `channel: "B"`.

`/start` = 이 레포 `git pull` + `sync-kit.ps1`. 상세: [`kit-start.md`](kit-start.md).

---

## 문제 해결

| 증상 | 확인 |
|------|------|
| pull 실패, 프롬프트 차단 | 네트워크·git 인증·브랜치명; `kit-start-last.json`의 `message` |
| submodule 폴더 비어 있음 | `git submodule update --init` |
| 스킬 중복 | 채널 A에서 제품 `.cursor/skills`에 공통 스킬 넣지 않기 |
| git 없음 | PATH에 `git` 설치; 훅은 fail-closed |

---

## 관련

- [`kit-start.md`](kit-start.md)
- [`skills-agents-deploy.md`](skills-agents-deploy.md)
- [`project-kit/README.md`](../../project-kit/README.md)
