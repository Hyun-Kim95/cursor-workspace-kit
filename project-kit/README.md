# project-kit

고객·게이트 중심 Cursor **rules·skills** 묶음이다. 신규 **제품 레포**에는 submodule + **`/start-setting`** / **`/start`** 를 권장한다.

## 제품 레포에 붙이기 (요약)

**전체 절차(SSOT):** [`docs/agent/product-onboarding.md`](../docs/agent/product-onboarding.md)

### 처음부터 (제품에 훅 없음)

```powershell
# 1) kit 템플릿 clone (PC당 1회)
git clone https://github.com/Hyun-Kim95/cursor-workspace-kit.git
cd cursor-workspace-kit

# 2) 제품 자동 설정 (1회)
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\Invoke-KitStartSetting.ps1 -WorkspaceRoot D:\path\to\my-product
```

그다음 Cursor에서 **제품 폴더**를 연고 채팅: `/start-setting` → 이후 `/start <할 일>`.

### 훅이 이미 있음

제품 워크스페이스에서 채팅 **`/start-setting`** (또는 바로 **`/start`**).

### 수동

[`product-onboarding.md` § 1회 설정 (수동)](../docs/agent/product-onboarding.md#1회-설정-수동참고) · 예시 파일:

- [`.cursor-kit.json.example`](.cursor-kit.json.example)
- [`.cursor/hooks.json.example`](.cursor/hooks.json.example)

## 포함 (SSOT)

### Rules — `.cursor/rules/`

- `60-delivery-gates.mdc` — Gate 1~3, 병렬, DoD
- `64-context-organization.mdc` — 맥락 정리 경계
- `70-client-lifecycle-default.mdc` — 고객 E2E·디자인 승인=구현 착수

### Skills — `.cursor/skills/`

- `client-project-lifecycle/` — 고객 E2E 전체 흐름

## 함께 필요한 것

| 항목 | SSOT 위치 |
|------|-----------|
| 오케스트레이션 | 저장소 루트 `AGENTS.md` |
| 공통 rules | `../shared/rules/` |
| 공통 skills | `../shared/skills/` |
| 서브에이전트 | `../shared/agents/` |

## 배포

- [`docs/agent/rules-deploy.md`](../docs/agent/rules-deploy.md)
- [`docs/agent/skills-agents-deploy.md`](../docs/agent/skills-agents-deploy.md)
