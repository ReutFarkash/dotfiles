#!/usr/bin/env bash
# cleanup_home.sh — Interactive home directory cleanup.
# Moves old dotfiles, broken symlinks, and stale config files to ~/archive/.
# Nothing is deleted. You can restore anything from the archive.

set -euo pipefail

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

ARCHIVE_DIR="$HOME/archive/cleanup_$(date +%Y%m%d_%H%M%S)"
to_archive=()

_head()  { echo -e "\n${BOLD}── $1 ──${NC}"; }
_found() { echo -e "  ${YELLOW}→${NC} $1"; }
_skip()  { echo -e "  ${CYAN}·${NC} $1 (kept)"; }
_done()  { echo -e "  ${GREEN}✓${NC} $1"; }
_info()  { echo -e "  ${CYAN}ℹ${NC} $1"; }

ask() {
    local prompt="$1"
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "  ${CYAN}[dry-run]${NC} would ask: $prompt"
        return 1
    fi
    read -rp "    $prompt [y/N] " ans
    [[ "$ans" =~ ^[Yy]$ ]]
}

queue() {
    to_archive+=("$1")
    _found "Queued: $1"
}

# ── 1. Dangling symlinks ──────────────────────────────────────────────────────
_head "Dangling Symlinks"
found_any=false
while IFS= read -r link; do
    found_any=true
    target=$(readlink "$link" 2>/dev/null || echo "?")
    echo -e "  ${RED}✗${NC} $link → $target  (target missing)"
    if ask "Archive this broken symlink?"; then
        queue "$link"
    else
        _skip "$link"
    fi
done < <(find ~ -maxdepth 3 -xdev -type l 2>/dev/null | while IFS= read -r l; do
    [[ -e "$l" ]] || echo "$l"
done)
[[ "$found_any" == false ]] && _info "No dangling symlinks found"

# ── 2. Old dotfiles not from this repo ───────────────────────────────────────
_head "Dotfiles Not Managed by This Repo"
[[ -f ~/.user_config ]] && source ~/.user_config
repo="${DOTFILES_REPO:-}"

known_dotfiles=(.bashrc .bash_profile .bash_aliases .bash_env_vars .bash_prompt
                .bash_logout .bash_command_color_aliases .aw-terminal-hooks.bash
                .path .inputrc .editorconfig)

for f in "${known_dotfiles[@]}"; do
    fp="$HOME/$f"
    if [[ -f "$fp" && ! -L "$fp" ]]; then
        # Regular file, not a symlink — may be from an old setup
        if [[ -n "$repo" && -f "$repo/$f" ]]; then
            echo -e "  ${YELLOW}?${NC} ~/$f is a plain file (not a symlink to the repo)"
            if ask "Archive ~/$f and let bootstrap re-link from repo?"; then
                queue "$fp"
            else
                _skip "~/$f"
            fi
        fi
    fi
done

# Check for leftover files from common old dotfile conventions
old_patterns=(.aliases .exports .functions .extra .profile_old .bash_profile.bak .bashrc.bak .bash_aliases.bak)
for f in "${old_patterns[@]}"; do
    fp="$HOME/$f"
    if [[ -f "$fp" || -L "$fp" ]]; then
        echo -e "  ${YELLOW}?${NC} ~/$f — looks like an old backup or leftover"
        if ask "Archive ~/$f?"; then
            queue "$fp"
        else
            _skip "~/$f"
        fi
    fi
done

# ── 3. Stale local config files ───────────────────────────────────────────────
_head "Stale Local Config Files"
local_configs=(.local_aliases .venv_aliases_local)
for f in "${local_configs[@]}"; do
    fp="$HOME/$f"
    if [[ -f "$fp" ]]; then
        # Check if it's just the unedited template
        if grep -q "# EDIT THIS FILE" "$fp" 2>/dev/null && [[ $(grep -v '^#' "$fp" | grep -v '^[[:space:]]*$' | wc -l) -eq 0 ]]; then
            echo -e "  ${CYAN}·${NC} ~/$f appears to be an unedited template — keeping"
        fi
    fi
done
_info "Local config files (~/.local_aliases, ~/.venv_aliases_local) reviewed"

# ── 4. Duplicate or leftover archive folders ─────────────────────────────────
_head "Old Archive Folders in ~/"
archive_count=$(find ~/archive -maxdepth 1 -mindepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
if [[ "$archive_count" -gt 5 ]]; then
    echo -e "  ${YELLOW}⚠${NC} You have $archive_count archive folders in ~/archive/"
    _info "Consider reviewing ~/archive/ manually — this script won't touch existing archives."
elif [[ "$archive_count" -gt 0 ]]; then
    _info "$archive_count archive folder(s) in ~/archive/ — looks fine"
fi

# ── Execute ───────────────────────────────────────────────────────────────────
echo ""
if [[ ${#to_archive[@]} -eq 0 ]]; then
    echo -e "${GREEN}Nothing to archive — home directory looks clean.${NC}"
    exit 0
fi

echo -e "${BOLD}Files queued for archiving (${#to_archive[@]} items):${NC}"
for f in "${to_archive[@]}"; do
    echo "  $f"
done
echo ""
echo -e "Archive destination: ${CYAN}$ARCHIVE_DIR${NC}"
echo ""

if [[ "$DRY_RUN" == true ]]; then
    echo -e "${CYAN}[dry-run] No files moved. Re-run without --dry-run to apply.${NC}"
    exit 0
fi

read -rp "Move all queued items to archive now? [y/N] " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Cancelled — nothing moved."
    exit 0
fi

mkdir -p "$ARCHIVE_DIR"
for f in "${to_archive[@]}"; do
    mv "$f" "$ARCHIVE_DIR/"
    _done "Moved: $(basename "$f")"
done

echo ""
echo -e "${GREEN}Done. ${#to_archive[@]} item(s) archived to:${NC}"
echo "  $ARCHIVE_DIR"
echo ""
echo "To restore something:"
echo "  mv $ARCHIVE_DIR/<filename> ~/"
echo ""
echo "Run bootstrap.sh to re-link any dotfiles that were removed."
