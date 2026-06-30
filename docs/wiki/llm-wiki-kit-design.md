---
type: wiki-note
project: cursor-workspace-kit
status: active
tags: [decision, kit, knowledge-base, llm-wiki]
sources: ["chat:2026-06-30 LLM 위키 도입 계획"]
updated_at: 2026-06-30T11:09:00
---
# LLM 위키(kit-wiki) 도입 설계

## 요약
- 한 줄 결론: AI 대화·결정·자료를 `docs/wiki/`에 정제 저장하고 다시 꺼내 쓰는 지식 관리 기능을 kit 스킬 `kit-wiki`로 추가했다.
- 맥락: AI 대화는 휘발성이 커서 좋은 결론도 흩어진다. "대화 → 정제 → 저장 → 재사용 → 갱신" 순환으로 지식을 자산화한다(카파시식 LLM Wiki의 Wiki 층).

## 결정 (왜)
- 배경: 기존 kit에는 Obsidian 문서 뷰어(읽기)와 행동 규칙(kit) 층만 있고, 그 사이의 "지식 정리 층"이 없었다.
- 대안: (1) 개인 Obsidian 볼트 전용, (2) kit 스킬로 추가, (3) 별도 레포.
- 근거(왜 이것): kit 스킬로 추가하면 기존 `sync-docs`(Obsidian)·sync·훅 인프라를 재사용하고, 팀 공유·결정 추적(SSOT) 가치를 git으로 살릴 수 있다.

### 세부 결정
- 명령 분리: `/kit-wiki`는 ingest(정제 저장) + 증분 lint를 한 번에, `/kit-wiki-ask`는 읽기 전용 질의로 분리. 이유: 쓰기와 읽기를 섞으면 "질문만 했는데 노트가 바뀌는" 사고 위험이 있고, 저장 직후 정합성 점검이 자연스럽다.
- 저장 절충안: 정제 노트(`docs/wiki/*.md`)는 Git 커밋, 원본 덤프(`docs/wiki/_raw/`)는 gitignore, ingest 시 redaction(경로/이메일/키 마스킹). 이유: 공유·추적 가치는 살리되 민감정보 유출을 막는다.
- RAG는 범위 밖: 파일 + `[[링크]]` + Dataview로 시작하고, 규모가 커지면 query 백엔드로 교체 가능.

## kit-rule-mine과의 경계
- `kit-wiki` = 지식(무엇을 결정했나). 위키 노트는 에이전트 강제 규칙이 아니다.
- `kit-rule-mine` = 규칙 후보(어떻게 일할지) → HUMAN 승인 → `shared/rules` 승격.
- 두 명령은 결과물·파이프라인이 다르며 상호 보완한다.

## 산출물
- 스킬: `shared/skills/kit-wiki/SKILL.md`
- 규약: `docs/wiki/README.md`, 템플릿 `docs/wiki/_templates/wiki-note-template.md`
- 슬래시: `/kit-wiki`는 스킬(슬래시 메뉴의 `kit-wiki`), `/kit-wiki-ask`는 명령 `project-kit/.cursor/commands/kit-wiki-ask.md`. 중복 방지로 `kit-wiki` 명령 파일은 두지 않는다.
- 훅: `shared/hooks/kit-wiki-on-prompt.ps1` (beforeSubmitPrompt, fail-open)

## Vault
- [[cursor-workspace-kit/docs/wiki/README|docs/wiki 규약]]
