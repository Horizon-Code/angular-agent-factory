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

# Layer 2: official Angular skill and the Angular CLI MCP server (adopted, not duplicated).
if command -v npx >/dev/null 2>&1; then
  npx -y skills add https://github.com/angular/skills --skill angular-developer -p -y -a claude-code </dev/null || \
    echo "Could not install the official angular-developer skill; run: npx skills add https://github.com/angular/skills" >&2
fi
MCP_HINT='add to .mcp.json under "mcpServers": "angular-cli": { "command": "npx", "args": ["-y", "@angular/cli", "mcp"] }'
if [ ! -f "$DEST/.mcp.json" ]; then
  cat > "$DEST/.mcp.json" <<'JSON'
{
  "mcpServers": {
    "angular-cli": { "command": "npx", "args": ["-y", "@angular/cli", "mcp"] }
  }
}
JSON
elif command -v node >/dev/null 2>&1; then
  # Existing .mcp.json: add the Angular CLI server without touching the others.
  node - "$DEST/.mcp.json" <<'NODE' || echo "Could not update .mcp.json; $MCP_HINT" >&2
const fs = require('fs');
const file = process.argv[2];
let config;
try {
  config = JSON.parse(fs.readFileSync(file, 'utf8'));
} catch {
  console.error(`${file} is not valid JSON; left unchanged.`);
  process.exit(1);
}
config.mcpServers ??= {};
if (config.mcpServers['angular-cli']) {
  console.log('.mcp.json already has the angular-cli server; left unchanged.');
} else {
  config.mcpServers['angular-cli'] = { command: 'npx', args: ['-y', '@angular/cli', 'mcp'] };
  fs.writeFileSync(file, JSON.stringify(config, null, 2) + '\n');
  console.log('Added the angular-cli server to the existing .mcp.json.');
}
NODE
else
  echo "Found .mcp.json but no node to update it; $MCP_HINT" >&2
fi

echo "Installed agents into .claude/agents, knowledge into .factory/, the angular-developer skill and .mcp.json (ng mcp)"
echo "Add a line to your AGENTS.md or CLAUDE.md: 'Follow .factory/AGENTS.md and .factory/WORKFLOW.md.'"
