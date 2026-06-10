---
type: doc
project: cursor-workspace-kit
doc_lane: work-log
updated_at: 2026-06-10T12:00:00
tags: [docs, work-log, vault-sync]
---

# work-log

날짜별 **작업 일지**를 남기는 폴더다. 나중에 **가장 최근 `YYYY-MM-DD.md`** 를 열어 오늘(또는 해당일) 무엇을 했는지, 어떻게 했는지, 무엇이 남았는지 빠르게 파악한다.

## `changelog`·`document-change`와 구분

| | work-log | changelog | document-change |
|--|----------|-----------|-----------------|
| 단위 | **하루** (세션 append 가능) | 월·릴리즈 | 작업·변경 1건 |
| 목적 | 내 작업 맥락·잔여 | 제품 변경 이력 | 팀 전달·계약 동기화 |
| 파일 | `docs/work-log/YYYY-MM-DD.md` | `docs/changelog/YYYY-MM.md` | (고정 경로 없음) |

커밋 저널(Obsidian `journal/`)은 **커밋 단위** 자동 기록이다. 의도·미커밋·남은 작업은 work-log에 남긴다.

## 파일 규칙

- **파일명:** `YYYY-MM-DD.md` (로컬 날짜 기준)
- **같은 날 여러 세션:** 새 파일을 만들지 않고 **같은 날짜 파일에 `## Session HH:mm` 섹션을 append**
- **템플릿:** [`templates/daily-work-log-template.md`](templates/daily-work-log-template.md)
- **인코딩:** UTF-8 (BOM 없음)

## 작성 방법 (권장)

세션·하루 마무리 시 채팅 맨 앞에:

```text
/kit-work-log
/kit-work-log 오늘 워크플로 다이어그램 작업 정리
/work-log
작업 일지
```

에이전트는 [`kit-work-log`](../../shared/skills/kit-work-log/SKILL.md) 스킬을 따른다. 채팅 `/` 입력 시 **`kit-work-log`** 가 자동완성에 뜬다(스킬 + `.cursor/commands/kit-work-log.md`). 상세 변경 설명이 필요하면 [`document-change`](../../shared/skills/document-change/SKILL.md) 섹션을 참고해 보강한다.

### 날짜 지정 (선택)

```text
/kit-work-log 2026-06-09
/kit-work-log date:2026-06-09 어제 마무리 못 한 내용 정리
```

## 빠른 확인

1. 탐색기·IDE에서 `docs/work-log/` 정렬 → **맨 아래(최신 날짜) 파일** 열기
2. **「남은 작업 / 다음 액션」** 섹션부터 읽기
3. Obsidian 사용 시 `docs/` sync 후 볼트에서 동일 경로 조회 가능

## 훅 (kit 레포)

`beforeSubmitPrompt` → `.cursor/hooks/work-log-on-prompt.ps1`  
제품 레포에서도 쓰려면 동일 훅 파일을 `.cursor/hooks/`에 두고 `hooks.json`에 슬롯을 추가한다(`sync-hooks.ps1`로 harness와 함께 복사 가능).

## Vault

- [[cursor-workspace-kit/docs/cursor-workspace-kit-docs-hub|Hub]]
- [[cursor-workspace-kit/docs/obsidian/dashboards/projects-overview|Dashboards]]
