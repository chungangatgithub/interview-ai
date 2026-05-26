# 脚本说明

## 克隆后第一次使用（推荐）

```bash
./scripts/setup.sh
```

会自动完成：

1. **检测 Node.js 18+**；若未安装则尝试自动安装  
   - macOS：有 Homebrew 时执行 `brew install node`  
   - Linux：有 apt/dnf 时尝试 `sudo` 安装（需本机权限）  
2. **安装 npm 依赖**（`npm ci`，约 1–3 分钟）

也可跳过 setup，直接导出：首次会尝试自动装依赖；若无 Node 会提示运行 `setup.sh`。

使用 [nvm](https://github.com/nvm-sh/nvm) 时：在仓库根目录执行 `nvm install && nvm use`（见 `.nvmrc`）。

## `export-resume.sh` / `export-resume.mjs`

将 Markdown 简历导出为 **PDF**。

```bash
./scripts/export-resume.sh -i path/to/resume.md
./scripts/export-resume.sh -i path/to/resume.md -o ./out
```

不需要 pandoc、LaTeX。

### 实现

- [md-to-pdf](https://github.com/simonhaenisch/md-to-pdf)（Puppeteer 渲染）
- 样式：`resume-pdf.css`

`scripts/node_modules/` 不提交仓库；`package-lock.json` 会提交以保证版本一致。
