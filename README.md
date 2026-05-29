# simple-dotfiles

轻量、开箱即用的 bash / vim / tmux 配置集合，`install.sh` 一键部署。

## 安装

```bash
git clone git@github.com:zephyr-lai/simple-dotfiles.git ~/simple-dotfiles
cd ~/simple-dotfiles
./install.sh                 # 默认：备份旧配置 + 安装全部
./install.sh install         # 仅安装，不备份
./install.sh backup          # 仅备份
source ~/.bashrc
```

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
| 语法高亮 | 关闭 | 开启 |
| 鼠标 | 关闭 | 点击定位、滚轮翻页 |
| 当前行/列 | 无 | 高亮行 + 列（十字准线） |
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
| pane 移动 | `Ctrl-b 方向键` | `Ctrl-a h/j/k/l`（vim 风格） |
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