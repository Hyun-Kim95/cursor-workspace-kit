# 1차 트랜스크립트 마이닝 → kit 승격 기록

**실행:** `Invoke-TranscriptRuleMining.ps1` (전체 `%USERPROFILE%\.cursor\projects`, 337 files, 5882 user lines)  
**일시:** 2026-05-29 (로컬 1회)  
**집계:** 27 clusters → `docs/agent/rule-candidates.ndjson` (`-ImportToCandidates`)

## HUMAN 검토 요약

제품별 이슈(로그인·통계·에뮬레이터 등)는 **해당 제품 레포** 후보로 두고, kit 템플릿에 공통으로 승격한 항목만 아래에 기록한다.

| 마이닝 클러스터 (요약) | hits | kit 승격 |
|------------------------|------|----------|
| `omission\|sync`, `recheck\|sync` | 9~19 | `verify-change` 8 — SSOT 수정 후 sync 실행·보고 |
| `repeat_fail\|general` (+ quality gate 맥락) | 49 | `verify-change` 9 — `quality-gate-last.json` ok 확인 |
| `repeat_fail\|encoding`, `omission\|encoding` | 5~11 | `verify-change` 10 — UTF-8/한글 diff 확인 |

미승격(예): `document-change` 대상 `omission|docs`, 제품 UI `repeat_fail|test` — 제품/PRD 작업 시 해당 스킬·Gate로 처리.

## 재측정

30일 후 동일 스크립트 재실행 → 동일 `cluster_key` 빈도 감소 여부 확인.
