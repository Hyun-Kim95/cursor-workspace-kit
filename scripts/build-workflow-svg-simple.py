# -*- coding: utf-8 -*-
"""Simplified workflow infographic: flow + regression + HUMAN gates."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT_SVG = ROOT / "assets" / "ai-development-workflow-simple.svg"

SVG = """<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1400 820" role="img" aria-label="AI Development Workflow (Simplified)">
  <defs>
    <linearGradient id="bg" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#0a1020"/>
      <stop offset="100%" stop-color="#0d1528"/>
    </linearGradient>
    <linearGradient id="titleGrad" x1="0%" y1="0%" x2="100%" y2="0%">
      <stop offset="0%" stop-color="#93c5fd"/>
      <stop offset="55%" stop-color="#a78bfa"/>
      <stop offset="100%" stop-color="#34d399"/>
    </linearGradient>
    <linearGradient id="card" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#1a2540"/>
      <stop offset="100%" stop-color="#121b2e"/>
    </linearGradient>
    <filter id="shadow"><feDropShadow dx="0" dy="6" stdDeviation="10" flood-color="#000" flood-opacity="0.4"/></filter>
    <marker id="af" markerWidth="9" markerHeight="9" refX="7" refY="4.5" orient="auto"><path d="M0,0 L9,4.5 L0,9 Z" fill="#5b9cff"/></marker>
    <marker id="ar" markerWidth="9" markerHeight="9" refX="7" refY="4.5" orient="auto"><path d="M0,0 L9,4.5 L0,9 Z" fill="#f87171"/></marker>
    <style>
      .title { font: 800 36px 'Segoe UI','Malgun Gothic',sans-serif; fill: url(#titleGrad); }
      .sub { font: 500 13px 'Segoe UI','Malgun Gothic',sans-serif; fill: #8b9ab0; }
      .legend { font: 600 12px 'Segoe UI','Malgun Gothic',sans-serif; fill: #9bb0d3; }
      .nt { font: 800 16px 'Segoe UI','Malgun Gothic',sans-serif; fill: #eef3fb; }
      .nd { font: 500 11px 'Segoe UI','Malgun Gothic',sans-serif; fill: #a8b8d4; }
      .el { font: 700 11px 'Segoe UI','Malgun Gothic',sans-serif; fill: #dbeafe; }
      .elr { fill: #fecaca; }
      .path-l { font: 600 11px 'Segoe UI','Malgun Gothic',sans-serif; fill: #7dd3fc; }
      .human { font: 800 10px 'Segoe UI','Malgun Gothic',sans-serif; fill: #fde68a; }
    </style>
  </defs>

  <rect width="1400" height="820" fill="url(#bg)"/>
  <circle cx="100" cy="60" r="200" fill="#4f8ffa" opacity="0.06"/>
  <circle cx="1300" cy="100" r="180" fill="#7c6ff7" opacity="0.07"/>

  <text x="700" y="48" text-anchor="middle" class="title">AI Development Workflow</text>
  <text x="700" y="72" text-anchor="middle" class="sub">\uc804\uccb4 \ud750\ub984 \u00b7 \ud68c\uadc0 \u00b7 HUMAN \uac8c\uc774\ud2b8 (\ub2e8\uc21c\ud654)</text>

  <g transform="translate(80,88)">
    <line x1="0" y1="0" x2="32" y2="0" stroke="#5b9cff" stroke-width="3"/>
    <text x="40" y="4" class="legend">\uc804\uc9c4</text>
    <line x1="100" y1="0" x2="132" y2="0" stroke="#f87171" stroke-width="2.5" stroke-dasharray="6 5"/>
    <text x="140" y="4" class="legend">\ud68c\uadc0</text>
    <rect x="220" y="-8" width="62" height="18" rx="9" fill="rgba(245,166,35,.15)" stroke="rgba(245,166,35,.55)"/>
    <text x="251" y="5" text-anchor="middle" class="human">HUMAN</text>
    <text x="292" y="4" class="legend">\uc778 \uac8c\uc774\ud2b8</text>
  </g>

  <!-- shared nodes helpers via inline groups -->
  <!-- p0 \uc694\uccad -->
  <g filter="url(#shadow)" transform="translate(60,200)">
    <rect width="120" height="72" rx="12" fill="url(#card)" stroke="#4f8ffa" stroke-width="1.5"/>
    <text x="60" y="32" text-anchor="middle" class="nt">\uc694\uccad \ubd84\uae30</text>
    <text x="60" y="52" text-anchor="middle" class="nd">E2E / \uc77c\ubc18 / \ubc84\uadf8</text>
  </g>

  <!-- E2E row y=160 -->
  <g filter="url(#shadow)" transform="translate(260,160)">
    <rect width="130" height="80" rx="12" fill="url(#card)" stroke="#2d4470"/>
    <text x="65" y="34" text-anchor="middle" class="nt">PRD</text>
    <text x="65" y="54" text-anchor="middle" class="nd">Gate 1 \u00b7 PRD+AC</text>
    <rect x="28" y="58" width="74" height="16" rx="8" fill="rgba(245,166,35,.18)" stroke="rgba(245,166,35,.6)"/>
    <text x="65" y="70" text-anchor="middle" class="human">HUMAN \uc2b9\uc778</text>
  </g>
  <g filter="url(#shadow)" transform="translate(460,160)">
    <rect width="130" height="80" rx="12" fill="url(#card)" stroke="#2d4470"/>
    <text x="65" y="34" text-anchor="middle" class="nt">\ub514\uc790\uc778 \uc120\ud0dd</text>
    <text x="65" y="54" text-anchor="middle" class="nd">\uc774\uc911 \ubaa9\uc5c5 \uc815\ud569</text>
    <rect x="22" y="58" width="86" height="16" rx="8" fill="rgba(245,166,35,.18)" stroke="rgba(245,166,35,.6)"/>
    <text x="65" y="70" text-anchor="middle" class="human">HUMAN \uc120\ud0dd</text>
  </g>

  <!-- general row -->
  <g filter="url(#shadow)" transform="translate(260,280)">
    <rect width="130" height="72" rx="12" fill="url(#card)" stroke="#2d4470"/>
    <text x="65" y="32" text-anchor="middle" class="nt">\ucc29\uc218 \ubb38\uc11c</text>
    <text x="65" y="52" text-anchor="middle" class="nd">Gate 1 (\uc77c\ubc18)</text>
  </g>

  <!-- bug row -->
  <g filter="url(#shadow)" transform="translate(260,390)">
    <rect width="130" height="72" rx="12" fill="url(#card)" stroke="#f5a623"/>
    <text x="65" y="32" text-anchor="middle" class="nt">\ubc84\uadf8 \uc218\uc815</text>
    <text x="65" y="52" text-anchor="middle" class="nd">bugfix-flow</text>
  </g>

  <!-- merge: implement -->
  <g filter="url(#shadow)" transform="translate(680,240)">
    <rect width="130" height="80" rx="12" fill="url(#card)" stroke="#22c87a" stroke-width="1.4"/>
    <text x="65" y="36" text-anchor="middle" class="nt">\uad6c\ud604</text>
    <text x="65" y="58" text-anchor="middle" class="nd">Gate 2 \u00b7 ATDD RED</text>
    <text x="65" y="72" text-anchor="middle" class="nd">FE/BE \u00b7 GREEN</text>
  </g>

  <!-- done -->
  <g filter="url(#shadow)" transform="translate(900,240)">
    <rect width="130" height="80" rx="12" fill="url(#card)" stroke="#22c87a" stroke-width="1.4"/>
    <text x="65" y="36" text-anchor="middle" class="nt">\uc644\ub8cc \ud310\uc815</text>
    <text x="65" y="58" text-anchor="middle" class="nd">Gate 3 \u00b7 AC \ucee4\ubc84\ub9ac</text>
  </g>

  <!-- forward edges -->
  <g fill="none" stroke-linecap="round" stroke-linejoin="round">
    <text x="200" y="152" class="path-l">E2E</text>
    <path d="M 180 196 L 210 200 L 260 200" stroke="#5b9cff" stroke-width="2.5" marker-end="url(#af)"/>
    <path d="M 390 200 L 460 200" stroke="#5b9cff" stroke-width="2.5" marker-end="url(#af)"/>
    <path d="M 590 200 L 640 200 L 680 260 L 745 280" stroke="#5b9cff" stroke-width="2.5" marker-end="url(#af)"/>

    <text x="200" y="318" class="path-l">\uc77c\ubc18</text>
    <path d="M 180 228 L 210 316 L 260 316" stroke="#5b9cff" stroke-width="2.5" marker-end="url(#af)"/>
    <path d="M 390 316 L 680 280 L 745 280" stroke="#5b9cff" stroke-width="2.5" marker-end="url(#af)"/>

    <text x="200" y="428" class="path-l">\ubc84\uadf8</text>
    <path d="M 180 260 L 210 426 L 260 426" stroke="#5b9cff" stroke-width="2.5" marker-end="url(#af)"/>
    <path d="M 390 426 L 520 426 L 965 320" stroke="#5b9cff" stroke-width="2.5" marker-end="url(#af)"/>

    <path d="M 810 280 L 900 280" stroke="#5b9cff" stroke-width="2.5" marker-end="url(#af)"/>

    <!-- regression from done -->
    <text x="1080" y="268" class="el elr">\ud68c\uadc0 \ub8e8\ud504</text>
    <path d="M 965 310 L 965 520 L 745 520 L 745 320" stroke="#f87171" stroke-width="2.2" stroke-dasharray="7 5" marker-end="url(#ar)"/>
    <text x="820" y="512" class="el elr">\ub2e4\uc2dc \uad6c\ud604</text>

    <path d="M 965 330 L 965 560 L 325 560 L 325 352" stroke="#f87171" stroke-width="2.2" stroke-dasharray="7 5" marker-end="url(#ar)"/>
    <text x="600" y="552" class="el elr">\ub2e4\uc2dc \ucc29\uc218</text>

    <path d="M 985 310 L 985 600 L 325 600 L 325 240" stroke="#f87171" stroke-width="2.2" stroke-dasharray="7 5" marker-end="url(#ar)"/>
    <text x="620" y="592" class="el elr">PRD \uc218\uc815</text>

    <path d="M 1005 310 L 1005 640 L 120 640 L 120 272" stroke="#f87171" stroke-width="2.2" stroke-dasharray="7 5" marker-end="url(#ar)"/>
    <text x="520" y="632" class="el elr">\uc7ac\ubd84\ub958</text>

    <!-- design to PRD regression (small) -->
    <path d="M 460 170 L 390 170" stroke="#f87171" stroke-width="2" stroke-dasharray="6 4" marker-end="url(#ar)"/>
    <text x="400" y="162" class="el elr">PRD \uc218\uc815</text>
  </g>

  <!-- summary box -->
  <g transform="translate(60,680)">
    <rect width="1280" height="110" rx="14" fill="#151d2e" stroke="#2d4470"/>
    <text x="24" y="28" class="nt" font-size="14">\uc694\uc57d</text>
    <text x="24" y="52" class="nd" font-size="12">\u2460 \uace0\uac1d E2E\ub294 PRD\u00b7\ub514\uc790\uc778 \uc5d0\uc11c HUMAN \uac8c\uc774\ud2b8 \u2192 \uad6c\ud604 \u2461 \uc77c\ubc18\uc740 \ucc29\uc218 \ubb38\uc11c \ud655\uc778 \u2192 \uad6c\ud604</text>
    <text x="24" y="72" class="nd" font-size="12">\u2462 \uc644\ub8cc \uae30\uc900 \ubbf8\ub2ec \uc2dc \uc810\uc120 \ud68c\uadc0(\ub2e4\uc2dc \uad6c\ud604 / \ucc29\uc218 / PRD / \uc7ac\ubd84\ub958) \u2463 \ub514\uc790\uc778 \uc120\ud0dd \ud6c4\ub294 \ubcc4\ub3c4 \uad6c\ud604 \uc2b9\uc778 \uc5c6\uc774 \uc774\uc5b4\uc9c4\ub2e4</text>
    <text x="24" y="92" class="nd" font-size="11" fill="#7d8fa8">\uc0c1\uc138 \ud1a0\ud3f4\ub85c\uc9c0 \u00b7 cursor-workflow-detailed.html</text>
  </g>
</svg>"""


def main():
    OUT_SVG.write_text(SVG, encoding="utf-8")
    print(f"Wrote {OUT_SVG}")


if __name__ == "__main__":
    main()
