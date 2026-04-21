
# Src: https://github.com/mathiasbynens/dotfiles/blob/master/.bashrc
# Idea: https://www.youtube.com/watch?v=c5RZWDLqifA
case "$-" in *i*) ;; *) return ;; esac

if [ "$DEBUG" == true ]; then
    scriptpath="${CUR_DIR}/${BASH_ARGV[0]}"
    echo "running $scriptpath"
fi

# History: append across sessions, sync on every prompt
PROMPT_COMMAND='history -a; history -n; history -w'

# ActivityWatch terminal watcher (opt-out: set AW_DISABLE_TERMINAL_WATCHER=1)
[[ -f ~/.aw-terminal-hooks.bash ]] && source ~/.aw-terminal-hooks.bash

# Tool PATH entries — machine-specific paths go in ~/.local_aliases instead
[[ -d "$HOME/.opencode/bin" ]] && export PATH="$HOME/.opencode/bin:$PATH"
[[ -d "/Applications/Obsidian.app/Contents/MacOS" ]] && export PATH="$PATH:/Applications/Obsidian.app/Contents/MacOS"
