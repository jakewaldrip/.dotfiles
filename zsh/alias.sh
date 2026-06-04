#!/bin/bash

# Shorthand

# We're on mac
if [ "$(uname)"=="Darwin" ];
then
  alias copy="tr -d '\n' | pbcopy"
fi

# Custom Function Aliases
deploylog() {
  str=$(git log --graph --pretty=format:'%h %s <%an>' --abbrev-commit $1)
  echo "$str"
  printf '%s' "$str" | pbcopy
}

githash() {
  str=$(git rev-parse HEAD)
  echo "$str"
  printf '%s' "$str" | pbcopy
}

branch_name() {
  str=$(git rev-parse --abbrev-ref HEAD)
  echo "$str"
  printf '%s' "$str" | pbcopy
}

uuid() {
  id=$(uuidgen | tr '[:upper:]' '[:lower:]')
  echo "$id"
  printf '%s' "$id" | pbcopy
}
