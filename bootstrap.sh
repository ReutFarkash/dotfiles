#!/usr/bin/env bash

if [ "$DEBUG" == true ]; then
    scriptpath="${CUR_DIR}/${BASH_ARGV[0]}"
    echo "running $scriptpath"
fi


# Resolve the symbolic link to get the actual script path
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
DIR="$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)"
echo "$DIR"

# Source the file list
source "${DIR}/dotfiles_list.sh"

source "${DIR}/manage_symlinks.sh"

echo "mkdir -p \"${HOME}/archive/\""
mkdir -p "${HOME}/archive/"
timestamp="$(date +%Y%m%d%H%M%S)"
archive_dir="${HOME}/archive/archive_${timestamp}/"
echo "mkdir -p \"${archive_dir}\""
mkdir -p "${archive_dir}"
for file in "${FILES[@]}"; do
        home_link="${HOME}/$(basename "$file")"
        archive_link="$archive_dir"
        echo "mv \"${home_link}\" \"${archive_link}\""
        mv "${home_link}" "${archive_link}"
done
# Run the function for dotfiles in the home directory and git scripts in ~/git_scripts
create_symlinks "${HOME}" "${FILES[@]}"
create_symlinks "${HOME}/git_scripts" "${GIT_SCRIPTS[@]}"