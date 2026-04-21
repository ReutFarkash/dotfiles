#!/usr/bin/env bash

if [ "$DEBUG" == true ]; then
    scriptpath="${CUR_DIR}/${BASH_ARGV[0]}"
    echo "running $scriptpath"
fi

source ~/prompt_utils.sh
source ~/theme_manager.sh

source ~/git_manager.sh
source ~/stats_manager.sh
source ~/shorten_path.sh
