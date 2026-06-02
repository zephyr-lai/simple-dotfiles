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

# color detection
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# === git status for prompt ===
parse_git_branch() {
    local branch=$(git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
    [ -z "$branch" ] && return

    local status=""
    git diff --quiet 2>/dev/null || status="${status}*"       # unstaged
    git diff --cached --quiet 2>/dev/null || status="${status}+"  # staged
    [ -n "$(git ls-files --others --exclude-standard 2>/dev/null)" ] && status="${status}?"  # untracked
    local ahead=$(git rev-list --count @{u}..HEAD 2>/dev/null)
    [ -n "$ahead" ] && [ "$ahead" -gt 0 ] && status="${status}↑"  # unpushed

    [ -n "$status" ] && status=" ${status}"
    echo "($branch$status)"
}

# === PS1 ===
if [ "$color_prompt" = yes ]; then
    PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] \[\033[01;33m\]$(parse_git_branch)\[\033[00m\]\$ '
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
