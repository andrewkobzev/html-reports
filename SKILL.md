---
name: html-document
description: Use ONLY when the user explicitly asks for output in HTML format — phrases like "make this an HTML report", "create as one-page HTML", "render as HTML", "HTML deck/explainer/status/dashboard", or "save as .html". Default output stays markdown; this skill applies only on explicit HTML request. Covers reports, status updates, post-mortems, explainers, slide decks, plans, design systems, prototypes, flowcharts, and interactive single-file tools. Do not trigger on "create a document", "save to memory", "MEMORY.md", "CLAUDE.md", commit messages, PR descriptions, Slack/Telegram replies — those stay markdown.
---

# HTML Document

Author production-quality, **single-file HTML artifacts** — reports, explainers, slide decks, plans, dashboards — instead of markdown when the user explicitly asks for HTML. Based on [Thariq Shihipar's "The unreasonable effectiveness of HTML"](https://thariqs.github.io/html-effectiveness/) (Anthropic, May 2026).

## When to use

**Trigger ONLY on explicit user request for HTML output:**

- "make / give / render this as HTML"
- "create an HTML report / explainer / deck / dashboard / one-pager / slide deck"
- "save it as `.html`"
- "I want a single-file HTML page for …"
- "одностраничный HTML", "в HTML", "сохрани как `.html`"

**Do NOT trigger when the user asks to:**

- "create a document / file / report / summary" → default is **markdown**
- "save memory" / write to `MEMORY.md` / `CLAUDE.md` → **always markdown**
- "make a plan / note / TODO" → default is **markdown**
- "write a PR description / commit message" → **always markdown**
- Compose a reply to Telegram, Slack, email → **markdown or plain text**

In doubt → ask. Default → markdown.

## Core philosophy

> Markdown flattens spatial information. HTML restores it.

A one-page `.html` is **a document you'd actually read** rather than skim. Twenty self-contained `.html` files an agent produced instead of a wall of markdown — each one trades a document you'd skim for one you'd actually read.

**The minimum bar for every artifact:**

- Single self-contained `.html` file — no CDN, no build step, no external assets. Open in a browser, done.
- Inline `<style>` and `<script>` only.
- Mobile-responsive (`<meta viewport>` + media queries on key grids).
- Vanilla JS only — no React/Vue/jQuery/Tailwind/Bootstrap.
- Inline SVG for diagrams and illustrations — no `<img src="...">` referencing external files.
- System fonts only — no Google Fonts or external font CDNs.
- Saved via the `Write` tool to a `.html` path.

## Pick a template

Six starter templates live in `templates/` next to this file. Read the matching one in full, then adapt.

| User asks for… | Start from |
|---|---|
| Weekly / monthly status, KPI cards, what shipped vs slipped | `templates/status-report.html` |
| Incident write-up, post-mortem, minute-by-minute timeline | `templates/incident-report.html` |
| Implementation plan, milestone roadmap, risk table | `templates/plan.html` |
| Feature / concept explainer, FAQ, collapsible sections, glossary | `templates/explainer.html` |
| Slide deck, arrow-key presentation | `templates/slide-deck.html` |
| Anything else (clean canvas, you pick the structure) | `templates/base.html` |

If no template fits perfectly, **start from `templates/base.html`** — it carries the design tokens and a layout skeleton you can shape.

## Design system — Thariq palette

This palette is **non-negotiable** unless the user explicitly overrides it. Every template already has it inline; if you write a one-off page from scratch, paste the block below into the top of `<style>`.

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

  /* Type */
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

- **Body**: `--sans`, 15px, line-height 1.55–1.6, `--g700` on `--ivory`.
- **Headings**: `--serif`, weight `500` (NOT bold), `letter-spacing: -0.01em`.
  - H1: `clamp(38px, 5.4vw, 62px)`, line-height 1.06.
  - H2: 24–27px.
  - H3: 18–19px.
- **Eyebrows / labels / file paths / numbers**: `--mono`, 11–12.5px, `text-transform: uppercase`, `letter-spacing: 0.08–0.12em`, color `--g500`.
- **The emphasis trick** — italic + clay on one word in H1:
  ```html
  <h1>The <em>effectiveness</em> of HTML</h1>
  <style> h1 em { font-style: italic; color: var(--clay); } </style>
  ```

### Links (mandatory baseline)

Every template MUST set a global anchor style — otherwise links fall back to ugly browser-default blue underlines that clash with the warm palette (especially obvious in dark mode):

```css
a { color: var(--clay); text-decoration-color: var(--oat); text-underline-offset: 3px; }
a:hover { text-decoration-color: var(--clay); }
```

This applies whether the artifact ships with `<a href="...">` today or not — a future user-added link will inherit the rule.

### Spacing & layout

- Max content width: **860–1120px**, centered (`max-width` + `margin: 0 auto`).
- Section spacing: **52–72px** between major sections.
- Card padding: **20–22px**, radius `12px`, `1.5px solid var(--g300)` border.
- Pill / chip: padding `5px 11px`, radius `999px`, `1.5px` border.
- Hairlines are **1.5px** (not 1px — looks too thin against ivory).
- Hover lift on interactive cards:
  ```css
  transform: translateY(-3px);
  box-shadow: 0 10px 30px rgba(20,20,19,.10);
  border-color: var(--slate);
  ```

### Status colors

| Meaning | Token | Use on |
|---|---|---|
| Shipped / on-track / OK | `--olive` | pills, timeline dots, bar chart |
| At risk / warning / soft callout | `--oat` (fill) + `--clay` (text) | pills, banners |
| Incident / red / blocked | `--rust` | pills, severity tags |
| Primary number / key emphasis | `--clay` | links, large numbers, italic in H1 |

### Don'ts

- ❌ No emojis in content unless the user explicitly asked.
- ❌ No purple / blue / teal — the palette is **warm earth + clay accent**.
- ❌ No `font-weight: 700` on headings — use `500` + serif.
- ❌ No 1px borders — `1.5px` reads better against ivory.
- ❌ No 8px radius on panels — `12px` on panels, `999px` on pills.
- ❌ No external fonts (Google Fonts, Inter, etc) — system stack only.
- ❌ No JavaScript libraries — vanilla JS, inlined.
- ❌ No multi-file output — one `.html`, period.

## Dark mode (always include)

Every template ships with a built-in light / dark theme switcher. The pattern is **mandatory** for new artifacts — never strip it out.

**Three pieces working together:**

1. **No-flash init script** in `<head>` (right after `<title>`) — reads `localStorage` and `prefers-color-scheme`, sets `data-theme` on `<html>` *before* the body renders so there's no light-to-dark flash on page load:

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

2. **Dark palette override** — `[data-theme="dark"]` block right after `:root`. The whole palette inverts; clay accent lightens slightly for contrast on dark surfaces:

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

3. **Toggle button** — fixed top-right corner, sun/moon SVG icons, inline `onclick` handler that flips `data-theme` and persists to `localStorage`:

    ```html
    <button class="theme-toggle" aria-label="Toggle dark mode" title="Toggle dark mode" onclick="var d=document.documentElement,c=d.getAttribute('data-theme'),n=c==='dark'?'light':'dark';d.setAttribute('data-theme',n);try{localStorage.setItem('html-doc-theme',n)}catch(e){}">
      <svg class="icon-sun" viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="4"/><line x1="12" y1="2" x2="12" y2="5"/><!-- ...rest of sun rays... --></svg>
      <svg class="icon-moon" viewBox="0 0 24 24" aria-hidden="true"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/></svg>
    </button>
    ```

    Plus the toggle's CSS (icon swap driven by `[data-theme="dark"] .theme-toggle .icon-moon { display: inline-block; }`).

### Critical rule — text on colored chips uses `#FFFFFF`, NOT `var(--paper)`

Pills / severity badges with a solid color background (`--olive`, `--rust`, `--clay`) need text that stays white in **both** themes. In dark mode, `var(--paper)` resolves to dark — which would make pill text invisible. Use a literal `#FFFFFF`:

```css
/* ✅ correct — stays white in both themes */
.pill.alert { background: var(--rust); color: #FFFFFF; }

/* ❌ wrong — text becomes dark on red in dark mode */
.pill.alert { background: var(--rust); color: var(--paper); }
```

SVG `<text>` labels overlaid on solid-colored shapes follow the same rule (`fill: #FFFFFF`).

### Things that CORRECTLY swap with theme

- `background: var(--paper)` on cards / panels — white in light, dark in dark. ✓
- `color: var(--slate)` on headings — near-black in light, near-white in dark. ✓
- `color: var(--g700)` on body text — dark gray in light, light gray in dark. ✓
- SVG `.wh` and `.box-w` classes — `fill: var(--paper)` represents "blank box in a diagram" and should darken in dark mode. ✓

## Workflow

1. **Confirm trigger.** Reread the user's request. If they said HTML / `.html` / a clear synonym → proceed. Otherwise → markdown.
2. **Pick a template** from the table above. Match the document type to the closest starter; fall back to `templates/base.html`.
3. **Read the template** in full with the `Read` tool — every template already inlines the design tokens, responsive layout skeleton, and the document-type-specific components.
4. **Adapt.** Keep the `:root` block intact. Replace headings, content, and example rows. Swap pill colors per status. Add or remove sections.
5. **Diagrams.** Use inline `<svg viewBox="...">`. The templates ship a handful of utility classes (`.cl`, `.ol`, `.oa`, `.sl`, `.fl`, `.ln`, `.lc`) that pick up the palette automatically.
6. **Charts.** Small bar/line charts as inline SVG with palette colors. For >50 data points, use a `<canvas>` block + vanilla JS — still no libraries.
7. **Interactivity.** Vanilla JS, one `<script>` block at the bottom. Examples: arrow-key slide nav, collapsible `<details>`, drag-and-drop with `draggable=true`, copy-to-clipboard.
8. **Editors → always add an export button** that converts the current UI state back to markdown / JSON / paste-able text. The loop is human → agent → human; the export closes the loop.
9. **Write the file** with the `Write` tool to the path the user requested. If unspecified, default to `./<descriptive-kebab-case-name>.html` in the current working directory.
10. **Report back** with the path and one line on what's inside. Do not dump the HTML into the chat.

## Red flags — STOP and reconsider

- ❓ The user said "report" / "document" / "summary" without saying HTML → are you sure? If unclear → **ask** before writing.
- ❓ The user asked to save to memory / `MEMORY.md` / `CLAUDE.md` / `feedback_*.md` → that's **always markdown**, regardless of topic.
- ❓ The user asked for a commit message / PR body / git note → **always markdown**.
- ❓ Output is going into a Slack thread / Telegram reply / email body → **markdown or plain text**.
- ❓ You're about to add `<script src="https://...">` or `<link rel="stylesheet" href="https://...">` → **stop** and inline it instead. The artifact must work offline.
- ❓ You're reaching for Tailwind / Bootstrap / a UI library → **stop**. Vanilla CSS only, using the tokens above.
- ❓ Adding emojis "to make it feel friendly" → don't. Andrew's global rule: no emojis unless explicitly asked.
- ❓ The document is going to be diffed / version-controlled as content (changelog, plan-of-record, feedback) → markdown wins for diffability.
- ❓ Tempted to skip the dark-mode toggle because "the artifact is short" → **don't**. Three pieces (no-flash init script + dark palette + toggle button) are mandatory. Strip them and the user has to read white-on-light at 11pm.

## Common mistakes

| Mistake | Fix |
|---|---|
| `font-weight: 700` on headings | `500` + `--serif` |
| 1px borders | `1.5px` |
| Purple / blue accent | `var(--clay)` (`#D97757`) |
| External font CDN | System fonts via `--serif` / `--sans` / `--mono` |
| Missing mobile viewport | Always add `<meta name="viewport" content="width=device-width, initial-scale=1">` |
| Editor without export | Always add a "Copy as markdown / JSON" button |
| Charts via Chart.js | Inline SVG (or `<canvas>` + vanilla JS for many points) |
| Multi-file output | Single `.html` only — no sibling `style.css` / `script.js` |
| Tailwind utility classes | Vanilla CSS with the token variables |
| `<img src="logo.png">` | Inline SVG, no external assets |
| Status pill colored ad-hoc | Use `--olive` / `--oat`+`--clay` / `--rust` mapping above |
| Stripped out dark-mode toggle "to keep file small" | Always include — three pieces (init script + palette + button) cost ~50 lines, ship every time |
| Forgot global `a {}` rule — links render as default blue underline | Always include `a { color: var(--clay); ... }` baseline, even if the artifact has no links today |
| Pill text uses `color: var(--paper)` | Use literal `#FFFFFF` — `var(--paper)` becomes dark in dark mode and makes pill text invisible |
| Toggle button placed elsewhere | Keep `position: fixed; top: 18px; right: 18px;` — that's where users look for it |

## References

- [thariqs.github.io/html-effectiveness](https://thariqs.github.io/html-effectiveness/) — companion to Thariq's original thread, 20 worked examples covering all 9 categories.
- [Original X thread](https://x.com/trq212/status/2052809885763747935) — "HTML is the new markdown" (Anthropic, May 2026).
- Repository with full source: `github.com/ThariqS/html-effectiveness`.
