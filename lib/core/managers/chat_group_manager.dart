import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mirage_tea/core/models/chat_models.dart';
import 'package:uuid/uuid.dart';

/// 群聊管理器 - 管理群聊的生命周期和操作
class ChatGroupManager {
  static const String _groupBoxName = 'chat_groups';
  static const String _groupStateBoxName = 'group_states';

  static Box<Map<String, dynamic>>? _groupBox;
  static Box<Map<String, dynamic>>? _groupStateBox;

  // 群聊变化流
  static final _groupsController = StreamController<List<ChatGroup>>.broadcast();
  static Stream<List<ChatGroup>> get groupsStream => _groupsController.stream;

  // 状态变化流
  static final _groupStateController = StreamController<Map<String, dynamic>>.broadcast();
  static Stream<Map<String, dynamic>> get groupStateStream => _groupStateController.stream;

  /// 将 Map 转换为 ChatGroup
  static ChatGroup _mapToGroup(Map<String, dynamic> map) {
    return ChatGroup(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      agentIds: List<String>.from(map['agentIds'] ?? []),
      currentTopic: map['currentTopic'],
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      lastActivityAt: DateTime.tryParse(map['lastActivityAt'] ?? '') ?? DateTime.now(),
    );
  }

  /// 将 ChatGroup 转换为 Map
  static Map<String, dynamic> _groupToMap(ChatGroup group) {
    return {
      'id': group.id,
      'name': group.name,
      'description': group.description,
      'agentIds': group.agentIds,
      'currentTopic': group.currentTopic,
      'createdAt': group.createdAt.toIso8601String(),
      'lastActivityAt': group.lastActivityAt.toIso8601String(),
    };
  }

  /// 获取群聊列表（已排序）
  static List<ChatGroup> getAllGroups() {
    final groups = (_groupBox?.values.toList() ?? []).map(_mapToGroup).toList();
    groups.sort((a, b) => b.lastActivityAt.compareTo(a.lastActivityAt));
    return groups;
  }

  /// 通知群聊列表变化
  static void _notifyGroupsChanged() {
    _groupsController.add(getAllGroups());
  }

  static Future<void> initialize() async {
    // 尝试删除可能存在的旧格式数据
    try {
      await Hive.deleteBoxFromDisk(_groupBoxName);
      await Hive.deleteBoxFromDisk(_groupStateBoxName);
    } catch (_) {
      // 如果删除失败（可能不存在），继续
    }

    await Hive.openBox<Map<String, dynamic>>(_groupBoxName);
    await Hive.openBox<Map<String, dynamic>>(_groupStateBoxName);
    _groupBox = Hive.box<Map<String, dynamic>>(_groupBoxName);
    _groupStateBox = Hive.box<Map<String, dynamic>>(_groupStateBoxName);

    // 监听盒子变化
    _groupBox?.listenable().addListener(_notifyGroupsChanged);
  }

  /// 创建群聊
  static Future<ChatGroup> createGroup({
    required String name,
    String description = '',
    List<String> agentIds = const [],
    String? topic,
  }) async {
    final id = const Uuid().v4();
    final group = ChatGroup(
      id: id,
      name: name,
      description: description,
      agentIds: agentIds,
      currentTopic: topic,
    );

    // 确保盒子已初始化
    if (_groupBox == null || !_groupBox!.isOpen) {
      await initialize();
    }

    await _groupBox?.put(id, _groupToMap(group));
    _notifyGroupsChanged();

    print('[ChatGroupManager] 创建群聊: $name (ID: $id)');
    return group;
  }

  /// 获取群聊
  static ChatGroup? getGroup(String id) {
    final map = _groupBox?.get(id);
    if (map != null) {
      return _mapToGroup(map);
    }
    return null;
  }

  /// 加载群聊（getGroup 的别名，用于兼容旧代码）
  static ChatGroup? loadGroup(String id) {
    return getGroup(id);
  }

  /// 添加 AI 到群聊
  static Future<void> addAgent(String groupId, String agentId) async {
    final group = getGroup(groupId);
    if (group == null) return;

    if (!group.agentIds.contains(agentId)) {
      final updatedGroup = ChatGroup(
        id: group.id,
        name: group.name,
        description: group.description,
        agentIds: [...group.agentIds, agentId],
        currentTopic: group.currentTopic,
        createdAt: group.createdAt,
        lastActivityAt: group.lastActivityAt,
      );
      await _groupBox?.put(groupId, _groupToMap(updatedGroup));
      _notifyGroupsChanged();
      print('[ChatGroupManager] 添加AI到群聊: group=$groupId, agent=$agentId');
    }
  }

  /// 从群聊移除 AI
  static Future<void> removeAgent(String groupId, String agentId) async {
    final group = getGroup(groupId);
    if (group == null) return;

    final updatedGroup = ChatGroup(
      id: group.id,
      name: group.name,
      description: group.description,
      agentIds: group.agentIds.where((id) => id != agentId).toList(),
      currentTopic: group.currentTopic,
      createdAt: group.createdAt,
      lastActivityAt: group.lastActivityAt,
    );
    await _groupBox?.put(groupId, _groupToMap(updatedGroup));
    _notifyGroupsChanged();
    print('[ChatGroupManager] 从群聊移除AI: group=$groupId, agent=$agentId');
  }

  /// 更新群聊（支持命名参数）
  static Future<void> updateGroup(String groupId, {String? name, String? description, String? topic}) async {
    final group = getGroup(groupId);
    if (group == null) return;

    final updatedGroup = ChatGroup(
      id: group.id,
      name: name ?? group.name,
      description: description ?? group.description,
      agentIds: group.agentIds,
      currentTopic: topic ?? group.currentTopic,
      createdAt: group.createdAt,
      lastActivityAt: group.lastActivityAt,
    );
    await _groupBox?.put(groupId, _groupToMap(updatedGroup));
    _notifyGroupsChanged();
    print('[ChatGroupManager] 更新群聊: ${updatedGroup.name}');
  }

  /// 开始对话
  static Future<void> startConversation(String groupId) async {
    print('[ChatGroupManager] 开始对话: $groupId');
    // TODO: 实现实际的对话开始逻辑
  }

  /// 暂停对话
  static Future<void> pauseConversation(String groupId) async {
    print('[ChatGroupManager] 暂停对话: $groupId');
    // TODO: 实现实际的对话暂停逻辑
  }

  /// 停止对话
  static Future<void> stopConversation(String groupId) async {
    print('[ChatGroupManager] 停止对话: $groupId');
    // TODO: 实现实际的对话停止逻辑
  }

  /// 删除群聊
  static Future<void> deleteGroup(String groupId) async {
    await _groupBox?.delete(groupId);
    await _groupStateBox?.delete(groupId);
    _notifyGroupsChanged();
    print('[ChatGroupManager] 删除群聊: $groupId');
  }

  /// 获取群聊状态
  static Map<String, dynamic>? getGroupState(String groupId) {
    return _groupStateBox?.get(groupId);
  }

  /// 保存群聊状态
  static Future<void> saveGroupState(String groupId, Map<String, dynamic> state) async {
    await _groupStateBox?.put(groupId, state);
    print('[ChatGroupManager] 保存群聊状态: $groupId');
  }

  /// 更新活动时间
  static Future<void> updateActivityTime(String groupId) async {
    final group = getGroup(groupId);
    if (group != null) {
      final updatedGroup = ChatGroup(
        id: group.id,
        name: group.name,
        description: group.description,
        agentIds: group.agentIds,
        currentTopic: group.currentTopic,
        createdAt: group.createdAt,
        lastActivityAt: DateTime.now(),
      );
      await _groupBox?.put(groupId, _groupToMap(updatedGroup));
    }
  }
}
