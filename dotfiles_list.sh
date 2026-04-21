# dotfiles_list.sh

# List of dotfiles for the home directory
FILES=(
    "$DIR/.path"
    "$DIR/.bashrc"
    "$DIR/.bash_env_vars"
    "$DIR/.bash_aliases"
    "$DIR/.bash_profile"
    "$DIR/.bash_prompt"
    "$DIR/.bash_command_color_aliases"
    "$DIR/.bash_logout"
    "$DIR/.aw-terminal-hooks.bash"
    "$DIR/prompt_utils.sh"
    "$DIR/git_manager.sh"
    "$DIR/stats_manager.sh"
    "$DIR/theme_manager.sh"
    "$DIR/manager.sh"
    "$DIR/shorten_path.sh"
    "$DIR/hydra_completion.sh"
)

# List of git script files (will go in ~/git_scripts)
GIT_SCRIPTS=(
    "$DIR/git_scripts/gitsubmodules_scripts.sh"
    "$DIR/git_scripts/graph_submodules.sh"
    "$DIR/git_scripts/lazygit.sh"
)
