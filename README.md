# html-reports

Single-file HTML reports rendered live via GitHub Pages.

**Live site:** https://andrewkobzev.github.io/html-reports/

## What is this

Reusable templates from the [html-document](https://gist.github.com/andrewkobzev/85331eec1b4e8adfecf32076e3dee8c0) Claude Code / Codex CLI / Gemini CLI skill, hosted here so the rendered HTML is one click away — no "view raw" / "save as / open" workflow needed.

Each `.html` file in the repo root is served as a fully rendered page at `https://andrewkobzev.github.io/html-reports/<filename>.html`. The root `index.html` is a landing page with cards linking to every template.

## Templates

| File | What it is |
|---|---|
| [`status-report.html`](status-report.html) | Weekly / monthly status — KPI cards, shipped / at-risk / blocked rows, bar chart |
| [`incident-report.html`](incident-report.html) | Post-mortem — severity pills, vertical timeline, 5-whys, action items |
| [`plan.html`](plan.html) | Implementation plan — milestone timeline, data-flow SVG, risk register |
| [`explainer.html`](explainer.html) | Feature explainer — collapsible steps, tabbed code, glossary sidebar, FAQ |
| [`slide-deck.html`](slide-deck.html) | Arrow-key navigable presentation |
| [`base.html`](base.html) | Clean canvas with full design tokens |

All templates:

- Single self-contained `.html` file — no external CDN, no build step.
- System fonts only (no Google Fonts).
- Built-in dark mode toggle (☀ / ☾ button top-right) with `prefers-color-scheme` detection and `localStorage` persistence.
- Mobile-responsive.
- Warm-earth palette with clay accent — from [Thariq Shihipar's "Unreasonable effectiveness of HTML"](https://thariqs.github.io/html-effectiveness/) (Anthropic, May 2026).

## Publishing your own reports

```bash
# One-time setup
git clone git@github.com:andrewkobzev/html-reports.git
cd html-reports

# To publish a new report
cp /path/to/my-report.html .
git add my-report.html
git commit -m "Add my-report"
git push

# Done — your report is live at:
# https://andrewkobzev.github.io/html-reports/my-report.html
# (usually within ~30 seconds of push)
```

## Privacy note

This repo is **public**. Any `.html` you push here is world-readable. For reports containing sensitive or internal data, use one of:

- **Private repo + GitHub Pages** (requires GitHub Pro for free accounts, included in Team/Enterprise).
- **Azure Static Web Apps** with Easy Auth (Entra ID gate). Free tier covers small reports.
- **Cloudflare Pages** with Cloudflare Access for auth.
- Keep them local and share via screenshot or file attachment.

## License

MIT. Forks and PRs welcome.
