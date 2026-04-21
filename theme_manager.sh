#!/usr/bin/env bash

if [ "$DEBUG" == true ]; then
    scriptpath="${CUR_DIR}/${BASH_ARGV[0]}"
    echo "running $scriptpath"
fi

ICON_GIT_STASH="☃️" # ⚑
ICON_GIT_UNTRACKED_FILES="💣" # ?
ICON_GIT_CHANGED_FILES="💥" # +
ICON_GIT_ADDED_FILES="🍒" # ●
ICON_GIT_UNPUSHED_COMMITS="🍓" #^

ICON_GIT_MERGED_BRANCH="💡"
ICON_GIT_LOCAL_REMOTE_BRANCH="🧰"
ICON_GIT_LOCAL_BRANCH="📄"

ICON_GIT_BRANCH="🌿"
ICON_DIR="📂"
DIR_PATH_LEN=20

# Symbols
prompt_symbol="❯"
prompt_clean_symbol="🌟"
prompt_dirty_symbol="💢"
prompt_venv_symbol="🐇"
prompt_conda_symbol="🦎"

alias venv_theme=cyan_fg
alias conda_theme=blue_fg
alias git_dirty_theme=red_fg
alias git_clean_theme=grey_fg # green_fg
alias user_root_theme=red_fg
alias user_nonroot_theme=purple_fg # orange_fg
alias host_reg_theme=yellow_fg
# host_ssh_theme="$(compose bold red_fg)"
alias host_ssh_theme=red_fg
alias dir_theme=pink_fg

prompt_explain(){
    echo "$ICON_GIT_STASH stash $ICON_GIT_UNTRACKED_FILES untracked $ICON_GIT_CHANGED_FILES changed $ICON_GIT_ADDED_FILES added $ICON_GIT_UNPUSHED_COMMITS unpushed $ICON_GIT_MERGED_BRANCH merged $ICON_GIT_LOCAL_REMOTE_BRANCH local remote $ICON_GIT_LOCAL_BRANCH local ↑n ahead of remote by n commits ↓n behind remote by n commits"
}

more_prompt_explain() {
    echo "ICON_GIT_STASH $ICON_GIT_STASH"
    echo "ICON_GIT_UNTRACKED_FILES $ICON_GIT_UNTRACKED_FILES"
    echo "ICON_GIT_CHANGED_FILES $ICON_GIT_CHANGED_FILES"
    echo "ICON_GIT_ADDED_FILES $ICON_GIT_ADDED_FILES"
    echo "ICON_GIT_UNPUSHED_COMMITS $ICON_GIT_UNPUSHED_COMMITS"

    echo "ICON_GIT_MERGED_BRANCH $ICON_GIT_MERGED_BRANCH"
    echo "ICON_GIT_LOCAL_REMOTE_BRANCH $ICON_GIT_LOCAL_REMOTE_BRANCH"
    echo "ICON_GIT_LOCAL_BRANCH $ICON_GIT_LOCAL_BRANCH"

    echo "ICON_GIT_BRANCH $ICON_GIT_BRANCH"
    echo "ICON_DIR $ICON_DIR"
    echo "DIR_PATH_LEN $DIR_PATH_LEN"

    echo "prompt_symbol $prompt_symbol"
    echo "prompt_clean_symbol $prompt_clean_symbol"
    echo "prompt_dirty_symbol $prompt_dirty_symbol"
    echo "prompt_venv_symbol $prompt_venv_symbol"
    echo "prompt_conda_symbol $prompt_conda_symbol"

    echo -e "$(venv_theme venv_theme)"
    echo -e "$(conda_theme conda_theme)"
    echo -e "$(git_dirty_theme git_dirty_theme)"
    echo -e "$(git_clean_theme git_clean_theme)"
    echo -e "$(user_root_theme user_root_theme)"
    echo -e "$(user_nonroot_theme user_nonroot_theme)"
    echo -e "$(host_reg_theme host_reg_theme)"
    echo -e "$(host_ssh_theme host_ssh_theme)"
    echo -e "$(dir_theme dir_theme)"
    echo -e "$(host_ssh_theme host_ssh_theme)"
}