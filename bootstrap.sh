#!/usr/bin/env bash

if [ "$DEBUG" == true ]; then
    scriptpath="${CUR_DIR}/${BASH_ARGV[0]}"
    echo "running $scriptpath"
fi

# Resolve this script's directory, following symlinks
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
DIR="$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)"
echo "$DIR"

# Load profile-specific file lists (requires DIR to be set)
source "${DIR}/dotfiles_list.sh"

# Determine which file list to use
[[ -f ~/.user_config ]] && source ~/.user_config
PROFILE="${DOTFILES_PROFILE:-standard}"

case "$PROFILE" in
    minimal)
        FILES=("${FILES_MINIMAL[@]}")
        GIT_SCRIPTS=("${GIT_SCRIPTS_MINIMAL[@]}")
        ;;
    full)
        FILES=("${FILES_FULL[@]}")
        GIT_SCRIPTS=("${GIT_SCRIPTS_FULL[@]}")
        ;;
    *)
        FILES=("${FILES_STANDARD[@]}")
        GIT_SCRIPTS=("${GIT_SCRIPTS_STANDARD[@]}")
        ;;
esac

echo "Profile: $PROFILE — linking ${#FILES[@]} files"

source "${DIR}/manage_symlinks.sh"

# Archive any existing dotfiles before linking
echo "mkdir -p \"${HOME}/archive/\""
mkdir -p "${HOME}/archive/"
timestamp="$(date +%Y%m%d%H%M%S)"
archive_dir="${HOME}/archive/archive_${timestamp}/"
echo "mkdir -p \"${archive_dir}\""
mkdir -p "${archive_dir}"

for file in "${FILES[@]}"; do
    home_link="${HOME}/$(basename "$file")"
    archive_link="$archive_dir"
    if [[ -e "$home_link" || -L "$home_link" ]]; then
        echo "mv \"${home_link}\" \"${archive_link}\""
        mv "${home_link}" "${archive_link}"
    fi
done

create_symlinks "${HOME}" "${FILES[@]}"

if [[ "${#GIT_SCRIPTS[@]}" -gt 0 ]]; then
    create_symlinks "${HOME}/git_scripts" "${GIT_SCRIPTS[@]}"
fi
