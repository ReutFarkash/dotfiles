#!/usr/bin/env bash
# profiles/full.sh — Full profile: standard + dev utilities + git power tools.
#
# Platform: macOS-first. Linux should work. Windows/WSL not supported here —
#           see profiles/_legacy_windows.sh for the old Windows code.
#
# Loaded automatically when DOTFILES_PROFILE=full in ~/.user_config.
# Inheritance: full → standard → minimal

# ── Everything from standard (includes minimal) ───────────────────────────────
source "${DOTFILES_REPO}/profiles/standard.sh"

# ── Dev utility aliases ───────────────────────────────────────────────────────
alias update_aliases="source ~/.bash_aliases"
alias debug_true="export DEBUG=true"
alias debug_false="export DEBUG=false"
alias printgit_true="export PRINTGIT=true"
alias printgit_false="export PRINTGIT=false"

[[ -n "${DOTFILES_REPO:-}" ]] && alias bootstrap="${DOTFILES_REPO}/bootstrap.sh"

# ── Git power tools ───────────────────────────────────────────────────────────
# NOTE: validated on macOS; not tested on Windows/WSL (see _legacy_windows.sh)
[[ -f "${DOTFILES_REPO}/git_scripts/graph_submodules.sh" ]] && source "${DOTFILES_REPO}/git_scripts/graph_submodules.sh"
[[ -f "${DOTFILES_REPO}/git_scripts/lazygit.sh" ]] && source "${DOTFILES_REPO}/git_scripts/lazygit.sh"

# ── Optional completions ──────────────────────────────────────────────────────
# hydra_completion: not validated — may need editing for your Hydra config
[[ -f "${DOTFILES_REPO}/hydra_completion.sh" ]] && source "${DOTFILES_REPO}/hydra_completion.sh"

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
    echo '  gd                    git diff'
    echo '  glog                  short visual log'
    echo '  graph                 full visual log (all branches)'
    echo ''
    echo 'SHELL'
    echo '  reload                re-load shell config'
    echo '  update_aliases        reload .bash_aliases'
    echo '  myip                  show your IP address'
    echo '  path                  show PATH entries one per line'
    echo '  debug_true            enable DEBUG output'
    echo '  debug_false           disable DEBUG output'
    echo '  printgit_true         enable git prompt'
    echo '  printgit_false        disable git prompt'
    echo '  bootstrap             re-run dotfile symlink setup'
    echo '  useful                show this help'
    echo ''
}

useful
