# project-kit

고객·게이트 중심 Cursor **rules·skills** 묶음이다. 신규 제품 레포에 복사하거나 submodule로 가져온다.

## 포함 (SSOT)

### Rules — `.cursor/rules/`

- `60-delivery-gates.mdc` — Gate 1~3, 병렬, DoD
- `64-context-organization.mdc` — 맥락 정리 경계
- `70-client-lifecycle-default.mdc` — 고객 E2E·디자인 승인=구현 착수

### Skills — `.cursor/skills/`

- `client-project-lifecycle/` — 고객 요구 → PRD → 목업 → 구현 → 검증 전체 흐름

## 함께 필요한 것

| 항목 | SSOT 위치 |
|------|-----------|
| 오케스트레이션 | 저장소 루트 `AGENTS.md` |
| 공통 rules | `../shared/rules/` (+ optional `locale-ko`) |
| 공통 skills | `../shared/skills/` |
| 서브에이전트 | `../shared/agents/` |

## 배포

- Rules: [`docs/agent/rules-deploy.md`](../docs/agent/rules-deploy.md)
- Skills·Agents: [`docs/agent/skills-agents-deploy.md`](../docs/agent/skills-agents-deploy.md)

**kit 레포 전체 sync:**

```powershell
powershell -NoProfile -File scripts/sync-kit.ps1
```

**최소 복사:** `AGENTS.md` + 이 폴더의 `rules/`·`skills/` + (권장) `../shared/`
