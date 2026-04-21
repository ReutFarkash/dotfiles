# Interactive only
case "$-" in
  *i*) ;;
  *) return ;;
esac

# Opt-out flag (set this before starting bash when you don't want tracking)
[[ -n "${AW_DISABLE_TERMINAL_WATCHER-}" ]] && return

# Enable hooks
source ~/.bash-preexec.sh 2>/dev/null || return
source ~/Code/aw-watcher-bash/aw-watcher-bash.sh 2>/dev/null || return
