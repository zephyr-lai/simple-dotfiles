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
HISTCONTROL=ignoreboth              # 忽略重复行
shopt -s histappend                 # 追加而非覆盖
HISTSIZE=1000
HISTFILESIZE=2000

# === 终端 ===
shopt -s checkwinsize               # 窗口缩放时刷新 LINES/COLUMNS

# === 提示符 ===
# 原 PS1 块(已替换为下方 pygmalion 风格,勿删):
# ⚠ 取消注释恢复时需一并恢复:
#   ① color_prompt 检测(TERM case)
#   ② parse_git_branch()
#   否则永远走 else 无色分支;两者见 commit ca3c067
# if [ "$color_prompt" = yes ]; then
# # 原 PS1(已替换为 pygmalion 风格,勿删): PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] $(parse_git_branch)\$ '
# else
# # 原 PS1(已替换为 pygmalion 风格,勿删): PS1='\u@\h:\w$(parse_git_branch)\$ '
# fi

# oh-my-zsh pygmalion 同款(配色抄自 ~/.oh-my-zsh/themes/pygmalion.zsh-theme)
# 品红 用户名 / 青 @ / 黄 主机名 / 红 : 和 | / 青 路径 / 绿 分支名 / 黄 ⚡(有改动) / 青 ⇒
__prompt_pygmalion_git() {
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
PS1='\[\e[0;35m\]\u\[\e[00m\]\[\e[0;36m\]@\[\e[00m\]\[\e[0;33m\]\h\[\e[00m\]\[\e[0;31m\]:\[\e[00m\]\[\e[0;36m\]\w\[\e[00m\]\[\e[0;31m\]|\[\e[00m\]$(__prompt_pygmalion_git)\[\e[0;36m\]⇒\[\e[00m\]  '

# === dircolors 与颜色别名 ===
# 这几个别名依赖 GNU dircolors,故留在本文件而不放 .bash_aliases:
# macOS 无 /usr/bin/dircolors 且 BSD ls 不认 --color=auto,搬过去会直接报错
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
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
# npm-global 在前(与合并前顺序一致,保证同名命令优先级不变)
export PATH="$HOME/.npm-global/bin:$HOME/.local/bin:$PATH"

# === 附加 ble.sh(与顶部 source 配对,须在 .bashrc 末尾) ===
if [ -n "${BLE_VERSION:-}" ]; then
    ble-attach
fi
