---
type: wiki-note
project: cursor-workspace-kit
status: active
review: done
tags: [decision, kit, knowledge-base, llm-wiki]
sources: ["chat:2026-06-30 LLM 위키 도입 계획", "chat:2026-06-30 kit-wiki C1/C2/review 보강"]
updated_at: 2026-06-30T18:30:00
---
# LLM 위키(kit-wiki) 도입 설계

## 요약
- 한 줄 결론: AI 대화·결정·자료를 `docs/wiki/`에 정제 저장하고 다시 꺼내 쓰는 지식 관리 기능을 kit 스킬 `kit-wiki`로 추가했다. 초기 도입 후 C1(redaction lint)·C2(index MOC)·review(사실관계 검토) 보강까지 반영했다.
- 맥락: AI 대화는 휘발성이 커서 좋은 결론도 흩어진다. "대화 → 정제 → 저장 → 재사용 → 갱신" 순환으로 지식을 자산화한다(카파시식 LLM Wiki의 Wiki 층). 요즘IT LLM 위키 구축기 분석에서 ingest/lint/query·redaction·index 즉시 참조 패턴을 kit에 맞게 흡수했다.

## 결정 (왜)
- 배경: 기존 kit에는 Obsidian 문서 뷰어(읽기)와 행동 규칙(kit) 층만 있고, 그 사이의 "지식 정리 층"이 없었다.
- 대안: (1) 개인 Obsidian 볼트 전용, (2) kit 스킬로 추가, (3) 별도 레포.
- 근거(왜 이것): kit 스킬로 추가하면 기존 `sync-docs`(Obsidian)·sync·훅 인프라를 재사용하고, 팀 공유·결정 추적(SSOT) 가치를 git으로 살릴 수 있다.

### 세부 결정 (초기 도입)
- 명령 분리: `/kit-wiki`는 ingest(정제 저장) + 증분 lint를 한 번에, `/kit-wiki-ask`는 읽기 전용 질의로 분리. 이유: 쓰기와 읽기를 섞으면 "질문만 했는데 노트가 바뀌는" 사고 위험이 있고, 저장 직후 정합성 점검이 자연스럽다.
- 저장 절충안: 정제 노트(`docs/wiki/*.md`)는 Git 커밋, 원본 덤프(`docs/wiki/_raw/`)는 gitignore, ingest 시 redaction(경로/이메일/키 마스킹). 이유: 공유·추적 가치는 살리되 민감정보 유출을 막는다.
- RAG는 범위 밖: 파일 + `[[링크]]` + Dataview로 시작하고, 규모가 커지면 query 백엔드로 교체 가능.

### 세부 결정 (C1 — lint redaction 정규식)
- 배경: redaction이 LLM 자연어 지시만으로는 ingest/lint 시 누락 가능.
- 대안: (1) lint 경고만, (2) lint + 커밋 전 가드 훅.
- 근거(왜 lint 경고만): `docs/wiki/README.md`에 정규식 패턴표를 SSOT로 두고 `/kit-wiki lint`가 스캔·자동 마스킹(명백한 키/이메일/경로) 또는 경고(카드·주민번호·긴 hex)한다. 커밋 흐름 무간섭·리스크 최소. 커밋 가드·결정적 PowerShell 스캐너는 후속 후보.

### 세부 결정 (C2 — index MOC)
- 배경: 노트 증가 시 ask가 폴더 전체 탐색에 의존하면 누락·고아 노트 위험.
- 대안: (1) 수동 index.md, (2) Dataview 자동 집계, (3) 고정 카테고리 + Dataview 병행.
- 근거(왜 고정 카테고리): `docs/wiki/index.md`(`type: wiki-index`)에 설계·결정 / 운영·워크플로우 / 리서치 / Q&A / 미분류. ingest 시 등록, ask 시 우선 참조, lint 시 미등록 노트 점검. GitHub diff에서도 읽히고 외부 플러그인 의존 없음.

### 세부 결정 (review — 사실관계 검토)
- 배경: LLM ingest는 사실관계 오류가 남을 수 있음(외부 기사·OCR 등).
- 대안: (1) frontmatter `review: pending|done` + `## 검토 필요`, (2) ingest 보고만.
- 근거(왜 둘 다): `pending`이면 검토 항목 bullet 작성, lint가 pending 목록·섹션 누락 보고, ask는 「검토 전 — 사실 확인 필요」 표시. 내부 설계·결정은 `done` 가능.

## kit-rule-mine과의 경계
- `kit-wiki` = 지식(무엇을 결정했나). 위키 노트는 에이전트 강제 규칙이 아니다.
- `kit-rule-mine` = 규칙 후보(어떻게 일할지) → HUMAN 승인 → `shared/rules` 승격.
- 두 명령은 결과물·파이프라인이 다르며 상호 보완한다.

## 산출물
- 스킬: `shared/skills/kit-wiki/SKILL.md`
- 규약: `docs/wiki/README.md`, 템플릿 `docs/wiki/_templates/wiki-note-template.md`
- index: `docs/wiki/index.md` (MOC 진입점)
- 슬래시: `/kit-wiki`는 스킬, `/kit-wiki-ask`는 명령 `project-kit/.cursor/commands/kit-wiki-ask.md`
- 훅: `shared/hooks/kit-wiki-on-prompt.ps1` (beforeSubmitPrompt, fail-open; index seed 포함)

## 후속 후보 (미구현)
- C1 커밋 전 시크릿 가드 훅
- 결정적 PowerShell 시크릿 스캐너
- C3 스케줄/PR 자동 lint
- (review 체크포인트는 2026-06-30 반영 완료)

## Vault
- [[index]] — 위키 MOC(목차)
- [[cursor-workspace-kit/docs/wiki/README|docs/wiki 규약]]
