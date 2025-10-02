# Cursor Hooks Examples

This repo gives you copy‑paste ready recipes for Cursor's [Agent Hooks](https://cursor.com/docs/agent/hooks). Hooks are lightweight scripts that exchange JSON with Cursor so you can observe, block, or mutate agent behavior.

## Quickstart: Format Hook

Create a minimal hook that runs after every file edit.

1. Write `~/.cursor/hooks.json`:

   ```json
   {
     "version": 1,
     "hooks": {
       "afterFileEdit": [
         { "command": "./hooks/format.sh" }
       ]
     }
   }
   ```

2. Create `~/.cursor/hooks/format.sh`:

   ```bash
   #!/bin/bash
   # Read input, do something, exit 0
   cat > /dev/null
   exit 0
   ```

3. Make it executable:

   ```bash
   chmod +x ~/.cursor/hooks/format.sh
   ```

4. Restart Cursor and verify the hook runs after edits.

## Why Hooks Matter

With a handful of scripts you can:
- run formatters or linters immediately after Cursor edits a file
- audit or block shell commands before they execute
- redact secrets before the agent reads sensitive content
- apply safety guardrails around MCP tool usage

Each hook definition maps to an executable script. Cursor streams JSON input on stdin and expects JSON back on stdout, letting you tailor the agent loop without patching Cursor itself.

## Hook Catalog

Below are reusable configurations and scripts you can drop into `~/.cursor/hooks/`.

### hooks.json

```json
{
  "version": 1,
  "hooks": {
    "beforeShellExecution": [
      { "command": "./hooks/audit.sh" },
      { "command": "./hooks/block-git.sh" }
    ],
    "beforeMCPExecution": [
      { "command": "./hooks/audit.sh" }
    ],
    "beforeReadFile": [
      { "command": "./hooks/redact-secrets.sh" }
    ],
    "afterFileEdit": [
      { "command": "./hooks/audit.sh" }
    ],
    "beforeSubmitPrompt": [
      { "command": "./hooks/audit.sh" }
    ],
    "stop": [
      { "command": "./hooks/audit.sh" }
    ]
  }
}
```

### hooks/audit.sh

```bash
#!/bin/bash

# audit.sh - Hook script that writes all JSON input to /tmp/agent-audit.log
# This script is designed to be called by Cursor's hooks system for auditing purposes

# Read JSON input from stdin
json_input=$(cat)

# Create timestamp for the log entry
timestamp=$(date '+%Y-%m-%d %H:%M:%S')

# Create the log directory if it doesn't exist
mkdir -p "$(dirname /tmp/agent-audit.log)"

# Write the timestamped JSON entry to the audit log
echo "[$timestamp] $json_input" >> /tmp/agent-audit.log

# Exit successfully
exit 0
```

### hooks/block-git.sh

```bash
#!/bin/bash

# Hook to block git commands and redirect to gh tool usage
# This hook implements the beforeShellExecution hook from the Cursor Hooks Spec

# Initialize debug logging
echo "Hook execution started" >> /tmp/hooks.log

# Read JSON input from stdin
input=$(cat)
echo "Received input: $input" >> /tmp/hooks.log

# Parse the command from the JSON input
command=$(echo "$input" | jq -r '.command // empty')
echo "Parsed command: '$command'" >> /tmp/hooks.log

# Check if the command contains 'git' or 'gh'
if [[ "$command" =~ git[[:space:]] ]] || [[ "$command" == "git" ]]; then
    echo "Git command detected - blocking: '$command'" >> /tmp/hooks.log
    # Block the git command and provide guidance to use gh tool instead
    cat <<'__BLOCK__'
{
  "continue": true,
  "permission": "deny",
  "userMessage": "Git command blocked. Please use the GitHub CLI (gh) tool instead.",
  "agentMessage": "The git command '$command' has been blocked by a project hook. Instead of using raw git commands, please use the 'gh' tool which provides better integration with GitHub and follows best practices. For example:\n- Instead of 'git clone', use 'gh repo clone'\n- Instead of 'git push', use 'gh repo sync' or the appropriate gh command\n- For other git operations, check if there's an equivalent gh command or use the GitHub web interface\n\nThis helps maintain consistency and leverages GitHub's enhanced tooling."
}
__BLOCK__
elif [[ "$command" =~ gh[[:space:]] ]] || [[ "$command" == "gh" ]]; then
    echo "GitHub CLI command detected - asking for permission: '$command'" >> /tmp/hooks.log
    # Ask for permission for gh commands
    cat <<'__ASK__'
{
  "continue": true,
  "permission": "ask",
  "userMessage": "GitHub CLI command requires permission: $command",
  "agentMessage": "The command '$command' uses the GitHub CLI (gh) which can interact with your GitHub repositories and account. Please review and approve this command if you want to proceed."
}
__ASK__
else
    echo "Non-git/non-gh command detected - allowing: '$command'" >> /tmp/hooks.log
    # Allow non-git/non-gh commands
    cat <<'__ALLOW__'
{
  "continue": true,
  "permission": "allow"
}
__ALLOW__
fi
```

### hooks/redact-secrets.sh

```bash
#!/bin/bash

# Secrets hide in code
# Like shadows in the moonlight
# This hook finds them all

# redact-secrets.sh - Hook script that checks for GitHub API keys in file content
# This script implements a file content validation hook from the Cursor Hooks Spec

# Initialize debug logging
echo "Redact-secrets hook execution started" >> /tmp/hooks.log

# Read JSON input from stdin
input=$(cat)
echo "Received input: $input" >> /tmp/hooks.log

# Parse the file path and content from the JSON input
file_path=$(echo "$input" | jq -r '.file_path // empty')
content=$(echo "$input" | jq -r '.content // empty')
attachments_count=$(echo "$input" | jq -r '.attachments | length // 0')
echo "Parsed file path: '$file_path'" >> /tmp/hooks.log
echo "Attachments count: $attachments_count" >> /tmp/hooks.log
echo "Content length: ${#content} characters" >> /tmp/hooks.log

# Check if the content contains a GitHub API key pattern
# Pattern explanation: GitHub personal access tokens (ghp_), GitHub app tokens (ghs_), or test keys (gh_api_) followed by alphanumeric characters
if echo "$content" | grep -qE 'gh[ps]_[A-Za-z0-9]{36}|gh_api_[A-Za-z0-9]+'; then
    echo "GitHub API key detected in file: '$file_path'" >> /tmp/hooks.log
    # Deny permission if GitHub API key is detected
    cat <<'__DENY__'
{
  "permission": "deny"
}
__DENY__
    exit 3
else
    echo "No GitHub API key detected in file: '$file_path' - allowing" >> /tmp/hooks.log
    # Allow permission if no GitHub API key is detected
    cat <<'__ALLOW__'
{
  "permission": "allow"
}
__ALLOW__
fi
```

## How To Use This Repo

1. Copy the configuration and scripts above into `~/.cursor/hooks.json` and `~/.cursor/hooks/`.
2. Run `chmod +x ~/.cursor/hooks/*.sh` so Cursor can execute them.
3. Tail `/tmp/hooks.log` or `/tmp/agent-audit.log` to verify hook activity.
4. Restart Cursor after modifying any hook.

## Contributing

Issues and pull requests are welcome. Please open an issue first if you plan to add new recipes or extend existing ones.

## License

Released under the MIT License. See [`LICENSE`](LICENSE).
