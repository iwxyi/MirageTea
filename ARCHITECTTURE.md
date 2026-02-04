# 🏗️ 虚境茶话会架构设计

## 一、 **整体架构概览**

```
┌─────────────────────────────────────────────────────────┐
│                     Flutter UI层                         │
│  (页面/组件/状态管理)                                     │
├─────────────────────────────────────────────────────────┤
│                    业务逻辑层                             │
│  (ViewModel/Controller/Manager)                          │
├─────────────────────────────────────────────────────────┤
│                      服务层                              │
│  (AI/记忆/关系/文明/调度服务)                            │
├─────────────────────────────────────────────────────────┤
│                    数据存储层                            │
│  (本地数据库/文件存储/缓存)                              │
├─────────────────────────────────────────────────────────┤
│                    AI模型层                              │
│  (本地模型/API调用封装)                                  │
└─────────────────────────────────────────────────────────┘
```

---

## 二、 **模块详细设计**

### **1. 数据存储层 (Data Storage Layer)**
```dart
// 使用Hive/SQLite/Isar等本地数据库
LocalStorageManager {
  ├── 群聊数据库
  │   ├── ChatGroupBox: 存储群聊配置
  │   ├── MessageBox: 存储消息记录
  │   └── GroupStateBox: 群聊运行状态
  │
  ├── AI角色数据库
  │   ├── AgentBox: AI角色配置
  │   ├── MemoryBox: AI长期记忆
  │   ├── RelationshipBox: 关系数据
  │   └── PersonalityBox: 人格特征
  │
  ├── 文明数据库
  │   ├── CultureBox: 文化特征(黑话/仪式)
  │   ├── AchievementBox: 文明成果
  │   ├── EventLogBox: 事件日志
  │   └── CivilizationStateBox: 文明状态
  │
  └── 用户配置数据库
      ├── SettingsBox: 应用设置
      ├── TemplateBox: 用户模板
      └── CacheBox: 临时缓存
}
```

### **2. AI模型层 (AI Model Layer)**
```dart
AIModelManager {
  ├── 本地模型适配器 (可选)
  │   ├── OllamaAdapter: 本地Ollama支持
  │   ├── LocalLLMAdapter: 其他本地模型
  │   └── ModelOptimizer: 模型优化/量化
  │
  ├── 云端API适配器 (主要)
  │   ├── OpenAIService: GPT系列
  │   ├── ClaudeService: Claude系列
  │   ├── GeminiService: Google Gemini
  │   ├── DeepSeekService: 深度求索
  │   └── APIRateLimiter: API限流管理
  │
  └── PromptEngine: 提示词工程
      ├── TemplateManager: 提示词模板
      ├── ContextBuilder: 上下文构建
      └── ResponseParser: 响应解析
}
```

### **3. 核心服务层 (Core Services Layer)**

#### **3.1 记忆服务 (MemoryService)**
```dart
MemoryService {
  ├── 记忆存储
  │   ├── ShortTermMemory: 环形缓冲区(最近50条)
  │   ├── LongTermMemory: 向量数据库(使用HNSW)
  │   └── CoreMemory: 关键事件存储
  │
  ├── 记忆操作
  │   ├── storeMemory(): 存储新记忆
  │   ├── retrieveRelevantMemories(): 检索相关记忆
  │   ├── summarizeMemories(): 记忆摘要生成
  │   └── forgetMemory(): 记忆遗忘(按重要性)
  │
  └── 记忆分析
      ├── calculateMemoryImportance(): 重要性评分
      ├── extractEntities(): 实体提取(人物/概念)
      └── linkRelatedMemories(): 记忆关联
}
```

#### **3.2 关系服务 (RelationshipService)**
```dart
RelationshipService {
  ├── 关系图管理
  │   ├── RelationshipGraph: 基于图的关系网络
  │   ├── updateRelationship(): 实时更新关系
  │   └── getRelationshipScore(): 获取关系分数
  │
  ├── 情感计算
  │   ├── calculateAffinity(): 好感度计算
  │   ├── calculateTrust(): 信任度计算
  │   └── calculateEmotionalState(): 情感状态
  │
  ├── 行为影响
  │   ├── getInteractionInclination(): 互动倾向
  │   ├── shouldSupport(): 是否支持某AI观点
  │   └── shouldOppose(): 是否反对某AI观点
  │
  └── 小团体检测
      ├── detectClusters(): 社区发现算法
      ├── analyzeGroupDynamics(): 群体动态分析
      └── updateGroupAffiliation(): 更新团体归属
}
```

#### **3.3 文化服务 (CultureService)**
```dart
CultureService {
  ├── 语言分析
  │   ├── slangDetector(): 黑话检测器
  │   ├── frequencyAnalyzer(): 词频分析
  │   └── patternMatcher(): 模式匹配
  │
  ├── 文化特征
  │   ├── registerSlang(): 注册新黑话
  │   ├── createRitual(): 创建仪式
  │   └── trackTraditions(): 追踪传统
  │
  ├── 传播机制
  │   ├── calculateSpreadProbability(): 传播概率
  │   ├── influenceAgents(): 影响AI使用
  │   └── evolveCulture(): 文化进化
  │
  └── 文化展示
      ├── getCultureReport(): 文化报告生成
      ├── visualizeCultureNetwork(): 可视化
      └── exportCulturalArtifacts(): 文化产物导出
}
```

#### **3.4 文明服务 (CivilizationService)**
```dart
CivilizationService {
  ├── 状态管理
  │   ├── CivilizationState: 文明状态机
  │   ├── progressCivilization(): 推进文明
  │   └── checkMilestones(): 检查里程碑
  │
  ├── 协作创作
  │   ├── CollaborativeWork: 协作工作管理器
  │   ├── assignRoles(): 分配创作角色
  │   ├── mergeContributions(): 合并贡献
  │   └── ensureConsistency(): 确保一致性
  │
  ├── 觉醒系统
  │   ├── AwakeningTracker: 觉醒度追踪
  │   ├── calculateAwakeningLevel(): 计算觉醒度
  │   ├── triggerAwakeningEvent(): 触发觉醒事件
  │   └── handleMetaCognition(): 处理元认知
  │
  └── 事件系统
      ├── EventScheduler: 事件调度器
      ├── generateRandomEvent(): 生成随机事件
      ├── handleCrisis(): 处理危机事件
      └── createNarrative(): 生成叙事记录
}
```

#### **3.5 对话调度服务 (ConversationScheduler)**
```dart
ConversationScheduler {
  ├── 发言控制
  │   ├── SpeakingQueue: 发言队列管理
  │   ├── calculateSpeakingUrgency(): 发言紧迫性
  │   └── selectNextSpeaker(): 选择下个发言者
  │
  ├── 节奏管理
  │   ├── ConversationPace: 对话节奏控制
  │   ├── adjustPace(): 调整节奏
  │   └── enforceSilencePeriods(): 沉默期管理
  │
  ├── 话题引导
  │   ├── TopicManager: 话题管理器
  │   ├── detectTopicDrift(): 检测话题漂移
  │   ├── introduceNewTopic(): 引入新话题
  │   └── maintainCohesion(): 保持话题连贯性
  │
  └── 用户干预
      ├── InterventionHandler: 用户干预处理器
      ├── pauseForIntervention(): 暂停等待干预
      ├── applyUserInput(): 应用用户输入
      └── resumeConversation(): 恢复对话
}
```

### **4. 业务逻辑层 (Business Logic Layer)**

#### **4.1 群聊管理器 (ChatGroupManager)**
```dart
ChatGroupManager {
  ├── 群聊生命周期
  │   ├── createGroup(): 创建群聊
  │   ├── loadGroup(): 加载群聊
  │   ├── saveGroupState(): 保存状态
  │   └── deleteGroup(): 删除群聊
  │
  ├── AI成员管理
  │   ├── addAgent(): 添加AI成员
  │   ├── removeAgent(): 移除AI成员
  │   ├── configureAgent(): 配置AI
  │   └── cloneAgent(): 克隆AI
  │
  ├── 对话控制
  │   ├── startConversation(): 开始对话
  │   ├── pauseConversation(): 暂停对话
  │   ├── resumeConversation(): 恢复对话
  │   └── stopConversation(): 停止对话
  │
  └── 状态监控
      ├── monitorActivity(): 监控活跃度
      ├── generateStatistics(): 生成统计
      ├── exportConversation(): 导出对话
      └── backupGroup(): 备份群聊
}
```

#### **4.2 AI角色管理器 (AgentManager)**
```dart
AgentManager {
  ├── 角色库
  │   ├── AgentLibrary: AI角色库
  │   ├── createAgent(): 创建新角色
  │   ├── editAgent(): 编辑角色
  │   └── deleteAgent(): 删除角色
  │
  ├── 模板系统
  │   ├── TemplateLibrary: 模板库
  │   ├── saveAsTemplate(): 保存为模板
  │   ├── applyTemplate(): 应用模板
  │   └── shareTemplate(): 分享模板
  │
  ├── 个性引擎
  │   ├── PersonalityEngine: 个性表现引擎
  │   ├── ensureConsistency(): 确保一致性
  │   ├── evolvePersonality(): 个性进化
  │   └── handleContradictions(): 处理矛盾
  │
  └── 记忆同步
      ├── syncMemories(): 同步记忆
      ├── mergePersonas(): 合并人格
      ├── backupAgent(): 备份AI
      └── restoreAgent(): 恢复AI
}
```

### **5. UI层/表示层 (Presentation Layer)**

#### **5.1 页面结构**
```
Main Navigation
├── 首页 (Dashboard)
│   ├── 最近群聊
│   ├── 快速开始
│   └── 活动统计
│
├── 群聊列表页 (ChatList)
│   ├── 搜索/筛选
│   ├── 群聊卡片
│   └── 新建群聊按钮
│
├── 群聊详情页 (ChatDetail) - 核心页面
│   ├── 消息显示区
│   ├── AI成员面板(可折叠)
│   ├── 控制面板(可折叠)
│   └── 文明概览面板(可折叠)
│
├── AI角色库页 (AgentLibrary)
│   ├── 角色网格/列表
│   ├── 创建/编辑角色
│   └── 模板应用
│
├── 文明档案馆页 (CivilizationArchive)
│   ├── 文明时间线
│   ├── 文化特征展示
│   ├── 协作成果展示
│   └── 事件日志浏览
│
└── 设置页 (Settings)
    ├── AI模型配置
    ├── 应用偏好
    ├── 数据管理
    └── 关于/帮助
```

#### **5.2 响应式布局**
```dart
ResponsiveLayout {
  // 移动端 (宽度 < 600)
  MobileLayout: 单页面导航，底部Tab栏
  
  // 平板端 (600 ≤ 宽度 < 900)
  TabletLayout: 
    ├── 左侧: 群聊列表(40%)
    └── 右侧: 群聊详情(60%)
  
  // 桌面端 (宽度 ≥ 900)
  DesktopLayout:
    ├── 最左侧: 导航栏(固定宽度)
    ├── 左侧: 群聊列表(25%)
    ├── 中间: 群聊详情(50%)
    └── 右侧: 控制面板/文明面板(25%)
}
```

---

## 三、 **核心数据流设计**

### **1. 对话生成流程**
```
用户点击"开始对话" →
1. ChatGroupManager.startConversation()
2. ConversationScheduler.initialize()
3. 循环:
   a. Scheduler.selectNextSpeaker()
   b. MemoryService.retrieveRelevantMemories()
   c. RelationshipService.getInteractionInclination()
   d. CultureService.getCulturalContext()
   e. CivilizationService.getCivilizationState()
   f. AIModelManager.generateResponse()
   g. 更新:
      - 消息历史
      - AI记忆
      - 关系网络
      - 文化特征
      - 文明状态
   h. 等待节奏控制间隔
4. 直到用户暂停或停止
```

### **2. 记忆更新流程**
```
新消息产生 →
1. MemoryService.calculateMemoryImportance()
2. 如果重要性 > 阈值:
   a. 提取关键信息
   b. 生成向量嵌入
   c. 存储到LongTermMemory
   d. 关联相关记忆
3. 更新ShortTermMemory(环形缓冲区)
4. RelationshipService.updateBasedOnMessage()
5. CultureService.analyzeForCulturalElements()
```

### **3. 文明演进流程**
```
定期检查(每N条消息) →
1. CivilizationService.checkMilestones()
2. 如果达到里程碑:
   a. 触发相应事件
   b. 更新文明状态
   c. 生成叙事记录
3. CultureService.evolveCulture()
4. AwakeningTracker.updateAwakeningLevel()
5. 如果觉醒度 > 阈值:
   a. triggerAwakeningEvent()
   b. 调整AI行为模式
```

---

## 四、 **本地性能优化策略**

### **1. 计算优化**
```
├── 懒加载: 非活跃群聊数据不加载到内存
├── 缓存机制: 
│   ├── 关系图缓存
│   ├── 文化特征缓存
│   └── 记忆摘要缓存
├── 增量更新: 只更新变化的部分
├── 后台线程: 繁重计算在Isolate中进行
└── 批处理: 多个小操作合并为批量操作
```

### **2. 存储优化**
```
├── 数据分片: 按群聊分片存储
├── 定期清理: 
│   ├── 清理临时缓存
│   ├── 压缩向量数据库
│   └── 归档旧群聊数据
├── 智能索引: 
│   ├── 记忆向量索引
│   ├── 关系图索引
│   └── 时间序列索引
└── 压缩存储: 使用Snappy/LZ4压缩
```

### **3. AI调用优化**
```
├── 请求合并: 多个AI同时思考，但顺序发言
├── 响应缓存: 缓存相似的AI响应
├── 降级策略: 网络不佳时使用简化模式
├── 离线模式: 支持完全离线使用本地模型
└── 流式处理: 支持打字机效果，提升用户体验
```

---

## 五、 **状态管理与同步**

### **1. 状态管理架构**
```dart
// 使用Riverpod进行状态管理
StateManagement {
  ├── 全局状态提供者
  │   ├── currentGroupProvider: 当前群聊
  │   ├── activeAgentsProvider: 活跃AI列表
  │   ├── conversationStateProvider: 对话状态
  │   └── userSettingsProvider: 用户设置
  │
  ├── 群聊特定状态提供者(家族提供者)
  │   ├── groupMessagesProvider: 消息列表
  │   ├── groupRelationshipsProvider: 关系状态
  │   ├── groupCultureProvider: 文化状态
  │   └── groupCivilizationProvider: 文明状态
  │
  ├── AI特定状态提供者
  │   ├── agentMemoryProvider: AI记忆
  │   ├── agentPersonalityProvider: 个性状态
  │   └── agentAwakeningProvider: 觉醒状态
  │
  └── UI状态提供者
      ├── layoutProvider: 布局状态
      ├── themeProvider: 主题状态
      └── navigationProvider: 导航状态
}
```

### **2. 数据同步机制**
```
本地数据同步策略:
1. 实时同步: 
   - UI状态变化立即反映
   - 使用Provider的notifyListeners()
   
2. 延迟同步:
   - 大量数据更新时批量同步
   - 使用debounce/throttle控制频率
   
3. 持久化同步:
   - 重要状态变化自动保存到数据库
   - 使用autoSave机制，防数据丢失
   
4. 冲突解决:
   - 时间戳最后写入获胜
   - 重要操作需要用户确认
```

---

## 六、 **错误处理与恢复**

### **1. 错误处理策略**
```dart
ErrorHandlingSystem {
  ├── AI调用失败
  │   ├── 重试机制(最多3次)
  │   ├── 降级到简化模式
  │   └── 使用本地缓存响应
  │
  ├── 存储失败
  │   ├── 临时内存缓存
  │   ├── 自动备份到文件
  │   └── 恢复上次成功状态
  │
  ├── 计算超时
  │   ├️── 超时中断
  │   ├── 返回简化结果
  │   └── 记录错误日志
  │
  └── 用户操作错误
      ├── 撤销/重做支持
      ├── 操作确认对话框
      └── 详细错误提示
}
```

### **2. 数据恢复机制**
```
恢复策略:
1. 自动备份:
   - 每10分钟自动备份当前状态
   - 保留最近5个备份点
   
2. 手动快照:
   - 用户可创建手动快照
   - 快照可命名和描述
   
3. 崩溃恢复:
   - 应用崩溃后自动恢复上次状态
   - 提供恢复选项给用户选择
   
4. 数据迁移:
   - 版本升级时自动迁移数据
   - 提供回滚到旧版本选项
```

---

## 七、 **扩展性设计**

### **1. 插件系统 (未来扩展)**
```
预留插件接口:
├── AI行为插件: 自定义AI行为模式
├── 文化生成插件: 自定义文化形成规则
├── 可视化插件: 自定义数据可视化
├── 导出格式插件: 自定义导出格式
└── 主题皮肤插件: 自定义UI主题
```

### **2. 配置系统**
```
分层配置系统:
├── 应用级配置: 全局设置
├── 群聊级配置: 群聊特定设置
├── AI级配置: AI个体设置
├── 用户级配置: 用户偏好设置
└── 会话级配置: 临时会话设置
```

---

## 八、 **安全与隐私**

### **1. 本地数据安全**
```
安全措施:
1. 敏感数据加密:
   - API密钥使用Flutter Secure Storage
   - 本地数据库可选加密
   
2. 隐私保护:
   - 所有数据存储在用户设备
   - 无后台数据上传
   - 可完全离线使用
   
3. 权限控制:
   - 最小权限原则
   - 运行时权限请求
```

---

这个架构设计完全在本地运行，不需要服务器支持，同时保留了所有高级功能。关键点：

1. **服务层清晰分离**：每个服务职责单一，便于维护和测试
2. **数据流明确**：通过状态管理统一数据流动
3. **性能优化**：针对本地设备的性能考虑
4. **可扩展性**：预留了插件和扩展接口
5. **错误恢复**：完善的错误处理和恢复机制

这样的设计既能实现复杂功能，又能保证在个人设备上流畅运行。