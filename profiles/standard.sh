#!/usr/bin/env bash
# profiles/standard.sh — Standard profile: minimal shell + git tools + prompt + venv scaffolding.
# Loaded automatically when DOTFILES_PROFILE=standard in ~/.user_config

# ── Everything from minimal ───────────────────────────────────────────────────
source "${DOTFILES_REPO}/profiles/minimal.sh"

# ── Git ───────────────────────────────────────────────────────────────────────
alias graph="git log --oneline --graph --decorate --all"
alias graph_c="graph --color=always"
alias graph_less="graph --color=always | less -R"

alias gc="git commit -m"
alias ga="git add"
alias gd="git diff"

# ── Machine-specific aliases and paths ───────────────────────────────────────
if [ -f ~/.local_aliases ]; then
    source ~/.local_aliases
fi

# ── Venv shortcuts ────────────────────────────────────────────────────────────
if [ -f ~/.venv_aliases_local ]; then
    source ~/.venv_aliases_local
fi

# ── Help ──────────────────────────────────────────────────────────────────────
useful() {
    echo ''
    echo 'NAVIGATION'
    echo '  ..  ...  ~             go up one/two dirs, go home'
    echo '  l   la   lr            list files (lr = newest at bottom)'
    echo ''
    echo 'GIT'
    echo '  gs                    git status'
    echo '  gp                    git pull'
    echo '  ga <file>             git add'
    echo '  gc "message"          git commit'
    echo '  glog                  short visual log'
    echo '  graph                 full visual log'
    echo ''
    echo 'SHELL'
    echo '  reload                re-load shell config'
    echo '  myip                  show your IP address'
    echo '  path                  show PATH entries one per line'
    echo '  useful                show this help'
    echo ''
}

useful
