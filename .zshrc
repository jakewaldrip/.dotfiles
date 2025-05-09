# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Set path for mac vs linux
if [[ "$(uname)" == "Darwin" ]]; then
  export package_path="$(brew --prefix)"
  export powerlevel_path="$(brew --prefix)/share"
else
  package_path="/usr/"
  powerlevel_path="$HOME"
fi

# Vars
export ZDIR=$HOME/zsh

# Sourcing
source $ZDIR/alias.sh
source $ZDIR/this-env.sh

# Lazy load all plugins
for f in $ZDIR/plugins/*; do
  source $f
done

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
source $powerlevel_path/powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

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
source $package_path/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $package_path/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
export PATH="/usr/local/sbin:$PATH"
