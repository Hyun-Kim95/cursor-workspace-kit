# Agent scripts

## Invoke-TranscriptRuleMining.ps1

로컬 Cursor `agent-transcripts` JSONL에서 **암묵적 보정 신호**(빠뜨림·재확인·반복 실패 등)를 집계한다.  
규칙 SSOT에 자동 반영하지 않는다 — [`docs/agent/rule-candidates.md`](../../docs/agent/rule-candidates.md).

### 실행 예

**터미널 없이:** Cursor 채팅에 `/kit-rule-mine` 또는 `/kit-rule-mine import` ( [`docs/agent/rule-candidates.md`](../../docs/agent/rule-candidates.md) ).

```powershell
# 기본: %USERPROFILE%\.cursor\projects 전체, 리포트만
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/agent/Invoke-TranscriptRuleMining.ps1

# 최근 90일 + pending 후보 ndjson 병합
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/agent/Invoke-TranscriptRuleMining.ps1 -SinceDays 90 -ImportToCandidates

# 파일 상한 (대량 환경)
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/agent/Invoke-TranscriptRuleMining.ps1 -MaxFiles 2000
```

### 출력

| 경로 | 설명 |
|------|------|
| `.cursor/state/rule-mined-report.json` | 집계 JSON |
| `.cursor/state/rule-mined-report.md` | 요약 표 |
| `docs/agent/rule-candidates.ndjson` | `-ImportToCandidates` 시만 (gitignore) |

### 프라이버시

- 트랜스크립트는 **로컬만** 읽는다.
- 스니펫은 경로·이메일·키를 redact 한다.
- 리포트·ndjson은 **커밋하지 않는다.**

### 2,500+ user 메시지

`-SinceDays 90` 또는 `-MaxFiles`로 범위를 나누고, 상위 클러스터만 HUMAN 검토 후 `shared/skills`에 승격한다.

### 테스트

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/agent/Test-TranscriptRuleMining.ps1
```
