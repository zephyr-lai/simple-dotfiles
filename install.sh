#!/bin/bash
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

backup_all() {
    echo "backup to: $BACKUP_DIR"
    echo ""
    backup_bash
    backup_vim
    backup_tmux
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

install_tmux() {
    echo "==> install tmux"
    cp "$DOTFILES/tmux/.tmux.conf" "$HOME/.tmux.conf"
    cp -r "$DOTFILES/tmux/.tmux" "$HOME/.tmux"
    echo "  [copy] tmux installed"
    if [ -n "$TMUX" ]; then
        tmux source-file "$HOME/.tmux.conf"
        echo "  [reload] tmux config reloaded"
    fi
}

stow_link() {
    local pkg="${1:-.}"
    command -v stow >/dev/null 2>&1 || { echo "  [error] stow not found, install: apt install stow"; exit 1; }
    echo "==> stow link ($pkg)"
    cd "$DOTFILES" && stow "$pkg" -t "$HOME" -v 2>&1 | while IFS= read -r line; do echo "  [link] $line"; done
}

stow_unlink() {
    local pkg="${1:-.}"
    command -v stow >/dev/null 2>&1 || { echo "  [error] stow not found, install: apt install stow"; exit 1; }
    echo "==> stow unlink ($pkg)"
    cd "$DOTFILES" && stow -D "$pkg" -t "$HOME" -v 2>&1 | while IFS= read -r line; do echo "  [unlink] $line"; done
}

install_all() {
    echo "dotfiles from: $DOTFILES"
    echo ""
    case "$METHOD" in
        stow) stow_link bash && stow_link vim && stow_link tmux ;;
        *)
            install_bash
            install_vim
            install_tmux
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

uninstall_all() {
    echo "dotfiles from: $DOTFILES"
    echo ""
    case "$METHOD" in
        stow) stow_unlink bash && stow_unlink vim && stow_unlink tmux ;;
        *)    uninstall_bash && uninstall_vim && uninstall_tmux ;;
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
    [ "$METHOD" = "stow" ] && stow_link tmux || install_tmux
}

deploy_all() {
    echo "dotfiles from: $DOTFILES"
    echo "backup to:    $BACKUP_DIR"
    echo ""
    deploy_bash
    deploy_vim
    deploy_tmux
    echo ""
    echo "All done. Run: source ~/.bashrc"
}

# === main ===
cmd="${1:-deploy}"
tool="${2:-all}"
METHOD="${3:-stow}"

case "$cmd" in
    backup)
        case "$tool" in
            bash) backup_bash ;;
            vim)  backup_vim ;;
            tmux) backup_tmux ;;
            all)  backup_all ;;
            *)    echo "Usage: $0 backup {bash|vim|tmux|all}" && exit 1 ;;
        esac
        ;;
    install)
        case "$tool" in
            bash) [ "$METHOD" = "stow" ] && stow_link bash || install_bash ;;
            vim)  [ "$METHOD" = "stow" ] && stow_link vim  || install_vim ;;
            tmux) [ "$METHOD" = "stow" ] && stow_link tmux || install_tmux ;;
            all)  install_all ;;
            *)    echo "Usage: $0 install {bash|vim|tmux|all} [{cp|stow}]" && exit 1 ;;
        esac
        ;;
    deploy)
        case "$tool" in
            bash) deploy_bash ;;
            vim)  deploy_vim ;;
            tmux) deploy_tmux ;;
            all)  deploy_all ;;
            *)    echo "Usage: $0 deploy {bash|vim|tmux|all} [{cp|stow}]" && exit 1 ;;
        esac
        ;;
    uninstall)
        case "$tool" in
            bash) [ "$METHOD" = "stow" ] && stow_unlink bash || uninstall_bash ;;
            vim)  [ "$METHOD" = "stow" ] && stow_unlink vim  || uninstall_vim ;;
            tmux) [ "$METHOD" = "stow" ] && stow_unlink tmux || uninstall_tmux ;;
            all)  uninstall_all ;;
            *)    echo "Usage: $0 uninstall {bash|vim|tmux|all} [{cp|stow}]" && exit 1 ;;
        esac
        ;;
    *)
        echo "Usage: $0 {backup|install|deploy|uninstall} [bash|vim|tmux|all] [{cp|stow}]"
        echo ""
        echo "  backup    仅备份已有配置"
        echo "  install   仅安装（不备份）"
        echo "  deploy    备份 + 安装（默认）"
        echo "  uninstall 卸载配置"
        echo ""
        echo "  cp        拷贝方式（离线安全）"
        echo "  stow      软链接方式（默认，改一处仓库同步）"
        exit 1
        ;;
esac
