# Set path for mac vs linux
if [[ "$(uname)" == "Darwin" ]]; then
  export package_path="$(brew --prefix)"
  export opencode_path="$HOME/.opencode/bin"
else
  package_path="/usr/share"
  opencode_path="/home/jacob/.opencode/bin"
fi

# Vars
export ZDIR=$HOME/zsh

# Sourcing
source $ZDIR/alias.sh
[ -f $ZDIR/this-env.sh ] && source $ZDIR/this-env.sh
export PATH="$ZDIR/scripts:$PATH"

# Lazy load all plugins
for f in $ZDIR/plugins/*; do
  source $f
done

# Prompt. To customize, edit ~/.config/starship.toml.
command -v starship >/dev/null && eval "$(starship init zsh)"

# Better history setup
HISTFILE=$HOME/.zhistory
SAVEHIST=1000
HISTSIZE=999
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify

# completion using arrow keys (based on history)
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
export PATH="/usr/local/sbin:$PATH"

# opencode
export PATH=$opencode_path:$PATH
export OPENCODE_DISABLE_EXTERNAL_SKILLS=1

if [[ "$(uname)" == "Darwin" ]]; then
  zsh_plugin_dir="$package_path/share"
else
  zsh_plugin_dir="$package_path/zsh/plugins"
fi

for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
  [ -f "$zsh_plugin_dir/$plugin/$plugin.zsh" ] && source "$zsh_plugin_dir/$plugin/$plugin.zsh"
done
unset zsh_plugin_dir plugin

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

# Deduplicate PATH entries (keep first occurrence, preserve order)
typeset -U path PATH
