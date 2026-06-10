# interview-ai

AI 辅助面试工具集 —— 一体两面：既是面试官的工具箱，也是候选人的准备仓。

## 项目定位

将面试方法论（STAR/BEI、岗位画像、评分标准）封装为可执行的 AI 工作流。同一套知识库、同一套 Slash 命令，支持 **Claude Code**、**Cursor** 与 **DeepSeek GUI** 三端使用：

- **面试官侧**：出题 → 追问 → 面评，辅助完成专业面试全流程
- **候选人侧**：JD 解码 → 人岗对齐 → 定制简历 → 面试准备

## 目录结构

```
├── 共享知识/                    两方共用的方法论与领域知识
│   ├── 领域知识/                AI 产品、AICoding、LLM安全、多模态等
│   └── 面试方法/                面试官手册、人才选拔技巧、JD解读方法
│
├── 面试官/                      作为面试官使用
│   ├── 招聘配置/                岗位画像、评价标准、面试官信息
│   ├── 候选人简历/
│   ├── 面试问答/
│   └── 面试报告/
│
├── 候选人/                      作为应聘者使用
│   ├── 我的材料/                个人简历、周报、项目总结等（跨岗位复用）
│   └── {公司}/                  按公司组织（示例：幻方-DeepSeek/）
│       ├── JD原始/              原始 JD 文件（不改动）
│       │   ├── Agent Harness 产品经理.md
│       │   ├── C端产品经理.md
│       │   └── 模型策略产品经理.md
│       ├── Agent-Harness-PM/    岗位产物目录
│       │   ├── JD人才画像.md    产物① /JD解码
│       │   ├── 对标表.md         产物② /知己
│       │   ├── 定制简历.md       产物③ /简历定制
│       │   └── 面试准备册.md     产物④ /面试准备
│       ├── C端-PM/              另一个岗位
│       └── 模型策略-PM/
│
├── scripts/                    简历导出等本地脚本（见 scripts/README.md）
├── .claude/commands/           Claude Code Slash 命令
├── .cursor/commands/           Cursor Slash 命令（内容与 Claude 版对齐）
└── .deepseek/commands/         DeepSeek GUI Slash 命令（Kun 原生适配）
```

## Slash 命令

两套命令目录内容对齐，在各自 IDE 中通过 `/命令名` 调用。

### 面试官侧

| 命令 | 功能 |
|------|------|
| `/简历生成` | OCR 简历图片 → 标准化 Markdown 简历 |
| `/AI产品问答生成` | 基于简历生成 AI 产品方向结构化面试问答 |
| `/AI技术问答生成` | 基于简历生成 AI 技术方向结构化面试问答 |
| `/面评生成` | 基于面试录音转写 → 结构化证据 → 面试评价报告 |
| `/简历导出PDF` | Markdown 简历 → PDF（需 Node.js） |

### 候选人侧

| 命令 | 功能 | 产物 |
|------|------|------|
| `/JD解码` | JD 反推人才画像 + 同公司多 JD 横向对比 | ① JD人才画像 |
| `/知己` | 收集个人材料 → 逐条对标 → 填表 | ② 对标表 |
| `/简历定制` | 基于对标表生成针对 JD 的定制简历 | ③ 定制简历 |
| `/面试准备` | 预测问题 + STAR 骨架 + 红旗预警 + 缺口策略 | ④ 面试准备册 |
| `/简历导出PDF` | 将 `定制简历.md` 等导出为 PDF | — |

产物链：`/JD解码` → `/知己` → `/简历定制` + `/面试准备` →（可选）`/简历导出PDF`

> **对标表是唯一的信息收集点。** 简历定制和面试准备只是对同一份数据的两种排版——`/知己` 产出的对标表填好后，后面两步不再需要候选人重复提供个人信息。

### 共享知识依赖

Slash 命令依赖以下共享知识文件，修改这些文件会影响对应命令的输出：

| 共享知识 | 依赖的命令 |
|----------|-----------|
| `共享知识/面试方法/03 JD解读方法.md` | `/JD解码` |
| `共享知识/面试方法/01 面试官手册.md` | `/JD解码`、`/知己`、`/面试准备` |
| `共享知识/面试方法/02 人才选拔与面试技巧.md` | `/JD解码`、`/知己`、`/面试准备` |
| `面试官/招聘配置/面试评价标准.md` | `/JD解码`、`/面评生成`、`/面试准备` |

## 使用方式

### Claude Code

1. 克隆本仓库
2. 在仓库目录下启动 [Claude Code](https://claude.ai/code)
3. 执行 `/reload-plugins` 加载 `.claude/commands/` 中的命令
4. 按场景使用对应 Slash 命令

### Cursor

1. 克隆本仓库并用 Cursor 打开
2. 在聊天中输入 `/` 选择 `.cursor/commands/` 中的命令
3. 用 `@` 引用 JD、对标表、简历、面试转写等文件作为输入
4. 按场景使用对应 Slash 命令

### DeepSeek GUI

1. 克隆本仓库并用 DeepSeek GUI 打开
2. 在对话中直接键入 `/命令名 参数...`，Kun 会读取 `.deepseek/commands/` 中的命令并执行
3. 用文件路径（如 `候选人/幻方-DeepSeek/JD.md`）指定输入
4. 按场景使用对应 Slash 命令

> Kun 使用原生工具（read / bash / find / write / edit / web_fetch），命令格式基于 Claude Code 版但使用自有工具名。命令行为与 Claude Code / Cursor 版对齐。

### 调用示例

```text
# 面试官侧
/面评生成 丛思羽 @面试记录/2026-5-15-丛思羽-原始转写.md
/AI产品问答生成 丛思羽

# 首次使用 PDF 导出（克隆后执行一次）
# macOS/Linux: ./scripts/setup.sh
# Windows PowerShell: .\scripts\setup.ps1

# 候选人侧
/JD解码 @候选人/幻方-DeepSeek/JD.md
/知己 @候选人/幻方-DeepSeek/JD人才画像.md @resume/我的简历.md
/简历定制 @候选人/幻方-DeepSeek/对标表.md
/面试准备 @候选人/幻方-DeepSeek/对标表.md
/简历导出PDF @候选人/幻方-DeepSeek/定制简历.md
```

## 命令格式说明

| | Claude Code (`.claude/commands/`) | Cursor (`.cursor/commands/`) | DeepSeek GUI (`.deepseek/commands/`) |
|---|-----------------------------------|-------------------------------|---------------------------------------|
| 元数据 | YAML frontmatter（`description`、`argument-hint`） | 无 frontmatter，正文即指令 | YAML frontmatter（`description`、`argument-hint`） |
| 参数 | `$ARGUMENTS` | 「参数解析」+ `@` 文件引用 | 用户自然语言指定文件路径 |
| 日期 | Bash 注入 `!`date ...`` | 说明用 `Shell` 执行 `date` | `bash date +%Y-%-m-%-d` |
| 读文件 | `Read` | `ReadFile` | `read` |
| 写文件 | `Write` | 编辑工具 | `write` / `edit` |
| 搜索文件 | `Glob` | `Glob` | `find` / `ls` |
| 执行命令 | `Bash` | `Shell` | `bash` |
| 联网 | `WebSearch` | `WebSearch` | `web_fetch` |

修改命令时，建议同步更新三套目录，保持行为一致。

## 环境要求：别人克隆后能否直接用？

| 能力 | 克隆即用？ | 说明 |
|------|------------|------|
| 全部 Slash 命令（出题、面评、JD 解码、简历定制等） | **可以** | 只需 [Cursor](https://cursor.com/)、[Claude Code](https://claude.ai/code) 或 [DeepSeek GUI](https://chat.deepseek.com/download) |
| **`/简历导出PDF`** | **几乎可以** | 克隆后执行环境准备脚本（见下） |

- macOS / Linux / Git Bash：`./scripts/setup.sh`  
- Windows PowerShell：`.\scripts\setup.ps1`（通过 **winget** 自动装 Node）

npm 依赖会在 setup 或首次导出时自动安装。详见 [`scripts/README.md`](scripts/README.md)。

## 其他依赖

- 面试官侧：候选人简历、面试问答计划、面试录音转写
- 候选人侧：JD 原文、个人材料（简历、周报、项目总结等）
