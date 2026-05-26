#!/usr/bin/env bash
# Markdown 简历 → PDF（Node.js + md-to-pdf）

set -euo pipefail

INPUT=""
OUTPUT_DIR=""

usage() {
  cat <<'EOF'
用法: scripts/export-resume.sh -i <简历.md> [-o <输出目录>]

示例:
  scripts/export-resume.sh -i 面试官/候选人简历/2026-5-15-丛思羽.md

首次使用请先运行: ./scripts/setup.sh
EOF
}

while getopts "i:o:h" opt; do
  case "$opt" in
    i) INPUT="$OPTARG" ;;
    o) OUTPUT_DIR="$OPTARG" ;;
    h) usage; exit 0 ;;
    *) usage; exit 1 ;;
  esac
done

if [[ -z "$INPUT" ]]; then
  echo "错误: 请用 -i 指定 Markdown 简历路径" >&2
  usage
  exit 1
fi

if [[ ! -f "$INPUT" ]]; then
  echo "错误: 文件不存在: $INPUT" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=env.sh
source "$SCRIPT_DIR/env.sh"

ensure_node
ensure_npm_deps

args=(-i "$INPUT")
[[ -n "$OUTPUT_DIR" ]] && args+=(-o "$OUTPUT_DIR")
node "$SCRIPT_DIR/export-resume.mjs" "${args[@]}"
