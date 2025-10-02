#!/bin/bash

# block-git.sh - Guard shell commands, deny raw git usage, and prefer gh

echo "Hook execution started" >> /tmp/hooks.log

input=$(cat)
echo "Received input: $input" >> /tmp/hooks.log

command=$(echo "$input" | jq -r '.command // empty')
echo "Parsed command: '$command'" >> /tmp/hooks.log

if [[ "$command" =~ git[[:space:]] ]] || [[ "$command" == "git" ]]; then
    echo "Git command detected - blocking: '$command'" >> /tmp/hooks.log
    cat <<'__DENY__'
{
  "continue": true,
  "permission": "deny",
  "userMessage": "Git command blocked. Please use the GitHub CLI (gh) tool instead.",
  "agentMessage": "The git command '$command' has been blocked by a project hook. Instead of using raw git commands, please use the 'gh' tool."
}
__DENY__
elif [[ "$command" =~ gh[[:space:]] ]] || [[ "$command" == "gh" ]]; then
    echo "GitHub CLI command detected - asking for permission: '$command'" >> /tmp/hooks.log
    cat <<'__ASK__'
{
  "continue": true,
  "permission": "ask",
  "userMessage": "GitHub CLI command requires permission: $command",
  "agentMessage": "The command '$command' uses the GitHub CLI (gh). Please review and approve this command if you want to proceed."
}
__ASK__
else
    echo "Non-git/non-gh command detected - allowing: '$command'" >> /tmp/hooks.log
    cat <<'__ALLOW__'
{
  "continue": true,
  "permission": "allow"
}
__ALLOW__
fi
