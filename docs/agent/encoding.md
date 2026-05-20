# 텍스트 인코딩 (UTF-8) — kit·제품 공통

GitHub에 한글이 `?` 또는 깨진 글자로 보일 때의 **예방·복구** SSOT이다.

## kit이 하는 일

| 항목 | 경로 | 제품에 전달 |
|------|------|-------------|
| 에이전트 규칙 | `shared/rules/encoding-utf8-global.mdc` | 채널 B: 전체 rules sync · 채널 A: 이 파일만 추가 sync |
| 에디터 힌트 | `project-kit/.editorconfig` | `/start-setting`·`sync-kit-product` (없을 때만 복사) |
| Git 텍스트 정규화 | `project-kit/.gitattributes` | 동일 |
| 스크립트 헬퍼 | `scripts/Kit-HookCommon.ps1` | submodule 경로 `vendor/.../scripts/` (훅·스크립트가 dot-source) |

규칙 본문: [`.cursor/rules/encoding-utf8-global.mdc`](../../.cursor/rules/encoding-utf8-global.mdc) (kit 레포는 `scripts/sync-rules.ps1` 후)

## 에이전트

- 파일 생성·수정 시 **UTF-8, BOM 없음** 기본.
- 이미 깨진 파일은 추측 복구하지 않고 사용자에게 알림.
- PowerShell 5.1: `Read-KitUtf8File` / `Write-KitUtf8File` / `Write-KitJsonFile` 사용 (`Set-Content -Encoding UTF8`만으로 BOM 없음을 보장하지 않음).

## 제품 레포 온보딩 후 확인

1. 루트에 `.editorconfig`, `.gitattributes`가 있는지 (없으면 `/start-setting` 또는 `/start` sync 재실행).
2. `.cursor/rules/encoding-utf8-global.mdc`가 있는지 (채널 A도 sync 시 복사됨).
3. Cursor **Settings → Files: Encoding** = `utf8`, **Auto Guess Encoding** = off 권장.

## Git (Windows, 권장)

```bash
git config --global i18n.commitEncoding utf-8
git config --global i18n.logOutputEncoding utf-8
git config --global core.quotepath false
```

PowerShell 5.1에서 `git` 출력을 문자열로 받을 때는 CP949 디코딩을 피한다. 예: `scripts/obsidian/write-commit-journal.ps1`의 `Run-Git`(stdout을 UTF-8 바이트로 읽기).

## 훅·Cursor UI

- 훅 stdout: `Initialize-KitHookConsole` ([`kit-start.md`](kit-start.md) Windows 절).
- `.cursor-kit.json` 등 JSON 상태 파일: UTF-8 **BOM 없음** ([`harness-layer1.md`](harness-layer1.md)).

## 관련

- [`product-assumptions.md`](product-assumptions.md) — 사업자·수익 기본 전제
- [`kit-inventory.md`](kit-inventory.md)
- [`product-onboarding.md`](product-onboarding.md)
- [`rules-deploy.md`](rules-deploy.md)
