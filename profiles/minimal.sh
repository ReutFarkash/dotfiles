#!/usr/bin/env bash
# profiles/minimal.sh — Sourced instead of the full alias set for non-dev users.
# Loaded automatically when DOTFILES_PROFILE=minimal in ~/.user_config

# ── Navigation ────────────────────────────────────────────────────────────────
alias ..="cd .."
alias ...="cd ../.."
alias ~="cd ~"

# ── Listing ───────────────────────────────────────────────────────────────────
alias ls="ls -F"
alias l="ls -lhF"
alias la="ls -lahF"
alias ll="ls -lhF"
alias lr="ls -lahtr"      # newest files at bottom

# ── Safety nets ───────────────────────────────────────────────────────────────
alias rm="rm -i"           # ask before deleting
alias cp="cp -i"           # ask before overwriting
alias mv="mv -i"           # ask before overwriting

# ── Shortcuts ─────────────────────────────────────────────────────────────────
alias bashrc="source ~/.bash_profile"
alias reload="source ~/.bash_profile"
alias myip="curl -s ifconfig.me && echo"
alias path='echo -e ${PATH//:/\\n}'  # show PATH one entry per line

# ── Git basics (enough for non-developers) ───────────────────────────────────
alias gs="git status"
alias gp="git pull"
alias glog="git log --oneline --graph --decorate -10"
