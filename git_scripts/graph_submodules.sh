#!/usr/bin/env bash


alias graph="git log --oneline --graph --decorate --all"
alias graph_c="graph --color=always"
alias graph_less="graph --color=always | less -R"

function graph_submodules() {
    
    local line_num="${1:-2}"
    echo "Top:"
    graph --color=always | grep HEAD -C $line_num

    while IFS= read -r submodule
    do
        pushd "$submodule" > /dev/null
        echo ""
        echo "$submodule:"
        graph --color=always | grep HEAD -C $line_num
        popd > /dev/null
    done < <(git config --file .gitmodules --get-regexp path | awk '{ print $2 }')

}


function graph_submodules_c() {
    
    local line_num="${1:-2}"
    graph_submodules $line_num | less -R
}

alias graph_submodules_less="graph_submodules_c"