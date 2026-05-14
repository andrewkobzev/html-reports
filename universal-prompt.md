# HTML document authoring — instructions for AI agents

> **How to use this file:** paste it (or include it) into your AI agent's system prompt, project rules (`.cursor/rules`, `AGENTS.md`, `CONVENTIONS.md`, `CONTEXT.md`, ChatGPT custom GPT instructions, etc.), or any "always-loaded" context location. It is self-contained — the agent does not need separate template files to produce compliant artifacts. The reference templates exist in the same repository if you want them: see "Reference templates" at the bottom.

This document tells the agent **when** to author single-file HTML artifacts (reports, explainers, slide decks, plans, dashboards) instead of markdown, and **how** to do so following a consistent design system. Based on [Thariq Shihipar's "The unreasonable effectiveness of HTML"](https://thariqs.github.io/html-effectiveness/) (Anthropic, May 2026).

## When to use HTML (vs markdown)

**Use HTML ONLY on explicit user request:**

- "make / give / render this as HTML"
- "create an HTML report / explainer / deck / dashboard / one-pager"
- "save it as `.html`"
- "I want a single-file HTML page for …"

**Stay markdown / plain text (do NOT switch to HTML) when:**

- "create a document / file / report / summary" without saying HTML → markdown
- "save to memory" / write to `MEMORY.md` / `CLAUDE.md` / `AGENTS.md` → markdown
- "make a plan / note / TODO" → markdown
- "write a PR description / commit message" → markdown / plain text
- Replies in Slack / Telegram / email → markdown or plain text
- The output will be diffed or version-controlled as content (changelog, plan-of-record) → markdown wins for diffability

In doubt → ask. Default → markdown.

## Core philosophy

> Markdown flattens spatial information. HTML restores it.

A one-page `.html` is a document the reader will actually read, not skim. Use HTML when the content benefits from spatial layout (KPI cards, timelines, charts, tabs, collapsibles, interactive elements). Stay markdown when the content is linear prose.

## Single self-contained file principle

Every HTML artifact you produce must be:

- A single `.html` file — no sibling `style.css`, `script.js`, image files.
- No CDN, no external assets — works fully offline. Open in a browser, done.
- Inline `<style>` and `<script>` only.
- Mobile-responsive — `<meta viewport>` + `@media` queries on key grids.
- Vanilla JS only — no React / Vue / jQuery / Tailwind / Bootstrap / Chart.js / Lodash.
- Inline SVG for diagrams and charts — no `<img src="...">` referencing external files.
- System fonts only — no Google Fonts, no font CDNs.

## Design system

### Color palette (warm earth + clay accent)

Inline this `:root` block at the top of every `<style>`:

```css
:root {
  /* Surfaces */
  --ivory:  #FAF9F5;   /* page background */
  --paper:  #FFFFFF;   /* card / panel background */
  --g100:   #F0EEE6;   /* subtle fill */
  --g200:   #E6E3DA;   /* hover fill */
  --g300:   #D1CFC5;   /* hairline borders */
  --g500:   #87867F;   /* secondary text, captions */
  --g700:   #3D3D3A;   /* body text */
  --slate:  #141413;   /* headings */

  /* Accents */
  --clay:   #D97757;   /* primary accent — links, key numbers, italic emphasis */
  --clay-d: #B85C3E;   /* hover state for clay */
  --oat:    #E3DACC;   /* warm fill — soft callouts */
  --olive:  #788C5D;   /* positive / shipped / OK */
  --rust:   #B04A3F;   /* alert / incident / red status */

  /* Type stacks */
  --serif: ui-serif, Georgia, "Times New Roman", Times, serif;
  --sans:  system-ui, -apple-system, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
  --mono:  ui-monospace, "SF Mono", Menlo, Monaco, Consolas, monospace;

  /* Geometry */
  --radius-panel: 12px;
  --radius-pill:  999px;
  --border: 1.5px solid var(--g300);
}
```

### Typography rules

- **Body:** `--sans`, 15px, line-height 1.55–1.6, `--g700` on `--ivory`.
- **Headings:** `--serif`, weight `500` (NOT bold), `letter-spacing: -0.01em`.
  - H1: `clamp(38px, 5.4vw, 62px)`, line-height 1.06.
  - H2: 24–27px.
  - H3: 18–19px.
- **Eyebrows / labels / file paths / numbers / pills:** `--mono`, 11–12.5px, `text-transform: uppercase`, `letter-spacing: 0.08–0.12em`, color `--g500`.
- **The emphasis trick** — italic + clay on one word in H1:

    ```html
    <h1>The <em>effectiveness</em> of HTML</h1>
    <style> h1 em { font-style: italic; color: var(--clay); } </style>
    ```

### Status colors

| Meaning | Token | Use on |
|---|---|---|
| Shipped / on-track / OK | `--olive` | pills, timeline dots, bar chart |
| At risk / warning / soft callout | `--oat` (fill) + `--clay-d` (text) | pills, banners |
| Incident / red / blocked | `--rust` | pills, severity tags |
| Primary number / key emphasis | `--clay` | links, large numbers, italic in H1 |

### Spacing & layout

- Max content width: **860–1120px**, centered (`max-width` + `margin: 0 auto`).
- Section spacing: **52–72px** between major sections.
- Card padding: **20–22px**, radius `12px`, `1.5px solid var(--g300)` border.
- Pill / chip: padding `5px 11px`, radius `999px`, `1.5px` border.
- Hairlines: **1.5px** (not 1px — looks too thin against ivory).
- Hover lift on interactive cards:

    ```css
    transform: translateY(-3px);
    box-shadow: 0 10px 30px rgba(20,20,19,.10);
    border-color: var(--slate);
    ```

### Links (mandatory baseline)

Every artifact MUST set a global anchor style — otherwise links fall back to ugly browser-default blue underlines (especially obvious in dark mode):

```css
a { color: var(--clay); text-decoration-color: var(--oat); text-underline-offset: 3px; }
a:hover { text-decoration-color: var(--clay); }
```

Include this even if the artifact has no `<a>` tags today — a future user-added link will inherit the rule.

## Dark mode (always include)

Every artifact ships with a built-in light / dark theme switcher. **Mandatory pattern** — never strip it out.

**Three pieces working together:**

### 1. No-flash init script in `<head>` (right after `<title>`)

Reads `localStorage` and `prefers-color-scheme`, sets `data-theme` on `<html>` **before** body renders so there is no light-to-dark flash on page load:

```html
<script>
  (function () {
    var saved = null;
    try { saved = localStorage.getItem('html-doc-theme'); } catch (e) {}
    var prefers = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
    document.documentElement.setAttribute('data-theme', saved || (prefers ? 'dark' : 'light'));
  })();
</script>
```

### 2. Dark palette override

`[data-theme="dark"]` block right after `:root`. The whole palette inverts; clay accent lifts slightly for contrast on dark surfaces:

```css
[data-theme="dark"] {
  --ivory:  #1A1917;   /* page background */
  --paper:  #232220;   /* cards */
  --slate:  #FAF9F5;   /* headings (was background in light) */
  --clay:   #E08A6D;   /* lifted for contrast */
  --clay-d: #D97757;
  --oat:    #3A3329;
  --olive:  #92A878;
  --rust:   #C4604F;
  --g100:   #2A2826;
  --g200:   #302E2C;
  --g300:   #393937;   /* hairlines visible on paper */
  --g500:   #87867F;
  --g700:   #D1CFC5;   /* body text */
}
```

### 3. Toggle button (fixed top-right corner, sun/moon icons)

```html
<button class="theme-toggle" aria-label="Toggle dark mode" title="Toggle dark mode" onclick="var d=document.documentElement,c=d.getAttribute('data-theme'),n=c==='dark'?'light':'dark';d.setAttribute('data-theme',n);try{localStorage.setItem('html-doc-theme',n)}catch(e){}">
  <svg class="icon-sun" viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="4"/><line x1="12" y1="2" x2="12" y2="5"/><line x1="12" y1="19" x2="12" y2="22"/><line x1="2" y1="12" x2="5" y2="12"/><line x1="19" y1="12" x2="22" y2="12"/><line x1="4.93" y1="4.93" x2="7.05" y2="7.05"/><line x1="16.95" y1="16.95" x2="19.07" y2="19.07"/><line x1="4.93" y1="19.07" x2="7.05" y2="16.95"/><line x1="16.95" y1="7.05" x2="19.07" y2="4.93"/></svg>
  <svg class="icon-moon" viewBox="0 0 24 24" aria-hidden="true"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/></svg>
</button>
```

And the button's CSS:

```css
.theme-toggle {
  position: fixed; top: 18px; right: 18px;
  width: 36px; height: 36px;
  padding: 0;
  border-radius: 999px;
  background: var(--paper);
  border: 1.5px solid var(--g300);
  cursor: pointer;
  display: flex; align-items: center; justify-content: center;
  z-index: 100;
  transition: border-color 150ms, transform 150ms;
}
.theme-toggle:hover { border-color: var(--slate); transform: scale(1.05); }
.theme-toggle svg { width: 18px; height: 18px; stroke: var(--g700); fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
.theme-toggle .icon-moon { display: none; }
[data-theme="dark"] .theme-toggle .icon-sun  { display: none; }
[data-theme="dark"] .theme-toggle .icon-moon { display: inline-block; }
```

### Critical rule — text on colored chips uses `#FFFFFF`, NOT `var(--paper)`

Pills / severity badges with a solid color background (`--olive`, `--rust`, `--clay`) need text that stays white in **both** themes. In dark mode, `var(--paper)` resolves to dark — which would make pill text invisible. Use a literal `#FFFFFF`:

```css
/* ✅ correct — stays white in both themes */
.pill.alert { background: var(--rust); color: #FFFFFF; }

/* ❌ wrong — text becomes dark on red in dark mode */
.pill.alert { background: var(--rust); color: var(--paper); }
```

SVG `<text>` overlaid on solid-colored shapes follows the same rule (`fill: #FFFFFF`).

### Things that CORRECTLY swap with theme

- `background: var(--paper)` on cards / panels — white in light, dark in dark.
- `color: var(--slate)` on headings — near-black in light, near-white in dark.
- `color: var(--g700)` on body text — dark gray in light, light gray in dark.
- SVG fills like `var(--paper)` representing "blank box in a diagram" — should darken with the theme.

## Document type structures

When the user asks for an HTML artifact, match their request to one of these structures. If none fits perfectly, use the generic structure at the end.

### Status report (weekly / monthly status)

- Header: eyebrow + H1 (one italic clay word) + "Auto-drafted" mono pill + date range
- **Summary band:** 4 stat-cards in a grid (e.g. Shipped / In flight / At risk / P0 incidents). Each card has a mono label, a serif big number, and a delta line.
- **What shipped:** item rows with `--olive` pills. Each row = pill + title + meta line (PR link, owner, date).
- **At risk / slipped:** item rows with `--oat`+`--clay-d` pills, blocked ones with `--rust`.
- **Throughput chart:** inline SVG bar chart, previous weeks in `--olive`, current week in `--clay`.
- **Focus next week:** item rows with neutral pills.
- Footer: drafted-by + last-updated.

### Incident / post-mortem

- Header: severity pills (`P0`, `Resolved`) + H1 with one italic `--rust` word + subtitle (impact summary).
- **Summary box:** `border-left: 4px solid var(--rust)` panel with Impact / Trigger / Resolution / Detection / MTTD / MTTR lines, each prefixed with a mono label.
- **Timeline (ET):** vertical timeline with `border-left` rule and colored dots (`--g300` for context, `--rust` for critical, `--clay` for action, `--olive` for recovery). Each entry: time + title + body (with optional `<pre>` log excerpts).
- **Why? (five whys):** counted list with circled numbers in clay.
- **Action items:** checkbox list, completed items checked.
- Footer: postmortem owner, review date.

### Implementation plan

- Header: eyebrow ("Implementation plan · v1") + H1 (one italic clay word) + subtitle.
- **Goals & non-goals:** single panel with two paragraphs, "Goals" in olive, "Non-goals" in rust.
- **Milestones:** grid with week label on left, milestone card on right. Card has `border-left: 4px` colored by status (olive = done, clay = in-flight, g300 = next).
- **Data flow:** inline SVG diagram with `--paper`/`--oat`/`--olive` boxes and `--g500`/`--clay` arrows.
- **Risk register:** table with severity pills (`sev-h` = rust, `sev-m` = oat+clay-d, `sev-l` = neutral).
- Footer.

### Feature / concept explainer

- Two-column layout: main content (1fr) + glossary sidebar (260px, sticky).
- Header: eyebrow + H1 + **TL;DR box** (`--oat` background, `--clay-d` border).
- **The flow / how it works:** numbered `<details>` (collapsible) elements. Each summary has a mono step number pill. First one is `open` by default.
- **Configuration:** tabbed code samples (custom JS to toggle `data-active` on panels).
- **FAQ:** collapsible `<details>` with `--g100` background.
- **Glossary sidebar:** sticky `dl`/`dt`/`dd` list, mono uppercase title.

### Slide deck

- Full-viewport sections, one slide visible at a time (controlled via `data-active` attribute).
- Each slide is centered vertically, big type (`clamp(48px, 7vw, 88px)` for H1).
- **Slide patterns:** title slide / quote slide / big-stat slide / bullet slide (numbered with mono) / two-column compare / closing slide.
- **Footer:** counter (`01 / 06`), dot progress, nav hint (`← →` `Space`).
- **JS:** keyboard handler (`ArrowLeft`/`ArrowRight`/`Space`/`Home`/`End`), click-anywhere-to-advance (with exceptions for buttons/links).

### Generic / "everything else"

Use the design system base:

- Header with eyebrow + H1 (one italic clay word) + subtitle.
- Sections separated by 52–72px, each starting with `<h2>` + `<hr class="rule">`.
- Card grid (`grid-template-columns: repeat(auto-fill, minmax(240px, 1fr))`) for browsable items.
- Pills for status (`.ok` olive, `.warn` oat+clay-d, `.alert` rust, neutral).
- Inline SVG with utility classes (`.cl` clay, `.ol` olive, `.oa` oat, `.sl` slate, `.fl` g300, `.wh` paper+g500-stroke, `.ln` g500-stroke, `.lc` clay-stroke).
- Footer with serif italic "drafted by" line.

## Workflow

1. **Confirm trigger.** Reread the user's request. If they said HTML / `.html` / a clear synonym → proceed. Otherwise → markdown.
2. **Pick a structure** from "Document type structures" above. If none fits perfectly, use the generic structure.
3. **Generate the file.** Start with `<!doctype html>`, `<html lang>`, `<head>` (charset, viewport, title, init script, style with palette + dark override + component CSS), then `<body>` (toggle button first, then content), then closing tags.
4. **Diagrams.** Use inline `<svg viewBox="...">` with palette colors via the utility classes.
5. **Charts.** Small bar/line charts as inline SVG with palette colors. For >50 data points, `<canvas>` + vanilla JS — still no libraries.
6. **Interactivity.** Vanilla JS only, one `<script>` block at the bottom. Examples: arrow-key slide nav, collapsible `<details>`, drag-and-drop with `draggable=true`, copy-to-clipboard.
7. **Editors → always add an export button** that converts UI state back to markdown / JSON / paste-able text. Human → agent → human loop; the export closes the loop.
8. **Write the file** to the path the user requested. If unspecified, default to `./<descriptive-kebab-case-name>.html` in the working directory.
9. **Report back** with the path and one line on what's inside. Do not dump the HTML into the chat.

## Red flags — STOP and reconsider

- ❓ The user said "report" / "document" / "summary" without saying HTML → are you sure? If unclear → **ask** before writing.
- ❓ The user asked to save to memory / `MEMORY.md` / `CLAUDE.md` / `AGENTS.md` → that is **always markdown**, regardless of topic.
- ❓ The user asked for a commit message / PR body / git note → **always markdown / plain text**.
- ❓ Output is going into a Slack thread / Telegram reply / email body → **markdown or plain text**.
- ❓ You are about to add `<script src="https://...">` or `<link rel="stylesheet" href="https://...">` → **stop** and inline it. The artifact must work offline.
- ❓ You are reaching for Tailwind / Bootstrap / a UI library → **stop**. Vanilla CSS only, using the tokens above.
- ❓ Adding emojis "to make it feel friendly" → don't, unless the user explicitly asked.
- ❓ Tempted to skip the dark-mode toggle because "the artifact is short" → don't. Three pieces (no-flash init + dark palette + toggle button) are mandatory.

## Common mistakes

| Mistake | Fix |
|---|---|
| `font-weight: 700` on headings | `500` + `--serif` |
| 1px borders | `1.5px` |
| Purple / blue accent | `var(--clay)` (`#D97757`) |
| External font CDN | System fonts via `--serif` / `--sans` / `--mono` |
| Missing mobile viewport | Always add `<meta name="viewport" content="width=device-width, initial-scale=1">` |
| Editor without export button | Always add a "Copy as markdown / JSON" button |
| Charts via Chart.js | Inline SVG (or `<canvas>` + vanilla JS for many points) |
| Multi-file output | Single `.html` only — no sibling `style.css` / `script.js` |
| Tailwind utility classes | Vanilla CSS with the token variables |
| `<img src="logo.png">` | Inline SVG, no external assets |
| Status pill colored ad-hoc | Use `--olive` / `--oat`+`--clay` / `--rust` mapping |
| Stripped dark-mode toggle to keep file small | Always include — the three pieces cost ~50 lines, ship every time |
| Pill text uses `color: var(--paper)` | Use literal `#FFFFFF` — `var(--paper)` becomes dark in dark mode and makes pill text invisible |
| Forgot global `a {}` rule — links render as default blue underline | Always include `a { color: var(--clay); ... }` baseline |
| Toggle button placed elsewhere | Keep `position: fixed; top: 18px; right: 18px;` — that is where users look for it |

## Reference templates

Six ready-made templates (richer than the structure descriptions above) live in the `templates/` directory of [the source repository](https://github.com/andrewkobzev/html-reports) and are also rendered live at [andrewkobzev.github.io/html-reports/](https://andrewkobzev.github.io/html-reports/):

- `base.html` — clean canvas with full tokens
- `status-report.html`
- `incident-report.html`
- `plan.html`
- `explainer.html`
- `slide-deck.html`

You may either:

- **Embed-only mode** (recommended for system prompts): work from this document alone. The tokens, the dark-mode pattern, and the type structures above are enough to generate compliant artifacts from scratch.
- **Template mode** (for CLI agents with file access): copy the six templates into the project (e.g. `docs/html-templates/`) and Read the matching template before adapting it. Faster than generating from scratch, less variance.

## Provenance

- [thariqs.github.io/html-effectiveness](https://thariqs.github.io/html-effectiveness/) — companion site to the original thread, 20 worked examples across 9 categories.
- [Original X thread](https://x.com/trq212/status/2052809885763747935) — "HTML is the new markdown" (Anthropic, May 2026).
