# Vars
export ZDIR=$HOME/zsh

# Sourcing
source $ZDIR/alias.sh
source $ZDIR/this-env.sh

# Lazy load all plugins
for f in $ZDIR/zsh/plugins/*; do
  source $f
done
