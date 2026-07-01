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
| `docs/wiki/index.md` | 진입점 목차(MOC), `type: wiki-index` | **커밋** |
| `docs/wiki/*.md` | 정제된 위키 노트 (요약·결정·링크) | **커밋** |
| `docs/wiki/_raw/` | 대화 덤프·원문 (민감정보 가능) | **gitignore** |
| `docs/wiki/_templates/` | 노트 템플릿 | 커밋 |

- 파일명: `<topic-slug>.md` (kebab-case, ASCII 권장)
- 같은 주제는 **새 파일 대신 기존 노트 갱신**(중복 방지)

## index.md (MOC, 진입점)

`docs/wiki/index.md`는 고정 카테고리(설계·결정 / 운영·워크플로우 / 리서치 / Q&A / 미분류)로 노트를 모아 둔 목차다. frontmatter는 `type: wiki-index`.

- ingest: 새 노트는 알맞은 카테고리에 `[[slug]]` 한 줄 등록(기존 노트 갱신은 index 유지).
- ask: 폴더 탐색 전 index를 먼저 읽어 후보를 좁힘(없으면 폴더 폴백).
- lint: index 어느 카테고리에도 없는 노트(템플릿·index 제외)는 고아 후보로 보고·등록 제안.

## 카파시 3층

- **Raw** = `docs/wiki/_raw/` (원본, gitignore)
- **Wiki** = `docs/wiki/*.md` (LLM 정제 노트) + `docs/wiki/index.md`(MOC 진입점)
- **Schema** = 본 문서 + `kit-wiki` 스킬 + `AGENTS.md` 진입/경계

## frontmatter 스펙 (위키 노트)

```yaml
---
type: wiki-note
project: <slug>
status: active        # active | deprecated
review: pending       # pending | done — ingest 사실관계 검토 상태
tags: [...]
sources: ["chat:<날짜 또는 id>", "docs/..."]
updated_at: <ISO8601>
---
```

본문 섹션 권장: `## 요약`, `## 결정 (왜)`(배경/대안/근거), `## 세부`, `## 검토 필요`(review: pending일 때), `## Vault`(교차 링크).

## review (사실관계 검토)

ingest는 LLM이 정제하므로 **사실관계 오류**가 남을 수 있다. frontmatter `review`로 검토 상태를 추적한다.

| 값 | 의미 |
|---|---|
| `pending` | 사람 검토 전. 수치·날짜·인용·외부 사실 등 확인 필요 |
| `done` | 사람이 검토했거나, 오류 위험이 낮은 내부 결정·설계 기록 |

**`pending` 기본(권장):**
- 이미지/OCR/손글씨·캡처 등 비텍스트 원본에서 ingest
- 외부 기사·URL·논문 요약(원문 대조 안 함)
- 수치·날짜·고유명사·인용문이 핵심인 노트
- `_raw/` 원문 기반 첫 ingest
- 기존 노트에 **사실·결정 내용**을 크게 바꾸는 갱신

**`done` 가능:**
- 사용자가 채팅에서 직접 확정한 내부 설계·결정
- 검토 완료 후 사용자가 `review: done`으로 표시
- 오탈자·링크·frontmatter 등 사실과 무관한 경미 수정(기존 `done` 유지)

**ingest:** `review: pending`이면 본문 `## 검토 필요`에 확인할 항목을 bullet로 적는다. 사용자 보고에 **검토 필요 항목** 1~3줄을 포함한다.

**lint:** `review: pending` 노트 목록을 보고한다. `pending`인데 `## 검토 필요`가 없으면 섹션 추가를 제안한다.

**ask:** `review: pending` 노트를 인용할 때 **「검토 전 — 사실 확인 필요」** 를 함께 표시한다.

## redaction 정책 (필수)

커밋 대상 노트(`docs/wiki/*.md`)에는 민감정보를 넣지 않는다. ingest 시 마스킹한다.

- 절대 경로 → `[path]`
- 이메일 → `[email]`
- `sk-…` / 토큰 → `[secret]`
- `Bearer …` → `Bearer [redacted]`
- 고객 실명·내부 식별자·비밀값 → 일반화/마스킹

판단이 어려운 민감 원문은 `_raw/`(gitignore)에만 두고 노트엔 요약·결정만 남긴다.

### lint 점검용 정규식 패턴 (1차 안전장치)

`/kit-wiki lint`가 커밋 대상 노트에 시크릿/PII가 남았는지 아래 패턴으로 스캔한다. 자연어 지시만으로 놓칠 수 있어 명시한 1차 안전장치이며, 완벽하지 않으므로 사람 검토를 대체하지 않는다.

| 패턴(정규식) | 분류 | 처리 |
|---|---|---|
| `[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}` | 이메일 | → `[email]` (자동) |
| `sk-[A-Za-z0-9]{20,}` | OpenAI 류 키 | → `[secret]` (자동) |
| `AKIA[0-9A-Z]{16}` | AWS 액세스 키 | → `[secret]` (자동) |
| `Bearer\s+[A-Za-z0-9._-]+` | Bearer 토큰 | → `Bearer [redacted]` (자동) |
| `(?i)(token\|secret\|api[_-]?key\|password)\s*[:=]\s*\S+` | 일반 자격증명 | → `[secret]` (자동) |
| `([A-Za-z]:\\Users\\\|/Users/\|/home/)` | 절대 경로 | → `[path]` (자동) |
| `\b[0-9a-fA-F]{32,}\b` | 긴 hex(키·해시 의심) | 경고 → 확인 후 마스킹 |
| `\b(?:\d[ -]?){13,16}\b` | 카드번호 의심 | 경고 → 사용자 확인 |
| `\b\d{6}[- ]?\d{7}\b` | 주민번호류 의심 | 경고 → 사용자 확인 |

- 자동: 명백한 키/이메일/경로/토큰은 lint가 바로 마스킹.
- 경고: 카드/주민번호/긴 hex 등 오탐 가능성이 있는 항목은 위치만 보고하고 사용자 확인 후 처리.

## kit-rule-mine과의 경계

- 위키 노트 = **지식 기록**(무엇을 결정했나). 에이전트 강제 규칙이 아니다.
- 규칙으로 올릴 패턴(반복 보정·DoD 누락 등)은 `kit-rule-mine` → HUMAN 승인 → `shared/rules` 경로를 따른다([`docs/agent/rule-candidates.md`](../agent/rule-candidates.md)).

## Obsidian

`docs/wiki/`는 [`scripts/obsidian/sync-docs.ps1`](../../scripts/obsidian/sync-docs.ps1)이 볼트로 단방향 복제한다. Dataview는 `type: wiki-note` 기준으로 집계 가능.

## Vault

- [[cursor-workspace-kit/docs/cursor-workspace-kit-docs-hub|Hub]]
- [[cursor-workspace-kit/docs/obsidian/dashboards/projects-overview|Dashboards]]
