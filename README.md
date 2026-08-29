# simple-dotfiles

轻量、开箱即用的 bash / vim / tmux / git / claude 配置集合，`install.sh` 一键部署。

## 目录结构

```
simple-dotfiles/
├── bash/               ← stow 包：.bashrc + .bash_aliases
├── vim/                ← stow 包：.vimrc + .vim/
├── tmux/               ← stow 包：.tmux.conf + .tmux/
├── git/                ← stow 包：.gitconfig
├── claude/             ← stow 包：settings.json（去敏）+ skills/ + commands/ + agents/
├── tools/stow/         ← vendored GNU stow（断网兜底，见「stow 自动安装」）
├── tools/claude-restore.sh ← 新机器恢复 Claude Code 插件环境
├── install.sh          ← 唯一入口
├── CLAUDE.md           ← 项目规则（AI 辅助开发时自动加载）
└── README.md
```

## 安装

```bash
git clone git@github.com:zephyr-lai/simple-dotfiles.git ~/simple-dotfiles
cd ~/simple-dotfiles

# stow 方式（默认，软链接，改一处仓库同步）
./install.sh deploy all            # 备份 + stow 全部
./install.sh deploy vim            # 只部署 vim
./install.sh install claude stow   # 只安装 claude（不备份）

# cp 方式（拷贝，仓库与 home 解耦）
./install.sh deploy all cp         # 备份 + cp 全部

source ~/.bashrc                   # bash 用户刷新配置
```

`./install.sh` 不带参数时输出帮助信息，不会执行任何操作。

### stow 自动安装

stow 方式会自动解析工具，顺序为：

1. 系统已有 stow → 直接用
2. 没有 → 尝试在线安装（macOS 用 brew，Linux 用 apt）
3. 在线安装失败 → 使用仓库内置的 `tools/stow/`，安装到 `~/.local/bin/` 使其全局可用

## 命令

```
./install.sh {backup|install|deploy|uninstall|help} [bash|vim|tmux|git|claude|all] [{cp|stow}]
```

| 命令 | 作用 |
|------|------|
| `backup` | 仅备份已有配置到 `~/.dotfiles_backup/<时间戳>/` |
| `install` | 仅安装，不备份 |
| `deploy` | 备份 + 安装 |
| `uninstall` | 卸载配置（claude 的本地密钥文件保留不删） |
| `help` | 显示帮助（无参数时默认执行） |

| 方法 | 作用 |
|------|------|
| `stow` | 软链接方式（默认，改一处仓库同步） |
| `cp` | 拷贝方式（离线安全，不需要额外依赖） |

| 示例 | 效果 |
|------|------|
| `./install.sh` | 显示帮助 |
| `./install.sh deploy all` | 备份 + stow 全部 |
| `./install.sh deploy vim cp` | 备份 vim + cp 安装 vim |
| `./install.sh install tmux` | 仅 stow 安装 tmux |
| `./install.sh uninstall claude` | 卸载 claude（保留本地密钥） |
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
| 文件浏览器 | 无 | 内置 netrw，`<C-n>` 开关目录树 |

### vim 常用快捷键

| 按键 | 作用 |
|------|------|
| `<C-n>` | 开关 netrw 目录侧边栏 |
| `Enter` | 打开文件 / 进入目录 |
| `-` | 返回上一级目录 |
| `i` | 切换目录显示样式 |
| `gh` | 显示/隐藏隐藏文件 |
| `d` | 新建目录 |
| `D` | 删除文件或空目录 |
| `dd` | 删除文件或非空目录 |
| `R` | 重命名 |
| `o` / `v` / `t` | 水平/垂直分屏 / 新标签页打开 |

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
| 复制模式 | 默认 | vi 键位（`v` 选择 `y` 复制），OSC 52 同步系统剪贴板 |

## git

| 配置项 | 说明 |
|--------|------|
| diff 工具 | vimdiff 作为 difftool |
| 别名 `df` / `dfs` | `git difftool` / `git difftool --staged` |

## claude

| 文件 | 说明 |
|------|------|
| `settings.json` | 去敏配置（模型映射、代理、权限白名单），stow 链接到 `~/.claude/` |
| `settings.local.json.example` | 本地配置模板，复制为 `~/.claude/settings.local.json` 后填入自己的 token |
| `skills/` | pms、ima-skill 技能（无硬编码凭证） |
| `commands/` `agents/` | 自定义斜杠命令和 subagent（目前为空，写了就往这里放） |

**敏感信息规则**：`~/.claude/settings.local.json` 存放 token 等秘密，永不入仓（`.gitignore` 已兜底）。仓库是 PUBLIC，提交任何改动前请自查是否包含密钥。

### 新机器恢复插件环境

skills / commands / agents 随 `install.sh` 部署，插件（11 个）需联网安装：

```bash
./tools/claude-restore.sh
```

脚本幂等：先注册自定义 marketplace（planning-with-files、ui-ux-pro-max、anthropic-agent-skills、karpathy-skills），再安装各插件（superpowers、code-review、code-simplifier、ralph-loop、frontend-design、skill-creator 等），已安装的自动跳过。新机器完整恢复流程：`install.sh deploy all` → 复制 settings.local.json 模板填 token → 跑本脚本。

## 插件更新

| 工具 | 命令 |
|------|------|
| vim | `:PlugUpdate` |
| tmux | `prefix + U` |

## 项目规则

仓库根目录的 `CLAUDE.md` 描述项目规则（架构、安全红线、新增 package 清单），使用 AI 辅助开发时会自动加载。
