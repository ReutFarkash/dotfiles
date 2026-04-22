# dotfiles_list.sh — Profile-aware file lists for bootstrap.sh
# DIR must be set by the caller before sourcing this file.

# ── Minimal: basic shell only ─────────────────────────────────────────────────
FILES_MINIMAL=(
    "$DIR/.path"
    "$DIR/.bashrc"
    "$DIR/.bash_env_vars"
    "$DIR/.bash_aliases"
    "$DIR/.bash_profile"
    "$DIR/.bash_logout"
)
GIT_SCRIPTS_MINIMAL=()

# ── Standard: adds prompt system ─────────────────────────────────────────────
FILES_STANDARD=(
    "${FILES_MINIMAL[@]}"
    "$DIR/.bash_prompt"
    "$DIR/prompt_utils.sh"
    "$DIR/git_manager.sh"
    "$DIR/stats_manager.sh"
    "$DIR/theme_manager.sh"
    "$DIR/manager.sh"
    "$DIR/shorten_path.sh"
)
GIT_SCRIPTS_STANDARD=()

# ── Full: everything ──────────────────────────────────────────────────────────
FILES_FULL=(
    "${FILES_STANDARD[@]}"
    "$DIR/.bash_command_color_aliases"
    "$DIR/.aw-terminal-hooks.bash"
    "$DIR/hydra_completion.sh"
)
GIT_SCRIPTS_FULL=(
    "$DIR/git_scripts/gitsubmodules_scripts.sh"
    "$DIR/git_scripts/graph_submodules.sh"
    "$DIR/git_scripts/lazygit.sh"
)
