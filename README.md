# Cursor Hooks Examples

This repo gives you copy‑paste ready recipes for Cursor's [Agent Hooks](https://cursor.com/docs/agent/hooks). Hooks are lightweight scripts that exchange JSON with Cursor so you can observe, block, or mutate agent behavior.

## Quickstart: Format Hook

Create a minimal hook that runs after every file edit. This repo already includes `hooks.json` and all referenced scripts under `hooks/`, so setup is just copying the files into `~/.cursor/`.

1. Copy `hooks.json` to `~/.cursor/hooks.json`.
2. Copy every script from `hooks/` to `~/.cursor/hooks/`.
3. Run `chmod +x ~/.cursor/hooks/*.sh` to make them executable.
4. Restart Cursor and verify the hook runs after edits. Tail `/tmp/agent-audit.log` or `/tmp/hooks.log` to confirm activity.

## Why Hooks Matter

With a handful of scripts you can:

- run formatters or linters immediately after Cursor edits a file
- audit or block shell commands before they execute
- redact secrets before the agent reads sensitive content
- apply safety guardrails around MCP tool usage

Each hook definition maps to an executable script. Cursor streams JSON input on stdin and expects JSON back on stdout, letting you tailor the agent loop without patching Cursor itself.

## Hook Catalog

Everything you need to mirror the documentation examples lives in this repository:

- `hooks.json` wires each documented hook event to the scripts in `hooks/`.
- `hooks/format.sh` is the minimal formatter-style hook used in the Quickstart.
- `hooks/audit.sh` captures every payload into `/tmp/agent-audit.log` for auditing.
- `hooks/block-git.sh` denies raw git usage, requests approval for `gh`, and logs decisions to `/tmp/hooks.log`.
- `hooks/redact-secrets.sh` prevents Cursor from reading files that look like they contain GitHub tokens.

## How To Use This Repo

1. Copy `hooks.json` and the scripts in `hooks/` into `~/.cursor/`.
2. Run `chmod +x ~/.cursor/hooks/*.sh` so Cursor can execute them.
3. Tail `/tmp/hooks.log` or `/tmp/agent-audit.log` to verify hook activity.
4. Restart Cursor after modifying any hook.

## Contributing

Issues and pull requests are welcome. Please open an issue first if you plan to add new recipes or extend existing ones.

## License

Released under the MIT License. See [`LICENSE`](LICENSE).
