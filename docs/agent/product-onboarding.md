# 제품 레포 온보딩 — kit submodule + `/start-setting` + `/start`

제품 앱 레포에 [cursor-workspace-kit](https://github.com/Hyun-Kim95/cursor-workspace-kit)을 붙이고, 채팅으로 rules·스킬을 최신화하는 절차이다.

**명령 정리:** [`kit-start.md`](kit-start.md) · 스크립트 목록: [`kit-inventory.md`](kit-inventory.md)

---

## 어떤 경로를 쓸지

| 상황 | 할 일 |
|------|--------|
| **제품에 kit·훅이 전혀 없음** (처음) | 아래 **[처음부터 3단계](#처음부터-3단계-완전-빈-제품)** |
| **훅은 있는데** submodule·설정만 다시 맞추기 | 제품 폴더를 Cursor로 연 뒤 채팅 **`/start-setting`** |
| **이미 온보딩 끝남** (`dietManagement` 등) | 매일 채팅 **`/start <할 일>`** 만 |

---

## 처음부터 3단계 (완전 빈 제품)

채팅 `/start-setting`은 **제품 `.cursor/hooks`에 훅이 있어야** 동작한다. 훅이 없으면 **아래 1→2를 먼저** 한 뒤, **3**에서 `/start-setting`을 쓴다.

### 전제

- **제품 레포**가 Git 저장소다 (`git init` 또는 clone된 상태).
- 이 PC에 `git`, `powershell`이 있다.
- 기본 **채널 A** (제품에 **공통 스킬·에이전트 전체** + lifecycle) — 채널 B는 [수동 설정](#1회-설정-수동참고) 참고.

### 1단계 — kit 레포 clone (이 PC, 보통 1회)

kit **템플릿 저장소**를 clone한다. 제품 레포 clone이 아니다.

```powershell
git clone https://github.com/Hyun-Kim95/cursor-workspace-kit.git
cd cursor-workspace-kit
```

(이미 `D:\cursor\cursor-workspace-kit` 등이 있으면 이 단계는 생략.)

### 2단계 — 제품에 자동 설정 (PowerShell 1회)

**kit clone 폴더**에서 제품 경로를 넘긴다.

```powershell
cd D:\path\to\cursor-workspace-kit
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\Invoke-KitStartSetting.ps1 -WorkspaceRoot D:\path\to\my-product
```

자동 처리:

1. 제품에 `git submodule add` → `vendor/cursor-workspace-kit` (없을 때만)
2. 제품 루트 `.cursor-kit.json` (없을 때만, 채널 A 기본)
3. 제품 `.cursor/hooks/kit-start-on-prompt.ps1` + `hooks.json` (없을 때만)
4. 첫 sync (`Invoke-KitStart`)
5. (없을 때만) 루트 `.editorconfig`·`.gitattributes` · global rules(`encoding-utf8-global`, `product-monetization-default`) — [`encoding.md`](encoding.md), [`product-assumptions.md`](product-assumptions.md)

결과 파일: 제품의 [`.cursor/state/kit-start-setting-last.json`](../.cursor/state/kit-start-setting-last.json)

**선택:** 제품에서 `git add` / `commit` (submodule, `.cursor-kit.json`, `.cursor/` 등).

### 3단계 — 제품 워크스페이스에서 채팅

1. Cursor에서 **제품 레포 루트**(`my-product`)를 연다. kit 레포가 아님.
2. 채팅:

```text
/start-setting
```

슬래시 목록에서는 스킬 **`start-setting`** 으로도 선택할 수 있다. 훅 실행을 확실히 하려면 채팅 맨 앞에 `/start-setting`(또는 `/kit-start-setting`)이 오도록 보낸다.

이미 2단계에서 설정됐으면 대부분 `exists` + sync만 다시 돈다. 문제 없으면 OK.
3. 이후 매일:

```text
/start 오늘 할 일: ...
```

### 4단계 — 소비 확인 (kit 사용)

**submodule·sync·훅 설치(생성)만으로 kit 도입 완료로 보지 않는다.** 소비 증거 기준: [`integration-consumption-gate.md`](../qa/integration-consumption-gate.md) (kit 연동 절).

- [ ] 제품 워크스페이스에서 **`/start` 한 번 이상** 실행 후 실제 할 일 수행(스킬·규칙이 작업에 반영됨)
- [ ] [`.cursor/state/kit-start-last.json`](../../.cursor/state/kit-start-last.json) `ok: true` 확인 (`false`이면 sync·submodule 점검 후 재시도)
- [ ] (권장) 제품 루트 `AGENTS.md`에 `/start`·상태 JSON 선독 규칙 — 아래 (선택) 5단계

**신규 기능**을 ATDD-lite로 진행할 때는 제품 `docs/qa/`에 [`atdd-lite-consumption-checklist.md`](../qa/atdd-lite-consumption-checklist.md)로 소비 증거를 남긴다. 기록 형식 예시: [`atdd-lite-consumption-record-example.md`](../qa/atdd-lite-consumption-record-example.md).

### (선택) 5단계 — `AGENTS.md`

kit [`AGENTS.md`](../../AGENTS.md)를 참고해 제품 루트에 두고, `/start`·`/start-setting` 시 상태 JSON 선독 규칙을 넣는다. **자동 생성되지 않는다.**

### (선택) Harness — shell guard + quality gate

[`harness-layer1.md`](harness-layer1.md) 2단계. `/start-setting`이 `hooks.json`에 `guard-shell`·`quality-gate` 슬롯과 훅 `.ps1` 3개를 merge한다.

| 항목 | 제품 기본 (example) |
|------|---------------------|
| `.cursor-kit.json` `harness.shellGuard.mode` | **block** (위험 shell 실차단) |
| 패턴 | sync된 `.cursor/hooks/guard-shell.patterns.json` |
| quality gate | [`project-kit/.cursor/quality-gate.json.example`](../../project-kit/.cursor/quality-gate.json.example) → `.cursor/quality-gate.json` (로컬, gitignore) |

- 채널 **A**·**B** 모두 `/start` 시 harness 훅 3파일을 제품 `.cursor/hooks/`에 복사한다(`hooks.json` 슬롯은 `/start-setting`).
- kit 템플릿 레포 self는 오탐 완화를 위해 `shellGuard.mode: warn`을 쓴다.

---

## 훅이 이미 있는 제품 (2단계 생략)

제품에 `.cursor/hooks/kit-start-on-prompt.ps1`과 `hooks.json`이 이미 있으면:

1. Cursor에서 **제품 레포** 연다.
2. 채팅 **`/start-setting`** 한 번 (또는 바로 **`/start`**).

---

## 이미 온보딩된 제품

| 하지 않아도 됨 | 매일 할 일 |
|----------------|------------|
| submodule add, `.cursor-kit.json` 복사, 훅 수동 복사 | **`/start <할 일>`** |
| `/start-setting` 반복 (설정 재확인·sync만 필요할 때만) | |

`/start-setting`을 다시 치면 설치 단계는 `exists`로 건너뛰고 **pull + sync**만 실행된다. 평소에는 `/start`만 쓰면 된다.

---

## 1회 설정 (수동·참고)

`/start-setting`·`Invoke-KitStartSetting.ps1`과 동일한 결과를 손으로 맞출 때 참고한다.

### 1. Submodule 추가

제품 레포 루트에서:

```powershell
git submodule add https://github.com/Hyun-Kim95/cursor-workspace-kit.git vendor/cursor-workspace-kit
git commit -m "chore: add cursor-workspace-kit submodule"
```

다른 PC에서 제품 clone 시:

```powershell
git clone --recurse-submodules <product-repo-url>
# 또는
git submodule update --init
```

### 2. `.cursor-kit.json`

[`project-kit/.cursor-kit.json.example`](../../project-kit/.cursor-kit.json.example) → 제품 루트 `.cursor-kit.json`

### 3. `/start` 훅 (제품 `.cursor/`만)

[`project-kit/.cursor/hooks/kit-start-on-prompt.ps1`](../../project-kit/.cursor/hooks/kit-start-on-prompt.ps1) + [`hooks.json.example`](../../project-kit/.cursor/hooks.json.example)

Obsidian·delivery 훅은 **kit 레포 전용** — 제품에 복사하지 않는다.

### 4. 첫 sync

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File vendor\cursor-workspace-kit\scripts\Invoke-KitStart.ps1 -WorkspaceRoot .
```

---

## 기존 레포 — 채널 A (기본)

| 항목 | 조치 |
|------|------|
| 전역 agents·skills | 비어 있어도 됨 — `/start`가 **shared/agents·shared/skills**를 제품 `.cursor/`에 반영 |
| 제품 `.cursor/rules` | `/start` 시 **60·64·70** 갱신 |
| 제품 `.cursor/skills` | `/start` 시 **공통 스킬 + lifecycle** 갱신 |
| 제품 `.cursor/agents` | `/start` 시 **공통 에이전트 6개** 갱신 (kit `shared/agents`와 동일 파일명 덮어씀) |
| `.cursor-kit.json` | `"channel": "A"` |

### 전역 복구 (선택)

제품만 쓸 경우 **`/start`** 만으로 스킬·에이전트가 채워진다. 전역을 kit과 맞추려면 kit clone에서:

```powershell
$skillsDst = Join-Path $env:USERPROFILE ".cursor\skills"
$agentsDst = Join-Path $env:USERPROFILE ".cursor\agents"
New-Item -ItemType Directory -Path $skillsDst, $agentsDst -Force | Out-Null
Copy-Item -Path "D:\path\to\cursor-workspace-kit\shared\skills\*" -Destination $skillsDst -Recurse -Force
Copy-Item -Path "D:\path\to\cursor-workspace-kit\shared\agents\*.md" -Destination $agentsDst -Force
```

채널 B: [`skills-agents-deploy.md`](skills-agents-deploy.md)

---

## kit 레포 자체 (템플릿만 개발할 때)

[`README.md`](../../README.md) 빠른 시작 → 이 폴더를 Cursor로 연다. 제품 연동은 위 **처음부터 3단계**를 본다.

---

## Submodule 최신화 — `/start` vs `submodule update --remote`

### 일상 (기본)

**매일**은 채팅 **`/kit-start <할 일>`** 또는 **`/start <할 일>`** 만으로 충분하다.

[`Invoke-KitStart.ps1`](../../scripts/Invoke-KitStart.ps1)이 제품이 **등록된 git submodule**이면, 필요할 때 자동으로:

```powershell
git submodule update --init --remote <kitPath>
```

을 실행한 뒤 submodule 안 `git pull` + `sync-kit-product`를 한다.

**자동 `--remote` 판단(요약):** submodule 미초기화·`origin/<branch>`보다 뒤처짐·`sync-kit-product.ps1`에 `sharedSkills` 없음(옛 kit) 등.  
결과는 `.cursor/state/kit-start-last.json`의 `submoduleRemoteSync`, `submoduleRemoteSyncMessage`에 남는다.

수동 `git submodule update --init --remote`는 **훅 없이** 점검·복구할 때만 쓴다.

### `git submodule update --init --remote`가 필요할 수 있는 경우

| 상황 | 설명 |
|------|------|
| `/start` 없이 kit만 올리려 할 때 | 훅·sync 전에 submodule 작업 트리를 원격 `main` tip으로 맞춤 |
| `/start` 후에도 스킬·스크립트가 옛 동작일 때 | submodule이 **옛 커밋**에 머물렀거나, `pull`이 fetch 없이 “이미 최신”으로 끝난 경우 |
| clone 후 `--init`만 했을 때 | `update --init`은 **부모가 pin한 SHA**만 가져옴. 원격 최신이 아닐 수 있음 |
| 다른 PC에서 오래된 제품 clone | 부모 repo의 submodule SHA가 낮은 채로 clone |

**필요 없는 경우:** `/start`가 성공했고, `kit-start-last.json`에 `submoduleRemoteSync: true`가 있거나, 아래 [확인 체크리스트](#submodule-확인-체크리스트)가 모두 통과할 때.

### 해당 경우인지 확인 — Submodule 확인 체크리스트

제품 레포 **루트**에서 실행한다. `kitPath`는 `.cursor-kit.json`의 값(기본 `vendor/cursor-workspace-kit`)에 맞춘다.

```powershell
# 1) kitPath (기본값 예시)
$kitPath = "vendor/cursor-workspace-kit"
if (Test-Path .cursor-kit.json) {
  $cfg = Get-Content .cursor-kit.json -Raw | ConvertFrom-Json
  if ($cfg.kitPath) { $kitPath = $cfg.kitPath }
}

# 2) submodule 존재·스크립트
Test-Path (Join-Path $kitPath "scripts\Invoke-KitStart.ps1")
Test-Path (Join-Path $kitPath "scripts\sync-kit-product.ps1")

# 3) 채널 A 전체 스킬·에이전트 sync 스크립트 포함 여부
Select-String -Path (Join-Path $kitPath "scripts\sync-kit-product.ps1") -Pattern "sharedSkills" -Quiet
Select-String -Path (Join-Path $kitPath "scripts\sync-kit-product.ps1") -Pattern "sharedAgents" -Quiet
# 둘 다 True 여야 channel A에서 shared/skills·shared/agents 복사

# 4) 로컬 submodule HEAD vs 원격 main
Push-Location $kitPath
git fetch origin
$local = (git rev-parse HEAD).Trim()
$remote = (git rev-parse origin/main).Trim()
Pop-Location
"$local"
"$remote"
# 두 SHA가 다르면 submodule 작업 트리가 원격 main보다 뒤처짐 → --remote 또는 submodule 안 git pull 검토

# 5) 제품에 복사된 스킬·에이전트 (채널 A 기대: 스킬 폴더 10개 전후, 에이전트 .md 6개)
(Get-ChildItem .cursor\skills -Directory -ErrorAction SilentlyContinue).Count
(Get-ChildItem .cursor\agents -Filter "*.md" -ErrorAction SilentlyContinue).Count
Get-ChildItem .cursor\skills -Directory -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name

# 6) 마지막 /start 기록 (skill 개수는 JSON에 없음)
Get-Content .cursor\state\kit-start-last.json -Raw -ErrorAction SilentlyContinue
```

| 확인 결과 | 판단 |
|-----------|------|
| `sharedSkills`가 스크립트에 **없음** | submodule이 **채널 A 전체 스킬 sync 이전** → `--remote`(또는 pull) **필요** |
| 로컬 HEAD ≠ `origin/main` | 원격 최신 미반영 → `--remote` 또는 submodule 안 `git pull` **검토** |
| `.cursor/skills` 폴더 **1개**뿐 (`client-project-lifecycle`만) | 위와 동일 가능성 큼 |
| `/start` 로그에 `skill-folders=1` 또는 `agents=0` (터미널·훅 stdout) | sync는 됐으나 **옛 스크립트** |
| 위가 모두 정상인데 UI만 1개 | [문제 해결](#문제-해결) — Cursor reload, **파일 탐색기** `.cursor/skills` 기준 |

`kit-start-last.json`의 `message`에 “sync 완료”만 있어도 **스킬 개수는 증명하지 않는다.**

### 명령 (예외 시)

`kitPath`가 `vendor/cursor-workspace-kit`이 아니면 경로를 바꾼다.

```powershell
# 제품 레포 루트
git submodule update --init --remote vendor/cursor-workspace-kit
```

동등한 방법 (submodule 안에서 pull):

```powershell
cd vendor\cursor-workspace-kit
git checkout main
git pull origin main
cd ..\..
```

그다음 **반드시** sync 한 번 더:

```text
/kit-start 동기화 확인
```

또는:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File vendor\cursor-workspace-kit\scripts\Invoke-KitStart.ps1 -WorkspaceRoot .
```

터미널에 `skill-folders=10`·`agents=6` 근처가 보이면 채널 A 전체 스킬·에이전트 복사로 보면 된다.

**팀 공유:** submodule SHA를 부모 제품 repo에 남기려면 `git add vendor/cursor-workspace-kit` 후 commit. 로컬만 쓸 때는 생략 가능.

---

## 문제 해결

| 증상 | 확인 |
|------|------|
| `/start` 했는데 스킬 폴더 1개·옛 템플릿 | [Submodule 최신화](#submodule-최신화--start-vs-submodule-update---remote) 체크리스트 → `--remote` 또는 submodule `git pull` |
| `/start` 대신 `start-feature`만 실행됨 | 자동완성 Tab 주의 → **`/kit-start `** 또는 **`/start `** 직접 입력, 또는 스킬 **`kit-start`** |
| `/start-setting`이 아무 일도 안 함 | 제품에 `hooks.json`·훅 파일 있는지 → 없으면 **2단계** PowerShell 먼저. 슬래시만 고르면 훅 미실행 → 맨 앞 `/start-setting` 직접 입력 |
| `Missing .cursor-kit.json` | 2단계 또는 `/start-setting` 재실행 |
| pull 실패 | `kit-start-last.json` · 네트워크·git 인증 |
| submodule 비어 있음 | `git submodule update --init` (최초). 최신 main은 [위 절](#submodule-최신화--start-vs-submodule-update---remote) |
| 한글 오류 깨짐 | [`kit-start.md`](kit-start.md) Windows PowerShell 5.1 절 |

---

## 관련

- [`kit-start.md`](kit-start.md)
- [`skills-agents-deploy.md`](skills-agents-deploy.md)
- [`project-kit/README.md`](../../project-kit/README.md)
