#!/bin/bash

# Shorthand

# We're on mac
if [ "$(uname)"=="Darwin" ];
then
  alias copy="tr -d '\n' | pbcopy"
fi

# Custom Function Aliases
deploylog() {
	git log --graph --pretty=format:'%h %s <%an>' --abbrev-commit $1 | pbcopy
}

githash() {
	git rev-parse HEAD | pbcopy
}

branch_name() {
	git rev-parse --abbrev-ref HEAD | pbcopy
}
