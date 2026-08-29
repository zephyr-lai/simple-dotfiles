# Claude Code 插件清单

新机器恢复：让 Claude 读此文件，用 `claude plugin marketplace add` 注册缺失的 marketplace，
`claude plugin install` 安装缺失的插件（先 `claude plugin list` 查现状，已装的跳过）。

## Marketplaces

| 名称 | GitHub 仓库 | 备注 |
|------|-------------|------|
| claude-plugins-official | （官方内置，无需注册） | 官方插件市场 |
| planning-with-files | OthmanAdi/planning-with-files | 计划文件工作流 |
| ui-ux-pro-max-skill | nextlevelbuilder/ui-ux-pro-max-skill | UI/UX 设计 skill |
| anthropic-agent-skills | anthropics/skills | 官方 agent skills 合集 |
| karpathy-skills | forrestchang/andrej-karpathy-skills | Karpathy 风格 skills |

## Plugins

官方市场（claude-plugins-official）：

- superpowers
- code-review
- code-simplifier
- ralph-loop
- frontend-design
- skill-creator

自定义市场：

- planning-with-files@planning-with-files
- ui-ux-pro-max@ui-ux-pro-max-skill
- example-skills@anthropic-agent-skills
- document-skills@anthropic-agent-skills
- andrej-karpathy-skills@karpathy-skills
