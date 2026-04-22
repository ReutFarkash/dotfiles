#!/usr/bin/env bash
# pre_setup_admin.sh — Admin prep for a Mac before handing it to a non-technical user.
# Run as an admin account (not with sudo): bash pre_setup_admin.sh
#
# Prerequisites (do these before running):
#   • Create the target user in System Settings > Users & Groups
#   • Log in as an admin account (not the target user, not as root)
#
# What it does:
#   1. Optionally installs Xcode Command Line Tools
#   2. Optionally installs Homebrew + bash 5.x
#   3. Adds the chosen bash to /etc/shells (requires sudo — will prompt once)
#   4. Sets the target user's default shell to that bash (requires sudo)

set -e

echo ""
echo "======================================"
echo "  Pre-Setup Admin Script"
echo "======================================"
echo ""

# ── 0. Guard: must not be run as root ─────────────────────────────────────────
if [[ "$EUID" -eq 0 ]]; then
    echo "✗ Run this script as an admin user, not with sudo." >&2
    echo "  Homebrew refuses to install as root." >&2
    exit 1
fi

# ── 1. macOS only ─────────────────────────────────────────────────────────────
if [[ "$(uname)" != "Darwin" ]]; then
    echo "✗ This script is for macOS only." >&2
    exit 1
fi

# ── 2. Target username ────────────────────────────────────────────────────────
echo "Which user account are you setting up?"
echo "  (The non-technical user you are handing this Mac to.)"
echo "  (Create them in System Settings > Users & Groups first if not yet done.)"
echo ""
read -rp "Target username: " target_user

if [[ -z "$target_user" ]]; then
    echo "✗ Username required." >&2
    exit 1
fi

if ! id "$target_user" >/dev/null 2>&1; then
    echo "✗ User '$target_user' does not exist on this machine." >&2
    echo "  Create them in System Settings > Users & Groups, then re-run." >&2
    exit 1
fi
echo "→ Target user: $target_user"
echo ""

# ── 3. Xcode Command Line Tools ───────────────────────────────────────────────
echo "Checking Xcode Command Line Tools..."
if xcode-select -p >/dev/null 2>&1; then
    echo "→ Already installed: $(xcode-select -p)"
else
    echo "Xcode CLT is not installed. It is required by Homebrew and many dev tools."
    read -rp "Install Xcode Command Line Tools now? [y/N]: " install_xcode
    if [[ "$install_xcode" =~ ^[Yy]$ ]]; then
        xcode-select --install
        echo ""
        echo "A dialog has opened to install Xcode CLT. Wait for it to finish."
        read -rp "Press Enter once the Xcode CLT installation is complete: "
    else
        echo "→ Skipped. Install later with: xcode-select --install"
    fi
fi
echo ""

# ── 4. Homebrew ───────────────────────────────────────────────────────────────
if command -v brew >/dev/null 2>&1; then
    echo "→ Homebrew already installed at: $(brew --prefix)"
else
    echo "Homebrew is not installed."
    read -rp "Install Homebrew now? [y/N]: " install_brew
    if [[ "$install_brew" =~ ^[Yy]$ ]]; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        echo "→ Homebrew installed."
        # Update PATH for the rest of this script (brew may not be in PATH yet)
        if [[ -x /opt/homebrew/bin/brew ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -x /usr/local/bin/brew ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    else
        echo "→ Skipped. Install later from: https://brew.sh"
    fi
fi
echo ""

# ── 5. Homebrew bash (bash 5.x) ───────────────────────────────────────────────
# Offer if Homebrew is present and the modern bash is not yet installed.
BREW_BASH_ARM="/opt/homebrew/bin/bash"
BREW_BASH_INTEL="/usr/local/bin/bash"

brew_bash_installed=false
if [[ -x "$BREW_BASH_ARM" || -x "$BREW_BASH_INTEL" ]]; then
    brew_bash_installed=true
fi

if command -v brew >/dev/null 2>&1 && ! $brew_bash_installed; then
    echo "Homebrew is installed but bash 5.x is not."
    echo "  macOS ships with bash 3.2 (/bin/bash). A modern bash is better."
    read -rp "Install bash via Homebrew? [y/N]: " install_bash
    if [[ "$install_bash" =~ ^[Yy]$ ]]; then
        brew install bash
        brew_bash_installed=true
        echo "→ bash 5.x installed."
    else
        echo "→ Skipped. Install later with: brew install bash"
    fi
fi
echo ""

# ── 6. Choose target bash path ────────────────────────────────────────────────
if [[ -x "$BREW_BASH_ARM" ]]; then
    TARGET_BASH="$BREW_BASH_ARM"
elif [[ -x "$BREW_BASH_INTEL" ]]; then
    TARGET_BASH="$BREW_BASH_INTEL"
else
    TARGET_BASH="/bin/bash"
fi
echo "→ Target shell: $TARGET_BASH"
echo ""

# ── 7. Add bash to /etc/shells ────────────────────────────────────────────────
if grep -qxF "$TARGET_BASH" /etc/shells 2>/dev/null; then
    echo "→ $TARGET_BASH already in /etc/shells. Skipping."
else
    echo "Adding $TARGET_BASH to /etc/shells (requires admin password)..."
    echo "$TARGET_BASH" | sudo tee -a /etc/shells >/dev/null
    echo "→ Added $TARGET_BASH to /etc/shells"
fi
echo ""

# ── 8. Set default shell for target user ─────────────────────────────────────
current_shell=$(dscl . -read /Users/"$target_user" UserShell 2>/dev/null | awk '{print $2}')
if [[ "$current_shell" == "$TARGET_BASH" ]]; then
    echo "→ $target_user's shell is already $TARGET_BASH. Skipping."
else
    echo "Switching $target_user's default shell from '$current_shell' to $TARGET_BASH..."
    sudo chsh -s "$TARGET_BASH" "$target_user"
    echo "→ Default shell set for $target_user."
fi
echo ""

# ── Done ─────────────────────────────────────────────────────────────────────
echo "======================================"
echo "  Admin prep complete!"
echo "======================================"
echo ""
echo "Next steps:"
echo "  1. Log in as '$target_user'"
echo "  2. Clone the dotfiles repo and run:  bash setup.sh"
echo "  3. Or walk them through GUIDE.md §1 for the basics"
echo ""
