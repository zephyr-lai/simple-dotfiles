# bash 登录 shell 入口:Terminal.app 直开 bash / tmux / bash -l 只读 .bash_profile,不读 .bashrc
# 交互式登录 shell 统一转交 .bashrc(提示符、别名、ble.sh 全套生效)
if [[ $- == *i* && -f "$HOME/.bashrc" ]]; then
    . "$HOME/.bashrc"
fi
