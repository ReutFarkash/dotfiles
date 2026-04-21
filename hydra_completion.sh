#!/usr/bin/env bash

export _HYDRA_OLD_COMP="$(complete -p python 2> /dev/null)"

hydra_bash_completion() {
    # echo "line as an array: $COMP_WORDS"

    # echo "cursor index: $COMP_CWORD"

    # echo "line as a string: $COMP_LINE"

    # echo "#COMP_WORDS[@]: ${#COMP_WORDS[@]}"

    # helper="${COMP_WORDS[0]} ${COMP_WORDS[1]}"
    # ls -d "$PWD/"*
    # echo "helper: $helper"

    script_path="${COMP_WORDS[1]}" # "$(pwd -P)/${COMP_WORDS[1]}"

    if ! [[ "${COMP_WORDS[0]}" == *"python"* ]] ; then
    # echo 1
        return
    fi

    if (( "${#COMP_WORDS[@]}" <= 2 )); then
    # echo  "#COMP_LINE[@]: ${#COMP_WORDS[@]}"
            return
    fi
    if ! grep -q "@hydra.main" $script_path && ! grep -q "@config_path" $script_path ; then
    # echo 3
        return
    fi 

    python_exec=$( readlink -f $(which "${COMP_WORDS[0]}"))

    # echo "python_exec: $python_exec"
    # # # script_path="$file_path" # "${COMP_WORDS[1]}" # "$(pwd -P)/${COMP_WORDS[1]}"
    # echo "script_path: $script_path"
    choices=$( COMP_POINT="$COMP_POINT" COMP_LINE="$COMP_LINE" "$python_exec" "$script_path" -sc query=bash )
    # echo "Choices:"

    # for choice in "${choices[@]}"
    # do
    #     echo -n "$choice , "
    # done 
    # echo 
    word="${COMP_LINE[$COMP_CWORD]}"
    COMPREPLY=($( compgen -o nospace -o default -W "$choices" -- "$word" ));
}


COMP_WORDBREAKS="${COMP_WORDBREAKS//=}"
complete -o nospace -o default -F hydra_bash_completion python
complete -o nospace -o default -F hydra_bash_completion python.exe
