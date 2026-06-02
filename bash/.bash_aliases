# common shortcuts
alias ..='cd ..'
alias ...='cd ../..'
alias mkdir='mkdir -p'
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias path='echo $PATH | tr ":" "\n"'
alias ip='ip -c'
alias rp='realpath'
alias c='clear'
alias reload='source ~/.bashrc'
alias untar='tar -xzvf'
alias h='history'
alias ports='ss -tlnp'

# custom aliases
alias clauded="claude --dangerously-skip-permissions"

# proxy
alias proxy='export https_proxy=http://127.0.0.1:7890 http_proxy=http://127.0.0.1:7890 all_proxy=socks5://127.0.0.1:7890'
alias unproxy='unset https_proxy http_proxy all_proxy'
