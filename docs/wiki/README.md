---
type: doc
project: cursor-workspace-kit
doc_lane: wiki
updated_at: 2026-06-30T11:09:00
tags: [docs, wiki, knowledge-base]
---
# docs/wiki — LLM 위키 (지식 저장소)

AI 대화·리서치·결정·산출물을 정제해 쌓는 **단일 지식 저장소**다. 운영 절차는 `kit-wiki` 스킬([`.cursor/skills/kit-wiki/SKILL.md`](../../.cursor/skills/kit-wiki/SKILL.md), SSOT: `shared/skills/kit-wiki/SKILL.md`)을 따른다.

## 폴더 규약

| 경로 | 용도 | Git |
|------|------|-----|
| `docs/wiki/*.md` | 정제된 위키 노트 (요약·결정·링크) | **커밋** |
| `docs/wiki/_raw/` | 대화 덤프·원문 (민감정보 가능) | **gitignore** |
| `docs/wiki/_templates/` | 노트 템플릿 | 커밋 |

- 파일명: `<topic-slug>.md` (kebab-case, ASCII 권장)
- 같은 주제는 **새 파일 대신 기존 노트 갱신**(중복 방지)

## 카파시 3층

- **Raw** = `docs/wiki/_raw/` (원본, gitignore)
- **Wiki** = `docs/wiki/*.md` (LLM 정제 노트)
- **Schema** = 본 문서 + `kit-wiki` 스킬 + `AGENTS.md` 진입/경계

## frontmatter 스펙 (위키 노트)

```yaml
---
type: wiki-note
project: <slug>
status: active        # active | deprecated
tags: [...]
sources: ["chat:<날짜 또는 id>", "docs/..."]
updated_at: <ISO8601>
---
```

본문 섹션 권장: `## 요약`, `## 결정 (왜)`(배경/대안/근거), `## 세부`, `## Vault`(교차 링크).

## redaction 정책 (필수)

커밋 대상 노트(`docs/wiki/*.md`)에는 민감정보를 넣지 않는다. ingest 시 마스킹한다.

- 절대 경로 → `[path]`
- 이메일 → `[email]`
- `sk-…` / 토큰 → `[secret]`
- `Bearer …` → `Bearer [redacted]`
- 고객 실명·내부 식별자·비밀값 → 일반화/마스킹

판단이 어려운 민감 원문은 `_raw/`(gitignore)에만 두고 노트엔 요약·결정만 남긴다.

## kit-rule-mine과의 경계

- 위키 노트 = **지식 기록**(무엇을 결정했나). 에이전트 강제 규칙이 아니다.
- 규칙으로 올릴 패턴(반복 보정·DoD 누락 등)은 `kit-rule-mine` → HUMAN 승인 → `shared/rules` 경로를 따른다([`docs/agent/rule-candidates.md`](../agent/rule-candidates.md)).

## Obsidian

`docs/wiki/`는 [`scripts/obsidian/sync-docs.ps1`](../../scripts/obsidian/sync-docs.ps1)이 볼트로 단방향 복제한다. Dataview는 `type: wiki-note` 기준으로 집계 가능.

## Vault

- [[cursor-workspace-kit/docs/cursor-workspace-kit-docs-hub|Hub]]
- [[cursor-workspace-kit/docs/obsidian/dashboards/projects-overview|Dashboards]]
