
if [ "$DEBUG" == true ]; then
    scriptpath="${CUR_DIR}/${BASH_ARGV[0]}"
    echo "running $scriptpath"
fi

# ── Profile dispatch ──────────────────────────────────────────────────────────
[[ -f ~/.user_config ]] && source ~/.user_config

if [[ "${DOTFILES_PROFILE}" == "minimal" ]]; then
    [[ -f "${DOTFILES_REPO}/profiles/minimal.sh" ]] && source "${DOTFILES_REPO}/profiles/minimal.sh"
    return 0 2>/dev/null || exit 0
fi

if [[ "${DOTFILES_PROFILE}" == "standard" ]]; then
    [[ -f "${DOTFILES_REPO}/profiles/standard.sh" ]] && source "${DOTFILES_REPO}/profiles/standard.sh"
    return 0 2>/dev/null || exit 0
fi

if [[ "${DOTFILES_PROFILE}" == "full" ]]; then
    [[ -f "${DOTFILES_REPO}/profiles/full.sh" ]] && source "${DOTFILES_REPO}/profiles/full.sh"
    return 0 2>/dev/null || exit 0
fi

# Fallback: standard profile
[[ -f "${DOTFILES_REPO}/profiles/standard.sh" ]] && source "${DOTFILES_REPO}/profiles/standard.sh"
