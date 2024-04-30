# Vars
export ZDIR=$HOME/zsh

# Sourcing
source $ZDIR/alias.sh
source $ZDIR/this-env.sh

# Lazy load all plugins
for f in $ZDIR/plugins/*; do
  source $f
done
