#!/usr/bin/env bash
# 克隆仓库后执行一次：尽量自动安装 Node.js（若缺失）+ npm 依赖

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=env.sh
source "$SCRIPT_DIR/env.sh"

echo "==> 检查 Node.js …"
ensure_node

echo "==> 安装 PDF 导出依赖 …"
ensure_npm_deps

echo ""
echo "环境已就绪。导出示例："
echo "  ./scripts/export-resume.sh -i 面试官/候选人简历/2026-5-15-丛思羽.md"
echo "或在 Cursor 中使用: /简历导出PDF @你的简历.md"
