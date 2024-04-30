# eza - custom ls
alias lso="$(which ls)"
alias ls="eza --color=always --icons=always --group-directories-first --across -w 170"
alias ll="ls --long --smart-group --git --time-style=relative --header -X"
alias la="ll --all"
alias lp="ll --tree --all --ignore-glob=.git --git-ignore --total-size"
