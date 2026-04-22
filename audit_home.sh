#!/usr/bin/env bash
# audit_home.sh — Scan home directory for stale, broken, or suspicious items.
# Reports only. Nothing is deleted or changed.

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BOLD='\033[1m'
NC='\033[0m'

issues=0
warnings=0

_flag() { echo -e "  ${RED}✗${NC} $1"; ((issues++))   || true; }
_warn() { echo -e "  ${YELLOW}⚠${NC} $1"; ((warnings++)) || true; }
_ok()   { echo -e "  ${GREEN}✓${NC} $1"; }
_head() { echo -e "\n${BOLD}── $1 ──${NC}"; }

# ── 1. Dangling symlinks ──────────────────────────────────────────────────────
_head "Dangling Symlinks (depth 3)"
dangling=0
while IFS= read -r link; do
    _flag "$link → $(readlink "$link" 2>/dev/null || echo '?')  (target missing)"
    ((dangling++)) || true
done < <(find ~ -maxdepth 3 -xdev -type l 2>/dev/null | while IFS= read -r l; do
    [[ -e "$l" ]] || echo "$l"
done)
[[ $dangling -eq 0 ]] && _ok "No dangling symlinks found"

# ── 2. Dotfile symlink health ─────────────────────────────────────────────────
_head "Dotfile Symlinks"
[[ -f ~/.user_config ]] && source ~/.user_config
profile="${DOTFILES_PROFILE:-unknown}"

base_files=(.bashrc .bash_profile .bash_aliases .bash_env_vars .bash_logout .path)
prompt_files=(.bash_prompt prompt_utils.sh git_manager.sh stats_manager.sh theme_manager.sh manager.sh shorten_path.sh)
full_files=(.bash_command_color_aliases .aw-terminal-hooks.bash hydra_completion.sh)

check_dotfiles() {
    local -n flist=$1
    for f in "${flist[@]}"; do
        fp="$HOME/$f"
        if [[ -L "$fp" ]]; then
            if [[ -e "$fp" ]]; then
                _ok "~/$f → $(readlink "$fp")"
            else
                _flag "~/$f is a broken symlink → $(readlink "$fp")  (run bootstrap.sh to fix)"
            fi
        elif [[ -f "$fp" ]]; then
            _warn "~/$f is a regular file, not a symlink — may not track repo changes"
        fi
    done
}

check_dotfiles base_files
[[ "$profile" == "standard" || "$profile" == "full" ]] && check_dotfiles prompt_files
[[ "$profile" == "full" ]] && check_dotfiles full_files

if [[ -f ~/.user_config ]]; then
    repo_path=$(grep 'DOTFILES_REPO=' ~/.user_config | head -1 | sed 's/.*="\(.*\)"/\1/')
    if [[ -n "$repo_path" && ! -d "$repo_path" ]]; then
        _flag "DOTFILES_REPO in ~/.user_config points to missing path: $repo_path"
        echo "       Update ~/.user_config with the new repo location."
    elif [[ -n "$repo_path" ]]; then
        _ok "DOTFILES_REPO = $repo_path"
    fi
else
    _warn "~/.user_config missing — run setup.sh to configure your profile"
fi

# ── 3. Shell config conflicts ─────────────────────────────────────────────────
_head "Shell Config Conflicts"
[[ -f ~/.bash_profile && -f ~/.profile ]] && \
    _warn "Both ~/.bash_profile and ~/.profile exist — ~/.profile may load redundant settings"
[[ -f ~/.zshrc && -f ~/.bash_profile ]] && \
    _warn "Both ~/.zshrc and ~/.bash_profile exist — if default shell is zsh, bash config won't auto-load"

# ── 4. SSH key security ───────────────────────────────────────────────────────
_head "SSH Keys"
if [[ ! -d ~/.ssh ]]; then
    _warn "~/.ssh does not exist — no SSH keys configured"
else
    ssh_perm=$(stat -f '%A' ~/.ssh 2>/dev/null || stat -c '%a' ~/.ssh 2>/dev/null)
    if [[ "$ssh_perm" != "700" ]]; then
        _flag "~/.ssh permissions are $ssh_perm, should be 700  →  chmod 700 ~/.ssh"
    else
        _ok "~/.ssh permissions: 700"
    fi

    found_keys=0
    for keyfile in ~/.ssh/id_*; do
        [[ -f "$keyfile" && "$keyfile" != *.pub ]] || continue
        ((found_keys++)) || true

        kperm=$(stat -f '%A' "$keyfile" 2>/dev/null || stat -c '%a' "$keyfile" 2>/dev/null)
        [[ "$kperm" != "600" ]] && _flag "$keyfile has permissions $kperm, should be 600  →  chmod 600 $keyfile"

        key_info=$(ssh-keygen -l -f "$keyfile" 2>/dev/null)
        if [[ -z "$key_info" ]]; then
            _warn "$(basename "$keyfile") — could not read (passphrase-protected or unreadable)"
            continue
        fi
        bits=$(echo "$key_info" | awk '{print $1}')
        algo=$(echo "$key_info" | awk '{print $NF}' | tr -d '()')
        case "$algo" in
            DSA)    _flag "$(basename "$keyfile") — DSA is deprecated and insecure. Regenerate with ed25519." ;;
            RSA)
                if   [[ "$bits" -lt 2048 ]]; then _flag "$(basename "$keyfile") — RSA $bits-bit too weak. Use 4096+ or ed25519."
                elif [[ "$bits" -lt 4096 ]]; then _warn "$(basename "$keyfile") — RSA $bits-bit works, but ed25519 is preferred."
                else _ok "$(basename "$keyfile") — RSA $bits-bit"; fi ;;
            ECDSA)  _warn "$(basename "$keyfile") — ECDSA works, but ed25519 is preferred." ;;
            ED25519) _ok "$(basename "$keyfile") — Ed25519 (good)" ;;
            *)      _warn "$(basename "$keyfile") — unknown algorithm: $algo" ;;
        esac
    done
    [[ $found_keys -eq 0 ]] && _warn "No private SSH keys found in ~/.ssh"
fi

# ── 5. Git configuration ──────────────────────────────────────────────────────
_head "Git Configuration"
if ! command -v git &>/dev/null; then
    _warn "git is not installed"
else
    git_name=$(git config --global user.name 2>/dev/null || echo "")
    git_email=$(git config --global user.email 2>/dev/null || echo "")
    def_branch=$(git config --global init.defaultBranch 2>/dev/null || echo "")
    cred_helper=$(git config --global credential.helper 2>/dev/null || echo "")

    [[ -z "$git_name" ]]  && _flag "user.name not set  →  git config --global user.name 'Your Name'"
    [[ -n "$git_name" ]]  && _ok  "user.name = $git_name"
    [[ -z "$git_email" ]] && _flag "user.email not set  →  git config --global user.email 'you@example.com'"
    [[ -n "$git_email" ]] && _ok  "user.email = $git_email"
    [[ -z "$def_branch" ]] && _warn "init.defaultBranch not set — new repos default to 'master'  →  git config --global init.defaultBranch main"
    [[ -n "$def_branch" ]] && _ok  "init.defaultBranch = $def_branch"
    [[ -z "$cred_helper" ]] && _warn "credential.helper not set — you'll be asked for passwords repeatedly"
    [[ -n "$cred_helper" ]] && _ok  "credential.helper = $cred_helper"
fi

# ── 6. Leftover tool remnants ─────────────────────────────────────────────────
_head "Unused Tool Remnants"
check_remnant() {
    local dir="$1" cmd="$2" label="$3"
    if [[ -d "$dir" ]] && ! command -v "$cmd" &>/dev/null; then
        _warn "$dir exists but '$cmd' is not installed — may be a leftover ($label)"
    fi
}
check_remnant ~/.nvm   "nvm"   "Node Version Manager"
check_remnant ~/.rvm   "rvm"   "Ruby Version Manager"
check_remnant ~/.rbenv "rbenv" "rbenv"
check_remnant ~/.pyenv "pyenv" "pyenv"
check_remnant ~/.cargo "cargo" "Rust/Cargo"

# Large files sitting directly in ~/
_head "Unexpected Large Files in Home Root"
large_found=0
while IFS= read -r f; do
    size=$(du -sh "$f" 2>/dev/null | cut -f1)
    _warn "$f ($size) — consider moving this out of ~/"
    ((large_found++)) || true
done < <(find ~ -maxdepth 1 -type f -size +50M 2>/dev/null)
[[ $large_found -eq 0 ]] && _ok "No large files (>50 MB) found directly in ~/"

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo "══════════════════════════════════════════"
if [[ $issues -eq 0 && $warnings -eq 0 ]]; then
    echo -e "${GREEN}✓ All clear — nothing suspicious found.${NC}"
else
    [[ $issues   -gt 0 ]] && echo -e "${RED}✗ $issues issue(s) found${NC}"
    [[ $warnings -gt 0 ]] && echo -e "${YELLOW}⚠ $warnings warning(s) found${NC}"
    echo ""
    echo "This script only reports. Nothing was changed."
fi
echo ""
