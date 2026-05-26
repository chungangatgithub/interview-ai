# 脚本说明

## 克隆后第一次使用（推荐）

| 系统 | 命令 |
|------|------|
| **macOS / Linux / Git Bash** | `./scripts/setup.sh` |
| **Windows PowerShell** | `.\scripts\setup.ps1` |

会自动完成：

1. **检测 Node.js 18+**；若未安装则尝试自动安装  
   - macOS：`brew install node`  
   - Linux：`apt` / `dnf`（需 sudo）  
   - Windows：`winget install OpenJS.NodeJS.LTS`，或已装 Chocolatey 时用 `choco`  
2. **安装 npm 依赖**（`npm ci`，约 1–3 分钟）

**Windows 说明：** 原生 PowerShell 请用 `setup.ps1`；不要用 bash 版 `setup.sh`（除非已装 Git Bash）。winget 随 Windows 10/11 自带；安装 Node 后若终端仍找不到 `node`，请**关闭并重新打开**终端。

也可跳过 setup，直接导出：首次会尝试自动装依赖。

使用 [nvm](https://github.com/nvm-sh/nvm) 时：`nvm install && nvm use`（见 `.nvmrc`）。

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
