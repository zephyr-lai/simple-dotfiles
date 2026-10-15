# 常用快捷方式
alias ..='cd ..'
alias ...='cd ../..'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
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

# 自定义
alias clauded="claude --dangerously-skip-permissions"

# 代理
alias proxy='export https_proxy=http://127.0.0.1:7890 http_proxy=http://127.0.0.1:7890 all_proxy=socks5://127.0.0.1:7890'
alias unproxy='unset https_proxy http_proxy all_proxy'

# === 颜色(ls/grep) ===
# 依赖 GNU dircolors:BSD/macOS 无此命令,且 BSD ls 不认 --color=auto 会直接报错
if [ -x /usr/bin/dircolors ]; then
    # LS_COLORS:有 ~/.dircolors 用自定义的,否则用 dircolors 默认
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi
