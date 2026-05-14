#!/usr/bin/env bash
# Installer for the html-document skill.
# Drops SKILL.md and 6 templates into one or more AI agent skill directories.
#
# Default: Claude Code user-level (~/.claude/skills/).
# Use flags to target other agents — see usage below.

set -euo pipefail

SKILL_NAME="html-document"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

USAGE="Usage: bash install.sh [TARGET...]

Targets (user-level — files dropped into \$HOME):
  --claude        ~/.claude/skills/${SKILL_NAME}/      (Claude Code — default if no flag)
  --codex         ~/.codex/skills/${SKILL_NAME}/       (Codex CLI)
  --gemini        ~/.gemini/skills/${SKILL_NAME}/      (Gemini CLI)
  --all           All three user-level targets above

Project-level (give a project path; installs into all known sub-dirs there):
  --project <path>  <path>/.claude/skills/${SKILL_NAME}/
                    <path>/.codex/skills/${SKILL_NAME}/
                    <path>/.cursor/commands/${SKILL_NAME}/
                    <path>/.github/skills/${SKILL_NAME}/
                    <path>/.gemini/skills/${SKILL_NAME}/

Examples:
  bash install.sh                                       # Claude Code only (default)
  bash install.sh --all                                 # Claude + Codex + Gemini user-level
  bash install.sh --claude --codex                      # Just those two
  bash install.sh --project ~/projects/my-repo          # Project-level for one repo
  bash install.sh --all --project ~/projects/my-repo    # User-level AND project-level

If a target already exists, you'll be prompted before overwriting.
"

# Sanity check — required source files must be in this repo.
if [[ ! -f "${HERE}/SKILL.md" ]]; then
  echo "ERROR: SKILL.md not found in ${HERE}" >&2
  echo "Did you forget to 'git clone https://github.com/andrewkobzev/html-reports.git' first?" >&2
  exit 1
fi
required_templates=(base.html status-report.html incident-report.html plan.html explainer.html slide-deck.html)
for f in "${required_templates[@]}"; do
  if [[ ! -f "${HERE}/templates/${f}" ]]; then
    echo "ERROR: templates/${f} not found in ${HERE}" >&2
    exit 1
  fi
done

# Parse args.
declare -a TARGETS=()
project_path=""

if [[ $# -eq 0 ]]; then
  TARGETS+=("${HOME}/.claude/skills")
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --claude) TARGETS+=("${HOME}/.claude/skills"); shift ;;
    --codex)  TARGETS+=("${HOME}/.codex/skills");  shift ;;
    --gemini) TARGETS+=("${HOME}/.gemini/skills"); shift ;;
    --all)
      TARGETS+=("${HOME}/.claude/skills" "${HOME}/.codex/skills" "${HOME}/.gemini/skills")
      shift
      ;;
    --project)
      if [[ -z "${2:-}" ]]; then
        echo "ERROR: --project needs a path argument" >&2
        echo "${USAGE}" >&2
        exit 1
      fi
      project_path="$2"
      if [[ ! -d "${project_path}" ]]; then
        echo "ERROR: project path ${project_path} does not exist or is not a directory" >&2
        exit 1
      fi
      TARGETS+=(
        "${project_path}/.claude/skills"
        "${project_path}/.codex/skills"
        "${project_path}/.cursor/commands"
        "${project_path}/.github/skills"
        "${project_path}/.gemini/skills"
      )
      shift 2
      ;;
    -h|--help)
      echo "${USAGE}"
      exit 0
      ;;
    *)
      echo "ERROR: unknown argument: $1" >&2
      echo "${USAGE}" >&2
      exit 1
      ;;
  esac
done

# Dedup TARGETS (in case user passed --all and individual flags).
declare -A seen=()
declare -a UNIQUE_TARGETS=()
for t in "${TARGETS[@]}"; do
  if [[ -z "${seen[$t]:-}" ]]; then
    UNIQUE_TARGETS+=("$t")
    seen[$t]=1
  fi
done

install_to() {
  local base_dir="$1"
  local skill_dir="${base_dir}/${SKILL_NAME}"
  local tpl_dir="${skill_dir}/templates"

  if [[ -d "${skill_dir}" ]]; then
    echo "WARN: ${skill_dir} already exists."
    read -r -p "Overwrite? [y/N] " confirm
    case "${confirm}" in
      [yY]|[yY][eE][sS])
        rm -rf "${skill_dir}"
        ;;
      *)
        echo "  Skipped ${skill_dir}"
        return 0
        ;;
    esac
  fi

  mkdir -p "${tpl_dir}"
  cp "${HERE}/SKILL.md" "${skill_dir}/SKILL.md"
  cp "${HERE}/templates/"*.html "${tpl_dir}/"

  echo "  ✓ ${skill_dir}/"
}

echo "Installing ${SKILL_NAME} to ${#UNIQUE_TARGETS[@]} target(s)..."
for tgt in "${UNIQUE_TARGETS[@]}"; do
  install_to "$tgt"
done

echo
echo "Done. Restart your AI client (or open a new chat) to pick up the skill."
echo "Trigger it by asking for HTML explicitly:"
echo "  'make this an HTML report' · 'save as .html' · 'create an HTML slide deck'"
