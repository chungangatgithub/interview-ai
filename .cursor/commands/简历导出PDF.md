# 简历导出 PDF

将 Markdown 简历导出为 **PDF**。

> **环境**：克隆后建议先执行 `./scripts/setup.sh`（尽量自动安装 Node.js + npm 依赖）。macOS 需已安装 [Homebrew](https://brew.sh/)。

---

## 参数解析

- **简历文件**：`@` 引用的 `.md`；或按姓名 `Glob` 匹配
- **输出目录**（可选）：`-o`

```text
/简历导出PDF @面试官/候选人简历/2026-5-15-丛思羽.md
/简历导出PDF @候选人/幻方-DeepSeek/定制简历.md
```

---

## 操作步骤

1. 若 `node` 不可用或 `scripts/node_modules` 缺失，先执行 `./scripts/setup.sh`。
2. 解析并定位源 `.md`。
3. 使用 `ReadFile` 确认文件存在。
4. 在项目根目录执行：

```bash
./scripts/export-resume.sh -i "<简历.md路径>" [-o "<输出目录>"]
```

5. 告知用户 `{同名}.pdf` 路径。

---

## 约束

- 不修改源 Markdown。
- 未成功生成时不得声称已完成。
