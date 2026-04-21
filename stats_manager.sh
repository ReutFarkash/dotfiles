#!/usr/bin/env bash

# Partially from: https://github.com/diogocavilha/fancy-git/blob/master/theme-functions.sh

if [ "$DEBUG" == true ]; then
    scriptpath="${CUR_DIR}/${BASH_ARGV[0]}"
    echo "running $scriptpath"
fi

# ----------------------------------------------------------------------------------------------------------------------
# Creates a poor notification area, which means it won't have icons.
# ----------------------------------------------------------------------------------------------------------------------
fancygit_get_poor_notification_area() {
    if [ "$DEBUG" == true ]; then
		echo "running fancygit_get_poor_notification_area $(date +%M,%S)" >&2
	fi

    local notification_area=""

    # Git info.
    local branch_name
    local staged_files
    local git_stash
    local git_has_unpushed_commits
    local git_number_untracked_files
    local git_number_changed_files

    # Set git info.
    branch_name=${1:-$(fancygit_git_get_branch)}

    local porc="$(git status --porcelain)"


    git_stash=$(fancygit_git_get_stash)
    git_number_untracked_files=$(fancygit_git_get_num_untracked_files "$(echo "$porc")")
    git_number_changed_files=$(fancygit_git_get_num_changed_files "$(echo "$porc")")
    git_number_staged_files=$(fancygit_git_get_num_staged_files "$(echo "$porc")")
    git_number_stash=$(echo $git_stash | grep -v -e '^[[:space:]]*$' | wc -l)
    
    local icon_git_stash="${FANCYGIT_ICON_HAS_STASHES:-$ICON_GIT_STASH}"
    local icon_untracked_files="${FANCYGIT_ICON_HAS_UNTRACKED_FILES:-$ICON_GIT_UNTRACKED_FILES}"
    local icon_changed_files="${FANCYGIT_ICON_HAS_CHANGED_FILES:-$ICON_GIT_CHANGED_FILES}"
    local icon_added_files="${FANCYGIT_ICON_HAS_ADDED_FILES:-$ICON_GIT_ADDED_FILES}"
    local icon_unpushed_commits="${FANCYGIT_ICON_HAS_UNPUSHED_COMMITS:-$ICON_GIT_UNPUSHED_COMMITS}"
    # local number_unpushed_commits=0
    local venv=""

    notification_area="${notification_area}${icon_untracked_files}${git_number_untracked_files}"
    notification_area="${notification_area}${icon_changed_files}${git_number_changed_files}"
    notification_area="${notification_area}${icon_added_files}${git_number_staged_files}"
    notification_area="${notification_area}${icon_git_stash}${git_number_stash}"


    if [ "" != "$notification_area" ]
    then
        # Trim notification_area content
        notification_area=$(echo "$notification_area" | sed -e 's/[[:space:]]*$//' | sed -e 's/^[[:space:]]*//')

        echo -e " ${notification_area//[[:space:]]*$/}"
        return
    fi

    echo ""
}

