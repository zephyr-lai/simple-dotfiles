#!/bin/bash
# 新机器恢复 Claude Code 插件环境
# 使用: ./tools/claude-restore.sh
# 幂等：已注册的 marketplace / 已安装的插件自动跳过
set -e

# 自定义 marketplace（官方 marketplace 内置，无需注册）
# 格式: name|github repo
MARKETPLACES=(
    "planning-with-files|OthmanAdi/planning-with-files"
    "ui-ux-pro-max-skill|nextlevelbuilder/ui-ux-pro-max-skill"
    "anthropic-agent-skills|anthropics/skills"
    "karpathy-skills|forrestchang/andrej-karpathy-skills"
)

# 插件清单: plugin@marketplace
PLUGINS=(
    "superpowers@claude-plugins-official"
    "code-review@claude-plugins-official"
    "code-simplifier@claude-plugins-official"
    "ralph-loop@claude-plugins-official"
    "frontend-design@claude-plugins-official"
    "skill-creator@claude-plugins-official"
    "planning-with-files@planning-with-files"
    "ui-ux-pro-max@ui-ux-pro-max-skill"
    "example-skills@anthropic-agent-skills"
    "document-skills@anthropic-agent-skills"
    "andrej-karpathy-skills@karpathy-skills"
)

command -v claude >/dev/null 2>&1 || { echo "[error] claude CLI not found"; exit 1; }

# === marketplace ===
existing_mkts=$(claude plugin marketplace list 2>/dev/null || true)
for entry in "${MARKETPLACES[@]}"; do
    name="${entry%%|*}"
    repo="${entry##*|}"
    if echo "$existing_mkts" | grep -q "$name"; then
        echo "==> marketplace $name (already added)"
        continue
    fi
    echo "==> marketplace add $name ($repo)"
    claude plugin marketplace add "$repo" || echo "  [warn] failed to add $name"
done

# === plugins ===
installed=$(claude plugin list 2>/dev/null || true)
for plugin in "${PLUGINS[@]}"; do
    if echo "$installed" | grep -q "$plugin"; then
        echo "==> plugin $plugin (already installed)"
        continue
    fi
    echo "==> plugin install $plugin"
    claude plugin install "$plugin" || echo "  [warn] failed: $plugin"
done

echo ""
echo "Done. 重启 Claude Code 后插件生效。"
