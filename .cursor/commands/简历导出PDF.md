# 简历导出 PDF

将 Markdown 简历导出为 **PDF**。

> **环境**：本机需 **Node.js 18+**。首次导出会自动在 `scripts/` 安装 npm 依赖；也可预先执行 `cd scripts && npm install`。

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

1. 解析并定位源 `.md`。
2. 使用 `ReadFile` 确认文件存在。
3. 在项目根目录执行：

```bash
./scripts/export-resume.sh -i "<简历.md路径>" [-o "<输出目录>"]
```

4. 告知用户 `{同名}.pdf` 路径。

---

## 约束

- 不修改源 Markdown。
- 未成功生成时不得声称已完成。
