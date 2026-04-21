#!/usr/bin/env bash


git_aliases=("git aliases: ")


alias gs="git submodule"
git_aliases+=("gs")

alias gsf="gs foreach"
git_aliases+=("gsf")

alias gsf_fetch="gsf 'git fetch'"
git_aliases+=("gsf_fetch")

alias gsf_branch="gsf 'git branch'"
git_aliases+=("gsf_branch")

alias gss="gs status"
git_aliases+=("gss")

alias gs_status="gss"
git_aliases+=("gsf_status")

alias gsu="gs update"
git_aliases+=("gsu")

alias gs_update="gsu"
git_aliases+=("gs_update")

alias gsur="gsu --remote"
git_aliases+=("gsur")

alias gs_update_remote="gs update --remote"
git_aliases+=("gs_update_remote")


tgsf_fetch() {
    echo 'git fetch in top'
    git fetch
    gsf_fetch
}
git_aliases+=("tgsf_fetch")


tgsf_branch() {
    echo 'git branch in top'
    git branch
    gsf_branch
}
git_aliases+=("tgsf_branch")


mylazygit() {
    git add .
    git commit -m "$1"
    git push
}
git_aliases+=("mylazygit")

fix_head_dev() {
    if [ $(git rev-parse HEAD) = $(git rev-parse dev) ]; then 
        echo "Detached HEAD is pointing to the same commit as dev" 
        git checkout dev
    else 
        echo "Detached HEAD is NOT pointing to the same commit as dev"
    fi
}
git_aliases+=("fix_head_dev")


fix_head_main() {
    if [ $(git rev-parse HEAD) = $(git rev-parse main) ]; then 
        echo "Detached HEAD is pointing to the same commit as main" 
        git checkout main
    else 
        echo "Detached HEAD is NOT pointing to the same commit as main"
    fi
}
git_aliases+=("fix_head_main")


fix_head() {
    branch_name="$1"
    # echo $branch_name
    if [ $(git rev-parse HEAD) = $(git rev-parse ${branch_name}) ]; then 
        echo "Detached HEAD is pointing to the same commit as ${branch_name}" 
        git checkout ${branch_name}
    else 
        echo "Detached HEAD is NOT pointing to the same commit as ${branch_name}"
    fi
}
git_aliases+=("fix_head")



gs_fix_head() {
    branch_name="$1"

    git submodule foreach '
        branch_exists() {
            if git rev-parse --verify "$1" >/dev/null 2>&1; then
                return 0
            else
                return 1
            fi
        }

        if branch_exists '"${branch_name}"'; then
            if [ $(git rev-parse HEAD) = $(git rev-parse '"$branch_name"') ]; then
                echo "Detached HEAD is pointing to the same commit as '"${branch_name}"'"
                git checkout '"${branch_name}"'
            else
                echo "Detached HEAD is NOT pointing to the same commit as '"${branch_name}"'"
            fi
        else
            echo "Branch '"${branch_name}"' does not exist in this submodule."
        fi
    '
}
git_aliases+=("gs_fix_head")


gs_fix_head_c_d_m_old() {
    branch_name="$1"

    git submodule foreach '
        branch_exists() {
            if git rev-parse --verify "$1" >/dev/null 2>&1; then
                return 0
            else
                return 1
            fi
        }

         if branch_exists 'main'; then
            if [ $(git rev-parse HEAD) = $(git rev-parse 'main') ]; then
                echo "Detached HEAD is pointing to the same commit as 'main'"
                git checkout 'main'
            else
                echo "Detached HEAD is NOT pointing to the same commit as 'main'"
            fi
        else
            echo "Branch 'main' does not exist in this submodule."
        fi

        
        if branch_exists 'dev'; then
            if [ $(git rev-parse HEAD) = $(git rev-parse 'dev') ]; then
                echo "Detached HEAD is pointing to the same commit as 'dev'"
                git checkout 'dev'
            else
                echo "Detached HEAD is NOT pointing to the same commit as 'dev'"
            fi
        else
            echo "Branch 'dev' does not exist in this submodule."
        fi

        if branch_exists '"${branch_name}"'; then
            if [ $(git rev-parse HEAD) = $(git rev-parse '"${branch_name}"') ]; then
                echo "Detached HEAD is pointing to the same commit as '"${branch_name}"'"
                git checkout '"${branch_name}"'
            else
                echo "Detached HEAD is NOT pointing to the same commit as '"$[branch_name]"'"
            fi
        else
            echo "Branch '"$branch_name"' does not exist in this submodule."
        fi
    '
}
git_aliases+=("gs_fix_head_c_d_m_old")


gs_fix_head_c_d_m() {
    branch_name="$1"

    git submodule foreach '
        branch_exists() {
            if git show-ref --verify --quiet refs/heads/"$1"; then
                return 0
            else
                return 1
            fi
        }

        remote_branch_exists() {
            if git ls-remote --exit-code --heads origin "$1" >/dev/null 2>&1; then
                return 0
            else
                return 1
            fi
        }

        ensure_branch_exists_locally() {
            if ! branch_exists "$1"; then
                if remote_branch_exists "$1"; then
                    echo "Branch ${1} exists on remote, fetching..."
                    git fetch origin "$1":"$1"
                fi
            fi
        }

        checkout_branch_if_same_commit() {
            branch=$1
            if branch_exists "${branch}"; then
                if [ "$(git rev-parse HEAD)" = "$(git rev-parse "${branch}")" ]; then
                    echo "Detached HEAD is pointing to the same commit as '${branch}'"
                    git checkout "$branch"
                else
                    echo "Detached HEAD is NOT pointing to the same commit as '${branch}'"
                fi
            else
                echo "Branch '${branch}' does not exist in this submodule."
            fi
        }

        ensure_branch_exists_locally main
        ensure_branch_exists_locally dev
        ensure_branch_exists_locally '"$branch_name"'

        checkout_branch_if_same_commit main
        checkout_branch_if_same_commit dev
        checkout_branch_if_same_commit '"$branch_name"'
    '
}


tgs_fix_head_c_d_m() {
    branch_name="$1"
    git fetch

    echo 'in top'
    fix_head_main
    fix_head_dev
    fix_head "$1"

    gs_fix_head_c_d_m "$1"

}
git_aliases+=("tgs_fix_head_c_d_m")

# Common argument parsing function
parse_arguments() {
    local func_name="$1"
    shift
    local options="$@"

    # Defaults
    timestamp="$(date +%Y%m%d%H%M%S)"
    file_name=""
    dir_name=".gitstate"
    custom_file=""
    latest_file=""
    superproject="$(pwd)"
    checkout_different_commit=false

    usage() {
        echo "Usage: ${func_name} [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  -t, --timestamp <timestamp>    Specify the timestamp (default: current timestamp)."
        echo "  -n, --name <name>              Set the base name for the file."
        echo "  -d, --dir <dir_name>           Set the directory for the file (default: '${dir_name}')."
        echo "  -f, --file <file>              Specify the full path to the file. Overrides --name and --dir."
        echo "  -l, --latest <latest_file>     Set the name for the latest file symlink."
        echo "  -s, --superproject <path>      Specify the path to the superproject (default: '${superproject}')."
        echo "  -h, --help                     Display this help message and exit."
        echo ""
        echo "Examples:"
        echo "  $func_name"
        echo "  ${func_name} --timestamp 20241129 --name my_file --dir /tmp"
        echo "  ${func_name} --file /custom/path/file_20241129.txt --latest custom_latest.txt"
    }

    # Parse options using getopt
    ARGS=$(getopt -o "t:n:d:f:l:s:hc" -l "timestamp:,name:,dir:,file:,latest:,superproject:,help,cccc" -- "$@")
    if [ $? -ne 0 ]; then
        usage
        return 1
    fi

    eval set -- "$ARGS"

    while true; do
        case "$1" in
            -t|--timestamp)
                timestamp="$2"
                shift 2
                ;;
            -n|--name)
                file_name="$2"
                shift 2
                ;;
            -d|--dir)
                dir_name="$2"
                shift 2
                ;;
            -f|--file)
                custom_file="$2"
                shift 2
                ;;
            -l|--latest)
                latest_file="$2"
                shift 2
                ;;
            -s|--superproject)
                superproject="$2"
                shift 2
                ;;
            -h|--help)
                usage
                return 1
                ;;
            -c|--ccc)
                checkout_different_commit=true
                shift 
                ;;
            --)
                shift
                break
                ;;
            *)
                echo "Invalid option: $1" >&2
                usage
                return 1
                ;;
        esac
    done
}

# Main function for save_branches
save_branches() {
    if ! parse_arguments "save_branches" "$@"; then
        return 1
    fi

    file_name="${file_name:-branches}"
    branch_file="${custom_file:-${dir_name}/${file_name}_${timestamp}.txt}"
    latest_file="${latest_file:-${file_name}_latest.txt}"

    pushd "$superproject" || exit
    mkdir -p "${dir_name}"

    super_branch="$(git symbolic-ref --short HEAD 2>/dev/null || echo 'detached')" # !!!!!!!!!!!!
    {
        echo "# timestamp:${timestamp}"
        echo "superproject:${super_branch}"
    } > "$branch_file"

    git submodule foreach '
        branch=$(git symbolic-ref --short HEAD 2>/dev/null || echo "detached")
        echo "$name:$branch" >> ../'"${branch_file}"'
    '

    cp "${branch_file}" "${latest_file}"
    echo "Branches saved to ${branch_file} and ${latest_file}."
    popd
}

# Main function for save_commits
save_commits() {
    if ! parse_arguments "save_commits" "$@"; then
        return 1
    fi

    file_name="${file_name:-commits}"
    commits_file="${custom_file:-${dir_name}/${file_name}_${timestamp}.txt}"
    latest_file="${latest_file:-${file_name}_latest.txt}"

    pushd "$superproject" || exit
    mkdir -p "$dir_name"

    super_commit="$(git rev-parse HEAD)" # !!!!!!!!!!!
    {
        echo "# timestamp:${timestamp}"
        echo "superproject:${super_commit}"
    } > "${commits_file}"

    git submodule foreach '
        commit=$(git rev-parse HEAD)
        echo "$name:$commit" >> ../'"${commits_file}"'
    '

    cp "$commits_file" "$latest_file"
    echo "Commits saved to ${commits_file} and ${latest_file}."
    popd
}

# Main function for save_stashes
save_stashes() {
    if ! parse_arguments "save_stashes" "$@"; then
        return 1
    fi

    file_name="${file_name:-stashes}"
    stashes_file="${custom_file:-${dir_name}/${file_name}_${timestamp}.txt}"
    latest_file="${latest_file:-${file_name}_latest.txt}"

    pushd "${superproject}" || exit
    mkdir -p "${dir_name}"

    touch "${stashes_file}"
    echo "# timestamp:${timestamp}" > "${stashes_file}"

    if git status --porcelain | grep -q "."; then
        super_stash_name="stash_superproject_${timestamp}"

        stash_sha="$(git stash create -u)" # !!!!!!!!!!!!!!
        if [ -n "$stash_sha" ]; then
            echo "Saving stash for superproject as ${super_stash_name}"
            git stash store -m "${super_stash_name}" "${stash_sha}"
            echo "superproject:${super_stash_name}" >> "${stashes_file}"
        else
            echo "No changes to stash in superproject."
        fi
    fi

    # Save submodule state
    git submodule status --recursive | while read -r line; do
        submodule_path="$(echo "${line}" | awk '{print $2}')" # !!!!!
        submodule_name="$(basename "${submodule_path}")" # !!!!!!!!!!!!

        (
            cd "$submodule_path" || exit

            # Save stash including untracked files
            if git status --porcelain | grep -q "."; then
                stash_name="stash_${submodule_name}_${timestamp}"

                stash_sha="$(git stash create -u)"
                if [ -n "$stash_sha" ]; then
                    echo "Saving stash for ${submodule_name} as ${stash_name}"
                    git stash store -m "$stash_name" "$stash_sha"
                    echo "${submodule_name}:${stash_name}" >> "../${stashes_file}"
                else
                    echo "No changes to stash in ${submodule_name}."
                fi
            fi
        )
    done


    cp "$stashes_file" "${latest_file}"
    echo "Stashes saved to ${stashes_file} and ${latest_file}."
    popd
}

git_aliases+=("save_branches")
git_aliases+=("save_commits")
git_aliases+=("save_stashes")


restore_branches() {
    if ! parse_arguments "restore_branches" "$@"; then
        return 1
    fi

    file_name="${file_name:-branches}"
    branch_file="${custom_file:-${dir_name}/${file_name}_${timestamp}.txt}"
    latest_file="${latest_file:-${file_name}_latest.txt}"
    echo "file_name: ${file_name}"
    echo "branch_file: ${branch_file}"
    echo "latest_file: ${latest_file}"

    # Determine which file to use: latest or custom
    if [[ -f "$latest_file" ]]; then
        branch_file="$latest_file"
    elif [[ ! -f "$branch_file" ]]; then
        echo "Error: Branch file ${branch_file} not found."
        return 1
    fi

    echo "Restoring branches from ${branch_file}..."
    echo "Force checkout option: ${checkout_different_commit}"

    # Read the branch file and restore branches
    while IFS=: read -r submodule branch; do
        echo "test"
        echo "Processing submodule: ${submodule}"
        echo "branch: ${branch}"

        if [[ "$submodule" == "superproject" ]]; then
            # Handle superproject branch separately
            if git rev-parse --verify "${branch}" >/dev/null 2>&1; then
                echo "Checking out superproject branch: ${branch}"
                git checkout "$branch" || echo "Warning: Unable to check out ${branch}."
            else
                echo "Superproject branch ${branch} does not exist locally."
            fi
            continue
        fi
        echo "UUUUUUUUUUUUUUUUUU"
        # Process submodule branches
        pushd "$submodule" || { echo "Error: Could not enter submodule ${submodule}"; continue; }
        echo "OOOOOOOOOOOOOOOO"
        branch_exists() {
            git show-ref --verify --quiet refs/heads/"$1"
        }
        echo "%%%%%%%%%"
        remote_branch_exists() {
            git ls-remote --exit-code --heads origin "$1" >/dev/null 2>&1
        }
        echo "**********"
        ensure_branch_exists_locally() {
            if ! branch_exists "$1"; then
                if remote_branch_exists "$1"; then
                    echo "Branch ${1} exists on remote. Fetching..."
                    git fetch origin "$1":"$1"
                fi
            fi
        }

        ensure_branch_exists_locally "${branch}"

        # Restore the branch based on whether it matches HEAD or not
        # if git rev-parse --verify "$branch" >/dev/null 2>&1; then
        if branch_exists "${branch}"; then
            if [ "$(git rev-parse HEAD)" = "$(git rev-parse ${branch})" ]; then
                echo "HEAD matches branch ${branch}. Checking out ${branch}..."
                git checkout "$branch"
            elif [ "${checkout_different_commit}" = true ]; then
                echo "HEAD does not match ${branch}. Force-checking out ${branch}..."
                save_stashes || echo "Warning: Failed to stash changes."
                git checkout "${branch}"
            else
                echo "HEAD does not match ${branch}. Skipping (use -c to force checkout)."
            fi
        else
            echo "Branch ${branch} does not exist locally or remotely. Skipping."
        fi

        popd || continue
    done < "${branch_file}" # "$(grep -v '^#' "$branch_file")"

    echo "Branch restoration complete."
}

git_aliases+=("restore_branches")

restore_commits() {
    if ! parse_arguments "restore_commits" "$@"; then
        return 1
    fi

    file_name="${file_name:-commits}"
    commit_file="${custom_file:-${dir_name}/${file_name}_${timestamp}.txt}"
    latest_file="${latest_file:-${file_name}_latest.txt}"

    # Determine which file to use: latest or custom
    if [[ -f "$latest_file" ]]; then
        commit_file="$latest_file"
    elif [[ ! -f "$commit_file" ]]; then
        echo "Error: Commit file ${commit_file} not found."
        return 1
    fi

    echo "Restoring commits from ${commit_file}..."

    # Read the commit file and restore commits
    while IFS=: read -r submodule commit; do
        echo "Processing submodule: ${submodule}"

        if [[ "$submodule" == "superproject" ]]; then
            # Handle superproject commit separately
            echo "Restoring superproject to commit: ${commit}"
            git checkout --detach "$commit" || echo "Warning: Unable to check out commit ${commit}."
            continue
        fi

        # Process submodule commits
        pushd "$submodule" || { echo "Error: Could not enter submodule ${submodule}"; continue; }

        echo "Restoring submodule to commit: ${commit}"
        git checkout --detach "${commit}" || echo "Warning: Unable to check out commit ${commit}."

        popd || continue
    done < "$commit_file" # "$(grep -v '^#' "$commit_file")"

    echo "Commit restoration complete."
}
git_aliases+=("restore_commits")

restore_ref_commits() {
    if ! parse_arguments "restore_ref_commits" "$@"; then
        return 1
    fi

    file_name="${file_name:-commits}"
    commit_file="${custom_file:-${dir_name}/${file_name}_${timestamp}.txt}"
    latest_file="${latest_file:-${file_name}_latest.txt}"

    # Determine which file to use: latest or custom
    if [[ -f "$latest_file" ]]; then
        commit_file="$latest_file"
    elif [[ ! -f "$commit_file" ]]; then
        echo "Error: Commit file ${commit_file} not found."
        return 1
    fi

    echo "Restoring commits from ${commit_file}..."

    # Read the commit file and restore commits
    while IFS=: read -r submodule commit; do
        echo "Processing submodule: ${submodule}"

        if [[ "$submodule" == "superproject" ]]; then
            # Handle superproject commit separately
            echo "skipping superproject"
            # echo "Restoring superproject to commit: ${commit}"
            # git checkout --detach "$commit" || echo "Warning: Unable to check out commit ${commit}."
            continue
        fi

        # # Process submodule commits
        # pushd "$submodule" || { echo "Error: Could not enter submodule ${submodule}"; continue; }

        echo "Restoring submodule to commit: ${commit}"
        git update-index --cacheinfo 160000 "${commit}" "$submodule" || echo "Warning: Unable to check out commit ${commit}."

        # git checkout --detach "${commit}" || echo "Warning: Unable to check out commit ${commit}."

        # popd || continue

    done < "$commit_file" # "$(grep -v '^#' "$commit_file")"

    echo "Commit restoration complete."
}
git_aliases+=("restore_ref_commits")

restore_stashes() {
    if ! parse_arguments "restore_stashes" "$@"; then
        return 1
    fi

    file_name="${file_name:-stashes}"
    stash_file="${custom_file:-${dir_name}/${file_name}_${timestamp}.txt}"
    latest_file="${latest_file:-${file_name}_latest.txt}"

    # Determine which file to use: latest or custom
    if [[ -f "$latest_file" ]]; then
        stash_file="$latest_file"
    elif [[ ! -f "$stash_file" ]]; then
        echo "Error: Stash file ${stash_file} not found."
        return 1
    fi

    echo "Restoring stashes from ${stash_file}..."

    # Read the stash file and apply stashes
    while IFS=: read -r submodule stash_name; do
        echo "Processing stash for submodule: $submodule"

        if [[ "$submodule" == "superproject" ]]; then
            # Handle superproject stash separately
            echo "Applying superproject stash: $stash_name"
            git stash list | grep "$stash_name" | head -n1 | cut -d: -f1 | xargs git stash apply || echo "Warning: Unable to apply stash ${stash_name}."
            continue
        fi

        # Process submodule stashes
        pushd "$submodule" || { echo "Error: Could not enter submodule ${submodule}"; continue; }

        echo "Applying stash for submodule: ${stash_name}"
        git stash list | grep "${stash_name}" | head -n1 | cut -d: -f1 | xargs git stash apply || echo "Warning: Unable to apply stash ${stash_name}."

        popd || continue
    done < "$stash_file" # "$(grep -v '^#' "$stash_file")"

    echo "Stash restoration complete."
}
git_aliases+=("restore_stashes")


save_state() {
    if ! parse_arguments "save_state" "$@"; then
        return 1
    fi


    echo "Saving state: branches, commits, and stashes..."

    # Save branches, commits, and stashes using the respective methods
    save_branches -t "$timestamp" -d "$dir_name"
    save_commits -t "$timestamp" -d "$dir_name"
    save_stashes -t "$timestamp" -d "$dir_name"

}


git_aliases+=("save_state")

restore_state() {
    if ! parse_arguments "restore_state" "$@"; then
        return 1
    fi

    file_name="${{file_name}:-'state'}"
    dir_name="${{dir_name}:-'.gitstate'}"

    branch_file="${{custom_file}:-${dir_name}'/branches_'${timestamp}'.txt'}"
    commit_file="${{custom_file}:-${dir_name}'/commits_'${timestamp}'.txt'}"
    stash_file="${{custom_file}:-${dir_name}'/stashes_'${timestamp}'.txt'}"

    latest_branch_file="${{latest_file}:-'branches_latest.txt'}"
    latest_commit_file="${{latest_file}:-'commits_latest.txt'}"
    latest_stash_file="${{latest_file}:-'stashes_latest.txt'}"

    # Use the latest files if no specific timestamp or custom file is provided
    if [[ -f "$latest_branch_file" ]]; then
        branch_file="$latest_branch_file"
    fi
    if [[ -f "$latest_commit_file" ]]; then
        commit_file="$latest_commit_file"
    fi
    if [[ -f "$latest_stash_file" ]]; then
        stash_file="$latest_stash_file"
    fi

    echo "Restoring state using:"
    echo "  Branches: $branch_file"
    echo "  Commits: $commit_file"
    echo "  Stashes: $stash_file"

    if [[ ! -f "$branch_file" || ! -f "$commit_file" || ! -f "$stash_file" ]]; then
        echo "Error: One or more state files are missing."
        return 1
    fi

    # Restore commits
    echo "Restoring commits..."
    restore_commits --file "$commit_file" || echo "Warning: Failed to restore commits."

    # Restore branches
    echo "Restoring branches..."
    if [ "$checkout_different_commit" = true ]; then
        restore_branches --file "$branch_file" -c || echo "Warning: Failed to restore branches."
    else
        restore_branches --file "$branch_file" || echo "Warning: Failed to restore branches."
    fi

    # Restore stashes
    echo "Restoring stashes..."
    restore_stashes --file "$stash_file" || echo "Warning: Failed to restore stashes."

    echo "State restoration complete."
}
git_aliases+=("restore_state")



git_aliases+=("graph")
git_aliases+=("graph_c")
git_aliases+=("graph_less")
git_aliases+=("graph_submodules")
git_aliases+=("graph_submodules_c")
git_aliases+=("graph_submodules_less")

git_aliases+=("useful_git")

useful_git(){

    echo ${git_aliases[@]}

}