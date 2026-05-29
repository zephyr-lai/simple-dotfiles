# simple-dotfiles

轻量、开箱即用的 bash / vim / tmux 配置集合，`cp` 或 `install.sh` 一键部署。

## 包含内容

| 工具 | 配置 | 插件 |
|------|------|------|
| bash | `.bashrc` / `.bash_aliases` | git 分支+状态提示，彩色 PS1，17 个 alias |
| vim | `.vimrc` | vim-commentary / vim-gitgutter / lightline |
| tmux | `.tmux.conf` | catppuccin / tmux-sensible / tmux-resurrect / tmux-continuum |

## 安装

```bash
git clone <repo-url> ~/simple-dotfiles
cd ~/simple-dotfiles
./install.sh                 # 默认：备份旧配置 + 安装全部
./install.sh install         # 仅安装，不备份
./install.sh backup          # 仅备份
source ~/.bashrc
```

也可单独安装：

```bash
./install.sh deploy bash     # 只处理 bash
./install.sh install vim     # 只装 vim，不备份
./install.sh backup tmux     # 只备份 tmux
```

## 插件更新

| 工具 | 命令 |
|------|------|
| vim | 打开 vim 执行 `:PlugUpdate` |
| tmux | `prefix + U`（Ctrl-a Shift-u） |

## 目录结构

```
simple-dotfiles/
├── .bashrc
├── .bash_aliases
├── .vimrc
├── .tmux.conf
├── .vim/
│   ├── autoload/plug.vim
│   └── plugged/
└── .tmux/
    └── plugins/
```
