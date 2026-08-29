#!/bin/bash
#
set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$HOME/.dotfiles_backup/$TIMESTAMP"

backup_file() {
    local target="$HOME/$1"
    if [ -e "$target" ] || [ -L "$target" ]; then
        mkdir -p "$BACKUP_DIR"
        mv "$target" "$BACKUP_DIR/${1##*/}"
        echo "  [backup] $target → $BACKUP_DIR/${1##*/}"
    fi
}

# === backup ===

backup_bash() {
    echo "==> backup bash"
    backup_file .bashrc
    backup_file .bash_aliases
}

backup_vim() {
    echo "==> backup vim"
    backup_file .vimrc
    backup_file .vim
}

backup_tmux() {
    echo "==> backup tmux"
    backup_file .tmux.conf
    backup_file .tmux
}

backup_git() {
    echo "==> backup git"
    backup_file .gitconfig
}

backup_claude() {
    echo "==> backup claude"
    local dest="$BACKUP_DIR/.claude"
    for f in settings.json skills/ima-skill skills/pms; do
        local src="$HOME/.claude/$f"
        if [ -e "$src" ] || [ -L "$src" ]; then
            mkdir -p "$dest/$(dirname "$f")"
            mv "$src" "$dest/$f"
            echo "  [backup] $src → $dest/$f"
        fi
    done
}

backup_all() {
    echo "backup to: $BACKUP_DIR"
    echo ""
    backup_bash
    backup_vim
    backup_tmux
    backup_git
    backup_claude
    echo ""
    echo "Backup done."
}

# === install ===

install_bash() {
    echo "==> install bash"
    cp "$DOTFILES/bash/.bashrc" "$HOME/.bashrc"
    cp "$DOTFILES/bash/.bash_aliases" "$HOME/.bash_aliases"
    echo "  [copy] bash installed"
}

install_vim() {
    echo "==> install vim"
    cp "$DOTFILES/vim/.vimrc" "$HOME/.vimrc"
    cp -r "$DOTFILES/vim/.vim" "$HOME/.vim"
    echo "  [copy] vim installed"
}

tmux_reload() {
    if [ -n "$TMUX" ]; then
        tmux source-file "$HOME/.tmux.conf"
        echo "  [reload] tmux config reloaded"
    fi
}

install_tmux() {
    echo "==> install tmux"
    cp "$DOTFILES/tmux/.tmux.conf" "$HOME/.tmux.conf"
    cp -r "$DOTFILES/tmux/.tmux" "$HOME/.tmux"
    echo "  [copy] tmux installed"
    tmux_reload
}

install_git() {
    echo "==> install git"
    cp "$DOTFILES/git/.gitconfig" "$HOME/.gitconfig"
    echo "  [copy] git installed"
}

install_claude() {
    echo "==> install claude"
    mkdir -p "$HOME/.claude"
    cp "$DOTFILES/claude/settings.json" "$HOME/.claude/settings.json"
    cp -r "$DOTFILES/claude/skills" "$HOME/.claude/skills"
    echo "  [copy] claude installed"
    echo "  [hint] secrets (settings.local.json) are kept locally, not synced"
}

require_stow() {
    [ -n "${STOW:-}" ] && return 0   # already resolved, skip detection

    # 1. system stow
    if command -v stow >/dev/null 2>&1; then
        STOW="stow"
        return 0
    fi

    # 2. try installing online
    echo "  [warn] stow not found, trying to install..."
    local installed=0
    case "$(uname -s)" in
        Darwin)
            if command -v brew >/dev/null 2>&1; then
                if brew install stow >/dev/null 2>&1; then
                    installed=1
                else
                    echo "  [warn] brew install stow failed"
                fi
            fi
            ;;
        Linux)
            if command -v apt-get >/dev/null 2>&1; then
                if sudo apt-get install -y stow >/dev/null 2>&1; then
                    installed=1
                else
                    echo "  [warn] apt install stow failed"
                fi
            fi
            ;;
    esac
    if [ "$installed" = 1 ]; then
        STOW="stow"
        echo "  [ok] stow installed via package manager"
        return 0
    fi
    echo "  [warn] online install failed, falling back to bundled stow"

    # 3. install the bundled stow so it becomes globally available
    local bundled="$DOTFILES/tools/stow/stow"
    if [ -x "$bundled" ]; then
        local bindir="$HOME/.local/bin"
        mkdir -p "$bindir"
        ln -sf "$bundled" "$bindir/stow"
        echo "  [ok] bundled stow installed to $bindir/stow"
        case ":$PATH:" in
            *":$bindir:"*)
                STOW="stow"
                echo "  [ok] stow is now globally available"
                ;;
            *)
                STOW="$bindir/stow"
                echo "  [warn] $bindir is not on PATH, stow only works via full path"
                echo "  [warn] add it to make it global: export PATH=\"$bindir:\$PATH\""
                ;;
        esac
        return 0
    fi

    echo "  [error] stow not found and no bundled copy available"
    echo "  [error] install it first:"
    case "$(uname -s)" in
        Darwin) echo "  [error]   brew install stow" ;;
        Linux)  echo "  [error]   apt install stow (or your distro's package manager)" ;;
        *)      echo "  [error]   install stow via your package manager" ;;
    esac
    exit 1
}

stow_link() {
    local pkg="${1:-.}"
    require_stow
    echo "==> stow link ($pkg)"
    cd "$DOTFILES" && "$STOW" "$pkg" -t "$HOME" -v 2>&1 | while IFS= read -r line; do echo "  [link] $line"; done
}

stow_unlink() {
    local pkg="${1:-.}"
    require_stow
    echo "==> stow unlink ($pkg)"
    cd "$DOTFILES" && "$STOW" -D "$pkg" -t "$HOME" -v 2>&1 | while IFS= read -r line; do echo "  [unlink] $line"; done
}

install_all() {
    echo "dotfiles from: $DOTFILES"
    echo ""
    case "$METHOD" in
        stow) stow_link bash && stow_link vim && stow_link tmux && tmux_reload && stow_link git && stow_link claude ;;
        *)
            install_bash
            install_vim
            install_tmux
            install_git
            install_claude
            ;;
    esac
    echo ""
    echo "Done. Run: source ~/.bashrc"
}

# === uninstall ===

remove_file() {
    local target="$HOME/$1"
    if [ -L "$target" ]; then
        rm "$target" && echo "  [rm] $target"
    elif [ -e "$target" ]; then
        rm -rf "$target" && echo "  [rm] $target"
    fi
}

uninstall_bash() {
    echo "==> uninstall bash"
    remove_file .bashrc
    remove_file .bash_aliases
}

uninstall_vim() {
    echo "==> uninstall vim"
    remove_file .vimrc
    remove_file .vim
}

uninstall_tmux() {
    echo "==> uninstall tmux"
    remove_file .tmux.conf
    remove_file .tmux
}

uninstall_git() {
    echo "==> uninstall git"
    remove_file .gitconfig
}

uninstall_claude() {
    echo "==> uninstall claude"
    remove_file .claude/settings.json
    remove_file .claude/skills/ima-skill
    remove_file .claude/skills/pms
    echo "  [keep] .claude/settings.local.json (local secrets) left untouched"
}

uninstall_all() {
    echo "dotfiles from: $DOTFILES"
    echo ""
    case "$METHOD" in
        stow) stow_unlink bash && stow_unlink vim && stow_unlink tmux && stow_unlink git && stow_unlink claude ;;
        *)    uninstall_bash && uninstall_vim && uninstall_tmux && uninstall_git && uninstall_claude ;;
    esac
    echo ""
    echo "Uninstall done."
}

# === deploy (backup + install) ===

deploy_bash() {
    echo "==> deploy bash"
    backup_file .bashrc
    backup_file .bash_aliases
    [ "$METHOD" = "stow" ] && stow_link bash || install_bash
}

deploy_vim() {
    echo "==> deploy vim"
    backup_file .vimrc
    backup_file .vim
    [ "$METHOD" = "stow" ] && stow_link vim || install_vim
}

deploy_tmux() {
    echo "==> deploy tmux"
    backup_file .tmux.conf
    backup_file .tmux
    if [ "$METHOD" = "stow" ]; then
        stow_link tmux && tmux_reload
    else
        install_tmux
    fi
}

deploy_git() {
    echo "==> deploy git"
    backup_file .gitconfig
    [ "$METHOD" = "stow" ] && stow_link git || install_git
}

deploy_claude() {
    echo "==> deploy claude"
    backup_claude
    [ "$METHOD" = "stow" ] && stow_link claude || install_claude
}

deploy_all() {
    echo "dotfiles from: $DOTFILES"
    echo "backup to:    $BACKUP_DIR"
    echo ""
    deploy_bash
    deploy_vim
    deploy_tmux
    deploy_git
    deploy_claude
    echo ""
    echo "All done. Run: source ~/.bashrc"
}

# === main ===
cmd="${1:-help}"
tool="${2:-all}"
METHOD="${3:-stow}"

# check stow before backup runs (backup itself doesn't need it)
case "$cmd" in
    install|deploy|uninstall) [ "$METHOD" = "stow" ] && require_stow ;;
esac

case "$cmd" in
    backup)
        case "$tool" in
            bash)   backup_bash ;;
            vim)    backup_vim ;;
            tmux)   backup_tmux ;;
            git)    backup_git ;;
            claude) backup_claude ;;
            all)    backup_all ;;
            *)      echo "Usage: $0 backup {bash|vim|tmux|git|claude|all}" && exit 1 ;;
        esac
        ;;
    install)
        case "$tool" in
            bash)   [ "$METHOD" = "stow" ] && stow_link bash   || install_bash ;;
            vim)    [ "$METHOD" = "stow" ] && stow_link vim    || install_vim ;;
            tmux)   if [ "$METHOD" = "stow" ]; then stow_link tmux && tmux_reload; else install_tmux; fi ;;
            git)    [ "$METHOD" = "stow" ] && stow_link git    || install_git ;;
            claude) [ "$METHOD" = "stow" ] && stow_link claude || install_claude ;;
            all)    install_all ;;
            *)      echo "Usage: $0 install {bash|vim|tmux|git|claude|all} [{cp|stow}]" && exit 1 ;;
        esac
        ;;
    deploy)
        case "$tool" in
            bash)   deploy_bash ;;
            vim)    deploy_vim ;;
            tmux)   deploy_tmux ;;
            git)    deploy_git ;;
            claude) deploy_claude ;;
            all)    deploy_all ;;
            *)      echo "Usage: $0 deploy {bash|vim|tmux|git|claude|all} [{cp|stow}]" && exit 1 ;;
        esac
        ;;
    uninstall)
        case "$tool" in
            bash)   [ "$METHOD" = "stow" ] && stow_unlink bash   || uninstall_bash ;;
            vim)    [ "$METHOD" = "stow" ] && stow_unlink vim    || uninstall_vim ;;
            tmux)   [ "$METHOD" = "stow" ] && stow_unlink tmux   || uninstall_tmux ;;
            git)    [ "$METHOD" = "stow" ] && stow_unlink git    || uninstall_git ;;
            claude) [ "$METHOD" = "stow" ] && stow_unlink claude || uninstall_claude ;;
            all)    uninstall_all ;;
            *)      echo "Usage: $0 uninstall {bash|vim|tmux|git|claude|all} [{cp|stow}]" && exit 1 ;;
        esac
        ;;
    help)
        echo "Usage: $0 {backup|install|deploy|uninstall} [bash|vim|tmux|git|claude|all] [{cp|stow}]"
        echo ""
        echo "  backup    仅备份已有配置"
        echo "  install   仅安装（不备份）"
        echo "  deploy    备份 + 安装"
        echo "  uninstall 卸载配置"
        echo "  help      显示本帮助"
        echo ""
        echo "  cp        拷贝方式（离线安全）"
        echo "  stow      软链接方式（默认，改一处仓库同步）"
        exit 0
        ;;
    *)
        echo "Unknown command: $cmd"
        echo ""
        echo "Usage: $0 {backup|install|deploy|uninstall} [bash|vim|tmux|git|claude|all] [{cp|stow}]"
        exit 1
        ;;
esac
