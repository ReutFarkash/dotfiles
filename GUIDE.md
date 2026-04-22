# Bash / Git / Python — Practical Guide

A concise reference for people with technical background who are new to the terminal or bash.  
Each section has a **Quick reference** block you can copy and an **Explanation** you can skim.

---

## Quick reference — most common commands

| What you want | Command |
|---|---|
| Where am I? | `pwd` |
| Who am I logged in as? | `whoami` |
| List files | `ls -lh` |
| Go home | `cd ~` |
| Go up one folder | `cd ..` |
| Open manual for a command | `man ls` |
| Edit a file | `nano filename.txt` |
| Exit nano | `Ctrl+X`, then `Y`, then Enter |
| Git status | `git status` |
| Stage all changes | `git add .` |
| Commit | `git commit -m "message"` |
| Push | `git push` |
| Create a venv | `python3 -m venv .venv` |
| Activate a venv | `source .venv/bin/activate` |
| Install a package | `pip install requests` |
| Deactivate venv | `deactivate` |
| See your SSH public key | `cat ~/.ssh/id_ed25519.pub` |
| Search text in files | `grep -r "word" .` |
| Read a long file | `less filename.txt` |

---

## 1. Terminal basics

### Who am I / where am I

```bash
whoami          # prints your username
pwd             # Print Working Directory — shows your current location
hostname        # name of this machine
```

**What to know:** Every terminal session has a *current directory* — the folder all your commands operate in. `pwd` tells you where you are. `whoami` tells you which user account you're running as (matters for permissions).

---

### The home directory and `~`

```bash
cd ~            # go to your home directory
cd              # same — cd with no argument always goes home
echo ~          # prints the full path, e.g. /Users/yourname
ls ~            # list your home directory from anywhere
```

**What to know:** `~` is a shorthand for your home directory (`/Users/yourname` on macOS, `/home/yourname` on Linux). The shell expands it before running the command — so `~/dotfiles` is the same as `/Users/yourname/dotfiles`. Config files like `.bashrc`, `.ssh/`, and `~/dotfiles` all live here.

---

### Navigating and listing files

```bash
ls              # list files in current directory
ls -l           # long format: permissions, size, date
ls -lh          # same with human-readable sizes (KB, MB)
ls -la          # include hidden files (files starting with .)
ls ~/Documents  # list a specific directory

cd Documents    # move into a folder
cd ..           # go up one level
cd ../..        # go up two levels
cd -            # go back to the previous directory
```

**What to know:** Files starting with `.` are hidden — `ls` won't show them unless you pass `-a`. Most config files (`.bashrc`, `.ssh/`) are hidden.

> **Go deeper:** [Unix terminals and shells](https://www.youtube.com/playlist?list=PLFAC320731F539902) — Brian Will's playlist covers how the terminal, shell, and Unix process model actually work.

---

### Reading files — `less` and `cat`

```bash
cat file.txt            # print the whole file at once
less file.txt           # open a scrollable viewer
```

Inside `less`:
- `j` / `k` or arrow keys — scroll down / up
- `Space` — page down
- `G` — jump to end, `g` — jump to start
- `/word` — search, `n` — next match
- `q` — quit

**What to know:** Use `cat` for short files, `less` for anything longer than a screen. Many commands pipe their output to `less` automatically (e.g. `man`).

---

### Manual pages — `man`

```bash
man ls          # manual for ls
man git         # manual for git
man bash        # full bash reference (long — use / to search)
```

Inside `man`, the controls are the same as `less`. Press `q` to exit.

**What to know:** Every standard Unix command has a man page. The synopsis at the top shows the syntax; scroll down to `DESCRIPTION` for details. If a man page doesn't exist, try `command --help`.

---

## 2. Shell concepts — `$`, variables, and quotes

### Variables and `$`

```bash
NAME="Alice"
echo $NAME              # prints: Alice
echo "Hello, $NAME"     # prints: Hello, Alice
echo '$NAME'            # prints: $NAME  (single quotes — no expansion)

echo $HOME              # your home directory path
echo $USER              # your username
echo $PATH              # colon-separated list of directories the shell searches for programs
echo $SHELL             # which shell you're running

MY_VAR="hello"
echo ${MY_VAR}_world    # prints: hello_world  (braces isolate the variable name)
```

**What to know:** `$` tells the shell "substitute the value of this variable here." This is called *variable expansion*. Without `$`, a word is treated as a literal string — `echo NAME` prints `NAME`, not `Alice`. Environment variables like `$HOME`, `$USER`, and `$PATH` are set automatically by the shell on startup.

---

### Single quotes, double quotes, and backticks

```bash
echo "Today is $(date)"         # double quotes: variables and $() expand
echo 'Today is $(date)'         # single quotes: everything literal, no expansion
echo "Path is $PATH"            # expands $PATH
echo 'Path is $PATH'            # prints literally: Path is $PATH

result=$(ls -l)                 # $() captures command output into a variable
echo "Files: $(ls | wc -l)"    # nest it in a string

# Backticks do the same as $() — older style, avoid nesting them
result=`ls -l`
```

**What to know:**
- **Double quotes** `"..."` — allow variable and command expansion. Use these when your string contains variables.
- **Single quotes** `'...'` — literal. Nothing inside is interpreted. Use these when you want the shell to see exactly what you typed.
- **`$()`** — command substitution. Runs the command inside and replaces itself with the output. Preferred over backticks because it nests cleanly.

---

### PATH — where the shell looks for programs

When you type a command like `git` or `python3`, the shell doesn't search your whole computer. It only checks the directories listed in the `PATH` variable, in order, and runs the first match it finds.

```bash
echo $PATH
# /opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
#  ^^^^^^^^^^^^^^^^  ^^^^^^^^^^^^^^  ^^^^^^^^  ^^^^
#  Homebrew first    common tools    system tools
```

Each directory is separated by a colon. The shell checks them left to right — whichever directory appears first wins.

```bash
which git           # shows the full path of the git being used
which python3       # useful when you have multiple versions installed
type git            # similar, but also reveals aliases and shell functions
```

**Adding a directory to PATH:**

```bash
# In ~/.bash_profile or ~/.bashrc:
export PATH="$HOME/.local/bin:$PATH"
#            ^^^^^^^^^^^^^^^^  ^^^^
#            new directory     keep everything that was there before
```

The `export` makes the variable available to any child processes (programs you launch from the shell). Without it, the variable exists in the current shell session only.

**What to know:** if you install a tool and the shell says "command not found", the tool's directory is probably not in your PATH. Find where it was installed (`which` won't help here — try the installer's output), then add it to PATH in your `~/.bash_profile`.

---

### Inspecting the environment — `printenv` and `env`

Environment variables are the key-value pairs your shell passes to every program it starts. Things like `HOME`, `USER`, `PATH`, `SHELL`, and any variables you `export`.

```bash
printenv                    # list all environment variables
printenv PATH               # print one specific variable
printenv HOME USER SHELL    # print several at once

env                         # same as printenv (slightly different output format)
```

```bash
# Check if a variable is set (and what it contains):
echo $DOTFILES_PROFILE      # empty if not set
printenv DOTFILES_PROFILE   # exits non-zero if not set — useful in scripts
```

**Common variables worth knowing:**

| Variable | What it holds |
|---|---|
| `HOME` | Your home directory (`/Users/yourname`) |
| `USER` | Your username |
| `PATH` | Colon-separated list of directories to search for programs |
| `SHELL` | The path to your current shell (`/bin/bash`, `/bin/zsh`, etc.) |
| `EDITOR` | The default text editor (used by git, cron, etc.) |
| `LANG` | Language and locale settings |
| `PS1` | Your shell prompt string |

**Temporary vs permanent:**

```bash
# Temporary — lasts only for this shell session:
export MY_VAR="hello"

# Permanent — add to ~/.bash_profile or ~/.bashrc:
export MY_VAR="hello"   # same line, different file

# One-off — set a variable for a single command only:
MY_VAR="hello" some_command
```

---

### Pipes and redirection

Every command has three standard streams: **stdin** (input), **stdout** (output), and **stderr** (errors). By default all three connect to your terminal. Pipes and redirection let you rewire them.

#### Pipes — `|`

A pipe sends the stdout of one command into the stdin of the next.

```bash
ls -l | less                        # page through a long listing
cat file.txt | grep "error"         # filter lines containing "error"
ps aux | grep python | head -5      # chain as many as you like
```

Think of `|` as "and feed the output into".

#### Redirecting stdout — `>` and `>>`

```bash
echo "hello" > output.txt           # write stdout to a file (overwrites)
echo "world" >> output.txt          # append stdout to a file
ls -l > listing.txt                 # save any command's output to a file
```

`>` creates or overwrites. `>>` creates or appends. Never use `>` when you mean `>>` — it silently erases the file first.

#### Redirecting stderr — `2>`

stderr uses file descriptor 2. Errors go there so they don't pollute stdout.

```bash
python3 script.py 2> errors.log     # save errors, print normal output
python3 script.py 2> /dev/null      # suppress errors entirely
```

`/dev/null` is a black hole — anything written there is discarded.

#### Redirecting both stdout and stderr

```bash
python3 script.py > output.log 2>&1     # both streams → same file
python3 script.py &> output.log         # shorthand for the same thing
python3 script.py > out.log 2> err.log  # split them into separate files
```

`2>&1` means "send stderr (2) to wherever stdout (1) is currently going."

#### Reading stdin from a file — `<`

```bash
sort < names.txt                    # feed file contents to stdin
sqlite3 mydb.db < schema.sql        # run SQL from a file
```

Less common than `>` but useful for commands that expect interactive input.

#### `tee` — write to a file and still see the output

```bash
make 2>&1 | tee build.log           # see output in terminal AND save it
```

`tee` splits the stream: one copy goes to the file, one to stdout. Combine with `2>&1` to capture errors too.

#### Putting it together

```bash
# Find all Python files, count them, save the count, and show it:
find . -name "*.py" | wc -l | tee py_count.txt

# Run tests, save all output (stdout + stderr), and page through it:
pytest 2>&1 | tee test.log | less
```

---

## 3. Editing files — nano

```bash
nano filename.txt       # open or create a file
```

Inside nano:

| Action | Key |
|---|---|
| Save | `Ctrl+O`, then Enter |
| Exit | `Ctrl+X` |
| Save and exit | `Ctrl+X`, then `Y`, then Enter |
| Exit without saving | `Ctrl+X`, then `N` |
| Cut a line | `Ctrl+K` |
| Paste | `Ctrl+U` |
| Search | `Ctrl+W` |

**What to know:** The `^` symbols at the bottom of nano mean `Ctrl`. New users most often get stuck because they don't know how to exit — `Ctrl+X` always gets you out. If you've made changes, it asks `Save modified buffer?` — press `Y` or `N`.

---

## 4. Users and permissions

### Who can do what

```bash
whoami                  # your username
id                      # your user ID, group ID, and all group memberships
groups                  # groups you belong to
ls -l file.txt          # see a file's permissions and owner
```

A typical `ls -l` line looks like:
```
-rw-r--r--  1  alice  staff  1234  Apr 20  notes.txt
```

Breaking down `-rw-r--r--`:
- Position 1: `-` = file, `d` = directory, `l` = symlink
- Positions 2–4: owner permissions (`rw-` = read + write, no execute)
- Positions 5–7: group permissions (`r--` = read only)
- Positions 8–10: everyone else (`r--` = read only)

### Changing permissions — `chmod`

```bash
chmod 600 ~/.ssh/config         # owner read+write only (rw-------)
chmod 700 ~/.ssh                # owner read+write+execute, no one else
chmod 644 notes.txt             # owner rw, group+others read-only
chmod +x script.sh              # add execute permission for everyone
chmod -x script.sh              # remove execute permission
```

**Octal quick reference:**
| Number | Permissions |
|---|---|
| `7` | read + write + execute |
| `6` | read + write |
| `5` | read + execute |
| `4` | read only |
| `0` | none |

Three digits: owner / group / everyone else.

**What to know:** Permissions control who can read, write, or execute a file. SSH *enforces* correct permissions — it refuses to use `~/.ssh/config` or private keys if they're world-readable. `chmod 600 file` is the standard fix.

### Running as another user — `sudo` and `su`

```bash
sudo command                    # run one command as root (you stay as yourself)
sudo nano /etc/hosts            # edit a system file that needs root access
sudo !!                         # re-run the last command as root
sudo -i                         # open a root shell (use sparingly, exit when done)

su username                     # switch to another user account (needs their password)
su -                            # switch to root (needs root password — disabled on macOS)
exit                            # return to your previous user
```

**What to know:** `sudo` ("superuser do") lets you run a single command with root privileges — it asks for *your* password and logs what you did. It's safer than `su` because it's targeted and audited. On macOS, `su -` to root is disabled by default; use `sudo` instead. Don't run things as root unless you need to — a mistake as root has no safety net.

> **Go deeper:** [Unix system calls](https://www.youtube.com/playlist?list=PL993D01B05C47C28D) — Brian Will's playlist explains how Unix handles files, processes, and permissions at the system level.

### macOS specifics

```bash
xattr -l file.txt               # list extended attributes (macOS metadata)
xattr -d com.apple.quarantine file.txt  # remove "downloaded from internet" flag
ls -l@ file.txt                 # show extended attributes in ls output
```

**What to know:** macOS adds *extended attributes* (metadata) to files, including a quarantine flag on anything downloaded from the internet. This causes Gatekeeper to show "cannot be opened because it is from an unidentified developer" warnings. `xattr -d com.apple.quarantine` removes it. *System Integrity Protection (SIP)* prevents even root from modifying certain system paths (`/System`, `/usr`) — this is by design and shouldn't be disabled.

---

## 5. Git

### Starting out

```bash
git init                        # create a new repo in the current folder
git clone https://github.com/user/repo.git   # download an existing repo
git clone git@github.com:user/repo.git       # same, over SSH (faster, no password prompts)
```

### Everyday workflow

```bash
git status                      # what's changed?
git add file.txt                # stage one file
git add .                       # stage everything
git diff                        # see unstaged changes
git diff --staged               # see staged changes

git commit -m "Add login page"  # commit with a message
git push                        # push to the remote (GitHub)
git pull                        # fetch + merge latest from remote
```

### Viewing history

```bash
git log                         # full history
git log --oneline               # one line per commit
git log --oneline --graph --decorate --all   # visual branch graph (aliased as 'graph')
graph                           # shortcut from this dotfiles setup
```

### Branches

```bash
git branch                      # list branches (* = current)
git branch feature-x            # create a branch
git checkout feature-x          # switch to it
git checkout -b feature-x       # create and switch in one step
git merge feature-x             # merge into current branch
```

**What to know:** Git tracks *snapshots* of your project, not file diffs. `add` stages what you want in the next snapshot; `commit` takes it; `push` uploads it to GitHub. Commits are permanent and can always be recovered — don't be afraid to commit often.

> **Go deeper:**
> - [Introduction to Git - Core Concepts](https://www.youtube.com/watch?v=uR6G2v_WsRA) — David Mahler
> - [Introduction to Git - Branching and Merging](https://www.youtube.com/watch?v=FyAAIHHClqI) — David Mahler
> - [Introduction to Git - Remotes](https://www.youtube.com/watch?v=Gg4bLk8cGNo) — David Mahler
> - [A Visual Git Reference](https://marklodato.github.io/visual-git-guide/index-en.html) — diagrams showing exactly what each Git command does to your working directory, staging area, and history

---

## 6. Python — venv and pip

### `python` vs `python3`, `pip` vs `pip3`

```bash
python3 --version       # check which Python 3 you have
python3 script.py       # run a script with Python 3

pip3 install requests   # install a package using Python 3's pip
pip3 --version          # confirm it's tied to Python 3
```

**What to know:** On most systems, `python` means Python 2 (old, no longer maintained) and `python3` means Python 3. Always use `python3` and `pip3` to be explicit. The exception: once you've activated a venv, both `python` and `pip` inside it refer to the venv's Python 3 — you don't need the `3` suffix. If `python3` isn't found, install it from [python.org](https://www.python.org/downloads/) or via `brew install python` on macOS.

### Why venv

Every Python project should have its own *virtual environment* — an isolated folder that holds that project's packages. Without it, all your projects share one global Python installation, and upgrading a package for project A can break project B.

### Creating and using a venv

```bash
python3 -m venv .venv           # create a venv in a folder called .venv
source .venv/bin/activate       # activate it (your prompt changes to show (.venv))
deactivate                      # deactivate — back to system Python

# Always activate before working on a project:
source .venv/bin/activate
```

**What to know:** The venv only exists for the current terminal session. You need to `source .venv/bin/activate` every time you open a new terminal. Most editors (VS Code, PyCharm) detect and activate the venv automatically.

### pip — installing packages

```bash
pip install requests            # install a package
pip install requests==2.31.0    # install a specific version
pip uninstall requests          # remove a package
pip list                        # show installed packages
pip freeze                      # show installed packages in requirements format
pip freeze > requirements.txt   # save them to a file

pip install -r requirements.txt # install everything from a requirements file
```

**What to know:** Always have your venv activated before running `pip install` — otherwise you'll install into the global Python. `pip freeze > requirements.txt` is the standard way to record what your project needs so others can reproduce it with `pip install -r requirements.txt`.

---

## 7. SSH keys

### What SSH keys are

SSH keys are a pair of files: a **private key** (stays on your machine, never share it) and a **public key** (you give this to servers and GitHub). When you connect to a server or push to GitHub over SSH, your machine proves its identity by showing it holds the private key — without ever sending it.

```
~/.ssh/id_ed25519       ← private key (mode 600, never share)
~/.ssh/id_ed25519.pub   ← public key (safe to share freely)
```

### Generating a key

```bash
bash ~/dotfiles/ssh_setup.sh    # guided setup (recommended)

# Or manually:
ssh-keygen -t ed25519 -C "you@yourmachine"
```

### Adding your key to GitHub

```bash
cat ~/.ssh/id_ed25519.pub       # print your public key
```

Copy the output. On GitHub: **Settings → SSH and GPG keys → New SSH key** → paste it in.

Test it:
```bash
ssh -T git@github.com           # should say "Hi username! You've successfully authenticated"
```

### Connecting to a server

```bash
ssh user@192.168.1.100          # connect by IP
ssh user@myserver.com           # connect by hostname
ssh myserver                    # connect using an alias from ~/.ssh/config
```

### `~/.ssh/config` — host aliases

Instead of typing `ssh user@192.168.1.100` every time, add a block to `~/.ssh/config`:

```
Host myserver
    HostName 192.168.1.100
    User alice
    IdentityFile ~/.ssh/id_ed25519
```

Then just: `ssh myserver`. `bash ~/dotfiles/ssh_setup.sh` can build this for you interactively.

### Copying your key to a server

```bash
ssh-copy-id user@192.168.1.100  # adds your public key to the server's authorized_keys
```

After this, you can SSH in without a password.

**What to know:** Never share your private key file (`id_ed25519`, no `.pub`). If you think it's been exposed, generate a new one and remove the old public key from GitHub and any servers.

---

## 8. Bash aliases

### What aliases are

An alias is a shortcut — you type a short name and the shell runs a longer command.

```bash
alias gs="git status"           # now typing 'gs' runs 'git status'
alias ll="ls -lh"
alias ..="cd .."
```

They last for the current terminal session. To make them permanent, put them in a file that loads on startup.

### Aliases installed by this dotfiles setup

These are available in your shell after running `setup.sh`:

**Navigation and listing:**

| Alias | Expands to | What it does |
|---|---|---|
| `l` | `ls -lhF` | list with details and sizes |
| `la` | `ls -lahF` | list including hidden files |
| `ll` | `ls -lhF` | same as `l` |
| `lr` | `ls -lahtr` | list by date, newest at bottom |
| `..` | `cd ..` | go up one folder |
| `...` | `cd ../..` | go up two folders |
| `~` | `cd ~` | go home |

**Safety nets** — these ask before doing anything destructive:

| Alias | Behaviour |
|---|---|
| `rm` | asks `remove file? y/n` before deleting |
| `cp` | asks before overwriting |
| `mv` | asks before overwriting |

**Git shortcuts:**

| Alias | Expands to |
|---|---|
| `gs` | `git status` |
| `gp` | `git pull` |
| `glog` | short visual commit history |
| `ga` | `git add` |
| `gc` | `git commit -m` |
| `gd` | `git diff` |
| `graph` | `git log --oneline --graph --decorate --all` |

**Shell:**

| Alias | What it does |
|---|---|
| `reload` | re-source your shell config without opening a new terminal |
| `myip` | print your public IP address |
| `path` | print your PATH one entry per line |

### Where to put your own aliases

This repo uses profile files for shared aliases. **Do not edit the profile files directly** — they're shared across machines. Instead, put machine-specific aliases in:

```
~/.local_aliases        ← your personal machine-specific aliases (created by setup.sh)
```

Open it:
```bash
nano ~/.local_aliases
```

Add a line like:
```bash
alias myproject="cd ~/Code/myproject && source .venv/bin/activate"
```

Save and reload:
```bash
reload                  # alias from this dotfiles setup — re-sources your config
```

**What to know:** `~/.local_aliases` is never committed to git — it's a template copy personal to your machine. Anything you put there is private and won't affect anyone else using this repo.

---

## 9. Regular expressions

A regular expression (regex) is a pattern for matching text. Used in `grep`, `sed`, and many programming languages.

### grep — searching files

```bash
grep "word" file.txt            # find lines containing "word"
grep -i "word" file.txt         # case-insensitive
grep -r "word" .                # search recursively in current directory
grep -n "word" file.txt         # show line numbers
grep -v "word" file.txt         # lines that do NOT match
grep -l "word" *.txt            # just print filenames that match
```

### Common regex patterns

| Pattern | Matches |
|---|---|
| `.` | Any single character |
| `*` | Zero or more of the previous |
| `+` | One or more of the previous |
| `?` | Zero or one of the previous |
| `^` | Start of line |
| `$` | End of line |
| `[abc]` | Any one of: a, b, or c |
| `[^abc]` | Any character except a, b, c |
| `[a-z]` | Any lowercase letter |
| `[0-9]` | Any digit |
| `\d` | Any digit (in most tools) |
| `\s` | Any whitespace |
| `\b` | Word boundary |

```bash
grep "^Error" logfile.txt       # lines starting with "Error"
grep "\.py$" filelist.txt       # lines ending with .py
grep -E "cat|dog" file.txt      # lines containing "cat" or "dog" (extended regex)
grep -E "^[0-9]{3}-" file.txt   # lines starting with 3 digits then a dash
```

**What to know:** In `grep`, use `-E` for *extended* regex (enables `+`, `?`, `|`, `{}`). The `.` in regex means "any character" — to match a literal dot, escape it with `\.`. Regex syntax varies slightly between tools (grep, Python, JavaScript) but the core patterns above are universal.

---

## Appendix — keyboard shortcuts

| Shortcut | Action |
|---|---|
| `Ctrl+C` | Cancel the current command |
| `Ctrl+D` | Exit the shell (or send end-of-input) |
| `Ctrl+L` | Clear the screen |
| `Ctrl+R` | Search command history |
| `Tab` | Autocomplete file/command name |
| `Tab Tab` | Show all completions |
| `↑` / `↓` | Previous / next command in history |
| `Ctrl+A` | Jump to start of line |
| `Ctrl+E` | Jump to end of line |
| `Ctrl+W` | Delete word before cursor |
| `Ctrl+U` | Delete from cursor to start of line |
