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
- 기본 **채널 A** (제품에 **공통 스킬 전체** + lifecycle; 전역 agents 유지) — 채널 B는 [수동 설정](#1회-설정-수동참고) 참고.

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

결과 파일: 제품의 [`.cursor/state/kit-start-setting-last.json`](../.cursor/state/kit-start-setting-last.json)

**선택:** 제품에서 `git add` / `commit` (submodule, `.cursor-kit.json`, `.cursor/` 등).

### 3단계 — 제품 워크스페이스에서 채팅

1. Cursor에서 **제품 레포 루트**(`my-product`)를 연다. kit 레포가 아님.
2. 채팅:

```text
/start-setting
```

이미 2단계에서 설정됐으면 대부분 `exists` + sync만 다시 돈다. 문제 없으면 OK.
3. 이후 매일:

```text
/start 오늘 할 일: ...
```

### (선택) 4단계 — `AGENTS.md`

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
| 전역 agents | **그대로** (또는 제품에 두지 않음) |
| 전역 skills | 비어 있어도 됨 — `/start`가 **shared/skills 전체**를 제품 `.cursor/skills`에 반영 |
| 제품 `.cursor/rules` | `/start` 시 **60·64·70** 갱신 |
| 제품 `.cursor/skills` | `/start` 시 **공통 스킬 + lifecycle** 갱신 |
| `.cursor-kit.json` | `"channel": "A"` |

### 전역 skills 복구 (선택)

전역을 kit과 맞추려면 kit clone에서:

```powershell
$dst = Join-Path $env:USERPROFILE ".cursor\skills"
New-Item -ItemType Directory -Path $dst -Force | Out-Null
Copy-Item -Path "D:\path\to\cursor-workspace-kit\shared\skills\*" -Destination $dst -Recurse -Force
```

제품만 쓸 경우 위 없이 제품에서 **`/start`** 만으로도 스킬이 채워진다.

채널 B: [`skills-agents-deploy.md`](skills-agents-deploy.md)

---

## kit 레포 자체 (템플릿만 개발할 때)

[`README.md`](../../README.md) 빠른 시작 → 이 폴더를 Cursor로 연다. 제품 연동은 위 **처음부터 3단계**를 본다.

---

## 문제 해결

| 증상 | 확인 |
|------|------|
| `/start` 대신 `start-feature`만 실행됨 | 자동완성 Tab 주의 → **`/kit-start `** 또는 **`/start `** 직접 입력, 또는 스킬 **`kit-start`** |
| `/start-setting`이 아무 일도 안 함 | 제품에 `hooks.json`·훅 파일 있는지 → 없으면 **2단계** PowerShell 먼저 |
| `Missing .cursor-kit.json` | 2단계 또는 `/start-setting` 재실행 |
| pull 실패 | `kit-start-last.json` · 네트워크·git 인증 |
| submodule 비어 있음 | `git submodule update --init` |
| 한글 오류 깨짐 | [`kit-start.md`](kit-start.md) Windows PowerShell 5.1 절 |

---

## 관련

- [`kit-start.md`](kit-start.md)
- [`skills-agents-deploy.md`](skills-agents-deploy.md)
- [`project-kit/README.md`](../../project-kit/README.md)
