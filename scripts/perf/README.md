# perf — 성능 게이트 스크립트 (kit 스텁)

제품이 `npm run perf:ci` 등으로 구현하기 **전** 계약·파일 경로를 맞추는 kit 예시다.

## Invoke-PerfGate.ps1

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/perf/Invoke-PerfGate.ps1 -WorkspaceRoot .
```

| 동작 | 설명 |
|------|------|
| budget 없음 | skip 메시지, `perf-last.json` 전 플랫폼 skipped, **exit 0** (fail-open) |
| budget 있음 | `enabled` 플랫폼만 게이트 대상; 스텁은 **실측 없이** `ok: true` + empty metrics |
| 산출 | `.cursor/state/perf-last.json` (UTF-8 BOM 없음) |

## 제품 구현 시

1. `docs/performance/perf-budget.template.json` → `docs/requirements/perf-budget.json`
2. `perf:ci`에서 web(Lighthouse/bundle), app(size), api(k6) 실행
3. [`docs/performance/policy-and-contract.md`](../../docs/performance/policy-and-contract.md) 스키마로 `perf-last.json` 작성
4. (선택) [`Invoke-DeliveryLoop.ps1`](../delivery/Invoke-DeliveryLoop.ps1)로 반복

## 계약

- [`docs/qa/perf-last.example.json`](../../docs/qa/perf-last.example.json)
- [`docs/performance/policy-and-contract.md`](../../docs/performance/policy-and-contract.md)
