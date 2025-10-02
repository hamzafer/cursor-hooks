#!/bin/bash

# redact-secrets.sh - Deny reads if probable GitHub tokens are detected

echo "Redact-secrets hook execution started" >> /tmp/hooks.log

input=$(cat)
echo "Received input: $input" >> /tmp/hooks.log

file_path=$(echo "$input" | jq -r '.file_path // empty')
content=$(echo "$input" | jq -r '.content // empty')
attachments_count=$(echo "$input" | jq -r '.attachments | length // 0')

echo "Parsed file path: '$file_path'" >> /tmp/hooks.log
echo "Attachments count: $attachments_count" >> /tmp/hooks.log
echo "Content length: ${#content} characters" >> /tmp/hooks.log

if echo "$content" | grep -qE 'gh[ps]_[A-Za-z0-9]{36}|gh_api_[A-Za-z0-9]+'; then
    echo "GitHub API key detected in file: '$file_path'" >> /tmp/hooks.log
    cat <<'__DENY__'
{
  "permission": "deny"
}
__DENY__
    exit 3
else
    echo "No GitHub API key detected in file: '$file_path' - allowing" >> /tmp/hooks.log
    cat <<'__ALLOW__'
{
  "permission": "allow"
}
__ALLOW__
fi
