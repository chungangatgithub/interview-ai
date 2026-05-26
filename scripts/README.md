# 脚本说明

## `export-resume.sh` / `export-resume.mjs`

将 Markdown 简历导出为 **PDF**。

```bash
./scripts/export-resume.sh -i path/to/resume.md
./scripts/export-resume.sh -i path/to/resume.md -o ./out
```

### 环境要求

| 依赖 | 说明 |
|------|------|
| **Node.js 18+** | 必需 |
| **首次 `npm install`** | 在 `scripts/` 下自动或手动执行一次 |

```bash
cd scripts && npm install
```

不需要 pandoc、LaTeX。

### 实现

- [md-to-pdf](https://github.com/simonhaenisch/md-to-pdf)（Puppeteer 渲染）
- 样式：`resume-pdf.css`

`scripts/node_modules/` 不提交仓库；`package-lock.json` 会提交以保证版本一致。
