# ~/.bashrc

# 非交互式 shell 直接返回
case $- in
    *i*) ;;
      *) return;;
esac

# === ble.sh 幽灵字自动补全(需安装,未装自动跳过;安装见 install.sh 的 require_blesh) ===
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

# === 提示符 ===
PROMPT_STYLE=pygmalion                 # 配色方案: green | pygmalion
GIT_STYLE=detail                   # git 段样式: detail(分支+*+?↑n↓n) | dirty(分支+⚡)
                                   # 两个开关自由组合,共 4 种;骨架四者共用,只有颜色和标记不同

# --- 调色板:PROMPT_STYLE 只决定各部位用什么颜色(数值是 ANSI 色号) ---
# __C_MARK 是唯一的标记色:dirty 的 ⚡ 与 detail 的 * + ? ↑n ↓n 共用它,
# 所以两种 git 样式下标记永远同色;换配色时改这一个值即可,别拆成两个变量
case "$PROMPT_STYLE" in
    pygmalion)
        __C_USER='0;35' __C_AT='0;36' __C_HOST='0;33'
        __C_SEP='0;31'                             # 冒号和竖线共用一个分隔色
        __C_PATH='0;36' __C_TAIL='0;36'            # 路径、结尾的 ⇒
        __C_BRANCH='0;32' __C_MARK='0;33'          # 分支、标记(=⚡ 色)
        __C_VENV='01;32'                           # 虚拟环境名
        ;;
    *)
        __C_USER='01;32' __C_AT='01;32' __C_HOST='01;32'
        __C_SEP='00'
        __C_PATH='01;34' __C_TAIL='01;32'
        __C_BRANCH='01;33' __C_MARK='0;33'         # 分支、标记(=⚡ 色;与 pygmalion 同为橙黄)
        __C_VENV='01;35'                           # 虚拟环境名
        ;;
esac

# $(...) 里输出的非打印字符标记:\001 \002 等价于 \[ \],在子 shell 中同样安全
__C_NP=$'\001' __C_CP=$'\002' __C_ESC=$'\033'
__G_SEP="${__C_NP}${__C_ESC}[${__C_SEP}m${__C_CP}"
__G_BRANCH="${__C_NP}${__C_ESC}[${__C_BRANCH}m${__C_CP}"
__G_MARK="${__C_NP}${__C_ESC}[${__C_MARK}m${__C_CP}"
__G_VENV="${__C_NP}${__C_ESC}[${__C_VENV}m${__C_CP}"
__G_RST="${__C_NP}${__C_ESC}[00m${__C_CP}"

# 关掉 venv 自带的 PS1 前缀:新版 Python 的 VIRTUAL_ENV_PROMPT 已含括号,
# activate 又套一层,会渲染成 ((.venv) ) 且没有颜色。改由 __prompt_venv 自己画。
export VIRTUAL_ENV_DISABLE_PROMPT=1

# --- git 状态:一次 git status 拿全,结果写进 __GIT_* ---
# 调用方是 PS1 里的 $(...),本身即子 shell,所以这些全局变量不会漏进交互 shell
__prompt_git_info() {
    local out line b
    out=$(git status --porcelain=v1 --branch -unormal 2>/dev/null) || return 1

    __GIT_BRANCH= __GIT_STAGED=0 __GIT_UNSTAGED=0 __GIT_UNTRACKED=0 __GIT_AHEAD=0 __GIT_BEHIND=0

    while IFS= read -r line; do
        case "$line" in
            '## '*)
                # ## master...origin/master [ahead 1, behind 2] / ## master / ## HEAD (no branch)
                b=${line#\#\# }
                case "$b" in
                    'HEAD (no branch)'*)   b=$(git rev-parse --short HEAD 2>/dev/null) ;;   # 游离头:用短 SHA
                    'No commits yet on '*|'Initial commit on '*)
                                           b=${b#* on } ;;                                 # 空仓库
                    *)                     b=${b%%...*}; b=${b%% *} ;;                     # 去掉 upstream
                esac
                __GIT_BRANCH=$b
                case "$line" in *'['*']'*)
                    b=${line##*\[}; b=${b%%]*}              # "ahead 1, behind 2"
                    case "$b" in *'ahead '*)
                        __GIT_AHEAD=${b##*ahead }; __GIT_AHEAD=${__GIT_AHEAD%%,*}
                    esac
                    case "$b" in *'behind '*)
                        __GIT_BEHIND=${b##*behind }; __GIT_BEHIND=${__GIT_BEHIND%%,*}
                    esac
                esac
                ;;
            '??'*) __GIT_UNTRACKED=1 ;;
            *)
                [ -z "$line" ] && continue
                # porcelain v1 前两列是 XY:未暂存修改是 " M"(首字符是空格),
                # 别用 [MARCDU]* 之类的模式匹配,会整个漏掉
                [ "${line:0:1}" != ' ' ] && __GIT_STAGED=1
                [ "${line:1:1}" != ' ' ] && __GIT_UNSTAGED=1
                ;;
        esac
    done <<< "$out"

    [ "$__GIT_AHEAD" ] || __GIT_AHEAD=0
    [ -n "$__GIT_BRANCH" ]
}

# --- git 段渲染:只决定画什么、什么格式,颜色一律取自调色板 ---

# detail:分支 + 逐项标记(* 未暂存 / + 已暂存 / ? 未跟踪 / ↑n 领先 / ↓n 落后)
__prompt_git_detail() {
    __prompt_git_info || return

    local marks=""
    [ "$__GIT_UNSTAGED"  = 1 ] && marks+="${__G_MARK}*${__G_RST}"
    [ "$__GIT_STAGED"    = 1 ] && marks+="${__G_MARK}+${__G_RST}"
    [ "$__GIT_UNTRACKED" = 1 ] && marks+="${__G_MARK}?${__G_RST}"
    [ "$__GIT_AHEAD"  -gt 0 ]  && marks+="${__G_MARK}↑${__GIT_AHEAD}${__G_RST}"
    [ "$__GIT_BEHIND" -gt 0 ]  && marks+="${__G_MARK}↓${__GIT_BEHIND}${__G_RST}"
    [ -n "$marks" ] && marks=" ${marks}"

    printf '%s' "${__G_SEP}|${__G_RST}${__G_BRANCH}${__GIT_BRANCH}${__G_RST}${marks}"
}

# dirty:分支 + 一个脏标记(口径与 zsh parse_git_dirty 一致:暂存/未暂存/未跟踪任一即脏)
__prompt_git_dirty() {
    __prompt_git_info || return

    local out="${__G_SEP}|${__G_RST}${__G_BRANCH}${__GIT_BRANCH}"
    if [ "$__GIT_STAGED" = 1 ] || [ "$__GIT_UNSTAGED" = 1 ] || [ "$__GIT_UNTRACKED" = 1 ]; then
        out+="${__G_MARK}⚡"
    fi
    printf '%s' "${out}${__G_RST} "
}

# --- 按 GIT_STYLE 绑定 __prompt_git(未知值一律回落 detail) ---
case "$GIT_STYLE" in
    dirty) __prompt_git() { __prompt_git_dirty;  } ;;
    *)     __prompt_git() { __prompt_git_detail; } ;;
esac

# --- venv 段:激活虚拟环境时在提示符最前面显示带颜色的 [环境名] ---
__prompt_venv() {
    [ -n "$VIRTUAL_ENV" ] || return
    local name=${VIRTUAL_ENV%/}
    printf '%s' "${__G_VENV}[${name##*/}]${__G_RST} "
}

# --- PS1:四个组合共用这一份骨架,颜色由上面的调色板填 ---
PS1='$(__prompt_venv)\[\e[${__C_USER}m\]\u\[\e[00m\]\[\e[${__C_AT}m\]@\[\e[00m\]\[\e[${__C_HOST}m\]\h\[\e[00m\]\[\e[${__C_SEP}m\]:\[\e[00m\]\[\e[${__C_PATH}m\]\w\[\e[00m\]$(__prompt_git)\[\e[${__C_TAIL}m\]⇒\[\e[00m\]  '

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

# === PATH ===
BIN_PATH="$HOME/.npm-global/bin:$HOME/.local/bin"   # 排在系统 PATH 前面,优先级更高
export PATH="$BIN_PATH:$PATH"

# === 本机私有配置(不入仓库) ===
# 内部地址、机器专属变量放 ~/.bashrc.local;该文件在 home 下,不在 stow 包内
if [ -f ~/.bashrc.local ]; then
    . ~/.bashrc.local
fi

# === 附加 ble.sh(放最后:attach 会抄走 PS1,之后设的 PS1 静默失效) ===
if [ -n "${BLE_VERSION:-}" ]; then
    ble-attach
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
