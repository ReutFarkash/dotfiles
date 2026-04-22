#!/usr/bin/env bash
# generate_cheatsheet.sh — Generate a personal shell command reference.
# Creates ~/shell-cheatsheet.md (Markdown) and ~/shell-cheatsheet.txt (plain, for less).
# Re-run any time to refresh after a profile change.

[[ -f ~/.user_config ]] && source ~/.user_config
PROFILE="${DOTFILES_PROFILE:-standard}"
USERNAME="${LOCAL_USERNAME:-$USER}"
GENERATED="Generated $(date +%Y-%m-%d)"

MD="$HOME/shell-cheatsheet.md"
TXT="$HOME/shell-cheatsheet.txt"

# ── Markdown version ──────────────────────────────────────────────────────────
{
cat <<EOF
# Shell Cheat Sheet — $USERNAME
_Profile: \`$PROFILE\` | $GENERATED_

## Navigation

| Command | What it does |
|---------|-------------|
| \`l\`   | list files |
| \`la\`  | list all files (including hidden) |
| \`lr\`  | list files, newest at bottom |
| \`l\`   | list files with details |
| \`..\`  | go up one directory |
| \`...\` | go up two directories |
| \`~\`   | go to home directory |

## Safety

These commands ask before doing anything destructive:

| Command | Behaviour |
|---------|-----------|
| \`rm\`  | asks before deleting |
| \`cp\`  | asks before overwriting |
| \`mv\`  | asks before overwriting |

## Shortcuts

| Command   | What it does |
|-----------|-------------|
| \`reload\` | reload your shell config |
| \`myip\`   | show your IP address |
| \`path\`   | show PATH, one entry per line |

## Git Basics

| Command  | What it does |
|----------|-------------|
| \`gs\`   | git status — see what changed |
| \`gp\`   | git pull — get latest from remote |
| \`glog\` | short visual commit history |
EOF

if [[ "$PROFILE" == "standard" || "$PROFILE" == "full" ]]; then
cat <<EOF

## Git — Standard

| Command             | What it does |
|---------------------|-------------|
| \`ga <file>\`       | git add a file |
| \`gc "message"\`    | git commit with a message |
| \`gd\`              | show uncommitted changes |
| \`graph\`           | visual tree of all branches |
| \`graph_less\`      | same, piped through less |
EOF
fi

if [[ "$PROFILE" == "full" ]]; then
cat <<EOF

## Full Profile

| Command             | What it does |
|---------------------|-------------|
| \`useful\`          | quick command list |
| \`more_useful\`     | full command list with descriptions |
| \`debug_true\`      | enable verbose shell debug output |
| \`debug_false\`     | disable debug output |
| \`printgit_true\`   | show git info in prompt |
| \`printgit_false\`  | hide git info in prompt |
| \`bootstrap\`       | re-create dotfile symlinks |
| \`update_aliases\`  | reload .bash_aliases without restarting |
EOF
fi

cat <<EOF

---
_Run \`useful\` in your shell for a quick refresher._
_Run \`bash generate_cheatsheet.sh\` from the dotfiles repo to regenerate this file._
EOF
} > "$MD"

# ── Plain text version (same content, readable with less) ────────────────────
{
cat <<EOF
Shell Cheat Sheet — $USERNAME
Profile: $PROFILE | $GENERATED
══════════════════════════════════════════════════

NAVIGATION
  l            list files with details
  la           list all files (including hidden)
  lr           list files, newest at bottom
  ..           go up one directory
  ...          go up two directories
  ~            go to home directory

SAFETY  (these ask before doing anything destructive)
  rm           asks before deleting
  cp           asks before overwriting
  mv           asks before overwriting

SHORTCUTS
  reload       reload your shell config
  myip         show your IP address
  path         show PATH, one entry per line

GIT BASICS
  gs           git status — see what changed
  gp           git pull — get latest from remote
  glog         short visual commit history
EOF

if [[ "$PROFILE" == "standard" || "$PROFILE" == "full" ]]; then
cat <<EOF

GIT — STANDARD
  ga <file>        git add a file
  gc "message"     git commit with a message
  gd               show uncommitted changes
  graph            visual tree of all branches
  graph_less       same, piped through less
EOF
fi

if [[ "$PROFILE" == "full" ]]; then
cat <<EOF

FULL PROFILE
  useful            quick command list
  more_useful       full command list with descriptions
  debug_true        enable verbose shell debug output
  debug_false       disable debug output
  printgit_true     show git info in prompt
  printgit_false    hide git info in prompt
  bootstrap         re-create dotfile symlinks
  update_aliases    reload .bash_aliases without restarting
EOF
fi

cat <<EOF

──────────────────────────────────────────────────
Run 'useful' in your shell for a quick refresher.
EOF
} > "$TXT"

echo "→ Cheat sheet saved:"
echo "   $MD   (Markdown — open in any viewer)"
echo "   $TXT  (Plain text — readable with 'less $TXT')"
