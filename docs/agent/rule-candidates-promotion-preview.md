# 규칙 후보 승격 미리보기 (HUMAN)

**기준:** 2026-05-29 배치 마이닝 · `docs/agent/rule-candidates.ndjson` 27건 · kit SSOT 수동 승격([`rule-candidates.md`](rule-candidates.md))  
**주의:** `규칙 승인` 훅만 누르면 기존 `shared/skills/.../SKILL.md`는 **거의 수정되지 않음**. 아래 초안대로 **직접 편집** → `scripts/sync-kit.ps1` → ndjson에서 **반려** 처리 권장.

---

## 요약

| 판정 | 건수 | 조치 |
|------|------|------|
| 이미 반영됨 | 3 클러스터 | ndjson **반려** (중복) |
| kit 승격 권장 | 4항목 (스킬/규칙) | 아래 문장 **복사·붙여넣기** |
| 제품 전용 | 20 클러스터 | ndjson **반려** (해당 제품 레포만) |

---

## A. 이미 반영됨 → `규칙 반려` 권장

| 후보 ID | 클러스터 | hits | 이유 | 대응 |
|---------|----------|------|------|------|
| `rc_mined_4` | repeat_fail\|sync | 19 | verify-change **8**과 동일 | 반려 |
| `rc_mined_15`, `rc_mined_16` | omission/sync, scope_reopen\|sync | 9+9 | sync·점검은 8·9로 커버 | 반려 |
| `rc_mined_12`, `rc_mined_22` | repeat_fail/omission\|encoding | 11+5 | verify-change **10**과 동일 | 반려 |

**반려 예시 (채팅):** `규칙 반려 rc_mined_4 사유: verify-change 8번과 중복`

---

## B. kit 승격 — `shared/skills/verify-change/SKILL.md`

**삽입 위치:** 현재 **10번 다음**, 기존 11·12(qa-agent·되돌리기) **앞**에 13·14 추가 후 번호 유지.

### 붙일 문장 (전체)

```markdown
13. 다단계·병렬 작업을 마무리할 때 **완료 항목 / 미완 항목 / 다음 액션**을 한 블록으로 보고하고, 실행 계획·todo와 불일치가 없는지 확인한다.
14. 완료·검증 완료를 선언하기 전, 사용자가 「여전히」「아직」「다시 확인」이라고 하기 쉬운 항목(요구 대비 구현, 상태 UI, sync·문서, 인코딩)을 체크리스트로 짚고, 빈 항목이 있으면 완료 선언하지 않는다.
```

### 매핑된 후보 (승격 후 ndjson 반려)

| 후보 ID | 클러스터 | hits | 13·14 중 |
|---------|----------|------|----------|
| `rc_mined_0` | repeat_fail\|general | 49 | **14** |
| `rc_mined_9` | recheck\|sync | 13 | **13** |
| `rc_mined_20` | recheck\|api | 6 | **13** |
| `rc_mined_21` | recheck\|darkmode | 6 | **13** |
| `rc_mined_2` | recheck\|general | 24 | 13·14 일부 |
| `rc_mined_8` | omission\|general | 15 | 14 (메타·마이닝 맥락) |

**반려 예시:** `규칙 반려 rc_mined_0 사유: verify-change 14번으로 승격`

---

## C. kit 승격 — `shared/skills/document-change/SKILL.md`

**삽입 위치:** `## 작업 절차` → `### 1) 병렬 작업 동기화 선확인` **앞**에 소절 추가.

### 붙일 문장

```markdown
### 0) 요구·문서·구현 삼각 점검

PRD·Gate·API·스킬/규칙·README를 건드린 변경은 **요구 ↔ 문서 ↔ 구현**이 맞는지 spot check한다. 「PRD 빠짐」「문서 반영」「범위 아니었나」 재지적이 나오기 쉬운 구간이다.
```

### 매핑된 후보

| 후보 ID | 클러스터 | hits |
|---------|----------|------|
| `rc_mined_6` | omission\|docs | 17 |
| `rc_mined_11` | repeat_fail\|docs | 11 |
| `rc_mined_18` | recheck\|docs | 7 |
| `rc_mined_24` | scope_reopen\|docs | 4 |

(`rc_mined_24`는 규칙 SSOT 정리 맥락 — document-change + [`rule-candidates.md`](rule-candidates.md) 링크로도 충분)

---

## D. kit 승격 (선택) — `shared/rules/working-principles.mdc`

**삽입 위치:** `## 출력/승인/상태 전환 규칙` 절 끝에 불릿 1개.

### 붙일 문장

```markdown
- 사용자 메시지에 **새 범위·추가 구현**이 섞였을 때, 기존 미완과 구분해 **범위 재확인**(Gate 1 간이 점검 또는 짧은 확인 질문) 후 진행한다. 「이것도 해줘」「추가로」만 보고 이전 완료를 가정하지 않는다.
```

### 매핑된 후보

| 후보 ID | 클러스터 | hits |
|---------|----------|------|
| `rc_mined_13` | scope_reopen\|general | 10 |
| `rc_mined_14` | scope_reopen\|test | 10 |
| `rc_mined_17` | scope_reopen\|sync | 9 |
| `rc_mined_23` | scope_reopen\|api | 4 |
| `rc_mined_25` | scope_reopen\|encoding | 3 |
| `rc_mined_18` | scope_reopen\|darkmode | 8 |

**미확정:** 전역 규칙 비대화를 피하려면 **D는 생략**하고, 제품별로 `plan-feature`만 써도 됨.

---

## E. 제품 전용 → `규칙 반려` (kit SSOT에 넣지 않음)

아래는 트랜스크립트에 **특정 앱/화면/API** 맥락이 강함. 해당 제품 레포 PRD·버그 플로우에서만 다룬다.

| 후보 ID | 클러스터 | hits | 샘플 맥락 |
|---------|----------|------|-----------|
| `rc_mined_1` | repeat_fail\|test | 26 | 통계 그래프·UI 잘림 |
| `rc_mined_3` | repeat_fail\|api | 20 | Disconnected, 통계 날짜 |
| `rc_mined_5` | omission\|test | 19 | PRD 정책(제품) |
| `rc_mined_7` | recheck\|test | 16 | 커밋·구독·MCP(제품) |
| `rc_mined_10` | omission\|api | 12 | 통계·과거기록 UI |
| `rc_mined_15` | omission\|sync | 9 | 신한 indi connected (제품) |
| `rc_mined_17` | scope_reopen\|sync | 9 | aab·출시 체크(제품) |
| `rc_mined_18` | scope_reopen\|darkmode | 8 | 신고 카테고리 UI |
| `rc_mined_19` | omission\|darkmode | 7 | Stitch 경로(제품 조사) |
| `rc_mined_22` | recheck\|darkmode | 6 | todo·다크 UI(제품) |
| `rc_mined_26` | repeat_fail\|darkmode | 3 | 다른 프로젝트 kit 미적용 |

**일괄 반려 예시:** 제품별로 묶어 `규칙 반려 rc_mined_1 사유: 제품 UI 전용` 반복.

---

## F. 실행 체크리스트 (승인 전 미리보기 = 이 문서)

1. [x] **B** — `shared/skills/verify-change/SKILL.md`에 11·12 추가 (기존 13·14를 11·12로 삽입, qa·되돌리기는 13·14)  
2. [x] **C** — `shared/skills/document-change/SKILL.md`에 `### 0)` 추가  
3. [ ] (선택) **D** — `shared/rules/working-principles.mdc` 불릿 1개 — **생략**  
4. [x] `powershell -NoProfile -File scripts/sync-kit.ps1`  
5. [x] ndjson 전건 `rejected` + `docs/agent/rule-approvals.md` 로그  
6. [ ] 30일 후 `/kit-rule-mine` 재실행 → 동일 클러스터 hits 감소 확인  

---

## G. `verify-change` 적용 후 절차 번호 (참고)

적용 후 절차는 대략 다음 순서가 됩니다.

1~10 — 기존 (Gate 3, 상태 UI, …, sync, quality-gate, UTF-8)  
**11~12 — 신규 (위 B, 마이닝 2차)**  
13 — qa-agent  
14 — 되돌리기  

`(8~10: 마이닝 1차 승격 — [`rule-mined-kit-promotion.md`](rule-mined-kit-promotion.md))`

---

## 관련

- 집계: [`.cursor/state/rule-mined-report.md`](../../.cursor/state/rule-mined-report.md)
- 후보 원본: `docs/agent/rule-candidates.ndjson` (gitignore)
- 승격 절차 SSOT: [`rule-candidates.md`](rule-candidates.md)
