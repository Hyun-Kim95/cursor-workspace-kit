# -*- coding: utf-8 -*-
"""Build assets/ai-development-workflow.svg (UTF-8, no BOM)."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "ai-development-workflow.svg"

SVG_TEMPLATE = """<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1600 980" role="img" aria-label="AI Development Workflow">
  <defs>
    <linearGradient id="bg" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#0a1020"/><stop offset="45%" stop-color="#0d1528"/><stop offset="100%" stop-color="#0a0f1a"/>
    </linearGradient>
    <linearGradient id="titleGrad" x1="0%" y1="0%" x2="100%" y2="0%">
      <stop offset="0%" stop-color="#93c5fd"/><stop offset="50%" stop-color="#a78bfa"/><stop offset="100%" stop-color="#34d399"/>
    </linearGradient>
    <linearGradient id="cardFill" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#1a2540"/><stop offset="100%" stop-color="#121b2e"/>
    </linearGradient>
    <linearGradient id="kitFill" x1="0%" y1="0%" x2="100%" y2="0%">
      <stop offset="0%" stop-color="#1e1b3a"/><stop offset="100%" stop-color="#151d2e"/>
    </linearGradient>
    <filter id="cardShadow" x="-20%" y="-20%" width="140%" height="140%">
      <feDropShadow dx="0" dy="8" stdDeviation="12" flood-color="#000" flood-opacity="0.45"/>
    </filter>
    <filter id="glowBlue"><feDropShadow dx="0" dy="0" stdDeviation="3" flood-color="#4f8ffa" flood-opacity="0.55"/></filter>
    <filter id="glowRed"><feDropShadow dx="0" dy="0" stdDeviation="2.5" flood-color="#f04444" flood-opacity="0.45"/></filter>
    <marker id="arrowFwd" markerWidth="10" markerHeight="10" refX="8" refY="5" orient="auto" markerUnits="strokeWidth"><path d="M0,0 L10,5 L0,10 Z" fill="#5b9cff"/></marker>
    <marker id="arrowReg" markerWidth="10" markerHeight="10" refX="8" refY="5" orient="auto" markerUnits="strokeWidth"><path d="M0,0 L10,5 L0,10 Z" fill="#f87171"/></marker>
    <marker id="arrowKit" markerWidth="10" markerHeight="10" refX="8" refY="5" orient="auto" markerUnits="strokeWidth"><path d="M0,0 L10,5 L0,10 Z" fill="#a78bfa"/></marker>
    <style>
      .title { font: 800 42px 'Segoe UI','Malgun Gothic',sans-serif; fill: url(#titleGrad); }
      .subtitle { font: 500 14px 'Segoe UI','Malgun Gothic',sans-serif; fill: #8b9ab0; }
      .node-title { font: 800 17px 'Segoe UI','Malgun Gothic',sans-serif; fill: #eef3fb; }
      .node-id { font: 700 13px 'Segoe UI',sans-serif; fill: #8fa4c4; }
      .node-desc { font: 500 12px 'Segoe UI','Malgun Gothic',sans-serif; fill: #b8c6e2; }
      .edge-label { font: 700 12px 'Segoe UI','Malgun Gothic',sans-serif; fill: #dbeafe; }
      .edge-label-reg { fill: #fecaca; }
      .legend { font: 600 12px 'Segoe UI','Malgun Gothic',sans-serif; fill: #9bb0d3; }
      .kit-title { font: 800 13px 'Segoe UI','Malgun Gothic',sans-serif; fill: #c4b5fd; letter-spacing: .06em; }
      .kit-step-t { font: 700 12px 'Segoe UI','Malgun Gothic',sans-serif; fill: #eef3fb; }
      .kit-step-d { font: 500 10px 'Segoe UI','Malgun Gothic',sans-serif; fill: #8b9ab0; }
      .kit-note { font: 500 11px 'Segoe UI','Malgun Gothic',sans-serif; fill: #7d8fa8; }
    </style>
  </defs>
  <rect width="1600" height="980" fill="url(#bg)"/>
  <circle cx="120" cy="80" r="280" fill="#4f8ffa" opacity="0.06"/>
  <circle cx="1480" cy="120" r="240" fill="#7c6ff7" opacity="0.07"/>
  <text x="800" y="52" text-anchor="middle" class="title">AI Development Workflow</text>
  <text x="800" y="78" text-anchor="middle" class="subtitle">cursor-workspace-kit \u00b7 Gate \u00b7 \ubd84\uae30 \u00b7 \ud68c\uadc0 \u00b7 \ud15c\ud074\ub9bf \ubc1c\uc804</text>
  <g transform="translate(80,96)">
    <line x1="0" y1="0" x2="36" y2="0" stroke="#5b9cff" stroke-width="3"/><text x="44" y="4" class="legend">\uc804\uc9c4 (\uc2e4\uc120)</text>
    <line x1="140" y1="0" x2="176" y2="0" stroke="#f87171" stroke-width="2.5" stroke-dasharray="7 5"/><text x="184" y="4" class="legend">\ud68c\uadc0 (\uc810\uc120)</text>
    <line x1="300" y1="0" x2="336" y2="0" stroke="#a78bfa" stroke-width="3"/><text x="344" y="4" class="legend">\ud15c\ud074\ub9bf \ubc1c\uc804</text>
  </g>
  <g fill="none" stroke-linecap="round" stroke-linejoin="round">
    <path d="M 145 352 L 145 200 L 320 200" stroke="#5b9cff" stroke-width="2.5" marker-end="url(#arrowFwd)" filter="url(#glowBlue)"/><text x="200" y="188" class="edge-label">\ucd08\uae30 \ucc29\uc218</text>
    <path d="M 240 352 L 320 352" stroke="#5b9cff" stroke-width="2.5" marker-end="url(#arrowFwd)" filter="url(#glowBlue)"/><text x="255" y="340" class="edge-label">\uac1c\uc120 \ucc29\uc218</text>
    <path d="M 145 410 L 145 520 L 580 520 L 580 465" stroke="#5b9cff" stroke-width="2.5" marker-end="url(#arrowFwd)" filter="url(#glowBlue)"/><text x="300" y="512" class="edge-label">\ubc84\uadf8 \uc218\uc815 \ucc29\uc218</text>
    <path d="M 510 127 L 840 127" stroke="#5b9cff" stroke-width="2.5" marker-end="url(#arrowFwd)" filter="url(#glowBlue)"/><text x="640" y="115" class="edge-label">PRD \uc2b9\uc778</text>
    <path d="M 930 185 L 930 295" stroke="#5b9cff" stroke-width="2.5" marker-end="url(#arrowFwd)" filter="url(#glowBlue)"/><text x="948" y="248" class="edge-label">\uc120\ud0dd \uc644\ub8cc</text>
    <path d="M 415 410 L 415 455 L 930 455 L 930 410" stroke="#5b9cff" stroke-width="2.5" marker-end="url(#arrowFwd)" filter="url(#glowBlue)"/><text x="640" y="448" class="edge-label">RED\u00b7\uad6c\ud604</text>
    <path d="M 510 352 L 580 352" stroke="#5b9cff" stroke-width="2.5" marker-end="url(#arrowFwd)" filter="url(#glowBlue)"/><text x="520" y="340" class="edge-label">\ubcf4\uc644</text>
    <path d="M 580 368 L 510 368" stroke="#5b9cff" stroke-width="2.5" marker-end="url(#arrowFwd)" filter="url(#glowBlue)"/><text x="518" y="384" class="edge-label">\ub2e4\uc2dc \ucc29\uc218</text>
    <path d="M 675 295 L 675 185 L 415 185" stroke="#5b9cff" stroke-width="2.5" marker-end="url(#arrowFwd)" filter="url(#glowBlue)"/><text x="520" y="178" class="edge-label">PRD \uc218\uc815</text>
    <path d="M 1030 352 L 1100 352" stroke="#5b9cff" stroke-width="2.5" marker-end="url(#arrowFwd)" filter="url(#glowBlue)"/><text x="1040" y="340" class="edge-label">\uac80\uc218</text>
    <path d="M 770 520 L 1100 520 L 1195 520 L 1195 410" stroke="#5b9cff" stroke-width="2.5" marker-end="url(#arrowFwd)" filter="url(#glowBlue)"/><text x="920" y="512" class="edge-label">\uac80\uc218</text>
    <path d="M 840 155 L 510 155" stroke="#f87171" stroke-width="2.2" stroke-dasharray="8 6" marker-end="url(#arrowReg)" filter="url(#glowRed)"/><text x="640" y="148" class="edge-label edge-label-reg">PRD \uc218\uc815</text>
    <path d="M 1100 380 L 1030 380" stroke="#f87171" stroke-width="2.2" stroke-dasharray="8 6" marker-end="url(#arrowReg)" filter="url(#glowRed)"/><text x="1045" y="372" class="edge-label edge-label-reg">\ub2e4\uc2dc \uad6c\ud604</text>
    <path d="M 1195 410 L 1195 660 L 415 660 L 415 410" stroke="#f87171" stroke-width="2.2" stroke-dasharray="8 6" marker-end="url(#arrowReg)" filter="url(#glowRed)"/><text x="780" y="652" class="edge-label edge-label-reg">\ub2e4\uc2dc \ucc29\uc218</text>
    <path d="M 1195 410 L 1195 600 L 770 600 L 770 520" stroke="#f87171" stroke-width="2.2" stroke-dasharray="8 6" marker-end="url(#arrowReg)" filter="url(#glowRed)"/><text x="980" y="592" class="edge-label edge-label-reg">\uc7ac\uc218\uc815</text>
    <path d="M 1245 410 L 1245 720 L 145 720 L 145 410" stroke="#f87171" stroke-width="2.2" stroke-dasharray="8 6" marker-end="url(#arrowReg)" filter="url(#glowRed)"/><text x="680" y="712" class="edge-label edge-label-reg">\uc7ac\ubd84\ub958</text>
  </g>
  <g filter="url(#cardShadow)">
__NODES__
  </g>
  <g transform="translate(60,780)">
    <rect width="1480" height="170" rx="16" fill="url(#kitFill)" stroke="#5b21b6" stroke-width="1"/>
    <text x="24" y="32" class="kit-title">\ud15c\ud074\ub9bf \ubc1c\uc804 \ub8e8\ud504 \u00b7 KIT EVOLUTION</text>
__KIT__
    <path d="M 1090 81 L 1320 81 L 1320 130 L 207 130 L 207 110" fill="none" stroke="#a78bfa" stroke-width="2" marker-end="url(#arrowKit)"/>
    <text x="740" y="148" text-anchor="middle" class="kit-note">/kit-start \u2192 \uc77c\uc0c1 \uac1c\ubc1c \ud658\ub958 \u00b7 emergent-rule-capture \u2192 HUMAN \u2192 SSOT</text>
  </g>
</svg>"""


def node(x, y, accent, stroke, sw, title, pid, desc1, desc2=None, highlight=False):
    hl = f' stroke="{accent}" stroke-width="1.6"' if highlight else f' stroke="{stroke}" stroke-width="{sw}"'
    lines = [
        f'    <g transform="translate({x}, {y})">',
        f'      <rect width="190" height="115" rx="14" fill="url(#cardFill)"{hl}/>',
        f'      <rect width="190" height="4" rx="2" fill="{accent}" opacity="0.9"/>',
        f'      <text x="16" y="36" class="node-title">{title}</text>',
        f'      <text x="128" y="36" class="node-id">({pid})</text>',
        f'      <text x="16" y="58" class="node-desc">{desc1}</text>',
    ]
    if desc2:
        lines.append(f'      <text x="16" y="76" class="node-desc">{desc2}</text>')
    lines.append("    </g>")
    return "\n".join(lines)


def kit_step(x, w, title, desc, accent="#334155"):
    cx = w // 2
    return f'''      <g transform="translate({x},52)">
        <rect width="{w}" height="58" rx="10" fill="#151d2e" stroke="{accent}" stroke-width="1"/>
        <text x="{cx}" y="24" text-anchor="middle" class="kit-step-t">{title}</text>
        <text x="{cx}" y="42" text-anchor="middle" class="kit-step-d">{desc}</text>
      </g>'''


def main():
    nodes = "\n".join([
        node(320, 70, "#4f8ffa", "#2d4470", 1.2, "PRD \uc791\uc131", "p2", "Gate 1 \u00b7 PRD+AC \u00b7 HUMAN \uc2b9\uc778"),
        node(840, 70, "#4f8ffa", "#2d4470", 1.2, "\uc774\uc911 \ubaa9\uc5c5\u00b7\uc815\ud569", "p3", "\uc120\ud0dd \uc804 \u00b7 PRD\u00b7\uc694\uad6c \uc815\ud569"),
        node(50, 295, "#4f8ffa", "#2d4470", 1.2, "\uc694\uccad \ubd84\uae30", "p1", "E2E \u00b7 \uc2e0\uadc0/\uac1c\uc120 \u00b7 \ubc84\uadf8", "\uac04\ub2e8 \uc218\uc815 \ubd84\uae30", True),
        node(320, 295, "#4f8ffa", "#2d4470", 1.2, "\ucc29\uc218 \ubb38\uc11c \ud655\uc778", "p5", "Gate 1 \u00b7 \uc694\uad6c\u00b7\ud654\uba74\u00b7API\u00b7AC"),
        node(580, 295, "#4f8ffa", "#2d4470", 1.2, "\uc694\uad6c\u00b7\uc2a4\ud3ed \ubcf4\uc644", "p8", "\ubb38\uc11c \ubcf4\uac15 \u00b7 \ud06c\uba74 PRD\ub85c"),
        node(840, 295, "#22c87a", "#22c87a", 1.4, "\uc81c\ud488 \uad6c\ud604", "p4", "Gate 2 \u00b7 ATDD RED", "FE/BE \ubcd1\ub82c \u00b7 GREEN"),
        node(1100, 295, "#22c87a", "#22c87a", 1.4, "\uc644\ub8cc \ud310\uc815", "p7", "Gate 3 \u00b7 AC \ucee4\ubc84\ub9ac"),
        node(580, 520, "#f5a623", "#2d4470", 1.2, "\ubc84\uadf8 \uc218\uc815", "p6", "bugfix-flow \u00b7 \uac04\ub2e8 \uc218\uc815"),
    ])

    kit = [
        (24, 118, "/start-setting", "\uc81c\ud488 \uc628\ub354\ub529", "#4c1d95"),
        (172, 118, "\uc77c\uc0c1 \uac1c\ubc1c", "\uc704 \uc6cc\ud06c\ud074\ub9ac\uc6b0"),
        (320, 148, "\uaddc\uce59 \uc2e0\ud638 \uc218\uc9d1", "\uc2e4\uc2dc\uac04 + /kit-rule-mine"),
        (498, 118, "HUMAN \uc2b9\uc778", "\uc2b9\uc778 / \ubc18\ub824"),
        (646, 118, "SSOT \uc2b9\uaca9", "shared/* \ud3b8\uc9d1"),
        (794, 118, "sync-kit", "\ub3d9\uae30\ud654"),
        (942, 118, "/kit-start", "\uc81c\ud488 \ubc30\ud3ec"),
    ]
    kit_parts = []
    for i, (x, w, t, d, *rest) in enumerate(kit):
        accent = rest[0] if rest else "#334155"
        kit_parts.append(kit_step(x, w, t, d, accent))
        if i < len(kit) - 1:
            nx = x + w + 8
            kit_parts.append(f'      <text x="{nx}" y="84" fill="#a78bfa" font-size="18" font-weight="700">\u2192</text>')

    kit_body = "\n".join(kit_parts)

    svg = SVG_TEMPLATE.replace("__NODES__", nodes).replace("__KIT__", kit_body)

    OUT.write_text(svg, encoding="utf-8")
    print(f"Wrote {OUT}")


if __name__ == "__main__":
    main()
