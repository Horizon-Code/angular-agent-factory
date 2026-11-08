#!/usr/bin/env sh
# Installs the Angular Agent Factory into the current Angular workspace.
# Usage (from the workspace root): .factory/scripts/install.sh
set -eu

SRC="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$(pwd)"

if [ "$SRC" = "$DEST" ]; then
  echo "Run this from the root of the target workspace, not from the factory itself." >&2
  exit 1
fi

mkdir -p "$DEST/.claude/agents" "$DEST/specs"
cp "$SRC"/agents/*.md "$DEST/.claude/agents/"

if [ "$SRC" != "$DEST/.factory" ]; then
  mkdir -p "$DEST/.factory"
  cp -R "$SRC/knowledge" "$SRC/templates" "$SRC/AGENTS.md" "$SRC/WORKFLOW.md" "$DEST/.factory/"
fi

echo "Installed agents into .claude/agents and knowledge into .factory/"
echo "Add a line to your AGENTS.md or CLAUDE.md: 'Follow .factory/AGENTS.md and .factory/WORKFLOW.md.'"
