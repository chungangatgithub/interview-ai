# 供 setup.sh、export-resume.sh 共用的环境检测与安装

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[1]:-${BASH_SOURCE[0]}}")" && pwd)"
NODE_MODULES="$SCRIPT_DIR/node_modules"
MIN_NODE_MAJOR=18

node_major_version() {
  node -e "console.log(process.versions.node.split('.')[0])" 2>/dev/null
}

has_usable_node() {
  command -v node >/dev/null 2>&1 &&
    command -v npm >/dev/null 2>&1 &&
    [[ "$(node_major_version)" -ge "$MIN_NODE_MAJOR" ]]
}

install_node_macos() {
  if ! command -v brew >/dev/null 2>&1; then
    echo "未检测到 Homebrew。请先安装：https://brew.sh/" >&2
    return 1
  fi
  echo "正在通过 Homebrew 安装 Node.js（可能需要几分钟）…" >&2
  brew install node
}

install_node_linux() {
  if command -v apt-get >/dev/null 2>&1; then
    echo "尝试通过 apt 安装 nodejs、npm（需要 sudo）…" >&2
    sudo apt-get update -qq
    sudo apt-get install -y nodejs npm
    return $?
  fi
  if command -v dnf >/dev/null 2>&1; then
    echo "尝试通过 dnf 安装 nodejs、npm（需要 sudo）…" >&2
    sudo dnf install -y nodejs npm
    return $?
  fi
  return 1
}

# 尝试自动安装 Node.js（仅 macOS/Homebrew 默认可无人值守；Linux 需 sudo）
try_install_node() {
  case "$(uname -s)" in
    Darwin) install_node_macos ;;
    Linux) install_node_linux ;;
    *)
      echo "当前系统请手动安装 Node.js ${MIN_NODE_MAJOR}+：https://nodejs.org/" >&2
      return 1
      ;;
  esac
}

ensure_node() {
  if has_usable_node; then
    return 0
  fi

  if [[ "${AUTO_INSTALL_NODE:-1}" == "1" ]]; then
    try_install_node || true
  fi

  if has_usable_node; then
    echo "Node.js $(node -v) 已就绪" >&2
    return 0
  fi

  cat >&2 <<EOF
错误: 需要 Node.js ${MIN_NODE_MAJOR}+ 与 npm。

可选方案：
  1. 运行一键环境准备: ./scripts/setup.sh
  2. macOS: brew install node
  3. 官网安装包: https://nodejs.org/
  4. 使用 nvm: 仓库根目录有 .nvmrc，可执行 nvm install && nvm use
EOF
  return 1
}

ensure_npm_deps() {
  if [[ -d "$NODE_MODULES/md-to-pdf" ]]; then
    return 0
  fi
  ensure_node || return 1
  echo "正在安装 PDF 导出依赖（约 1–3 分钟，仅需一次）…" >&2
  if [[ -f "$SCRIPT_DIR/package-lock.json" ]]; then
    (cd "$SCRIPT_DIR" && npm ci --omit=dev --no-fund --no-audit)
  else
    (cd "$SCRIPT_DIR" && npm install --omit=dev --no-fund --no-audit)
  fi
}
