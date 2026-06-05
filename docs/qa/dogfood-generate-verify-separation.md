# Dogfood: 생성·검증 분리 kit 반영

## 목적

메인 에이전트가 산출(코드·문서)을 하고, 검증은 `qa-agent`에 파일·루브릭만 넘기는 **생성·검증 분리** 흐름을 kit에 반영했다.

## 변경 SSOT

| 경로 | 변경 요약 |
|------|-----------|
| `shared/skills/start-feature/SKILL.md` | `## 생성·검증 분리` 절, 절차 8 갱신 |
| `shared/skills/verify-change/SKILL.md` | `## 독립 검증 계약`, qa-agent 필수화 |
| `shared/agents/qa-agent.md` | `## 독립 검증기 계약` |
| `docs/agent/agent-brief.md` | Done Criteria, `## 9) Verifier Handoff` |
| `AGENTS.md` | 기본 진입 규칙 1줄 |
| `shared/skills/bugfix-flow/SKILL.md` | cross-reference 1줄 |
| `shared/skills/parallel-delivery/SKILL.md` | 절차 4 생성·검증 분리 정렬 |
| `project-kit/.cursor/skills/client-project-lifecycle/SKILL.md` | 단계 3·4·4B handoff·self-verify 금지 |
| `shared/skills/release-check/SKILL.md` | 절차 6 cross-reference |

## 핵심 계약

1. 메인 **self-verify 금지**
2. `qa-agent` 입력: `artifactPaths` + `rubricRef` + `forbidden` 만
3. 체크리스트: `checkedItems N/M`, `uncheckedIds` 보고

## 미확정

- harness 훅 신규 개발은 범위 외 (기존 delivery-loop·quality-gate 유지)
