// ignore_for_file: avoid_classes_with_only_static_members

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mirage_tea/core/models/agent_models.dart';
import 'package:uuid/uuid.dart';

/// AI角色管理器 - 管理AI角色的创建、编辑和使用
class AgentManager {
  static const String _agentBoxName = 'ai_agents';
  static const String _templateBoxName = 'agent_templates';

  static Box<Map<String, dynamic>>? _agentBox;
  static Box<Map<String, dynamic>>? _templateBox;

  // 用于通知 UI 更新的 ChangeNotifier
  static final ValueNotifier<List<AIAgent>> agentsNotifier = ValueNotifier<List<AIAgent>>([]);

  /// 获取所有角色的可监听对象
  static ValueListenable<List<AIAgent>> getAgentsListenable() {
    return agentsNotifier;
  }

  static Future<void> initialize() async {
    // 尝试删除可能存在的旧格式数据
    try {
      await Hive.deleteBoxFromDisk(_agentBoxName);
      await Hive.deleteBoxFromDisk(_templateBoxName);
    } catch (_) {
      // 如果删除失败（可能不存在），继续
    }

    await Hive.openBox<Map<String, dynamic>>(_agentBoxName);
    await Hive.openBox<Map<String, dynamic>>(_templateBoxName);
    _agentBox = Hive.box<Map<String, dynamic>>(_agentBoxName);
    _templateBox = Hive.box<Map<String, dynamic>>(_templateBoxName);

    // 初始化数据
    _refreshAgents();

    // 监听 Hive 盒子变化
    _agentBox?.listenable().addListener(_onBoxChanged);
  }

  static void _onBoxChanged() {
    _refreshAgents();
  }

  static void _refreshAgents() {
    final agents = _agentBox?.values.map(_mapToAgent).toList() ?? [];
    agentsNotifier.value = List<AIAgent>.from(agents);
  }

  /// 将 Map 转换为 AIAgent
  static AIAgent _mapToAgent(Map<String, dynamic> map) {
    return AIAgent(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      avatar: map['avatar'] ?? '',
      description: map['description'] ?? '',
      personality: AgentPersonality(
        traits: List<String>.from(map['traits'] ?? []),
        speakingStyles: List<String>.from(map['speakingStyles'] ?? []),
        catchphrases: List<String>.from(map['catchphrases'] ?? []),
        expertise: List<String>.from(map['expertise'] ?? []),
        backgroundStory: map['backgroundStory'] ?? '',
      ),
    );
  }

  /// 将 AIAgent 转换为 Map
  static Map<String, dynamic> _agentToMap(AIAgent agent) {
    return {
      'id': agent.id,
      'name': agent.name,
      'avatar': agent.avatar,
      'description': agent.description,
      'traits': agent.personality.traits,
      'speakingStyles': agent.personality.speakingStyles,
      'catchphrases': agent.personality.catchphrases,
      'expertise': agent.personality.expertise,
      'backgroundStory': agent.personality.backgroundStory,
    };
  }

  /// 创建AI角色
  static Future<AIAgent?> createAgent({
    required String name,
    String avatar = '',
    String description = '',
    required AgentPersonality personality,
    String? groupId,
    String? topic,
  }) async {
    if (_agentBox == null) {
      print('[AgentManager] ❌ 创建失败: _agentBox 为空，AgentManager 未初始化');
      return null;
    }

    final id = const Uuid().v4();
    final agent = AIAgent(
      id: id,
      name: name,
      avatar: avatar,
      description: description,
      personality: personality,
    );

    final map = _agentToMap(agent);
    await _agentBox!.put(id, map);
    _refreshAgents();

    print('[AgentManager] ✅ 创建角色成功: $name (ID: $id)');
    print('[AgentManager]   - 角色数量: ${_agentBox?.length ?? 0}');
    return agent;
  }

  /// 获取角色
  static AIAgent? getAgent(String id) {
    final map = _agentBox?.get(id);
    if (map != null) {
      return _mapToAgent(map);
    }
    return null;
  }

  /// 更新角色
  static Future<void> updateAgent(AIAgent agent) async {
    await _agentBox?.put(agent.id, _agentToMap(agent));
    _refreshAgents();
    print('[AgentManager] 更新角色: ${agent.name}');
  }

  /// 删除角色
  static Future<void> deleteAgent(String id) async {
    await _agentBox?.delete(id);
    _refreshAgents();
    print('[AgentManager] 删除角色: $id');
  }

  /// 获取所有角色
  static List<AIAgent> getAllAgents() {
    return _agentBox?.values.map(_mapToAgent).toList() ?? [];
  }

  /// 获取角色模板列表
  static List<AgentTemplate> getTemplates() {
    return _templateBox?.values.map((map) => AgentTemplate(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      personality: AgentPersonality(
        traits: List<String>.from(map['traits'] ?? []),
        speakingStyles: List<String>.from(map['speakingStyles'] ?? []),
        catchphrases: List<String>.from(map['catchphrases'] ?? []),
        expertise: List<String>.from(map['expertise'] ?? []),
        backgroundStory: map['backgroundStory'] ?? '',
      ),
      tagIds: List<String>.from(map['tagIds'] ?? []),
    )).toList() ?? [];
  }

  /// 保存为模板
  static Future<AgentTemplate> saveAsTemplate({
    required String name,
    String description = '',
    required AgentPersonality personality,
    List<String> tagIds = const [],
  }) async {
    final id = const Uuid().v4();
    final template = AgentTemplate(
      id: id,
      name: name,
      description: description,
      personality: personality,
      tagIds: tagIds,
    );

    await _templateBox?.put(id, {
      'id': template.id,
      'name': template.name,
      'description': template.description,
      'traits': template.personality.traits,
      'speakingStyles': template.personality.speakingStyles,
      'catchphrases': template.personality.catchphrases,
      'expertise': template.personality.expertise,
      'backgroundStory': template.personality.backgroundStory,
      'tagIds': template.tagIds,
    });

    print('[AgentManager] 保存模板: $name (ID: $id)');
    return template;
  }
}
