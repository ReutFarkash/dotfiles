# dotfiles

Bash dotfiles for macOS and Linux. Three profiles — pick the one that fits.

CI: ![macOS + Ubuntu](https://github.com/ReutFarkash/dotfiles/actions/workflows/test.yml/badge.svg) ![Windows](https://github.com/ReutFarkash/dotfiles/actions/workflows/test-windows.yml/badge.svg)

---

## TL;DR — Quick start

Open **Terminal** and paste these two lines:

```bash
git clone https://github.com/ReutFarkash/dotfiles.git ~/dotfiles
bash ~/dotfiles/setup.sh
```

When it asks **"Which profile?"**, just press Enter — the default (`standard`) is the right choice.  
Press Enter for everything else too — the defaults are fine.

Close and reopen Terminal. Done.  
Type `useful` to see what's available.

> **macOS only:** If it asks to install Git, click Install and run the second line again once it finishes.

### Other things you can run anytime

Set up your SSH key (needed to connect to GitHub or remote servers):
```bash
bash ~/dotfiles/ssh_setup.sh
```

Check your home folder for broken or misconfigured files:
```bash
bash ~/dotfiles/audit_home.sh
```

Clean up old leftover files (moves them to an archive folder — nothing is deleted):
```bash
bash ~/dotfiles/cleanup_home.sh
```

Generate a personal command cheat sheet saved to your home folder:
```bash
bash ~/dotfiles/generate_cheatsheet.sh
```

Read the general bash/git/Python guide (Git, venv, SSH, aliases, permissions, and more):
```bash
less ~/dotfiles/GUIDE.md
```

---

## Profiles

### `minimal` — basics only

A clean, safer shell. Good for anyone who just wants a friendlier terminal without extras.

- Navigation: `..`, `...`, `~`
- Improved listing: `l`, `la`, `ll`, `lr` (newest at bottom)
- Safety nets: `rm`, `cp`, `mv` ask before overwriting
- Shortcuts: `reload`, `myip`, `path`
- Git basics: `gs` (status), `gp` (pull), `glog` (visual log)

### `standard` — everyday use *(default)*

Everything in minimal, plus:

- Custom prompt showing git branch, git status icons, and active venv
- `graph` — visual git log (all branches)
- `gc`, `ga`, `gd` — quick commit, add, diff
- Machine-specific aliases via `~/.local_aliases`
- Venv shortcuts via `~/.venv_aliases_local`
- `useful` — prints available commands on shell start

### `full` — developer setup

Everything in standard, plus:

- `debug_true` / `debug_false` — toggle DEBUG output
- `printgit_true` / `printgit_false` — toggle git prompt
- `bootstrap` — re-run symlink setup from anywhere
- `update_aliases` — reload `.bash_aliases` without opening a new terminal
- Git submodule tools and state save/restore (`lazygit.sh`, `graph_submodules.sh`)
- Bash completion for [Hydra](https://hydra.cc) ML framework
- ActivityWatch terminal time-tracking integration

---

## Setup

### New machine

```bash
git clone https://github.com/ReutFarkash/dotfiles.git ~/dotfiles
bash ~/dotfiles/setup.sh
```

`setup.sh` is interactive and walks through everything. It will ask:

1. **Profile** — `1` full, `2` standard (default), `3` minimal
2. **Username** — personalises the prompt; defaults to your system username
3. **Git identity** — name and email for commit attribution (skipped if already set)
4. **Shell switch** *(macOS only)* — offer to change default shell to bash
5. **Cheat sheet** — offer to generate `~/shell-cheatsheet.md` and `~/shell-cheatsheet.txt`

The repo can live anywhere — not just `~/dotfiles`. `DOTFILES_REPO` in `~/.user_config` tracks the path.

### Windows (Git Bash)

Open **Git Bash** (not PowerShell or cmd) and run the same command. The script detects the platform and skips macOS-specific steps. Symlink creation requires either administrator rights or Developer Mode enabled in Windows settings.

### Re-running setup

`setup.sh` is safe to re-run. It skips steps that are already done (`~/.user_config` already exists, git identity already set, etc.).

---

## What gets installed

`bootstrap.sh` creates symlinks based on the selected profile. Only files the profile actually uses are linked — minimal users don't get hydra completion or the prompt system in their home directory.

### Symlinked files by profile

**All profiles (minimal+):**

| File | Purpose |
|------|---------|
| `.bashrc` | Core session config |
| `.bash_profile` | Login shell entry point |
| `.bash_aliases` | Profile dispatcher — sources the right profile on startup |
| `.bash_env_vars` | Environment variable defaults (`DEBUG`, `PRINTGIT`) |
| `.bash_logout` | Cleanup on logout |
| `.path` | PATH extensions |

**Standard and full only (prompt system):**

| File | Purpose |
|------|---------|
| `.bash_prompt` | Custom prompt with git status and venv indicator |
| `manager.sh` | Loads the prompt utility scripts |
| `prompt_utils.sh` | Color/styling functions |
| `theme_manager.sh` | Prompt theme definitions |
| `git_manager.sh` | Git helpers and branch detection for the prompt |
| `stats_manager.sh` | Git stats (staged, unstaged counts) |
| `shorten_path.sh` | Shortens long paths in the prompt display |

**Full only:**

| File | Purpose |
|------|---------|
| `.bash_command_color_aliases` | Color and formatting shortcuts |
| `.aw-terminal-hooks.bash` | ActivityWatch terminal integration |
| `hydra_completion.sh` | Tab completion for the Hydra CLI |
| `~/git_scripts/graph_submodules.sh` | Visual git log across submodules |
| `~/git_scripts/lazygit.sh` | Save and restore full git state |
| `~/git_scripts/gitsubmodules_scripts.sh` | Submodule workflow helpers |

### Not symlinked (machine-specific, created from templates)

| File | Purpose |
|------|---------|
| `~/.user_config` | Profile, username, `DOTFILES_REPO` path — generated by `setup.sh` |
| `~/.local_aliases` | Machine-specific paths and aliases — edit freely, never committed |
| `~/.venv_aliases_local` | Per-machine venv activation shortcuts — edit freely, never committed |

---

## Utility scripts

These can be run at any time from the repo root.

### `ssh_setup.sh` — SSH key and config

Guided SSH key setup and `~/.ssh/config` host alias scaffolding. Safe to re-run — skips key generation if a key already exists, and won't add a duplicate host alias.

```bash
bash ~/dotfiles/ssh_setup.sh
```

What it does:
- Generates an `ed25519` key at `~/.ssh/id_ed25519` (if none exists)
- Displays the public key and copies it to the clipboard
- Optionally adds the key to `ssh-agent` (macOS: persists via Keychain)
- Optionally adds a named host block to `~/.ssh/config` — sets `HostName`, `User`, `IdentityFile`; on macOS also adds `UseKeychain yes` and `AddKeysToAgent yes`
- Creates `~/.ssh/` (mode 700) and `~/.ssh/config` (mode 600) with correct permissions

### `audit_home.sh` — health check

Scans the home directory and reports issues. **Never changes anything.**

```bash
bash ~/dotfiles/audit_home.sh
```

Checks:
- Dangling symlinks (broken targets, depth 3)
- Dotfile symlink health — broken links, plain files that should be symlinks, stale `DOTFILES_REPO` path
- Shell config conflicts (`.bash_profile` + `.profile`, bash vs. zsh)
- SSH key security — permissions, algorithm, key strength
- Git configuration — `user.name`, `user.email`, `init.defaultBranch`, `credential.helper`
- Leftover tool remnants (`.nvm`, `.rvm`, `.pyenv`, `.cargo` for uninstalled tools)
- Large files (>50 MB) sitting directly in `~/`

### `cleanup_home.sh` — interactive archiver

Walks through old or broken files and moves approved items to `~/archive/cleanup_<timestamp>/`. **Nothing is deleted** — everything goes to the archive and can be restored.

```bash
bash ~/dotfiles/cleanup_home.sh          # interactive
bash ~/dotfiles/cleanup_home.sh --dry-run  # preview only, no changes
```

What it looks for:
- Dangling symlinks
- Dotfiles that are plain files instead of symlinks (leftover from before this repo was set up)
- Common old-setup leftovers (`.bash_profile.bak`, `.aliases`, `.exports`, `.extra`, etc.)

After archiving, run `bootstrap.sh` to re-link any dotfiles that were removed.

### `generate_cheatsheet.sh` — command reference

Generates a personal command reference based on your current profile.

```bash
bash ~/dotfiles/generate_cheatsheet.sh
```

Produces two files in `~/`:
- `shell-cheatsheet.md` — Markdown, renders nicely in any viewer
- `shell-cheatsheet.txt` — plain text, readable with `less ~/shell-cheatsheet.txt`

Both files contain the same content, formatted for their medium. Content is profile-specific — minimal users get the minimal command set, standard users get the full standard set, etc.

Also runs automatically at the end of `setup.sh` (optional).

---

## Customisation

**Machine-specific aliases and paths** → edit `~/.local_aliases`

**Venv shortcuts** → edit `~/.venv_aliases_local` (see `.venv_aliases_local_template` for the pattern)

**Switch profiles** → edit `DOTFILES_PROFILE` in `~/.user_config`, then run `reload`; or re-run `setup.sh` after deleting `~/.user_config`

**Refresh symlinks after a profile change** → `bash ~/dotfiles/bootstrap.sh`

**Refresh cheat sheet after a profile change** → `bash ~/dotfiles/generate_cheatsheet.sh`

**Update dotfiles** → `cd ~/dotfiles && git pull`, then open a new terminal

---

## CI

Tests run on push to `main` and on all pull requests.

**`test.yml`** — macOS and Ubuntu:

*Profile tests (all three profiles):*
- Runs `setup.sh` non-interactively
- Verifies profile-aware symlinks (minimal doesn't get full-only files, etc.)
- Syntax checks all shell files
- Sources the profile and verifies base aliases (`ll`, `la`, `gs`, `gp`, `reload`, `myip`)
- Verifies `useful` is defined for every profile
- Verifies all commands listed in `useful()` output are actually defined
- Verifies `PRINTGIT=true` for standard and full profiles
- Runs `setup.sh` a second time to confirm idempotency

*`ssh_setup.sh` tests (macOS and Ubuntu):*
- Pre-creates an SSH key pair to exercise the "key already exists" path
- Runs `ssh_setup.sh` non-interactively with a host alias
- Verifies `~/.ssh/config` was created with the correct `Host`, `HostName`, `User`, and `IdentityFile` entries
- Verifies `~/.ssh/` is mode 700 and `~/.ssh/config` is mode 600
- Runs `ssh_setup.sh` again and verifies no duplicate host block is added

**`test-windows.yml`** — Windows (Git Bash), minimal and standard profiles:
- Same core profile checks as above
- Only triggers when code files change (skips on doc-only commits via `paths-ignore`)
