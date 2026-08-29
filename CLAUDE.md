# simple-dotfiles

跨平台 dotfiles 仓库。**仓库是 PUBLIC，禁止提交任何敏感信息。**

## 架构

- 每个包一个顶层目录：`bash/` `vim/` `tmux/` `git/` `claude/`
- `install.sh` 为唯一入口，子命令：`backup | install | deploy | uninstall`，无参数输出 help
- 安装方式：`cp`（拷贝）或 `stow`（符号链接，默认）
- stow 解析链（`require_stow`）：系统已有 → brew/apt 在线安装 → 仓库内置版安装到 `~/.local/bin`（全局可用）
- 内置 stow 在 `tools/stow/`（vendored GNU stow 2.4.1，改过 shebang 和 lib 路径，勿用上游原样覆盖）
- `claude/` 包维护 skills / commands / agents / 去敏 settings；插件用 `tools/claude-restore.sh` 恢复（新装插件后需同步更新该脚本的清单）

## 敏感信息规则（最重要）

- `~/.claude/settings.local.json` 存放 token 等秘密，**永不入仓**（`.gitignore` 已兜底 `claude/settings.local.json`）
- 新机器用 `claude/settings.local.json.example` 模板填写
- 提交前自查：`grep -rnE "sk-[a-z0-9]{20,}|token|password" <待提交文件>`
- `claude/` 包只能包含去敏配置；skills 不得含硬编码凭证（凭证走环境变量或 CLI 参数）

## 新增/修改 package 清单

1. 顶层建 `xxx/` 目录
2. install.sh 中实现 `backup_xxx` `install_xxx` `deploy_xxx` `uninstall_xxx`（保持幂等）
3. 接入 `backup_all` / `install_all` / `deploy_all` / `uninstall_all` 及对应 case 分支
4. 更新 Usage / help 文案
5. 更新 README.md（目录结构、命令、配置表）
6. 包内敏感或本地专属文件用 `.stow-local-ignore` 排除，并加 `.gitignore` 兜底

## 约定

- 脚本与配置文件注释用中文
- commit 用英文 conventional commits（feat/fix/chore），单行 subject
- 配置改动即改即生效（stow 软链接指向仓库）；新增顶层文件后需重跑 `./install.sh deploy all`
- **每次提交前检查 README.md 是否需要更新**（目录结构、命令/参数、配置表、行为变化），需要时先提示用户确认，再更新 README 后一并提交
