# Rules 배포 가이드

Rules **편집 SSOT**는 Git 저장소의 `shared/rules/`, `shared/optional/`, `project-kit/.cursor/rules/`이다.  
인벤토리: [`kit-inventory.md`](kit-inventory.md)

## 이 kit 레포(`cursor-workspace-kit`)에서 작업할 때

**채널 B (권장):** Cursor **User Rules에는 중복을 두지 않고**, 워크스페이스 `.cursor/rules/`만 사용한다.

1. SSOT 파일을 수정한다.
2. 저장소 루트에서 sync 실행:

```powershell
powershell -NoProfile -File scripts/sync-kit.ps1
```

(rules만: `scripts/sync-rules.ps1`)

3. Cursor를 다시 로드하거나 워크스페이스를 재연다.

**주의:** [`.cursor/rules/`](../../.cursor/rules/)는 sync **산출물**이다. 직접 편집하지 않는다.

## 마이그레이션: 기존 Cursor User Rules 정리

이전에 User Rules UI에 긴 블록을 붙여 두었다면, sync 후 **중복 적용**을 막기 위해:

1. `scripts/sync-kit.ps1`(또는 `sync-rules.ps1`) 실행으로 `.cursor/rules`가 최신인지 확인한다.
2. Cursor **Settings → Rules → User Rules**에서 아래와 **동일한 내용**을 제거한다.
   - `product-ui-core-global`
   - `emergent-rule-capture-global`
   - 기본 작업 원칙 전체 블록
   - (선택) `Always respond in Korean` — `locale-ko`를 sync에 쓰는 경우
3. 규칙이 한 번만 적용되는지 새 채팅으로 smoke test한다.

## 채널 A — User Rules + 제품 `.cursor/rules` 분리

모든 프로젝트에 공통 `shared/rules`를 **User Rules**에 두고, 제품 레포 `.cursor/rules`에는 **게이트 키트만** 둔다.

| 위치 | 복사 대상 |
|------|-----------|
| Cursor User Rules | `shared/rules/*.mdc` 전체 (또는 마크다운으로 동일 내용) |
| 제품 `.cursor/rules/` | `project-kit/.cursor/rules/60`, `64`, `70` |

`shared/optional/locale-ko.mdc`는 팀 정책에 따라 User Rules 또는 생략.

## 신규 제품 레포에 kit 붙이기

### 최소 세트 (고객 게이트만)

1. 루트에 [`AGENTS.md`](../../AGENTS.md) 복사.
2. `project-kit/.cursor/rules/` → 제품 `.cursor/rules/` (60, 64, 70).
3. 공통 UX/UI 규칙은 **채널 A**로 User Rules에 `shared/rules` 배포, 또는 **채널 B**로 제품 레포에 `shared/rules` + sync 스크립트 복사.

### 전체 kit (이 레포와 동일)

1. `shared/`, `project-kit/`, `scripts/sync-kit.ps1` 복사 또는 submodule.
2. clone 후 `powershell -NoProfile -File scripts/sync-kit.ps1`.
3. `AGENTS.md`를 루트에 둔다.

## 버전 고정

kit repo 태그(예: `v0.1.0-rules`)를 기준으로 submodule 또는 release asset을 고정한다.  
규칙 변경 시 CHANGELOG를 확인한 뒤 태그를 올린다.
