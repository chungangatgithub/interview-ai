# AI 应用开发框架专项知识问答

**适用岗位**：AI 应用开发工程师
**问答设计原则**：按难度梯度递进（⭐ 入门 → ⭐⭐ 初级 → ⭐⭐⭐ 中级 → ⭐⭐⭐⭐ 高级 → ⭐⭐⭐⭐⭐ 专家）

---

## 目录

1. [框架全景与选型](#一框架全景与选型)
2. [LangChain 深入](#二langchain-深入)
3. [LlamaIndex 深入](#三llamaindex-深入)
4. [低代码平台与编排](#四低代码平台与编排)
5. [工程化实践](#五工程化实践)

---

## 一、框架全景与选型

### Q1.1 AI 应用开发框架对比 ⭐⭐

**问题**：
> 目前主流的 AI 应用开发框架有哪些？LangChain、LlamaIndex、Dify 各自适合什么场景？

**期望答案**：

**框架定位对比**：

| 维度 | LangChain | LlamaIndex | Dify |
|------|-----------|------------|------|
| **定位** | 通用 LLM 应用编排框架 | 数据索引与检索框架（RAG 专精） | 低代码 LLM 应用平台 |
| **目标用户** | Python/JS 开发者 | RAG / 数据工程师 | 业务人员 + 开发者 |
| **核心能力** | Chain/Agent/Tool 编排 | 文档解析、索引、检索 Pipeline | 可视化编排、开箱即用 |
| **学习曲线** | 陡峭（抽象层多） | 中等（聚焦 RAG） | 平缓（GUI 操作） |
| **灵活性** | 极高 | 高（RAG 领域） | 有限（受 GUI 约束） |
| **生产就绪** | 高（需自行搭建） | 高 | 中（快速上线） |

**选型决策树**：

```
你的需求是？
├── 构建复杂 Agent / 多步工作流 → LangChain（+ LangGraph）
├── 构建 RAG / 知识库系统 → LlamaIndex
├── 快速上线 / 非技术团队使用 → Dify
├── 两者结合 → LlamaIndex 做检索 + LangChain 做编排
└── 企业级全流程 → LangChain + LangSmith（可观测性）
```

**其他值得关注的框架**：

| 框架 | 特点 | 适用场景 |
|------|------|---------|
| **Haystack** | Deepset 出品，Pipeline 式设计 | 搜索和问答系统 |
| **Semantic Kernel** | 微软出品，C#/.NET 友好 | .NET 生态的 AI 集成 |
| **Spring AI** | Spring 生态，Java 原生 | Java / 企业级后端集成 |
| **Vercel AI SDK** | 前端友好，流式 UI | AI 聊天界面、Next.js 应用 |

**评分要点**：
- 3 分：知道 LangChain 和 LlamaIndex 的大致区别
- 4 分：能根据场景推荐合适的框架
- 5 分：能对比多个框架并给出组合方案

---

## 二、LangChain 深入

### Q2.1 LangChain 核心概念 ⭐⭐⭐

**问题**：
> LangChain 的核心抽象有哪些？Chain、Agent、Tool 分别是什么关系？LangGraph 解决了什么问题？

**期望答案**：

**核心抽象**：

| 概念 | 说明 | 类比 |
|------|------|------|
| **LLM / ChatModel** | 语言模型的统一接口 | 大脑 |
| **Prompt Template** | 提示词模板，支持变量插入 | 指令卡 |
| **Chain** | 将多个组件串联的线性流程 | 流水线 |
| **Agent** | 动态决策调用工具的执行体 | 自主员工 |
| **Tool** | Agent 可调用的外部功能 | 工具箱 |
| **Memory** | 对话历史和上下文管理 | 记忆 |
| **Retriever** | 从数据源检索相关文档 | 搜索引擎 |
| **Output Parser** | 解析 LLM 输出为结构化数据 | 格式化器 |

**LCEL（LangChain Expression Language）**：
LangChain 的声明式管道语法，用 `|` 连接组件：

```python
from langchain_core.prompts import ChatPromptTemplate
from langchain_openai import ChatOpenAI
from langchain_core.output_parsers import StrOutputParser

chain = (
    ChatPromptTemplate.from_template("翻译为英文：{text}")
    | ChatOpenAI(model="gpt-4o")
    | StrOutputParser()
)

result = chain.invoke({"text": "你好世界"})
```

**LangGraph 解决的问题**：
- Chain 只支持线性流程，无法处理**循环、分支、条件判断**
- Agent 的 ReAct 循环不够灵活，难以精细控制
- LangGraph 引入**有向图**：节点（处理逻辑）+ 边（流转条件）+ 状态（共享上下文）
- 支持 Human-in-the-Loop（人工介入）、持久化、断点恢复

**LangChain 生态全景**：

```
LangChain（核心库）
├── LangGraph（复杂工作流编排）
├── LangSmith（可观测性、调试、评估）
├── LangServe（一键部署 API）
└── Community Integrations（社区集成）
```

**评分要点**：
- 3 分：知道 Chain 和 Agent 的区别
- 4 分：能解释 LCEL 和 LangGraph 的作用
- 5 分：能清晰描述 LangChain 生态各组件的定位

---

### Q2.2 LangChain Agent 实现 ⭐⭐⭐⭐

**问题**：
> 如何用 LangChain 实现一个带工具调用的 Agent？ReAct 模式是如何工作的？

**期望答案**：

**ReAct 模式**：
ReAct = **Re**asoning + **Act**ing，LLM 交替进行"思考"和"行动"：

```
用户问题 → LLM 思考（Thought）
                ↓
        决定调用工具（Action）
                ↓
        获取结果（Observation）
                ↓
        继续思考或输出最终答案
```

**代码实现**：

```python
from langchain_openai import ChatOpenAI
from langchain.agents import create_tool_calling_agent, AgentExecutor
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.tools import tool

@tool
def search_knowledge_base(query: str) -> str:
    """在知识库中搜索相关信息"""
    # 向量检索逻辑
    results = vector_store.similarity_search(query, k=3)
    return "\n".join([doc.page_content for doc in results])

@tool
def execute_sql(sql: str) -> str:
    """执行 SQL 查询并返回结果"""
    return db.run(sql)

llm = ChatOpenAI(model="gpt-4o")

prompt = ChatPromptTemplate.from_messages([
    ("system", "你是一个数据分析助手，可以查询知识库和数据库。"),
    ("human", "{input}"),
    ("placeholder", "{agent_scratchpad}"),
])

agent = create_tool_calling_agent(llm, [search_knowledge_base, execute_sql], prompt)
executor = AgentExecutor(agent=agent, tools=[search_knowledge_base, execute_sql])

result = executor.invoke({"input": "上个月的销售额是多少？"})
```

**Tool Calling vs ReAct**：

| 维度 | ReAct（Prompt 驱动） | Tool Calling（API 原生） |
|------|---------------------|------------------------|
| **实现方式** | 在 Prompt 中描述工具 | 使用模型的 Function Calling API |
| **可靠性** | 依赖 Prompt 解析 | 结构化输出，更可靠 |
| **多工具** | 容易混乱 | 模型原生支持多工具并行调用 |
| **推荐度** | 早期方案 | **当前推荐** |

**评分要点**：
- 3 分：知道 Agent 可以调用工具
- 4 分：能解释 ReAct 循环的工作方式
- 5 分：能写出 Agent 代码并对比 ReAct 和 Tool Calling

---

## 三、LlamaIndex 深入

### Q3.1 LlamaIndex 核心架构 ⭐⭐⭐

**问题**：
> LlamaIndex 的核心架构是什么？它在 RAG Pipeline 中各阶段提供了哪些关键组件？

**期望答案**：

**LlamaIndex 五阶段 Pipeline**：

```
Loading → Indexing → Storing → Querying → Evaluating
 加载       索引       存储       查询        评估
```

**各阶段核心组件**：

| 阶段 | 组件 | 说明 |
|------|------|------|
| **Loading** | `SimpleDirectoryReader`、`LlamaParse` | 支持 PDF/HTML/Markdown/数据库等多种数据源 |
| **Indexing** | `VectorStoreIndex`、`SummaryIndex`、`KnowledgeGraphIndex` | 多种索引策略 |
| **Storing** | 对接 Milvus/Qdrant/Chroma/Pinecone 等 | 持久化存储 |
| **Querying** | `RetrieverQueryEngine`、`RouterQueryEngine` | 检索 + 生成 |
| **Evaluating** | `FaithfulnessEvaluator`、`RelevancyEvaluator` | RAG 效果评估 |

**代码示例**（最简 RAG）：

```python
from llama_index.core import VectorStoreIndex, SimpleDirectoryReader

documents = SimpleDirectoryReader("./data").load_data()
index = VectorStoreIndex.from_documents(documents)
query_engine = index.as_query_engine()
response = query_engine.query("项目的技术栈是什么？")
```

**高级特性**：

| 特性 | 说明 |
|------|------|
| **LlamaParse** | 专业文档解析服务（PDF 表格/图表提取） |
| **Ingestion Pipeline** | 可自定义的数据摄入管线（分块、清洗、Embedding） |
| **Router Query Engine** | 根据 Query 自动选择合适的索引/检索策略 |
| **Sub-Question Query Engine** | 将复杂问题拆解为子问题，分别检索后合并 |
| **Agentic RAG** | 将 RAG 与 Agent 结合，支持多步推理检索 |

**评分要点**：
- 3 分：知道 LlamaIndex 用于构建 RAG
- 4 分：能描述五阶段 Pipeline 和核心组件
- 5 分：能说出 Router/Sub-Question 等高级检索策略

---

### Q3.2 LlamaIndex vs LangChain 在 RAG 中的选择 ⭐⭐⭐⭐

**问题**：
> 构建 RAG 系统时，LlamaIndex 和 LangChain 各有什么优势？什么场景下应该选哪个或组合使用？

**期望答案**：

**RAG 能力对比**：

| 维度 | LlamaIndex | LangChain |
|------|------------|-----------|
| **文档解析** | ★★★★★ LlamaParse 专业解析 | ★★★ 基础 DocumentLoader |
| **分块策略** | ★★★★★ 多种 Node Parser | ★★★★ TextSplitter 丰富 |
| **索引类型** | ★★★★★ 向量/摘要/知识图谱/树形 | ★★★ 主要依赖向量索引 |
| **检索策略** | ★★★★★ Router/Fusion/Sub-Question | ★★★★ Retriever 种类多 |
| **Agent 集成** | ★★★ 基础 Agent 能力 | ★★★★★ Agent/LangGraph 成熟 |
| **工作流编排** | ★★★ Workflow（较新） | ★★★★★ LangGraph 强大 |
| **可观测性** | ★★★★ LlamaTrace | ★★★★★ LangSmith 完善 |

**选型建议**：

| 场景 | 推荐 | 理由 |
|------|------|------|
| 纯 RAG / 知识库问答 | **LlamaIndex** | 索引策略丰富，文档解析强 |
| RAG + Agent 混合 | **LlamaIndex + LangChain** | 各取所长 |
| 复杂工作流 + RAG | **LangChain（LangGraph）** | 工作流编排能力强 |
| 快速原型 | **LlamaIndex** | 代码量少，5 行即可跑通 |
| 生产级全链路 | **LangChain + LangSmith** | 可观测性和调试成熟 |

**组合使用示例**：

```python
from llama_index.core import VectorStoreIndex
from langchain.tools import Tool
from langchain.agents import AgentExecutor

llama_index = VectorStoreIndex.from_documents(docs)
query_engine = llama_index.as_query_engine()

rag_tool = Tool(
    name="knowledge_base",
    func=lambda q: str(query_engine.query(q)),
    description="查询内部知识库"
)

# 将 LlamaIndex 检索能力作为 LangChain Agent 的工具
agent = create_tool_calling_agent(llm, [rag_tool, ...], prompt)
```

**评分要点**：
- 3 分：知道两者的大致区别
- 4 分：能按场景给出选型建议
- 5 分：能描述组合使用的方案

---

### Q3.3 生产级 RAG 数据摄入 Pipeline ⭐⭐⭐⭐

**问题**：
> 用 LangChain 或 LlamaIndex 构建 RAG 时，数据摄入 Pipeline 应该如何设计？如何利用 `CacheBackedEmbeddings`、Ingestion Pipeline 等能力减少重复计算并支撑增量更新？

**期望答案**：

**典型摄入链路**：

```
Loader / Parser
      ↓
结构化清洗 / 元数据抽取
      ↓
去重 / 内容哈希
      ↓
Chunking（按文档类型）
      ↓
Embedding（带缓存）
      ↓
写入 Vector Store
      ↓
校验 / 发布 / 监控
```

**框架能力分工**：

| 环节 | LlamaIndex | LangChain | 最佳实践 |
|------|------------|-----------|----------|
| **加载/解析** | `SimpleDirectoryReader`、`LlamaParse` | `DocumentLoader` 体系 | 复杂 PDF/表格优先专业解析 |
| **分块** | `NodeParser`、Ingestion Pipeline | `TextSplitter` | 按 FAQ、商品、长文档定制 Chunk 策略 |
| **Embedding** | Pipeline Transformation | `CacheBackedEmbeddings` | 对重复文本启用缓存，降低成本 |
| **更新编排** | 自定义 Ingestion Pipeline | Runnable / 异步任务编排 | 用 `content_hash` 判断是否需要重算 |
| **观测调试** | LlamaTrace | LangSmith | 监控新鲜度、缓存命中率、召回质量 |

**`CacheBackedEmbeddings` 的实战要点**：
1. 适合文档摄入阶段，对重复 Chunk 或重复跑批的场景收益明显
2. `namespace` 最好绑定 Embedding 模型名和版本，避免不同向量空间的缓存互相污染
3. 默认更适合缓存 Document Embedding；是否缓存 Query Embedding，要看查询重复度和失效策略
4. 缓存键建议基于规范化后的文本或 `content_hash`，而不是原始脏数据

**增量更新的推荐做法**：
1. 用 CDC / MQ / 定时任务识别新增、修改、删除
2. 为每个 Chunk 维护 `source_id`、`chunk_id`、`content_hash`、`doc_version`
3. `content_hash` 未变化时跳过 Embedding，直接复用缓存或旧向量
4. `content_hash` 变化时，只重算受影响的 Chunk，而不是全量重建
5. 写入向量库时采用版本化发布，避免先删后写带来的查询空窗期

**为什么 Pipeline 要“先清洗后向量化”**：
- 脏数据、模板噪声、重复字段会直接拉低 Embedding 质量
- 对商品、工单、FAQ 这类半结构化数据，先结构化再拼装文本，通常比直接把原始 JSON 全量塞给 Embedding 效果更稳定
- 分块策略、元数据抽取、Embedding 模型版本应该作为同一个摄入版本的一部分统一管理

**社区常见组合方案**：
- **LlamaIndex**：负责复杂文档解析、Node 切分、Retriever 构建
- **LangChain**：负责缓存、工作流编排、工具集成、可观测性
- **向量数据库**：负责检索、过滤、版本化发布和在线服务

**评分要点**：
- 3 分：知道数据摄入不只是“读文档然后入库”
- 4 分：能讲清清洗、分块、缓存、增量更新之间的关系
- 5 分：能结合 `CacheBackedEmbeddings`、版本管理、可观测性给出生产级方案

---

## 四、低代码平台与编排

### Q4.1 Dify 与低代码 AI 平台 ⭐⭐⭐

**问题**：
> Dify 这类低代码 AI 平台的架构是什么？适合哪些场景？有什么局限性？

**期望答案**：

**Dify 核心架构**：

```
可视化 Workflow 编排器
        ↓
┌───────────────────────────┐
│  LLM Node  │  RAG Node   │
│  Tool Node │  Code Node  │
│  IF/ELSE   │  Loop       │
└───────────────────────────┘
        ↓
统一 API / 嵌入式 Chat UI
        ↓
监控 & 日志 & 标注
```

**核心功能**：

| 功能 | 说明 |
|------|------|
| **Workflow 编排** | 拖拽式流程编辑，支持条件分支、循环、并行 |
| **RAG Pipeline** | 内置文档上传、分块、向量化、检索全流程 |
| **多模型支持** | 对接 OpenAI、Claude、本地模型等 |
| **API 发布** | 一键发布为 REST API |
| **对话管理** | 内置聊天 UI、对话日志、用户反馈标注 |

**适用场景**：
- 内部知识库问答系统（快速搭建）
- 客服机器人（非技术团队运维）
- 内容生成工作流（营销文案、报告生成）
- AI 应用 MVP 快速验证

**局限性**：

| 局限 | 说明 |
|------|------|
| **灵活性不足** | 复杂逻辑受 GUI 约束，无法实现任意代码 |
| **性能瓶颈** | 大并发场景下可能不如原生代码 |
| **定制化困难** | 深度定制需要 Fork 源码修改 |
| **Agent 能力弱** | 多步推理和复杂 Agent 场景不如 LangGraph |
| **供应商锁定** | 迁移到其他方案成本高 |

**同类平台对比**：

| 平台 | 特点 | 适合谁 |
|------|------|--------|
| **Dify** | 开源、功能全面、中文社区活跃 | 中小团队 |
| **Coze（扣子）** | 字节出品、Plugin 生态丰富 | 个人开发者 |
| **FastGPT** | 开源、聚焦知识库问答 | 知识库场景 |
| **Flowise** | 开源、LangChain 的可视化前端 | LangChain 用户 |

**评分要点**：
- 3 分：知道 Dify 是低代码 AI 平台
- 4 分：能说清适用场景和局限性
- 5 分：能对比多个平台并给出选型建议

---

## 五、工程化实践

### Q5.1 LLM 应用可观测性 ⭐⭐⭐⭐

**问题**：
> LLM 应用上线后如何做可观测性（Observability）？LangSmith 提供了哪些能力？

**期望答案**：

**为什么 LLM 应用需要可观测性**：
- LLM 输出具有**不确定性**，相同输入可能产生不同输出
- 多步 Agent/Chain 调用链路复杂，出错时难以定位
- 需要持续评估和优化 Prompt/检索效果
- Token 成本需要监控和管理

**可观测性三大支柱**：

| 支柱 | 传统应用 | LLM 应用 |
|------|---------|---------|
| **Traces（追踪）** | HTTP 请求链路 | LLM 调用链路（Prompt → 模型 → 工具 → 输出） |
| **Metrics（指标）** | QPS、延迟 | Token 用量、延迟、成功率、用户满意度 |
| **Logs（日志）** | 结构化日志 | 完整的 Prompt/Response 记录 |

**LangSmith 核心能力**：

| 功能 | 说明 |
|------|------|
| **Tracing** | 可视化完整调用链路（每个 Chain/Agent/Tool 节点的输入输出） |
| **Evaluation** | 自动评估（LLM-as-Judge）+ 人工标注 |
| **Prompt Hub** | Prompt 版本管理和协作 |
| **Datasets** | 构建和管理测试数据集 |
| **Monitoring** | 生产环境实时监控面板 |

**开源替代方案**：

| 工具 | 特点 |
|------|------|
| **LangFuse** | 开源，功能与 LangSmith 类似 |
| **Phoenix（Arize）** | 开源，专注 LLM 可观测性 |
| **OpenLLMetry** | 基于 OpenTelemetry 的 LLM 追踪 |

**关键监控指标**：
1. **质量指标**：回答准确率、Faithfulness（忠实度）、用户反馈评分
2. **性能指标**：首 Token 延迟（TTFT）、端到端延迟、Token 吞吐量
3. **成本指标**：每次请求的 Token 消耗、月度总成本
4. **可靠性指标**：调用成功率、超时率、重试率

**评分要点**：
- 3 分：知道 LLM 应用需要可观测性
- 4 分：能描述 Tracing 和 Evaluation 的作用
- 5 分：能对比 LangSmith 与开源方案，给出监控指标体系

---

### Q5.2 LLM 应用的测试与评估 ⭐⭐⭐⭐⭐

**问题**：
> 如何系统性地测试和评估一个 LLM 应用？从开发到上线需要哪些测试环节？

**期望答案**：

**LLM 应用测试金字塔**：

```
            ╱╲
           ╱  ╲
          ╱ 人工╲         ← 人工评估（少量高价值 Case）
         ╱ 评估  ╲
        ╱──────────╲
       ╱ LLM-as-   ╲      ← 自动化评估（LLM 做 Judge）
      ╱   Judge      ╲
     ╱────────────────╲
    ╱  规则 / 启发式    ╲   ← 规则校验（格式、长度、关键词）
   ╱    校验             ╲
  ╱──────────────────────╲
 ╱    单元测试 / 集成测试  ╲ ← 代码级测试（工具调用、API）
╱──────────────────────────╲
```

**各层测试详解**：

| 层次 | 方法 | 工具 | 频率 |
|------|------|------|------|
| **单元测试** | 测试工具调用、数据解析、格式化 | pytest | 每次提交 |
| **规则校验** | 输出格式、长度、禁用词检测 | 自定义脚本 | 每次运行 |
| **LLM-as-Judge** | LLM 对输出打分（准确性、相关性、安全性） | RAGAS、LangSmith | 每日/每次部署 |
| **人工评估** | 领域专家标注、A/B 测试 | LangSmith、Label Studio | 每周/重大变更 |

**评估数据集构建**：

```json
{
  "test_cases": [
    {
      "input": "什么是 RAG？",
      "expected_output": "RAG 是检索增强生成...",
      "context": "从知识库检索的参考文档",
      "metadata": {"category": "基础概念", "difficulty": "easy"}
    }
  ]
}
```

**关键评估维度**：
1. **正确性（Correctness）**：答案是否事实正确
2. **忠实度（Faithfulness）**：答案是否忠实于检索到的上下文
3. **相关性（Relevancy）**：答案是否回答了用户的问题
4. **安全性（Safety）**：是否有有害/偏见内容
5. **一致性（Consistency）**：相似问题是否给出一致的答案

**回归测试策略**：
- 维护一组"黄金测试集"（Golden Test Set），每次 Prompt 或模型变更后跑回归
- 使用 LLM-as-Judge 自动打分，人工抽检不一致的 Case
- 设定质量门槛（如 Faithfulness > 0.9），低于门槛阻断部署

**评分要点**：
- 3 分：知道需要评估 LLM 应用的输出质量
- 4 分：能描述测试金字塔和各层测试方法
- 5 分：能设计完整的测试评估体系和回归策略

---

## 附录：难度分布总结

| 难度 | 数量 | 涵盖领域 |
|------|------|----------|
| ⭐⭐ 初级 | 1 题 | 框架全景与选型 |
| ⭐⭐⭐ 中级 | 3 题 | LangChain 核心、LlamaIndex 架构、Dify 低代码 |
| ⭐⭐⭐⭐ 高级 | 4 题 | Agent 实现、RAG 选型与摄入、LLM 可观测性 |
| ⭐⭐⭐⭐⭐ 专家 | 1 题 | LLM 应用测试与评估 |
