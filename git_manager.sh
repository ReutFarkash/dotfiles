#!/usr/bin/env bash

# partially from: https://github.com/diogocavilha/fancy-git/blob/master/modules/git-manager.sh

if [ "$DEBUG" == true ]; then
    scriptpath="${CUR_DIR}/${BASH_ARGV[0]}"
    echo "running $scriptpath"
fi

# ----------------------------------------------------------------------------------------------------------------------
# Checks if the given branch name is local only.
#
# param string $1 Branch name.
#
# return int 0: The given branch name is local only.
# return int 1: The given branch name is local and remote.
# ----------------------------------------------------------------------------------------------------------------------
fancygit_git_is_only_local_branch_old() {
    if [ "$DEBUG" == true ]; then
		echo "running fancygit_git_is_only_local_branch_old $(date +%M,%S)" >&2
	fi
    local param_branch_name="$1"
    local is_only_local_branch

    is_only_local_branch=$(git branch -r 2> /dev/null | grep -c "$param_branch_name")

    if [ 0 -eq "$is_only_local_branch" ]
    then
        return 0
    fi

    return 1
}

fancygit_git_is_only_local_branch() {
    if [ "$DEBUG" == true ]; then
		echo "running fancygit_git_is_only_local_branch $(date +%M,%S)" >&2
	fi
    local param_branch_name="$1"
    local is_only_local_branch
    local remote_info

    remote_info=$(git branch -vv 2> /dev/null | grep '^\*' | grep origin/)
    is_only_local_branch=$(echo $remote_info | wc -l)

    if [ 0 -eq "$is_only_local_branch" ]
    then
        return "0"
    fi

    local remote_ahead_num=$(echo $remote_info | grep -Eo 'ahead [0-9]{1,}' | grep -Eo '[0-9]{1,}')
    local remote_behind_num=$(echo $remote_info | grep -Eo 'behind [0-9]{1,}' | grep -Eo '[0-9]{1,}')

    local sync_info=
    [ -n "$remote_behind_num" ] && sync_info="${sync_info}↓${remote_behind_num}"
    [ -n "$remote_ahead_num" ] && sync_info="${sync_info}↑${remote_ahead_num}"
    [ -n "$sync_info" ] && echo "($sync_info)"
    return
}

# ----------------------------------------------------------------------------------------------------------------------
# Returns the branch icon according to the given branch name.
# It returns different icons for a local only branch and a local/remote one.
#
# param string $1 Branch name.
#
# return string Branch icon.
# ----------------------------------------------------------------------------------------------------------------------

fancygit_git_get_branch_icon() {
    if [ "$DEBUG" == true ]; then
		echo "running fancygit_git_get_branch_icon $(date +%M,%S)" >&2
	fi
    local param_branch_name="$1"
    local icon_local_branch="${FANCYGIT_ICON_LOCAL_BRANCH:-$ICON_GIT_MERGED_BRANCH}"
    local icon_local_remote_branch="${FANCYGIT_ICON_LOCAL_REMOTE_BRANCH:-$ICON_GIT_LOCAL_REMOTE_BRANCH}"
    local icon_merged_branch="${FANCYGIT_ICON_MERGED_BRANCH:-$ICON_GIT_LOCAL_BRANCH}"

    local out_remote=$(fancygit_git_is_only_local_branch "$param_branch_name")
    if [ "0" = "$out_remote" ]
    then
        echo "$icon_local_branch"
        return
    fi

    echo "$icon_local_remote_branch$out_remote"
}




fancygit_git_get_num_staged_files() {
    if [ "$DEBUG" == true ]; then
		echo "running fancygit_git_get_num_staged_files $(date +%M,%S)" >&2
	fi
    local input_porc="$1"
    # echo "$input_porc" | grep '^A'  | wc -l 
    echo "$input_porc" | grep '^[ATMDRC]'  | wc -l 
}

# ----------------------------------------------------------------------------------------------------------------------
# Get current branch name.
# ----------------------------------------------------------------------------------------------------------------------
fancygit_git_get_branch() {
    if [ "$DEBUG" == true ]; then
		echo "running fancygit_git_get_branch $(date +%M,%S)" >&2
	fi
    git rev-parse --abbrev-ref HEAD 2> /dev/null
}

# ----------------------------------------------------------------------------------------------------------------------
# Get current tag name.
# ----------------------------------------------------------------------------------------------------------------------
fancygit_git_get_tag() {
    if [ "$DEBUG" == true ]; then
		echo "running fancygit_git_get_tag $(date +%M,%S)" >&2
	fi
    local tag

    tag=$(git describe --tags --exact-match 2> /dev/null)

    if [ "" != "$tag" ]
    then
        echo "HEAD $tag"
    fi
}

# ----------------------------------------------------------------------------------------------------------------------
# Get a list of stashes.
# ----------------------------------------------------------------------------------------------------------------------
fancygit_git_get_stash() {
    if [ "$DEBUG" == true ]; then
		echo "running fancygit_git_get_stash $(date +%M,%S)" >&2
	fi
    git stash list 2> /dev/null
}

# ----------------------------------------------------------------------------------------------------------------------
# Get untracked files.
# ----------------------------------------------------------------------------------------------------------------------
fancygit_git_get_num_untracked_files() {
    if [ "$DEBUG" == true ]; then
		echo "running fancygit_git_get_num_untracked_files $(date +%M,%S)" >&2
	fi
    # git ls-files --others --exclude-standard 2> /dev/null
    local input_porc="$1"
    echo "$input_porc" | grep '^??'  | wc -l 
}

# ----------------------------------------------------------------------------------------------------------------------
# Get a list of changed files.
# ----------------------------------------------------------------------------------------------------------------------
fancygit_git_get_num_changed_files() {
    if [ "$DEBUG" == true ]; then
		echo "running fancygit_git_get_num_changed_files $(date +%M,%S)" >&2
	fi
    # git ls-files -m 2> /dev/null
    local input_porc="$1"
    echo "$input_porc" | grep '^.[MARTDC]'  | wc -l 
}

# ----------------------------------------------------------------------------------------------------------------------
# Get remote branch name.
# ----------------------------------------------------------------------------------------------------------------------
__fancygit_git_get_remote_branch() {
    if [ "$DEBUG" == true ]; then
		echo "running __fancygit_git_get_remote_branch $(date +%M,%S)" >&2
	fi
    local branch_name

    branch_name=$(git rev-parse --abbrev-ref --symbolic-full-name "@{u}" 2> /dev/null | cut -d"/" -f1)
    branch_name=${branch_name:-origin}
    echo "$branch_name"
}

