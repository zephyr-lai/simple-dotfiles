# Claude Code 插件清单

新机器恢复流程：

1. `claude plugin list` 查看已装插件
2. 对照下方清单，缺失的 marketplace 先注册：`claude plugin marketplace add <仓库>`
3. 缺失的插件再安装：`claude plugin install <插件名>@<市场名>`
4. 已存在的跳过，不要重复安装

> 装新插件或停用插件后，需同步更新本文件。

## Marketplaces（官方内置 1 个 + 自定义 5 个）

| 名称 | 注册方式 | 说明 |
|------|----------|------|
| claude-plugins-official | 官方内置，无需注册 | Anthropic 官方插件市场 |
| planning-with-files | `claude plugin marketplace add OthmanAdi/planning-with-files` | 计划文件工作流 |
| ui-ux-pro-max-skill | `claude plugin marketplace add nextlevelbuilder/ui-ux-pro-max-skill` | UI/UX 设计 skill |
| anthropic-agent-skills | `claude plugin marketplace add anthropics/skills` | Anthropic 官方 agent skills 合集 |
| karpathy-skills | `claude plugin marketplace add forrestchang/andrej-karpathy-skills` | Karpathy 风格 skills |
| ecc | `claude plugin marketplace add affaan-m/ECC` | ECC 工程插件集（Git 仓库） |

## Plugins（共 12 个，全部启用）

### 官方市场 claude-plugins-official（6 个）

| 插件 | 说明 |
|------|------|
| superpowers | 结构化工作流 skill 集（TDD、系统化调试、写计划等） |
| code-review | 代码审查 |
| code-simplifier | 代码简化重构 |
| ralph-loop | 自主循环执行 |
| frontend-design | 前端设计 |
| skill-creator | 创建新 skill |

### 自定义市场（6 个）

| 插件 | 所属市场 | 说明 |
|------|----------|------|
| planning-with-files | planning-with-files | 计划文件工作流（/plan、/status 等命令） |
| ui-ux-pro-max | ui-ux-pro-max-skill | UI/UX 设计 skill |
| example-skills | anthropic-agent-skills | 官方示例 skills（webapp-testing、mcp-builder 等） |
| document-skills | anthropic-agent-skills | Office 文档处理（xlsx / docx / pptx / pdf） |
| andrej-karpathy-skills | karpathy-skills | Karpathy 风格编码 guidelines |
| ecc | ecc | 大型工程插件集（67 agents / 282 skills），自带 hooks 自动化，必要时可停用单个插件：`claude plugin disable ecc@ecc` |
