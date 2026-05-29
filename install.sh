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
    cp "$DOTFILES/.bashrc" "$HOME/.bashrc"
    cp "$DOTFILES/.bash_aliases" "$HOME/.bash_aliases"
    echo "  [done] bash installed"
}

install_vim() {
    echo "==> install vim"
    cp "$DOTFILES/.vimrc" "$HOME/.vimrc"
    cp -r "$DOTFILES/.vim" "$HOME/.vim"
    echo "  [done] vim installed"
}

install_tmux() {
    echo "==> install tmux"
    cp "$DOTFILES/.tmux.conf" "$HOME/.tmux.conf"
    cp -r "$DOTFILES/.tmux" "$HOME/.tmux"
    echo "  [done] tmux installed"
    echo "  [tip]  run: tmux source-file ~/.tmux.conf"
}

install_all() {
    echo "dotfiles from: $DOTFILES"
    echo ""
    install_bash
    install_vim
    install_tmux
    echo ""
    echo "Done."
echo ""
echo "  bash: source ~/.bashrc"
echo "  tmux: tmux source-file ~/.tmux.conf"
}

# === deploy (backup + install) ===

deploy_bash() {
    echo "==> deploy bash"
    backup_file .bashrc
    backup_file .bash_aliases
    install_bash
}

deploy_vim() {
    echo "==> deploy vim"
    backup_file .vimrc
    backup_file .vim
    install_vim
}

deploy_tmux() {
    echo "==> deploy tmux"
    backup_file .tmux.conf
    backup_file .tmux
    install_tmux
}

deploy_all() {
    echo "dotfiles from: $DOTFILES"
    echo "backup to:    $BACKUP_DIR"
    echo ""
    deploy_bash
    deploy_vim
    deploy_tmux
    echo ""
    echo "All done."
echo ""
echo "  bash: source ~/.bashrc"
echo "  tmux: tmux source-file ~/.tmux.conf"
}

# === main ===
cmd="${1:-deploy}"
tool="${2:-all}"

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
            bash) install_bash ;;
            vim)  install_vim ;;
            tmux) install_tmux ;;
            all)  install_all ;;
            *)    echo "Usage: $0 install {bash|vim|tmux|all}" && exit 1 ;;
        esac
        ;;
    deploy)
        case "$tool" in
            bash) deploy_bash ;;
            vim)  deploy_vim ;;
            tmux) deploy_tmux ;;
            all)  deploy_all ;;
            *)    echo "Usage: $0 deploy {bash|vim|tmux|all}" && exit 1 ;;
        esac
        ;;
    *)
        echo "Usage: $0 {backup|install|deploy} [bash|vim|tmux|all]"
        echo ""
        echo "  backup  仅备份已有配置"
        echo "  install 仅安装（不备份）"
        echo "  deploy  备份 + 安装（默认）"
        exit 1
        ;;
esac
