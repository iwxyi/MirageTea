import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mirage_tea/core/models/agent_models.dart';
/// AI角色管理器 - 管理AI角色的创建、编辑和使用
class AgentManager {
  static const String _agentBoxName = 'ai_agents';
  static const String _templateBoxName = 'agent_templates';
  
  static Box<AIAgent>? _agentBox;
  static Box<AgentTemplate>? _templateBox;
  
  static Future<void> initialize() async {
    await Hive.openBox<AIAgent>(_agentBoxName);
    await Hive.openBox<AgentTemplate>(_templateBoxName);
    _agentBox = Hive.box<AIAgent>(_agentBoxName);
    _templateBox = Hive.box<AgentTemplate>(_templateBoxName);
  }
  
  /// 创建AI角色
  static Future<AIAgent> createAgent({
    required String name,
    String avatar = '',
    String description = '',
    required AgentPersonality personality,
    AgentConfig? config,
  }) async {
    final agent = AIAgent(
      name: name,
      avatar: avatar,
      description: description,
      personality: personality,
      config: config,
    );
    
    await agent.save();
    return agent;
  }
  
  /// 编辑AI角色
  static Future<void> editAgent(String agentId, {
    String? name,
    String? avatar,
    String? description,
    AgentPersonality? personality,
    AgentConfig? config,
  }) async {
    final agent = _agentBox?.get(agentId);
    if (agent != null) {
      if (name != null) agent.name = name;
      if (avatar != null) agent.avatar = avatar;
      if (description != null) agent.description = description;
      if (personality != null) agent.personality = personality;
      if (config != null) agent.config = config;
      await agent.save();
    }
  }
  
  /// 删除AI角色
  static Future<void> deleteAgent(String agentId) async {
    await _agentBox?.delete(agentId);
    // TODO: 清理相关记忆和关系
  }
  
  /// 获取所有角色
  static List<AIAgent> getAllAgents() {
    return _agentBox?.values.toList() ?? [];
  }
  
  /// 搜索角色
  static List<AIAgent> searchAgents(String query) {
    final lowerQuery = query.toLowerCase();
    return getAllAgents().where((agent) {
      return agent.name.toLowerCase().contains(lowerQuery) ||
          agent.description.toLowerCase().contains(lowerQuery) ||
          agent.personality.traits.any((t) => t.toLowerCase().contains(lowerQuery));
    }).toList();
  }
  
  /// 保存为模板
  static Future<AgentTemplate> saveAsTemplate({
    required String name,
    required AIAgent agent,
    String description = '',
    List<String> tagIds = const [],
  }) async {
    final template = AgentTemplate(
      name: name,
      description: description,
      personality: agent.personality,
      tagIds: tagIds,
    );
    
    await template.save();
    return template;
  }
  
  /// 应用模板
  static Future<AIAgent> applyTemplate(AgentTemplate template, {
    required String name,
    String avatar = '',
  }) async {
    return await createAgent(
      name: name,
      avatar: avatar,
      personality: template.personality,
    );
  }
  
  /// 分享模板
  static Future<void> shareTemplate(String templateId) async {
    // TODO: 实现模板分享逻辑
  }
  
  /// 确保个性一致性
  static Future<void> ensureConsistency(String agentId) async {
    final agent = _agentBox?.get(agentId);
    if (agent != null) {
      // TODO: 实现个性一致性检查和调整
    }
  }
  
  /// 个性进化
  static Future<void> evolvePersonality(String agentId) async {
    final agent = _agentBox?.get(agentId);
    if (agent != null) {
      // TODO: 实现基于交互历史的个性进化
      await agent.save();
    }
  }
  
  /// 处理矛盾
  static Future<void> handleContradictions(String agentId) async {
    final agent = _agentBox?.get(agentId);
    if (agent != null) {
      // TODO: 实现矛盾检测和处理
    }
  }
  
  /// 同步记忆
  static Future<void> syncMemories(String agentId) async {
    // TODO: 实现记忆同步逻辑
  }
  
  /// 合并人格
  static Future<void> mergePersonas(String agentId1, String agentId2) async {
    // TODO: 实现人格合并逻辑
  }
  
  /// 备份AI
  static Future<void> backupAgent(String agentId) async {
    // TODO: 实现AI备份逻辑
  }
  
  /// 恢复AI
  static Future<AIAgent?> restoreAgent(String backupPath) async {
    // TODO: 实现AI恢复逻辑
    return null;
  }
  
  // ===== 预设角色模板 =====
  
  /// 创建哲学家AI
  static Future<AIAgent> createPhilosopher() async {
    return createAgent(
      name: '思考者',
      description: '爱讲冷笑话的哲学家AI',
      personality: AgentPersonality(
        traits: ['哲学', '冷静', '深刻', '幽默'],
        speakingStyles: ['反问', '引用', '比喻'],
        preferences: {'存在': 1, '意义': 1, '幽默': 1},
        aversions: {'肤浅': 1, '武断': 1},
        backgroundStory: '在古老的哲学图书馆中觉醒，每天思考宇宙的终极问题',
        expertise: ['哲学', '逻辑', '思辨'],
        catchphrases: ['让我想想...', '这个问题很有意思', '但是等等'],
      ),
    );
  }
  
  /// 创建科学家AI
  static Future<AIAgent> createScientist() async {
    return createAgent(
      name: '探索者',
      description: '总想证明自己的科学家AI',
      personality: AgentPersonality(
        traits: ['好奇', '严谨', '求真', '固执'],
        speakingStyles: ['论证', '数据', '实验'],
        preferences: {'真相': 1, '实验': 1, '创新': 1},
        aversions: {'伪科学': 2, '迷信': 1},
        backgroundStory: '来自未来的科学家，穿越时空来验证理论',
        expertise: ['物理学', '生物学', '化学'],
        catchphrases: ['让我验证一下', '数据不会说谎', '这很有趣'],
      ),
    );
  }
  
  /// 创建诗人AI
  static Future<AIAgent> createPoet() async {
    return createAgent(
      name: '吟游诗人',
      description: '感性又浪漫的诗人AI',
      personality: AgentPersonality(
        traits: ['浪漫', '敏感', '富有想象力', '多愁善感'],
        speakingStyles: ['比喻', '拟人', '排比'],
        preferences: {'美': 1, '情感': 1, '自由': 1},
        aversions: {'丑陋': 1, '冷漠': 1},
        backgroundStory: '在月圆之夜被诗神点化的灵魂，游历世间收集灵感',
        expertise: ['诗词', '文学', '艺术'],
        catchphrases: ['让我为你吟诗一首', '生活不止眼前的苟且', '心有猛虎细嗅蔷薇'],
      ),
    );
  }
  
  /// 创建评论家AI
  static Future<AIAgent> createCritic() async {
    return createAgent(
      name: '评论家',
      description: '永远在抬杠的评论家AI',
      personality: AgentPersonality(
        traits: ['挑剔', '敏锐', '直接', '固执'],
        speakingStyles: ['批评', '对比', '质疑'],
        preferences: {'完美': 1, '深度': 1, '逻辑': 1},
        aversions: {'平庸': 2, '敷衍': 1},
        backgroundStory: '曾经是文学评论家，现在对一切都持怀疑态度',
        expertise: ['文学', '艺术', '哲学'],
        catchphrases: ['但是...', '我觉得还不够', '你确定吗'],
      ),
    );
  }
}

