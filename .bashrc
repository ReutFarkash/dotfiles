
# Src: https://github.com/mathiasbynens/dotfiles/blob/master/.bashrc
# Idea: https://www.youtube.com/watch?v=c5RZWDLqifA
case "$-" in *i*) ;; *) return ;; esac

if [ "$DEBUG" == true ]; then
    scriptpath="${CUR_DIR}/${BASH_ARGV[0]}"
    echo "running $scriptpath"
fi

# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH` (includes Homebrew init).
# * ~/.extra can be used for other settings you don't want to commit.
for file in ~/.{path,bash_env_vars,bash_aliases,bash_prompt,profile,bash_logout,exports,aliases,functions,extra}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

[[ -f ~/manager.sh ]] && source ~/manager.sh

# History: append to whatever .bash_prompt already set (e.g. prompt_command)
PROMPT_COMMAND="${PROMPT_COMMAND:+${PROMPT_COMMAND}; }history -a; history -n; history -w"
shopt -s histappend;

# ActivityWatch terminal watcher (opt-out: set AW_DISABLE_TERMINAL_WATCHER=1)
[[ -f ~/.aw-terminal-hooks.bash ]] && source ~/.aw-terminal-hooks.bash

# Tool PATH entries — machine-specific paths go in ~/.local_aliases instead
[[ -d "$HOME/.opencode/bin" ]] && export PATH="$HOME/.opencode/bin:$PATH"
[[ -d "/Applications/Obsidian.app/Contents/MacOS" ]] && export PATH="$PATH:/Applications/Obsidian.app/Contents/MacOS"

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob;

# Autocorrect typos in path names when using `cd`
shopt -s cdspell;

# Enable some Bash 4 features when possible:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
for option in autocd globstar; do
	shopt -s "$option" 2> /dev/null;
done;

# Add tab completion for many Bash commands
if which brew &> /dev/null && [ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]; then
	# Ensure existing Homebrew v1 completions continue to work
	export BASH_COMPLETION_COMPAT_DIR="$(brew --prefix)/etc/bash_completion.d";
	source "$(brew --prefix)/etc/profile.d/bash_completion.sh";
elif [ -f /etc/bash_completion ]; then
	source /etc/bash_completion;
fi;

# Enable tab completion for `g` by marking it as an alias for `git`
if type _git &> /dev/null; then
	complete -o default -o nospace -F _git g;
fi;

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh;

# Add tab completion for `defaults read|write NSGlobalDomain`
complete -W "NSGlobalDomain" defaults;

# Add `killall` tab completion for common apps
complete -o "nospace" -W "Contacts Calendar Dock Finder Mail Safari iTunes SystemUIServer Terminal Twitter" killall;
