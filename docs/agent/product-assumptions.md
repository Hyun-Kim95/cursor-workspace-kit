# 제품·사업 전제 (기본값)

에이전트가 **계획·PRD·실행 계획**을 짤 때 쓰는 기본 전제 SSOT이다.

## 수익·사업자

| 항목 | 기본값 |
|------|--------|
| 사업자 | 없음 (개인사업자·법인 없음) |
| 수익 | 광고 + 후원(기부) 수준만 |
| 기본 제외 | 유료 구독·결제·세금계산서·사업자 정산·B2B 청구 등 |

규칙: [`shared/rules/product-monetization-default.mdc`](../../shared/rules/product-monetization-default.mdc)  
sync 후: `.cursor/rules/product-monetization-default.mdc`

**다른 모델**(유료 구독·사업자 등록·PG)을 쓰려면 채팅에서 **명시**한다. 에이전트는 그때 전제를 갱신하고 PRD에 기록한다.

## 배포

- 채널 B: `shared/rules` 전체 sync
- 채널 A: `project-kit` 게이트 rules + `encoding-utf8-global.mdc` + **`product-monetization-default.mdc`** (`sync-kit-product.ps1`)

## 관련

- [`encoding.md`](encoding.md) — UTF-8
- [`plan-feature`](../../shared/skills/plan-feature/SKILL.md), [`prd-agent`](../../shared/agents/prd-agent.md)
- [`AGENTS.md`](../../AGENTS.md)
