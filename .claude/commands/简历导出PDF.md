---
description: 将 Markdown 简历导出为 PDF。需 Node.js 18+；首次自动 npm install。
argument-hint: [@简历.md]
---

# 简历导出 PDF

输入：$ARGUMENTS

## 操作步骤

1. 解析简历 `.md` 路径。
2. 执行 `./scripts/export-resume.sh -i "<路径>"`（首次会自动 `cd scripts && npm install`）。
3. 回报 `.pdf` 路径或错误信息。

## 环境

需要 **Node.js 18+**。
