#!/usr/bin/env bash

if [ "$DEBUG" == true ]; then
    scriptpath="${CUR_DIR}/${BASH_ARGV[0]}"
    echo "running $scriptpath"
fi


# Helper function to create symbolic links
create_symlinks() {
    local target_dir=$1
    shift
    local files=("$@")

    # Create the target directory if it doesn’t exist (for git scripts)
    mkdir -p "$target_dir"

    for file in "${files[@]}"; do
        link="${target_dir}/$(basename "$file")"
        target="$file"

        # Delete existing link if it exists
        if [ -L "$link" ]; then
            echo "Removing existing symlink ${link}"
            rm "$link"
        fi

        # Create a new symlink
        echo "Creating symlink for ${file} in ${link}"
        MSYS=winsymlinks:native ln -s "${target}" "${link}"
    done
}

