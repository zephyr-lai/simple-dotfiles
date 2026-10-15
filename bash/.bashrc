# ~/.bashrc

# 非交互式 shell 直接返回
case $- in
    *i*) ;;
      *) return;;
esac

# === ble.sh 幽灵字自动补全(需安装,未装自动跳过;安装见 install.sh 的 require_blesh) ===
# 输入时灰色历史建议,→ 采纳整句、Alt+f 逐词;ble.sh 需在 .bashrc 顶部 source、末尾 attach
# ble.sh 仅支持 bash>=4(macOS 自带 3.2 会静默失败,先 brew install bash)
if [ "${BASH_VERSION%%.*}" -ge 4 ] 2>/dev/null; then
for _blesh in "$HOME/.local/share/blesh/ble.sh" /usr/local/share/blesh/ble.sh /usr/share/blesh/ble.sh; do
  if [ -f "$_blesh" ]; then
    source "$_blesh" --noattach
    break
  fi
done
unset _blesh
fi

# === 历史记录 ===
HISTSIZE=1000
HISTFILESIZE=2000
HISTCONTROL=ignoreboth              # 忽略重复行 + 空格开头的行
shopt -s histappend

# === 终端 ===
shopt -s checkwinsize

# === 提示符 ===
PROMPT_STYLE=green                 # 可选: green | pygmalion

__prompt_git_green() {
    local branch=$(git symbolic-ref --short HEAD 2>/dev/null \
                || git rev-parse --short HEAD 2>/dev/null)
    [ -z "$branch" ] && return

    # Bash 非打印字符标记（等价于 \[ \]，在 $(...) 子 shell 中也安全）
    local NP=$'\001' CP=$'\002' ESC=$'\033'
    local RST="${NP}${ESC}[00m${CP}" YEL="${NP}${ESC}[01;33m${CP}" RED="${NP}${ESC}[01;31m${CP}"

    local markers=""

    git diff --quiet 2>/dev/null || markers+="${RED}*${RST}"
    git diff --cached --quiet 2>/dev/null || markers+="${RED}+${RST}"
    [ -n "$(git ls-files --others --exclude-standard 2>/dev/null)" ] \
        && markers+="${RED}?${RST}"

    local ahead=$(git rev-list --count @{u}..HEAD 2>/dev/null)
    [ -n "$ahead" ] && [ "$ahead" -gt 0 ] && markers+="${RED}↑${ahead}${RST}"

    local behind=$(git rev-list --count HEAD..@{u} 2>/dev/null)
    [ -n "$behind" ] && [ "$behind" -gt 0 ] && markers+="${RED}↓${behind}${RST}"

    [ -n "$markers" ] && markers=" ${markers}"
    echo "${YEL}(${branch}${RST}${markers}${YEL})${RST}"
}

__prompt_git_pygmalion() {
    local branch
    branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
    [ -z "$branch" ] && return
    local NP=$'\001' CP=$'\002' ESC=$'\033'
    local GRN="${NP}${ESC}[0;32m${CP}" YEL="${NP}${ESC}[0;33m${CP}" RST="${NP}${ESC}[00m${CP}"
    local out="${GRN}${branch}"
    # 脏口径与 zsh parse_git_dirty 一致:staged / unstaged / 未跟踪任一即脏
    git diff --quiet 2>/dev/null && git diff --cached --quiet 2>/dev/null \
        && [ -z "$(git ls-files --other --exclude-standard 2>/dev/null)" ] || out+="${YEL}⚡"
    printf '%s' "${out}${RST} "
}

# --- 按 PROMPT_STYLE 选 PS1(未知值一律回落 green) ---
case "$PROMPT_STYLE" in
    pygmalion)
        PS1='\[\e[0;35m\]\u\[\e[00m\]\[\e[0;36m\]@\[\e[00m\]\[\e[0;33m\]\h\[\e[00m\]\[\e[0;31m\]:\[\e[00m\]\[\e[0;36m\]\w\[\e[00m\]\[\e[0;31m\]|\[\e[00m\]$(__prompt_git_pygmalion)\[\e[0;36m\]⇒\[\e[00m\]  '
        ;;
    *)
        case "$TERM" in
            xterm-color|*-256color) color_prompt=yes;;
        esac
        if [ "$color_prompt" = yes ]; then
            PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] $(__prompt_git_green)\$ '
        else
            PS1='\u@\h:\w$(__prompt_git_green)\$ '
        fi
        unset color_prompt
        ;;
esac

# === PATH ===
BIN_PATH="$HOME/.npm-global/bin:$HOME/.local/bin"   # 排在系统 PATH 前面,优先级更高
export PATH="$BIN_PATH:$PATH"

# === 别名 / 补全 ===
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# === 附加 ble.sh(与顶部 source 配对,须在 .bashrc 末尾) ===
if [ -n "${BLE_VERSION:-}" ]; then
    ble-attach
fi
