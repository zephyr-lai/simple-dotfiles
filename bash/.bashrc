# ~/.bashrc

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# === history ===
HISTCONTROL=ignoreboth              # ignore duplicate lines
shopt -s histappend                 # append to history
HISTSIZE=1000
HISTFILESIZE=2000

# === terminal ===
shopt -s checkwinsize               # update LINES/COLUMNS on resize

# readline 补全行为
bind 'set show-all-if-ambiguous on'     # Tab 一次直接列出所有候选(不响铃)
bind 'set completion-ignore-case off'   # 区分大小写
bind 'set visible-stats on'              # 路径后追加类型指示符 (/ @ * = % |)
bind 'set blink-matching-paren on'       # 输入 )/] 时光标闪到匹配处
bind 'set colored-completion-prefix on'  # 补全列表中共同前缀加粗高亮 (bash 4.3+)

# color detection
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# === git status for prompt ===
# 每种状态用不同 ANSI 颜色，分支名干净/有改动时也会变色
parse_git_branch() {
    local branch=$(git symbolic-ref --short HEAD 2>/dev/null \
                || git rev-parse --short HEAD 2>/dev/null)
    [ -z "$branch" ] && return

    # Bash 非打印字符标记（等价于 \[ \]，在 $(...) 子 shell 中也安全）
    local NP=$'\001' CP=$'\002' ESC=$'\033'
    local RST="${NP}${ESC}[00m${CP}"   # reset
    local YEL="${NP}${ESC}[01;33m${CP}" # 括号 + 分支名
    local RED="${NP}${ESC}[01;31m${CP}" # 所有状态标记

    local markers=""

    git diff --quiet 2>/dev/null \
        || markers+="${RED}*${RST}"                                    # 未暂存
    git diff --cached --quiet 2>/dev/null \
        || markers+="${RED}+${RST}"                                    # 已暂存
    [ -n "$(git ls-files --others --exclude-standard 2>/dev/null)" ] \
        && markers+="${RED}?${RST}"                                   # 未跟踪

    local ahead=$(git rev-list --count @{u}..HEAD 2>/dev/null)
    [ -n "$ahead" ] && [ "$ahead" -gt 0 ] \
        && markers+="${RED}↑${ahead}${RST}"                            # 未推送

    local behind=$(git rev-list --count HEAD..@{u} 2>/dev/null)
    [ -n "$behind" ] && [ "$behind" -gt 0 ] \
        && markers+="${RED}↓${behind}${RST}"                           # 落后

    [ -n "$markers" ] && markers=" ${markers}"
    echo "${YEL}(${branch}${RST}${markers}${YEL})${RST}"
}

# === PS1 ===
if [ "$color_prompt" = yes ]; then
    PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] $(parse_git_branch)\$ '
else
    PS1='\u@\h:\w$(parse_git_branch)\$ '
fi
unset color_prompt

# === dircolors ===
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# === ls aliases ===
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# === bash_aliases ===
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# === bash completion ===
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# === PATH ===
export PATH="$HOME/.local/bin:$PATH"
