# simple-dotfiles

轻量、开箱即用的 bash / vim / tmux 配置集合，`install.sh` 一键部署。

## 目录结构

```
dotfiles/
├── bash/               ← stow 包
│   ├── .bashrc
│   └── .bash_aliases
├── vim/                ← stow 包
│   ├── .vimrc
│   └── .vim/
├── tmux/               ← stow 包
│   ├── .tmux.conf
│   └── .tmux/
├── install.sh
└── README.md
```

## 安装

```bash
git clone git@github.com:zephyr-lai/simple-dotfiles.git ~/simple-dotfiles
cd ~/simple-dotfiles

# cp 方式（默认，离线安全）
./install.sh                     # 备份 + 安装全部
./install.sh deploy vim cp       # 只部署 vim

# stow 方式（软链接，改一处仓库同步）
./install.sh deploy all stow     # 备份 + stow 全部
./install.sh install vim stow    # 只安装 vim（不备份）

source ~/.bashrc
```

## 命令

```
./install.sh {backup|install|deploy|uninstall} [bash|vim|tmux|all] [{cp|stow}]
```

| 命令 | 作用 |
|------|------|
| `backup` | 仅备份已有配置到 `~/.dotfiles_backup/<时间戳>/` |
| `install` | 仅安装，不备份 |
| `deploy` | 备份 + 安装（默认） |
| `uninstall` | 卸载配置 |

| 方法 | 作用 |
|------|------|
| `cp` | 拷贝方式（默认，离线安全，不需要额外依赖） |
| `stow` | 软链接方式（需要 `apt install stow`，改一处仓库同步） |

| 示例 | 效果 |
|------|------|
| `./install.sh` | 备份旧配置 + cp 安装全部 |
| `./install.sh deploy vim stow` | 备份 vim + stow 链接 vim |
| `./install.sh install tmux cp` | 仅 cp 安装 tmux |
| `./install.sh uninstall vim stow` | stow 卸载 vim |
| `./install.sh uninstall all cp` | 删除全部配置文件 |
| `./install.sh backup bash` | 仅备份 bash |

## bash

| 配置项 | 默认 | 配置后 |
|--------|------|--------|
| 命令提示符 | `user@host:~/dir$` | `user@host:~/dir (main *+?↑)$` 彩色 + git 分支及状态 |
| git 分支显示 | 无 | 当前分支名 |
| git 状态提示 | 无 | `*` unstaged / `+` staged / `?` untracked / `↑` unpushed |
| 常用 alias | 无 | `..` `...` `c` `h` `ports` `rp` `reload` 等 14 个 |
| 历史记录 | 默认 | 去重 + 追加模式 |
| 搜索大小写 | 严格区分 | 忽略大小写，有大写时自动区分 |

## vim

| 配置项 | 默认 | 配置后 |
|--------|------|--------|
| 行号 | 无 | 显示行号 |
| 语法高亮 | 关闭 | 开启，内置配色 retrobox（暗色） |
| 当前行/列 | 无 | 高亮行（仅行号列）+ 列关闭 |
| 光标形状 | 始终块状 | Normal 块 / Insert 竖线 / Replace 下划线 |
| 鼠标 | 关闭 | 点击定位、滚轮翻页 |
| 搜索 | 逐次回车 | 边输入边搜索 + 高亮所有结果 |
| Tab 键 | 插入 `\t` | 插入 4 个空格 |
| 撤销 | 关文件后丢失 | 持久撤销 |
| 系统剪贴板 | 不通 | `y` 复制可在系统粘贴 |
| swap 文件 | 生成 `.swp` | 不生成 |
| 状态栏 | 默认单行 | lightline 美化（模式/文件名/行列号） |
| git 改动标记 | 无 | 行号左侧 `+` `~` `-` 标记（gitgutter） |
| 注释代码 | 手打注释符 | `gcc` 一键注释/取消（vim-commentary） |

## tmux

| 配置项 | 默认 | 配置后 |
|--------|------|--------|
| 前缀键 | `Ctrl-b` | `Ctrl-a`（主）+ `Ctrl-b`（副），两个都可用 |
| 竖直分屏 | `Ctrl-b %` | `Ctrl-b %` + `Ctrl-a \|` |
| 横向分屏 | `Ctrl-b "` | `Ctrl-b "` + `Ctrl-a -` |
| 分屏后目录 | 回到 home | 继承当前 pane 目录 |
| 窗口编号 | 从 0 开始 | 从 1 开始，关闭后自动重排 |
| 鼠标 | 关闭 | 点击切 pane、拖拽调大小、滚轮翻屏 |
| 回滚行数 | 2000 | 50000 |
| 状态栏 | 默认 | Catppuccin Mocha 暗色主题，左侧 session\|window\|pane，右侧时间日期 |
| 会话恢复 | 无 | tmux-resurrect（手动）+ tmux-continuum（自动） |
| 复制模式 | 默认 | vi 键位（`v` 选择 `y` 复制） |

## 插件更新

| 工具 | 命令 |
|------|------|
| vim | `:PlugUpdate` |
| tmux | `prefix + U` |
