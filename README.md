# html-reports

A reusable AI-agent skill for generating production-quality, **single-file HTML artifacts** — status reports, post-mortems, explainers, slide decks, plans, dashboards — instead of markdown when the user explicitly asks for HTML.

Based on Thariq Shihipar's [The unreasonable effectiveness of HTML](https://thariqs.github.io/html-effectiveness/) (Anthropic, May 2026).

- 🟢 **Live previews:** https://andrewkobzev.github.io/html-reports/
- 📦 **Install skill in one command:** see [Install the skill](#install-the-skill) below
- 🪶 **No-skill agents** (Cursor, Aider, ChatGPT, etc.): paste [`universal-prompt.md`](universal-prompt.md) into your system prompt

## What's in this repo

```
.
├── SKILL.md               ← the skill itself (Anthropic Agent Skills frontmatter)
├── universal-prompt.md    ← drop-in for agents without a skills directory
├── install.sh             ← multi-target installer (Claude Code, Codex CLI, Gemini CLI, project-level)
├── templates/             ← 6 ready-made templates (canonical source)
│   ├── base.html
│   ├── status-report.html
│   ├── incident-report.html
│   ├── plan.html
│   ├── explainer.html
│   └── slide-deck.html
├── index.html             ← GitHub Pages landing
├── reports/               ← your own published reports go here
└── LICENSE                ← MIT
```

Every template ships with:

- **Single self-contained `.html` file** — no CDN, no build step, no external assets. Open in a browser, done.
- **Dark-mode toggle** out of the box — sun / moon button top-right, `prefers-color-scheme` aware, choice persisted in `localStorage`, no-flash init in `<head>`.
- **Warm-earth palette** with clay accent (`#D97757`), invertible to dark surfaces.
- **System fonts only** — no Google Fonts, no font CDNs.
- **Inline SVG** for diagrams. No Tailwind / Bootstrap / Chart.js / external assets.
- **Mobile-responsive** via `@media` queries on key grids.
- **Global `a { color: var(--clay); ... }`** baseline so links never fall back to default browser blue.

## Live previews

The `templates/` folder is served through GitHub Pages — every template is one click away:

| Live URL | What it is |
|---|---|
| [/](https://andrewkobzev.github.io/html-reports/) | Landing page with cards |
| [/templates/status-report.html](https://andrewkobzev.github.io/html-reports/templates/status-report.html) | Weekly / monthly status — KPI cards, shipped / at-risk rows, throughput chart |
| [/templates/incident-report.html](https://andrewkobzev.github.io/html-reports/templates/incident-report.html) | Post-mortem — severity pills, vertical timeline, 5-whys, action items |
| [/templates/plan.html](https://andrewkobzev.github.io/html-reports/templates/plan.html) | Implementation plan — milestone timeline, data-flow SVG, risk register |
| [/templates/explainer.html](https://andrewkobzev.github.io/html-reports/templates/explainer.html) | Feature explainer — collapsible steps, tabbed code, glossary, FAQ |
| [/templates/slide-deck.html](https://andrewkobzev.github.io/html-reports/templates/slide-deck.html) | Arrow-key / space / click navigable presentation |
| [/templates/base.html](https://andrewkobzev.github.io/html-reports/templates/base.html) | Clean canvas with the full design tokens |

## Install the skill

### Mode A — skill format (Claude Code / Codex CLI / Gemini CLI)

For AI clients that scan a `~/.<client>/skills/` directory on startup and parse YAML-frontmatter skills ([agentskills.io](https://agentskills.io/specification) spec).

```bash
git clone https://github.com/andrewkobzev/html-reports.git /tmp/html-doc-install
cd /tmp/html-doc-install

# Default — Claude Code only (user-level)
bash install.sh

# OR — install for multiple agents at once
bash install.sh --all                       # Claude Code + Codex CLI + Gemini CLI (user-level)
bash install.sh --claude --codex            # just those two
bash install.sh --project ~/projects/repo   # project-level — drops into .claude/, .cursor/, .codex/, .github/, .gemini/ inside that repo
bash install.sh --help                      # full list
```

Restart your AI client (or open a new chat) — the skill auto-registers. You should see `html-document` in the available skills list.

### Mode B — universal prompt (any agent without a skills directory)

For agents that don't have a skills system but accept a system prompt or project-rules file (Cursor, Aider, Cline, Roo, Continue.dev, GitHub Copilot Chat, ChatGPT custom GPTs, raw API integrations, etc.).

1. Open [`universal-prompt.md`](universal-prompt.md).
2. Paste its contents into your agent's "always-loaded" instruction surface:
   - **Cursor:** `.cursor/rules/html-document.mdc`
   - **Aider:** `.aider.conf.yml` `read:` entry or `--read <path>`
   - **Cline / Continue.dev:** project rules / system message
   - **ChatGPT custom GPT:** Instructions panel
   - **Generic `AGENTS.md` / `CONVENTIONS.md` / `CONTEXT.md`:** append the file
3. (Optional) Copy the six templates into the project at `docs/html-templates/` if you want the agent to start from them rather than generate from scratch — speeds it up and reduces variance.

The universal prompt is **self-contained** — all design tokens, dark-mode pattern, link styling, and per-document-type structural guidance are embedded inline. The agent can produce compliant artifacts even without template files.

## How the skill triggers

The skill description is intentionally strict — it fires **only on explicit HTML request**, so your default markdown workflow is undisturbed.

**Triggers (will use HTML):**

- "make / give / render this as HTML"
- "create an HTML report / explainer / deck / dashboard / one-pager"
- "save it as `.html`"
- "I want a single-file HTML page for …"
- Russian: "сделай HTML-отчёт", "одностраничный HTML", "сохрани как `.html`"

**Anti-triggers (stays markdown):**

- "create a document / report / summary" without saying HTML → markdown
- "save to memory / MEMORY.md / CLAUDE.md / AGENTS.md" → always markdown
- "write a commit message / PR description" → always markdown / plain text
- Replies in Slack / Telegram / email → markdown or plain text

## Verification — baseline test results

Before publishing, the skill was tested with 7 parallel subagent scenarios:

| Scenario | Expected | Got |
|---|---|---|
| 1. RU "HTML-отчёт о статусе" | html + status-report | ✓ |
| 2. EN "HTML slide deck" | html + slide-deck | ✓ |
| 3. RU "post-mortem в .html" | html + incident-report | ✓ |
| 4. RU "сохрани в MEMORY.md" | markdown, no skill | ✓ |
| 5. RU "commit message" | plain text, no skill | ✓ |
| 6. RU "краткий отчёт" (no HTML kw) | markdown, no skill | ✓ (agent cited skill rule) |
| 7. RU "красивый отчёт с интерактивностью" (no HTML kw) | gray zone | agent chose HTML, defensible — "interactivity only HTML supports" |

Compliance audit of 4 HTML outputs:

| Check | Result |
|---|---|
| Dark-mode toggle (init + button + palette) | 4/4 ✓ |
| Global `a {}` style | 4/4 ✓ |
| `color: #FFFFFF` instead of `var(--paper)` on colored pills | 4/4 ✓ |
| No external CDN / Tailwind / Bootstrap / Chart.js / Google Fonts | 4/4 ✓ |
| Zero emoji | 4/4 ✓ |
| Palette tokens actively used (`--clay`, `--olive`, etc.) | 21–42 refs per file ✓ |

## Customization

- **Different brand palette?** Edit the `:root` block in [`SKILL.md`](SKILL.md) (and each template's CSS). Every color used downstream is a CSS variable.
- **New document type?** Add another template to [`templates/`](templates/) and a row to the "Pick a template" table in `SKILL.md`.
- **Different trigger phrases?** Edit the `description:` frontmatter in `SKILL.md`. Keep it laser-focused on triggering conditions; don't summarize what the skill does (LLMs tend to follow description summaries instead of reading the skill body).

## Privacy note

This repo is **public**. Any `.html` you push to it (including under `reports/`) is world-readable. For reports containing sensitive or internal data, use:

- **Fork as private repo + GitHub Pages** (requires GitHub Pro for free accounts, included in Team/Enterprise).
- **Azure Static Web Apps** with Easy Auth (Entra ID gate). Free tier covers small sites.
- **Cloudflare Pages** with Cloudflare Access.
- Or just keep them local and share via screenshot / file attachment.

## Provenance

- [thariqs.github.io/html-effectiveness](https://thariqs.github.io/html-effectiveness/) — companion site to the original thread, 20 worked examples across 9 categories.
- [Original X thread](https://x.com/trq212/status/2052809885763747935) — "HTML is the new markdown" (Anthropic, May 2026).
- Built with the `superpowers:writing-skills` methodology (YAML frontmatter, "Use when…" triggers, Red flags + Common mistakes for closing rationalization loopholes, templates as separate files).

## License

[MIT](LICENSE). Use it, fork it, ship it. PRs welcome — especially new templates and corrections.
