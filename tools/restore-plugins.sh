#!/usr/bin/env bash
# Claude Code 插件清单 + 一键恢复脚本(唯一来源) — 清单生成于 2026-09-24
# 来源:~/.claude/plugins/{installed_plugins,known_marketplaces}.json(不含任何密钥)
# 用法:新机器装好 Claude Code 后,运行 bash restore-plugins.sh
# 维护:新装/停用插件后直接改本文件,勿另建 md 清单
set -euo pipefail

echo "== 添加插件市场 (7) =="
claude plugin marketplace add anthropics/claude-plugins-official    # Anthropic 官方市场
claude plugin marketplace add anthropics/skills                     # 官方 agent skills 合集
claude plugin marketplace add OthmanAdi/planning-with-files         # 计划文件工作流
claude plugin marketplace add nextlevelbuilder/ui-ux-pro-max-skill  # UI/UX 设计 skill
claude plugin marketplace add https://github.com/affaan-m/ECC.git   # ECC 工程插件集
claude plugin marketplace add forrestchang/andrej-karpathy-skills   # Karpathy 风格 skills
claude plugin marketplace add cathrynlavery/diagram-design          # 图表/示意图设计

echo "== 安装插件 (13,install 默认即启用) =="
claude plugin install andrej-karpathy-skills@karpathy-skills        # Karpathy 风格编码 guidelines
claude plugin install code-review@claude-plugins-official           # 代码审查
claude plugin install code-simplifier@claude-plugins-official       # 代码简化重构
claude plugin install diagram-design@diagram-design                 # 图表/示意图设计
claude plugin install document-skills@anthropic-agent-skills        # Office 文档处理(xlsx/docx/pptx/pdf)
claude plugin install ecc@ecc                                       # 大型工程插件集(67 agents/282 skills,自带 hooks)
claude plugin install example-skills@anthropic-agent-skills         # 官方示例 skills(webapp-testing、mcp-builder 等)
claude plugin install frontend-design@claude-plugins-official       # 前端设计
claude plugin install planning-with-files@planning-with-files       # 计划文件工作流(/plan、/status 等命令)
claude plugin install ralph-loop@claude-plugins-official            # 自主循环执行
claude plugin install skill-creator@claude-plugins-official         # 创建新 skill
claude plugin install superpowers@claude-plugins-official           # 结构化工作流 skill 集(TDD、系统化调试、写计划等)
claude plugin install ui-ux-pro-max@ui-ux-pro-max-skill             # UI/UX 设计 skill

# 本机 diagram-design 是"装了但未启用",要保持一致保留下行,想用它就删掉:
claude plugin disable diagram-design@diagram-design

echo "完成。运行 claude plugin list 核对。"
