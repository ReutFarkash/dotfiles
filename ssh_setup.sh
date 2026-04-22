#!/usr/bin/env bash
# ssh_setup.sh — Guided SSH key setup and ~/.ssh/config host alias scaffolding.
# Run standalone: bash ssh_setup.sh
# Safe to re-run: skips key generation if a key already exists; skips duplicate host aliases.

set -e

echo ""
echo "======================================"
echo "  SSH Setup"
echo "======================================"
echo ""

OS="$(uname)"

# ── 1. Ensure ~/.ssh exists with correct permissions ─────────────────────────
if [[ ! -d "$HOME/.ssh" ]]; then
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    echo "→ Created ~/.ssh"
fi

# ── 2. SSH key generation ────────────────────────────────────────────────────
DEFAULT_KEY="$HOME/.ssh/id_ed25519"

if [[ -f "$DEFAULT_KEY" ]]; then
    echo "SSH key already exists: $DEFAULT_KEY"
    echo "→ Skipping key generation."
else
    echo "No SSH key found at $DEFAULT_KEY."
    echo "A key comment identifies this machine in authorized_keys and GitHub."
    echo "  (Press Enter to use: ${USER}@$(hostname -s))"
    echo ""
    read -rp "Key comment [${USER}@$(hostname -s)]: " key_comment
    key_comment="${key_comment:-${USER}@$(hostname -s)}"

    echo ""
    echo "Generating ed25519 key..."
    ssh-keygen -t ed25519 -C "$key_comment" -f "$DEFAULT_KEY"
    echo "→ Key generated: $DEFAULT_KEY"
fi

# ── 3. Display the public key ─────────────────────────────────────────────────
echo ""
echo "Your public key (add this to GitHub, remote servers, etc.):"
echo ""
cat "${DEFAULT_KEY}.pub"
echo ""

# Clipboard copy — macOS uses pbcopy, Linux tries xclip then wl-copy.
# All branches use `if` so a missing/failing clipboard tool doesn't abort under set -e.
if [[ "$OS" == "Darwin" ]] && pbcopy < "${DEFAULT_KEY}.pub" 2>/dev/null; then
    echo "→ Public key copied to clipboard."
elif command -v xclip >/dev/null 2>&1 && xclip -selection clipboard < "${DEFAULT_KEY}.pub" 2>/dev/null; then
    echo "→ Public key copied to clipboard (xclip)."
elif command -v wl-copy >/dev/null 2>&1 && wl-copy < "${DEFAULT_KEY}.pub" 2>/dev/null; then
    echo "→ Public key copied to clipboard (wl-copy)."
else
    echo "  (Clipboard not available — copy it manually from above.)"
fi

# ── 4. ssh-agent ─────────────────────────────────────────────────────────────
echo ""
read -rp "Add this key to ssh-agent now? [Y/n]: " add_agent
if [[ ! "$add_agent" =~ ^[Nn]$ ]]; then
    if [[ "$OS" == "Darwin" ]]; then
        # macOS: persist via Keychain so you don't re-enter the passphrase after reboot
        ssh-add --apple-use-keychain "$DEFAULT_KEY"
        echo "→ Key added to agent and macOS Keychain."
    else
        ssh-add "$DEFAULT_KEY"
        echo "→ Key added to agent."
    fi
fi

# ── 5. ~/.ssh/config scaffolding ─────────────────────────────────────────────
echo ""
read -rp "Add a host alias to ~/.ssh/config? [y/N]: " add_host
if [[ "$add_host" =~ ^[Yy]$ ]]; then
    SSH_CONFIG="$HOME/.ssh/config"

    # Ensure config exists with correct permissions
    if [[ ! -f "$SSH_CONFIG" ]]; then
        touch "$SSH_CONFIG"
        chmod 600 "$SSH_CONFIG"
        echo "→ Created ~/.ssh/config"
    fi

    echo ""
    read -rp "Host alias (e.g. myserver): " host_alias
    read -rp "Hostname or IP (e.g. 192.168.1.100): " host_hostname
    read -rp "Remote user [${USER}]: " host_user
    host_user="${host_user:-${USER}}"

    if [[ -z "$host_alias" || -z "$host_hostname" ]]; then
        echo "→ Skipped: alias and hostname are required."
    elif grep -q "^Host ${host_alias}$" "$SSH_CONFIG" 2>/dev/null; then
        echo "→ Host '${host_alias}' already exists in ~/.ssh/config — not adding duplicate."
    else
        # Blank line separator if config already has content
        if [[ -s "$SSH_CONFIG" ]]; then
            echo "" >> "$SSH_CONFIG"
        fi

        cat >> "$SSH_CONFIG" << EOF
Host ${host_alias}
    HostName ${host_hostname}
    User ${host_user}
    IdentityFile ${DEFAULT_KEY}
EOF

        # macOS keychain integration: add UseKeychain + AddKeysToAgent to the block
        if [[ "$OS" == "Darwin" ]]; then
            cat >> "$SSH_CONFIG" << EOF
    UseKeychain yes
    AddKeysToAgent yes
EOF
        fi

        chmod 600 "$SSH_CONFIG"
        echo "→ Added host '${host_alias}' to ~/.ssh/config"
        echo "  You can now connect with: ssh ${host_alias}"
    fi
fi

# ── Done ─────────────────────────────────────────────────────────────────────
echo ""
echo "======================================"
echo "  SSH setup complete!"
echo "======================================"
echo ""
echo "Next steps:"
echo "  • Add your public key to GitHub: https://github.com/settings/keys"
echo "  • Copy it to a server:           ssh-copy-id ${host_alias:-user@server}"
echo "  • Test a connection:             ssh -T git@github.com"
echo ""
