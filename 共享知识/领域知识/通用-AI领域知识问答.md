# AI 领域通用知识问答

**适用岗位**：AI 应用开发工程师  
**问答设计原则**：按难度梯度递进（⭐ 入门 → ⭐⭐ 初级 → ⭐⭐⭐ 中级 → ⭐⭐⭐⭐ 高级 → ⭐⭐⭐⭐⭐ 专家）

---

## 目录

1. [LLM 大模型基础](#一llm-大模型基础)
2. [RAG 检索增强生成](#二rag-检索增强生成)
3. [Agent 智能体](#三agent-智能体)
4. [MCP 协议](#四mcp-协议)
5. [模型微调](#五模型微调)
6. [AI Infra 基础设施](#六ai-infra-基础设施)
7. [Prompt 工程](#七prompt-工程)

---

## 一、LLM 大模型基础

### Q1.1 Transformer 架构 ⭐⭐

**问题**：
> 请简单介绍一下 Transformer 架构的核心组件，为什么它比 RNN/LSTM 更适合处理长序列？

**期望答案**：

**核心组件**：
| 组件 | 作用 |
|------|------|
| Self-Attention | 计算序列中每个位置与其他位置的关联权重，捕获全局依赖 |
| Multi-Head Attention | 多个注意力头并行学习不同的关注模式 |
| Feed-Forward Network | 对每个位置独立进行非线性变换 |
| Positional Encoding | 注入位置信息（Transformer 本身不感知顺序） |
| Layer Normalization | 稳定训练，加速收敛 |

**优于 RNN/LSTM 的原因**：
1. **并行计算**：RNN 必须按顺序处理，Transformer 可以并行处理所有位置
2. **长距离依赖**：RNN 的梯度消失问题使其难以捕获长距离依赖，Self-Attention 直接建模任意两个位置的关系
3. **计算效率**：在 GPU 上，Transformer 的矩阵运算效率远高于 RNN 的循环操作

**评分要点**：
- 3 分：能说出 Self-Attention 是核心
- 4 分：能解释并行计算和长距离依赖优势
- 5 分：能深入讲解 Multi-Head Attention 机制

---

### Q1.2 大模型推理优化技术 ⭐⭐⭐

**问题**：
> 大模型推理时，常用的优化技术有哪些？请解释 KV Cache 和 PagedAttention 的原理。

**期望答案**：

**常用推理优化技术**：

| 技术 | 原理 | 效果 |
|------|------|------|
| **KV Cache** | 缓存已计算的 Key/Value，生成新 Token 时只计算增量 | 避免重复计算，显著提升吞吐 |
| **PagedAttention** | 借鉴操作系统虚拟内存机制，将 KV Cache 分页管理 | 减少显存碎片，提高 GPU 利用率 |
| **Continuous Batching** | 动态组批，请求完成后立即填入新请求 | 提高 GPU 利用率 |
| **量化（INT8/INT4）** | 降低权重精度 | 减少显存占用和计算量 |
| **投机采样（Speculative Decoding）** | 小模型预测多个 Token，大模型验证 | 提升生成速度 |
| **FlashAttention** | 优化 Attention 计算的内存访问模式 | 减少显存占用，加速计算 |

**KV Cache 详解**：
- 自回归生成时，每生成一个新 Token，需要与所有历史 Token 做 Attention
- KV Cache 将历史 Token 的 Key/Value 缓存，新 Token 只需计算自己的 Q/K/V
- 问题：长序列时 KV Cache 占用大量显存

**PagedAttention 详解**（vLLM 核心技术）：
- 传统方式：为每个请求预分配连续显存，造成碎片
- PagedAttention：将 KV Cache 分成固定大小的"页"，按需分配
- 类似操作系统虚拟内存管理，支持 Copy-on-Write
- 效果：显存利用率提升 2-4 倍，支持更大批量并发

**评分要点**：
- 3 分：知道 KV Cache 的作用
- 4 分：能解释 PagedAttention 原理
- 5 分：能对比多种优化技术并讲清适用场景

---

### Q1.3 vLLM vs Triton Inference Server ⭐⭐⭐⭐

**问题**：
> vLLM 和 Triton Inference Server 有什么区别？分别适合什么场景？

**期望答案**：

**核心定位差异**：
- **vLLM**：专注于 LLM 的高性能推理**引擎**
- **Triton**：通用的企业级模型**服务平台**，可集成多种后端（包括 vLLM）

**对比**：

| 维度 | vLLM | Triton Inference Server |
|------|------|-------------------------|
| **定位** | LLM 专用推理引擎 | 通用模型服务平台 |
| **核心技术** | PagedAttention、Continuous Batching | TensorRT-LLM、Ensemble Models |
| **易用性** | Python 原生，快速上手 | 配置复杂，学习曲线陡 |
| **量化支持** | GPTQ、AWQ、GGUF 等开源格式 | TensorRT 优化，FP8 支持 |
| **多模型** | 主要针对 LLM | 支持多模态 Pipeline |
| **部署方式** | 独立部署或集成 | 企业级部署，支持 K8s |

**组合使用**：
- Triton 可以将 vLLM 作为后端，兼得两者优势
- vLLM 负责高效推理，Triton 提供企业级服务能力（负载均衡、监控、多模型管理）

**适用场景**：
- **选 vLLM**：快速开发、纯 LLM 场景、需要灵活量化
- **选 Triton**：企业级部署、多模态 Pipeline、需要深度 NVIDIA GPU 优化
- **组合**：大规模生产环境，用 Triton + vLLM 后端

**评分要点**：
- 3 分：知道两者都是推理方案
- 4 分：能说清定位差异和各自优势
- 5 分：能讲清组合使用场景和技术细节

---

## 二、RAG 检索增强生成

### Q2.1 RAG 基本流程 ⭐⭐

**问题**：
> 请介绍 RAG（Retrieval-Augmented Generation）的基本工作流程。

**期望答案**：

**RAG 基本流程**：

```
用户问题 → Embedding → 向量检索 → Top-K 文档 → 构建 Prompt → LLM 生成 → 回答
```

**详细步骤**：

| 阶段 | 操作 | 技术组件 |
|------|------|----------|
| 1. 文档预处理 | 文档分块（Chunking） | 固定长度/语义分块 |
| 2. 向量化 | 文档块 → Embedding 向量 | BGE、OpenAI Embedding |
| 3. 索引存储 | 向量存入向量数据库 | Milvus、Faiss、Pinecone |
| 4. 查询向量化 | 用户问题 → Embedding | 同上 |
| 5. 相似度检索 | 检索 Top-K 相关文档 | ANN 近似最近邻 |
| 6. Prompt 构建 | 拼接检索结果 + 问题 | Prompt Template |
| 7. LLM 生成 | 基于上下文生成回答 | GPT、Qwen、Claude |

**核心优势**：
1. **知识更新**：无需重新训练模型，更新知识库即可
2. **减少幻觉**：回答有据可查，可溯源
3. **成本低**：比微调便宜，适合领域知识注入

**评分要点**：
- 3 分：能说清检索 + 生成的基本流程
- 4 分：能列举核心技术组件
- 5 分：能解释 RAG 解决了什么问题

---

### Q2.2 RAG 优化策略 ⭐⭐⭐

**问题**：
> RAG 系统的准确率不高时，有哪些常见的优化策略？

**期望答案**：

**RAG 优化策略全景**：

| 阶段 | 优化策略 | 说明 |
|------|----------|------|
| **检索前** | Query 改写 | 扩展/重写用户问题，提升召回 |
| | HyDE | 先让 LLM 生成假设答案，用假设答案做检索 |
| | Query 分解 | 复杂问题拆成多个子问题 |
| **检索中** | 混合检索 | 向量检索 + 关键词检索（BM25）结合 |
| | 多路召回 | 不同 Embedding 模型并行召回 |
| | 元数据过滤 | 按时间、类别等元数据预过滤 |
| **检索后** | Reranker 重排序 | 使用交叉编码器对召回结果精排 |
| | 上下文压缩 | 去除无关内容，保留关键信息 |
| **分块策略** | 语义分块 | 按段落/章节分块，保持语义完整 |
| | 层次化分块 | 父子块结构，支持 Small-to-Big |
| | 重叠分块 | Chunk 间设置 overlap，避免切断语义 |
| **索引优化** | 多级索引 | 先粗检索再精检索 |
| | 摘要索引 | 先检索摘要，再定位原文 |

**重点优化技术**：

**1. 混合检索（Hybrid Search）**：
- 向量检索：语义相似度高，但可能漏掉关键词
- 关键词检索（BM25）：精确匹配专业术语
- 融合策略：RRF（Reciprocal Rank Fusion）或加权合并

**2. Reranker 重排序**：
- 召回阶段追求高召回率（如 Top-100）
- Reranker 用交叉编码器对 Query-Document 对打分
- 输出精排后的 Top-K（如 Top-5）

**评分要点**：
- 3 分：能说出 2-3 种优化策略
- 4 分：能解释混合检索或重排序原理
- 5 分：能系统性讲解检索前/中/后的优化

---

### Q2.3 RAG 评估指标 ⭐⭐⭐⭐

**问题**：
> 如何评估 RAG 系统的效果？常用的评估指标有哪些？RAGAS 和 ARES 框架有什么区别？

**期望答案**：

**RAG 评估维度**：

| 维度 | 指标 | 说明 |
|------|------|------|
| **检索质量** | Context Recall | 检索到的上下文是否包含回答所需的全部信息 |
| | Context Precision | 检索到的上下文中，相关内容的占比 |
| | Hit Rate | Top-K 中是否命中正确文档 |
| | MRR（Mean Reciprocal Rank） | 正确文档在排序中的平均倒数位置 |
| | NDCG | 考虑位置权重的排序质量 |
| **生成质量** | Answer Relevancy | 生成答案与用户问题的相关程度 |
| | Faithfulness | 答案是否忠实于检索到的上下文（无幻觉） |
| | Answer Correctness | 答案是否正确（需要标准答案） |

**RAGAS vs ARES**：

| 维度 | RAGAS | ARES |
|------|-------|------|
| **评估方式** | 固定 Prompt 模板 + LLM 打分 | 训练专用 LLM Judge |
| **适应性** | 通用但不够灵活 | 可针对特定领域微调 |
| **人工标注** | 不需要 | 需要少量人工标注（~数百条） |
| **跨域能力** | 一般 | 更好的域迁移能力 |
| **准确性** | 受 Prompt 质量影响 | 更高精度 |

**ARES 核心创新**（NAACL 2024）：
1. 自动生成合成训练数据
2. 为每个 RAG 组件微调专用 LLM Judge
3. 使用 PPI（Prediction-Powered Inference）校正预测误差

**评估最佳实践**：
1. 自动评估（RAGAS/ARES）+ 人工抽样校验
2. 分别评估检索质量和生成质量
3. 建立基线，持续迭代监控

**评分要点**：
- 3 分：知道需要评估检索和生成两个环节
- 4 分：能说出 Faithfulness、Context Recall 等核心指标
- 5 分：能对比 RAGAS 和 ARES 的差异

---

### Q2.4 生产级 RAG 的工程化最佳实践 ⭐⭐⭐⭐

**问题**：
> 如果要把一个 RAG 系统真正上线到生产环境，除了“能检索到内容”之外，你还会重点关注哪些工程化问题？如何设计一套可持续迭代的 RAG 架构？

**期望答案**：

**生产级 RAG 的六个核心维度**：

| 维度 | 最佳实践 | 说明 |
|------|----------|------|
| **数据摄入** | 结构化清洗 + 文档标准化 | 统一标题、正文、标签、时间、来源，去噪、去重、去模板噪声 |
| **分块策略** | 按文档类型定制 Chunking | FAQ、商品、制度文档、技术文档应采用不同的 Chunk 大小和 overlap |
| **增量更新** | CDC/MQ + 内容哈希 + 版本号 | 只重算变更 Chunk，避免全量重建 |
| **检索增强** | 混合检索 + Reranker + 元数据过滤 | 先追求 Recall，再做精排 |
| **生成控制** | 引用来源 + 上下文压缩 + 无答案兜底 | 降低幻觉，提升可解释性 |
| **评估运维** | 离线评估 + 在线监控 + 回归测试 | 持续监控 Recall、Faithfulness、延迟、成本、新鲜度 |

**关键工程化实践**：

1. **数据预处理要前移**：
   - 先做文档清洗、结构化抽取、字段标准化，再进入分块和 Embedding
   - 对商品、工单、FAQ 等结构化数据，优先构造成固定模板文本，减少冗余描述导致的召回漂移

2. **分块不能一刀切**：
   - 技术文档适合语义分块 + overlap
   - 商品/FAQ 适合结构化小块，通常一条记录对应 1～数个 Chunk
   - 复杂长文档可采用父子块（Parent-Child）或 Small-to-Big 检索

3. **增量更新链路要可追踪、可回放**：
   - 用 CDC / MQ 监听源数据变更
   - 通过 `source_id`、`chunk_id`、`content_hash`、`doc_version` 标识数据版本
   - 只对内容变化的 Chunk 重新计算 Embedding，未变化部分直接复用缓存结果

4. **检索链路要分层优化**：
   - 第一层：向量检索 / 混合检索尽量提高 Recall
   - 第二层：Reranker 做精排
   - 第三层：按权限、时间、品类、语言等元数据过滤
   - 必要时再做 Contextual Compression（上下文压缩）

5. **生成阶段要做回答约束**：
   - Prompt 中要求“仅基于检索结果回答”
   - 没有足够证据时明确回答“知识库暂无依据”
   - 输出中保留引用片段或来源 ID，便于追踪和人工复核

6. **要区分离线评估和在线观测**：
   - 离线：Golden Set、RAGAS/ARES、人工抽检
   - 在线：Hit Rate、无结果率、首 Token 延迟、整体延迟、Token 成本、知识新鲜度

**常见误区**：
1. 只关注 LLM 模型本身，忽略数据清洗和 Chunking 质量
2. 只做向量检索，不做 BM25 / Reranker，导致专业术语召回差
3. 每次源数据变更都全量重建 Embedding，成本高且更新慢
4. 更新时直接删旧数据再写新数据，产生查询空窗期
5. 只有离线 Demo，没有线上监控、回归测试和回滚机制

**评分要点**：
- 3 分：能说出分块、检索、评估等几个核心环节
- 4 分：能系统性覆盖数据摄入、检索、生成、评估、运维
- 5 分：能给出增量更新、版本管理、观测指标等生产级方案

---

## 三、Agent 智能体

### Q3.1 Agent 基本概念 ⭐⭐

**问题**：
> 什么是 AI Agent？它与普通的 LLM 对话有什么区别？

**期望答案**：

**AI Agent 定义**：
AI Agent 是一个能够感知环境、自主决策、采取行动并从反馈中学习的智能系统。在 LLM 时代，Agent = LLM + 记忆 + 工具 + 规划能力。

**Agent vs 普通 LLM 对话**：

| 维度 | 普通 LLM 对话 | AI Agent |
|------|---------------|----------|
| **能力边界** | 仅基于训练数据回答 | 可调用外部工具获取实时信息 |
| **任务复杂度** | 单轮问答 | 多步骤复杂任务分解执行 |
| **记忆** | 无状态或短期上下文 | 短期记忆 + 长期记忆 |
| **自主性** | 被动响应 | 主动规划、自主决策 |
| **与环境交互** | 无 | 读写数据库、调用 API、执行代码 |

**Agent 核心组件**：
1. **LLM（大脑）**：理解、推理、决策
2. **Memory（记忆）**：短期（对话历史）+ 长期（用户画像）
3. **Tools（工具）**：搜索、数据库、API、代码执行等
4. **Planning（规划）**：任务分解、目标追踪

**评分要点**：
- 3 分：知道 Agent 可以调用工具
- 4 分：能说清 Agent 的核心组件
- 5 分：能对比 Agent 与普通对话的本质区别

---

### Q3.2 多 Agent 框架对比 ⭐⭐⭐⭐

**问题**：
> 目前主流的多 Agent 框架有 LangGraph、CrewAI、AutoGen，它们有什么区别？分别适合什么场景？

**期望答案**：

**框架对比**：

| 维度 | LangGraph | CrewAI | AutoGen |
|------|-----------|--------|---------|
| **开发者** | LangChain 团队 | CrewAI Inc. | Microsoft |
| **架构模式** | 图（Graph）驱动 | 角色（Role）驱动 | 对话（Conversation）驱动 |
| **核心抽象** | 节点 + 边 + 状态 | Agent + Task + Crew | Agent + 多轮对话 |
| **状态管理** | 强（显式状态图） | 中等 | 弱 |
| **学习曲线** | 中等 | 简单 | 复杂 |
| **生产就绪** | 优秀 | 良好 | 一般 |
| **调试能力** | 强（可视化状态图） | 中等 | 弱 |

**适用场景**：

**LangGraph**：
- 复杂工作流，需要精细控制流程分支
- 需要强状态管理和持久化
- 生产级应用，需要可追溯和可调试
- 示例：金融审批流程、医疗诊断系统

**CrewAI**：
- 角色分工明确的团队协作场景
- 快速原型开发
- 内容生成、市场研究
- 示例：内容创作团队、客服协作

**AutoGen**：
- 多 Agent 对话式协作
- 代码生成和执行
- 研究和数据分析
- 示例：代码 Review、数据探索

**选型建议**：
```
需要精细控制 + 生产部署 → LangGraph
快速原型 + 角色分工 → CrewAI
对话协作 + 代码执行 → AutoGen
```

**评分要点**：
- 3 分：知道有多个框架存在
- 4 分：能说清各框架的核心差异
- 5 分：能结合具体场景给出选型建议

---

### Q3.3 Agent 状态管理 ⭐⭐⭐⭐⭐

**问题**：
> 在多 Agent 系统中，如何设计状态管理？LangGraph 的状态机制是如何工作的？

**期望答案**：

**为什么需要状态管理**：
- 多步骤任务需要跟踪执行进度
- Agent 间需要共享上下文
- 支持中断恢复、回退、人工介入
- 便于调试和审计

**LangGraph 状态机制**：

```python
from typing import TypedDict, Annotated
from langgraph.graph import StateGraph
from operator import add

# 1. 定义状态结构
class AgentState(TypedDict):
    messages: Annotated[list, add]  # 消息累加
    current_step: str               # 当前步骤
    context: dict                   # 共享上下文
    iteration_count: int            # 迭代计数

# 2. 定义节点（Agent）
def planner_node(state: AgentState) -> AgentState:
    # 规划逻辑
    return {"current_step": "execute", "context": {...}}

def executor_node(state: AgentState) -> AgentState:
    # 执行逻辑
    return {"current_step": "review", "messages": [...]}

# 3. 定义边（转换条件）
def should_continue(state: AgentState) -> str:
    if state["iteration_count"] > 3:
        return "end"
    if needs_review(state):
        return "review"
    return "execute"

# 4. 构建图
graph = StateGraph(AgentState)
graph.add_node("plan", planner_node)
graph.add_node("execute", executor_node)
graph.add_node("review", reviewer_node)

graph.add_edge("plan", "execute")
graph.add_conditional_edges("execute", should_continue)
```

**状态管理最佳实践**：

| 实践 | 说明 |
|------|------|
| 状态不可变 | 每个节点返回新状态，不修改原状态 |
| 状态持久化 | 使用 Checkpointer 保存状态，支持恢复 |
| 状态压缩 | 长对话时压缩历史，避免 Token 溢出 |
| 版本控制 | 状态结构变更时兼容旧版本 |
| 审计日志 | 记录每次状态变更，便于追溯 |

**Human-in-the-Loop**：
```python
# 在关键节点暂停，等待人工确认
graph.add_node("human_approval", interrupt_before=True)
```

**评分要点**：
- 3 分：知道需要状态管理
- 4 分：能描述 LangGraph 的状态传递方式
- 5 分：能写出状态定义和条件路由的代码

---

## 四、MCP 协议

### Q4.1 MCP 基本概念 ⭐⭐⭐

**问题**：
> 什么是 MCP（Model Context Protocol）？它解决了什么问题？

**期望答案**：

**MCP 定义**：
MCP（Model Context Protocol）是 Anthropic 于 2024 年 11 月开源的协议标准，用于规范 AI 模型与外部数据源、工具的交互方式。可以类比为"AI 应用的 USB-C 接口"。

**解决的问题**：

| 问题 | 传统方式 | MCP 方式 |
|------|----------|----------|
| 工具集成 | 每个 AI 应用单独开发集成 | 标准化协议，一次开发多处复用 |
| 数据连接 | 碎片化的自定义 API | 统一的数据访问接口 |
| 上下文管理 | 各应用自行处理 | 协议层面标准化 |

**核心架构**：

```
┌─────────────┐     MCP Protocol      ┌─────────────┐
│  MCP Client │ ◄──────────────────► │  MCP Server │
│  (AI 模型)   │                      │  (工具/数据) │
└─────────────┘                       └─────────────┘
```

- **MCP Client**：AI 模型/应用，请求上下文和工具
- **MCP Server**：提供数据、工具、资源的服务端
- **Protocol**：标准化的通信协议

**MCP vs Function Calling**：

| 维度 | Function Calling | MCP |
|------|------------------|-----|
| 标准化 | 各厂商实现不同 | 开放标准 |
| 工具发现 | 需手动配置 | 动态发现 |
| 多工具管理 | 简单列表 | 结构化资源管理 |
| 复用性 | 与特定模型绑定 | 跨模型复用 |

**生态支持**：
- 官方 SDK：TypeScript、Python、Java、Kotlin、Go、Rust 等
- 预置 Server：GitHub、Slack、Google Drive、Postgres 等
- 早期采用者：Block、Replit、Codeium、Sourcegraph

**评分要点**：
- 3 分：知道 MCP 是工具调用协议
- 4 分：能解释 MCP 与 Function Calling 的区别
- 5 分：能讲清 Client/Server 架构和生态

---

### Q4.2 MCP 工具开发 ⭐⭐⭐⭐

**问题**：
> 如何开发一个 MCP Server？请描述主要步骤和核心概念。

**期望答案**：

**MCP Server 核心概念**：

| 概念 | 说明 | 示例 |
|------|------|------|
| **Resources** | 暴露数据资源 | 文件内容、数据库记录 |
| **Tools** | 可执行的操作 | 查询 API、执行命令 |
| **Prompts** | 预定义的提示模板 | 代码审查模板 |

**开发步骤（Python）**：

```python
from mcp.server import Server
from mcp.types import Tool, TextContent

# 1. 创建 Server 实例
server = Server("my-mcp-server")

# 2. 定义工具
@server.tool()
async def search_database(query: str) -> list[TextContent]:
    """
    搜索数据库
    
    Args:
        query: 搜索关键词
    """
    results = await db.search(query)
    return [TextContent(type="text", text=str(results))]

# 3. 定义资源
@server.resource("config://settings")
async def get_settings() -> str:
    """获取系统配置"""
    return json.dumps(settings)

# 4. 启动 Server
if __name__ == "__main__":
    server.run()
```

**工具定义最佳实践**：

1. **清晰的描述**：让 LLM 知道何时使用这个工具
2. **参数校验**：使用类型注解和 Pydantic
3. **错误处理**：返回有意义的错误信息
4. **幂等性**：工具调用应尽量幂等

**部署方式**：
- 本地运行：Claude Desktop 直接连接
- 远程部署：通过 HTTP/WebSocket 暴露

**评分要点**：
- 3 分：知道 MCP Server 的作用
- 4 分：能描述 Tools/Resources 概念
- 5 分：能写出工具定义代码

---

## 五、模型微调

### Q5.1 微调方法选择 ⭐⭐⭐

**问题**：
> 什么情况下需要微调大模型？微调有哪些方法？如何选择？

**期望答案**：

**何时需要微调**：
| 场景 | 是否微调 | 替代方案 |
|------|----------|----------|
| 需要领域专业知识 | 可能需要 | 先试 RAG |
| 需要特定输出格式 | 通常需要 | Few-shot Prompt |
| 需要降低延迟/成本 | 小模型微调 | 模型量化 |
| 基座模型效果够好 | 不需要 | Prompt Engineering |

**微调方法对比**：

| 方法 | 原理 | 显存需求 | 效果 | 适用场景 |
|------|------|----------|------|----------|
| **Full Fine-tuning** | 更新全部参数 | 极高 | 最好 | 小模型、资源充足 |
| **LoRA** | 低秩矩阵分解 | 低 | 接近全量 | 主流选择 |
| **QLoRA** | LoRA + 4bit 量化 | 更低 | 略低于 LoRA | 资源受限 |
| **DoRA** | 分解权重为幅度+方向 | 同 LoRA | 优于 LoRA | 追求效果 |
| **Prefix Tuning** | 学习虚拟前缀 | 很低 | 较弱 | 多任务场景 |

**LoRA 关键参数**：
| 参数 | 说明 | 推荐值 |
|------|------|--------|
| rank (r) | 低秩矩阵的秩 | 8-64 |
| alpha | 缩放系数 | 通常 = 2 × rank |
| target_modules | 微调的模块 | q_proj, v_proj |
| dropout | 防止过拟合 | 0.05-0.1 |

**选择建议**：
```
资源充足 + 追求效果 → Full Fine-tuning 或 DoRA
资源有限 + 效果要求高 → LoRA
资源极度有限 → QLoRA
多任务共享基座 → Prefix Tuning
```

**评分要点**：
- 3 分：知道 LoRA 是主流方法
- 4 分：能解释 LoRA 的原理
- 5 分：能对比多种方法并给出选型建议

---

### Q5.2 SFT vs RLHF vs DPO ⭐⭐⭐⭐

**问题**：
> 请解释 SFT、RLHF、DPO 三种训练方法的区别，分别适合什么场景？

**期望答案**：

**三种方法对比**：

| 维度 | SFT（监督微调） | RLHF（强化学习） | DPO（直接偏好优化） |
|------|----------------|------------------|---------------------|
| **训练数据** | (prompt, response) 对 | 偏好数据 + Reward Model | 偏好数据 (chosen, rejected) |
| **训练流程** | 直接学习 | RM 训练 → PPO 优化 | 直接优化 |
| **复杂度** | 简单 | 复杂（4 个模型） | 中等（2 个模型） |
| **稳定性** | 稳定 | 不稳定 | 稳定 |
| **效果上限** | 一般 | 高 | 接近 RLHF |

**训练流程图**：

```
预训练模型
    │
    ▼
SFT（监督微调）────────► SFT 模型
    │                      │
    ▼                      ▼
RLHF                     DPO
├── 训练 Reward Model     │
├── PPO 优化              │ 直接优化
└── 需要 4 个模型         └── 只需 2 个模型
    │                      │
    ▼                      ▼
对齐后的模型              对齐后的模型
```

**DPO 核心原理**：
- 将 RLHF 的目标函数转化为直接优化问题
- 无需训练 Reward Model
- 数学上等价于 RLHF，但实现更简单

**适用场景**：
- **SFT**：让模型学会特定任务、格式、风格
- **RLHF**：追求极致对齐效果，有足够资源
- **DPO**：想要对齐效果但资源有限

**偏好数据构建**：
```json
{
  "prompt": "如何学习编程？",
  "chosen": "首先选择一门语言，如 Python，然后...",
  "rejected": "编程很简单，随便学学就会了"
}
```

**评分要点**：
- 3 分：知道三种方法的名称和大致区别
- 4 分：能解释 DPO 相比 RLHF 的优势
- 5 分：能讲清训练流程和适用场景

---

## 六、AI Infra 基础设施

### Q6.1 KServe 推理平台 ⭐⭐⭐

**问题**：
> 什么是 KServe？它相比直接用 K8s Deployment 部署模型有什么优势？

**期望答案**：

**KServe 定义**：
KServe 是 CNCF 孵化项目，为 Kubernetes 提供标准化、分布式的 AI 模型推理平台，支持 Serverless 弹性伸缩。

**KServe vs 原生 K8s Deployment**：

| 维度 | K8s Deployment | KServe |
|------|----------------|--------|
| **弹性伸缩** | 需自行配置 HPA | 原生支持 Scale-to-Zero |
| **GPU 利用率** | 常驻 Pod 浪费资源 | 无请求时自动缩容 |
| **模型版本管理** | 需自行实现 | 内置 Canary/A-B 发布 |
| **多框架支持** | 需为每个框架写部署配置 | 统一 CRD，支持 TF/PyTorch/Triton |
| **推理图编排** | 不支持 | InferenceGraph 支持多模型串联 |
| **监控** | 需集成 | 内置 metrics |

**KServe 架构**：
```
用户请求 → Istio Gateway → Knative Serving → 推理 Pod
                              │
                              ▼
                         自动扩缩容（0 → N）
```

**核心功能**：
1. **Serverless 推理**：基于 Knative，请求驱动的弹性伸缩
2. **多运行时**：Triton、TorchServe、ONNX Runtime、vLLM
3. **模型存储**：支持 S3、GCS、Azure Blob
4. **流量治理**：Istio 集成，灰度发布、限流

**适用场景**：
- 多模型管理（几十到上百个模型）
- 需要 GPU 成本优化（Scale-to-Zero）
- 需要灰度发布和 A/B 测试

**评分要点**：
- 3 分：知道 KServe 是推理平台
- 4 分：能说清 Serverless 和弹性伸缩优势
- 5 分：能描述完整架构和适用场景

---

### Q6.2 GPU 调度与管理 ⭐⭐⭐⭐

**问题**：
> 在 K8s 集群中管理 GPU 资源有哪些挑战？Volcano 调度器解决了什么问题？

**期望答案**：

**GPU 管理挑战**：

| 挑战 | 说明 |
|------|------|
| **资源碎片化** | 节点剩余 1-2 张卡，无法分配给需要 4 卡的任务 |
| **Gang Scheduling** | 分布式训练需要同时获取所有卡 |
| **公平调度** | 多团队共享时如何保证公平 |
| **GPU 共享** | 小模型推理不需要整卡 |
| **异构硬件** | A100/V100/T4 如何混合调度 |

**Volcano 调度器优势**：

| 能力 | 默认 K8s 调度器 | Volcano |
|------|-----------------|---------|
| Gang Scheduling | ❌ | ✅ All-or-Nothing |
| 队列管理 | ❌ | ✅ 多队列 + 优先级 |
| 公平调度（DRF） | ❌ | ✅ Dominant Resource Fairness |
| 装箱算法 | 基础 | ✅ 优化的 Bin-Packing |
| 弹性调度 | ❌ | ✅ Min/Max 副本数 |
| 任务优先级 | 有限 | ✅ 细粒度优先级 |

**Gang Scheduling 原理**：
```yaml
# Volcano PodGroup 定义
apiVersion: scheduling.volcano.sh/v1beta1
kind: PodGroup
metadata:
  name: distributed-training
spec:
  minMember: 4  # 必须同时调度 4 个 Pod
  queue: training-queue
```

**GPU 虚拟化方案**：
- **HAMI**：阿里开源，支持 GPU 按比例分配
- **MIG**（Multi-Instance GPU）：NVIDIA 硬件级分区（A100/H100）
- **vGPU**：NVIDIA 虚拟化方案

**评分要点**：
- 3 分：知道 GPU 调度的挑战
- 4 分：能解释 Gang Scheduling 的必要性
- 5 分：能对比多种调度/虚拟化方案

---

## 七、Prompt 工程

### Q7.1 Prompt 基础技巧 ⭐⭐

**问题**：
> 有哪些常用的 Prompt 工程技巧？如何让 LLM 输出更准确？

**期望答案**：

**常用 Prompt 技巧**：

| 技巧 | 说明 | 示例 |
|------|------|------|
| **角色设定** | 给 LLM 设定专家角色 | "你是一位资深 Python 开发者..." |
| **任务拆分** | 复杂任务分步骤执行 | "第一步分析需求，第二步设计方案..." |
| **Few-shot** | 提供示例引导输出格式 | "输入: X，输出: Y。输入: A，输出: ?" |
| **CoT（思维链）** | 要求逐步推理 | "请一步一步思考..." |
| **输出格式约束** | 指定 JSON/Markdown 格式 | "请用 JSON 格式输出，包含字段..." |
| **负面约束** | 明确不要做什么 | "不要编造信息，不要重复问题" |

**Prompt 结构模板**：
```
# 角色
你是 [专家角色]，擅长 [能力描述]。

# 任务
请完成以下任务：[任务描述]

# 约束
- 约束条件 1
- 约束条件 2

# 输出格式
请按以下格式输出：
[格式说明]

# 示例（可选）
输入：[示例输入]
输出：[示例输出]
```

**提升准确性的技巧**：
1. **具体化**：避免模糊描述，给出具体标准
2. **分步验证**：让模型先输出推理过程，再给结论
3. **自我检查**：要求模型检查自己的输出
4. **温度调节**：降低 temperature 减少随机性

**评分要点**：
- 3 分：知道 Few-shot、CoT
- 4 分：能给出结构化的 Prompt 模板
- 5 分：能根据场景选择合适的技巧

---

### Q7.2 复杂 Prompt 设计 ⭐⭐⭐⭐

**问题**：
> 如何设计一个让 LLM 完成代码审查任务的 Prompt？需要考虑哪些方面？

**期望答案**：

**代码审查 Prompt 设计**：

```markdown
# 角色
你是一位资深的代码审查专家，拥有 10 年以上的软件开发经验，精通代码质量、安全性、性能优化和最佳实践。

# 任务
请对以下代码进行全面审查，并提供改进建议。

# 审查维度
1. **代码正确性**：逻辑是否正确，边界条件是否处理
2. **代码风格**：是否符合语言规范和团队约定
3. **安全性**：是否存在安全漏洞（SQL 注入、XSS 等）
4. **性能**：是否有性能问题或优化空间
5. **可维护性**：命名、注释、代码结构是否清晰
6. **测试覆盖**：是否有足够的测试用例

# 输出格式
请按以下 JSON 格式输出：
{
  "summary": "整体评价（1-2 句话）",
  "score": 1-10,
  "issues": [
    {
      "severity": "critical/major/minor/suggestion",
      "line": 行号或行范围,
      "category": "审查维度",
      "description": "问题描述",
      "suggestion": "改进建议",
      "code_example": "修改后的代码（可选）"
    }
  ],
  "highlights": ["值得肯定的地方"]
}

# 约束
- 只关注提交的代码变更，不要审查未修改的部分
- 问题按严重程度排序
- 如果代码质量很好，也要指出亮点
- 不要编造不存在的问题

# 待审查代码
```python
[代码内容]
```
```

**设计考虑**：

| 方面 | 考虑点 |
|------|--------|
| **完整性** | 覆盖多个审查维度，避免遗漏 |
| **结构化输出** | JSON 格式便于后续处理 |
| **严重程度分级** | 帮助开发者优先处理关键问题 |
| **可操作性** | 提供具体改进建议和代码示例 |
| **平衡性** | 既指出问题，也肯定亮点 |

**评分要点**：
- 3 分：能写出基本的审查 Prompt
- 4 分：考虑到多个审查维度和输出格式
- 5 分：设计完整、可落地的 Prompt 并解释设计思路

---

## 附录：难度分布总结

| 难度 | 数量 | 涵盖领域 |
|------|------|----------|
| ⭐⭐ 初级 | 4 题 | Transformer、RAG 基础、Agent 概念、Prompt 基础 |
| ⭐⭐⭐ 中级 | 5 题 | 推理优化、RAG 优化、MCP 概念、微调方法、KServe |
| ⭐⭐⭐⭐ 高级 | 6 题 | vLLM/Triton、RAG 评估与工程化、Agent 框架、SFT/RLHF/DPO、GPU 调度 |
| ⭐⭐⭐⭐⭐ 专家 | 1 题 | Agent 状态管理 |

**使用建议**：
- 初级：用于筛选基础认知
- 中级：用于评估实践经验
- 高级：用于评估技术深度
- 专家：用于评估架构能力
