#!/usr/bin/env bash
# Claude Code 插件恢复脚本 — 生成于 2026-09-24
# 来源:~/.claude/plugins/{installed_plugins,known_marketplaces}.json(不含任何密钥)
# 配套文档:同目录 claude-plugins.md(每个插件的用途说明)
# 用法:新机器装好 Claude Code 后,运行 bash restore-plugins.sh
set -euo pipefail

echo "== 添加插件市场 (7) =="
claude plugin marketplace add anthropics/claude-plugins-official
claude plugin marketplace add anthropics/skills
claude plugin marketplace add OthmanAdi/planning-with-files
claude plugin marketplace add nextlevelbuilder/ui-ux-pro-max-skill
claude plugin marketplace add https://github.com/affaan-m/ECC.git
claude plugin marketplace add forrestchang/andrej-karpathy-skills
claude plugin marketplace add cathrynlavery/diagram-design

echo "== 安装插件 (13,install 默认即启用) =="
claude plugin install andrej-karpathy-skills@karpathy-skills
claude plugin install code-review@claude-plugins-official
claude plugin install code-simplifier@claude-plugins-official
claude plugin install diagram-design@diagram-design
claude plugin install document-skills@anthropic-agent-skills
claude plugin install ecc@ecc
claude plugin install example-skills@anthropic-agent-skills
claude plugin install frontend-design@claude-plugins-official
claude plugin install planning-with-files@planning-with-files
claude plugin install ralph-loop@claude-plugins-official
claude plugin install skill-creator@claude-plugins-official
claude plugin install superpowers@claude-plugins-official
claude plugin install ui-ux-pro-max@ui-ux-pro-max-skill

# 本机 diagram-design 是"装了但未启用",要保持一致保留下行,想用它就删掉:
claude plugin disable diagram-design@diagram-design

echo "完成。运行 claude plugin list 核对。"
