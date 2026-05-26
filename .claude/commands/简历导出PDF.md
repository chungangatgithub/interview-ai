---
description: 将 Markdown 简历导出为 PDF。克隆后先运行 ./scripts/setup.sh 自动准备 Node 与依赖。
argument-hint: [@简历.md]
---

# 简历导出 PDF

输入：$ARGUMENTS

## 操作步骤

1. 若环境未就绪，先执行 `./scripts/setup.sh`（自动装 Node + npm 依赖，macOS 需 Homebrew）。
2. 解析简历 `.md` 路径。
3. 执行 `./scripts/export-resume.sh -i "<路径>"`。
4. 回报 `.pdf` 路径或错误信息。
