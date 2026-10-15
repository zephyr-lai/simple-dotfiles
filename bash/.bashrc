# ~/.bashrc

# 非交互式 shell 直接返回
case $- in
    *i*) ;;
      *) return;;
esac

# ==================== 用户配置:日常只改这一段 ====================
# PROMPT_STYLE  green     = 亮绿 user@host + 蓝路径 + 黄(分支) + 红 * ? ↑↓  ← 默认
#               pygmalion = oh-my-zsh 同款(品红用户名 / 青路径 / 绿分支 / 黄 ⚡)
PROMPT_STYLE=green
HISTSIZE=1000             # 内存中保存的历史条数
HISTFILESIZE=2000         # 历史文件保留的条数
BIN_PATH="$HOME/.npm-global/bin:$HOME/.local/bin"   # 追加到 PATH 前部,靠前优先级高
# ==============================================================

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
HISTCONTROL=ignoreboth              # 忽略重复行
shopt -s histappend                 # 追加而非覆盖
# 条数(HISTSIZE / HISTFILESIZE)见顶部用户配置区

# === 终端 ===
shopt -s checkwinsize               # 窗口缩放时刷新 LINES/COLUMNS

# === 提示符 ===
# 两套配色的 git 函数分开常驻(各查各的,互不拖累),由顶部 PROMPT_STYLE 选 PS1

# --- 配色 green 专用:黄括号 + 分支名,红状态符 ---
__prompt_git_green() {
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

# --- 配色 pygmalion 专用:绿分支名,黄 ⚡ 表示有改动 ---
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
        # 品红 用户名 / 青 @ / 黄 主机名 / 红 : 和 | / 青 路径 / 绿 分支名 / 黄 ⚡ / 青 ⇒
        PS1='\[\e[0;35m\]\u\[\e[00m\]\[\e[0;36m\]@\[\e[00m\]\[\e[0;33m\]\h\[\e[00m\]\[\e[0;31m\]:\[\e[00m\]\[\e[0;36m\]\w\[\e[00m\]\[\e[0;31m\]|\[\e[00m\]$(__prompt_git_pygmalion)\[\e[0;36m\]⇒\[\e[00m\]  '
        ;;
    *)
        # 亮绿 user@host / 蓝 路径 / 黄 分支 / 红 状态符
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

# === dircolors ===
# 只负责初始化 LS_COLORS;BSD/macOS 无此命令故加守卫
# 颜色别名(ls/grep/fgrep/egrep)已移至 .bash_aliases,那边带同样的守卫
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

# === bash_aliases ===
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# === bash 补全 ===
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# === PATH ===
# 靠前的优先级更高;待追加的目录见顶部用户配置区的 BIN_PATH
export PATH="$BIN_PATH:$PATH"

# === 附加 ble.sh(与顶部 source 配对,须在 .bashrc 末尾) ===
if [ -n "${BLE_VERSION:-}" ]; then
    ble-attach
fi
