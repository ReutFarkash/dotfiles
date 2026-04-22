
if [ "$DEBUG" == true ]; then
    scriptpath="${CUR_DIR}/${BASH_ARGV[0]}"
    echo "running $scriptpath"
fi

# ── Profile: load minimal set for non-dev users, full set for everyone else ──
[[ -f ~/.user_config ]] && source ~/.user_config
if [[ "${DOTFILES_PROFILE}" == "minimal" ]]; then
    [[ -f "${DOTFILES_REPO}/profiles/minimal.sh" ]] && source "${DOTFILES_REPO}/profiles/minimal.sh"
    return 0 2>/dev/null || exit 0
fi

if [[ "${DOTFILES_PROFILE}" == "standard" ]]; then
    [[ -f "${DOTFILES_REPO}/profiles/standard.sh" ]] && source "${DOTFILES_REPO}/profiles/standard.sh"
    return 0 2>/dev/null || exit 0
fi

# Full profile: load base aliases first so navigation, ls, safety, and git basics are always present
[[ -f "${DOTFILES_REPO}/profiles/minimal.sh" ]] && source "${DOTFILES_REPO}/profiles/minimal.sh"
export PRINTGIT=true

is_gitbash_admin() {
    if net session &>/dev/null; then
        echo "true"
    else
        echo "false"
    fi
}

if [[ "$(uname -r)" == *"microsoft"* ]]; then
  echo "Running in WSL2"
  export Cpath="/mnt/c/"
  export C__path="$Cpath"
  export Epath="/mnt/e/"
  export E__path="$Epath"
  export Dpath="/mnt/d/"
  export D__path="$Dpath"
elif [[ "$(uname)" == *"MINGW64"* ]]; then
  echo "Running in Git Bash"
  export Cpath="/c/"
  export C__path="C:/"
  export Epath="/e/"
  export E__path="E:/"
  export Dpath="/d/"
  export D__path="D:/"

  if [ "$(is_gitbash_admin)" == "true" ]; then
      export ADMIN=TRUE
  else
      export ADMIN=FALSE
  fi


else
    echo "Couldn't decifer cmd type"
    export Cpath="????"
fi


export user="$LOGNAME"  # <-- CHANGE USERNAME
export winhome="cd ${Cpath}Users/${user}/"


if [ -f ~/.local_aliases ]; then
    source ~/.local_aliases  # required: PROJECT_PATH
else
    echo "~/.local_aliases don't exist.."
fi

# Resolve the symbolic link to get the actual script path
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
DIR="$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)"

export repo_dotfiles="${DIR}/"

export PATH="$PATH:${C__path}Program Files/Microsoft VS Code/bin:/usr/bin"

if ! [[ "$(uname -r)" == *"microsoft"* ]]; then
    echo "Not in WSL, setting winpy python.exe"
    alias python='winpty python.exe'
    else
    echo "in WSL"
fi


source ~/git_scripts/graph_submodules.sh

source ~/hydra_completion.sh

dir_aliases=("dir aliases: ")
dir_aliases_short=("dir aliases short: ")

if [ -f ~/.venv_aliases_local ]; then
    source ~/.venv_aliases_local  # copy from .venv_aliases_template to start
else
    echo "~/.venv_aliases_local don't exist.."
fi

alias bootstrap="${repo_dotfiles}bootstrap.sh"
alias unbootstrap="${repo_dotfiles}unbootstrap.sh"
alias bashrc="source ~/.bashrc"
alias update_aliases="source ~/.bash_aliases"
alias debug_true="export DEBUG=true"
alias debug_false="export DEBUG=false"
alias printgit_true="export PRINTGIT=true"
alias printgit_false="export PRINTGIT=false"

source ~/git_scripts/lazygit.sh

source ~/.bash_command_color_aliases



useful() {
    echo "PROJECT_PATH"
    echo "graph bootstrap bashrc update_aliases"
}

more_useful() {
    echo ' '
    echo 'USEFUL COMMANDS:'
    echo 'cd $PROJECT_PATH   # go to your project directory'
    echo 'graph             # print summarized git log graph (git log --oneline --graph --decorate --all)'
    echo 'start_dev         # go to project dir + activate dev_venv + launch VScode'
    echo 'start_test        # same as start_dev but with test_venv'
    echo 'bashrc            # source ~/.bashrc'
    echo 'bootstrap         # create dotefile symbolic links'
    echo 'update_aliases    # source ~/.bash_aliases'
    echo 'debug_true        # set DEBUG env var to print verbose debug messages in dotfiles'
    echo 'debug_false       # the reverse'
    echo 'printgit_true     # set PRINTGIT env var to print git info in bash promt'
    echo 'printgit_false    # the reverse'
    echo 'act_dev           # activate dev_venv (source ${dev_venv}bin/activate)'
    echo 'act_test          # activate test_venv (source ${test_venv}bin/activate)'
    echo 'useful            # print list of useful funcs for quick reminder'
    echo 'more_useful       # more verbose'
    echo 'useful_git        # print list of useful git funcs for quick reminder'
    echo 'prompt_explain    # print command line prompt icon glossary'
    echo ${dir_aliases[@]}
    # echo ${dir_aliases_short[@]}

}
# echo "test"
more_useful
#[ -n "$PS1" ] && more_useful
