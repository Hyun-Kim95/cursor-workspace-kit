# security — 보안 게이트 스크립트 (kit 스텁)

제품이 `npm run security:ci` 등으로 구현하기 **전** 계약·파일 경로를 맞추는 kit 예시다.

## Invoke-SecurityGate.ps1

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/security/Invoke-SecurityGate.ps1 -WorkspaceRoot .
```

| 동작 | 설명 |
|------|------|
| policy 없음 | skip 메시지, 전 축 skipped, **exit 0** (fail-open) |
| policy 있음 | `enabled` 축만 게이트 대상; 스텁은 **실스캔 없이** `ok: true` + note |
| tier strict | `manualReview` pending, `blockers`에 구현 안내 — **ok: false** (엄격: 완료 선언 전 제품 구현 필요) |
| 산출 | `.cursor/state/security-last.json` (UTF-8 BOM 없음) |

## 제품 구현 시 (엄격)

1. `docs/security/security-policy.template.json` → `docs/requirements/security-policy.json`
2. 6축 `enabled: true`, `tier: strict`
3. `security:ci`에서 secrets·deps·sast 실행 + 수동 축은 [`strict-axis-checklist.md`](../../docs/security/strict-axis-checklist.md)
4. [`policy-and-contract.md`](../../docs/security/policy-and-contract.md) 스키마로 `security-last.json` 작성
5. (선택) [`Invoke-DeliveryLoop.ps1`](../delivery/Invoke-DeliveryLoop.ps1)로 반복
6. (권장) [`quality-gate.security.example.json`](../../project-kit/.cursor/quality-gate.security.example.json)을 `.cursor/quality-gate.json`에 병합

## 계약

- [`docs/qa/security-last.example.json`](../../docs/qa/security-last.example.json)
- [`docs/security/policy-and-contract.md`](../../docs/security/policy-and-contract.md)
