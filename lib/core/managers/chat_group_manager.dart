import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mirage_tea/core/models/chat_models.dart';
import 'package:mirage_tea/core/services/conversation_scheduler.dart';
/// 群聊管理器 - 管理群聊的生命周期和操作
class ChatGroupManager {
  static const String _groupBoxName = 'chat_groups';
  static const String _groupStateBoxName = 'group_states';
  
  static Box<ChatGroup>? _groupBox;
  static Box<dynamic>? _groupStateBox;
  
  // 状态变化流
  static final _groupStateController = StreamController<Map<String, dynamic>>.broadcast();
  static Stream<Map<String, dynamic>> get groupStateStream => _groupStateController.stream;
  
  static Future<void> initialize() async {
    await Hive.openBox<ChatGroup>(_groupBoxName);
    await Hive.openBox<dynamic>(_groupStateBoxName);
    _groupBox = Hive.box<ChatGroup>(_groupBoxName);
    _groupStateBox = Hive.box<dynamic>(_groupStateBoxName);
  }
  
  /// 创建群聊
  static Future<ChatGroup> createGroup({
    required String name,
    String description = '',
    List<String> agentIds = const [],
    String? topic,
  }) async {
    final group = ChatGroup(
      name: name,
      description: description,
      agentIds: agentIds,
      currentTopic: topic,
    );
    
    await group.save();
    return group;
  }
  
  /// 加载群聊
  static ChatGroup? loadGroup(String groupId) {
    return _groupBox?.get(groupId);
  }
  
  /// 保存群聊状态
  static Future<void> saveGroupState(String groupId) async {
    final group = _groupBox?.get(groupId);
    if (group != null) {
      group.lastActivityAt = DateTime.now();
      await group.save();
    }
  }
  
  /// 删除群聊
  static Future<void> deleteGroup(String groupId) async {
    // 停止对话
    await ConversationScheduler.stopConversation();
    
    // 删除群聊数据
    await _groupBox?.delete(groupId);
    await _groupStateBox?.delete(groupId);
    
    // TODO: 删除相关消息、记忆等
  }
  
  /// 添加AI成员
  static Future<void> addAgent(String groupId, String agentId) async {
    final group = _groupBox?.get(groupId);
    if (group != null && !group.agentIds.contains(agentId)) {
      group.agentIds.add(agentId);
      await group.save();
    }
  }
  
  /// 移除AI成员
  static Future<void> removeAgent(String groupId, String agentId) async {
    final group = _groupBox?.get(groupId);
    if (group != null) {
      group.agentIds.remove(agentId);
      await group.save();
    }
  }
  
  /// 配置AI成员
  static Future<void> configureAgent(String groupId, String agentId, {String? topic}) async {
    final group = _groupBox?.get(groupId);
    if (group != null) {
      if (topic != null) {
        group.currentTopic = topic;
      }
      await group.save();
    }
  }
  
  /// 克隆AI成员
  static Future<String?> cloneAgent(String groupId, String agentId) async {
    // TODO: 实现AI克隆逻辑
    return null;
  }
  
  /// 开始对话
  static Future<void> startConversation(String groupId) async {
    final group = _groupBox?.get(groupId);
    if (group != null) {
      group.state = ChatGroupState.running;
      await group.save();
      
      await ConversationScheduler.startConversation(groupId);
      
      _groupStateController.add({
        'groupId': groupId,
        'state': 'running',
      });
    }
  }
  
  /// 暂停对话
  static Future<void> pauseConversation(String groupId) async {
    final group = _groupBox?.get(groupId);
    if (group != null) {
      group.state = ChatGroupState.paused;
      await group.save();
      
      await ConversationScheduler.pauseConversation();
      
      _groupStateController.add({
        'groupId': groupId,
        'state': 'paused',
      });
    }
  }
  
  /// 恢复对话
  static Future<void> resumeConversation(String groupId) async {
    final group = _groupBox?.get(groupId);
    if (group != null) {
      group.state = ChatGroupState.running;
      await group.save();
      
      await ConversationScheduler.resumeConversation();
      
      _groupStateController.add({
        'groupId': groupId,
        'state': 'running',
      });
    }
  }
  
  /// 停止对话
  static Future<void> stopConversation(String groupId) async {
    final group = _groupBox?.get(groupId);
    if (group != null) {
      group.state = ChatGroupState.stopped;
      await group.save();
      
      await ConversationScheduler.stopConversation();
      
      _groupStateController.add({
        'groupId': groupId,
        'state': 'stopped',
      });
    }
  }
  
  /// 监控活跃度
  static Future<Map<String, dynamic>> monitorActivity(String groupId) async {
    final group = _groupBox?.get(groupId);
    if (group == null) return {};
    
    return {
      'groupId': groupId,
      'state': group.state.toString(),
      'lastActivity': group.lastActivityAt,
      'messageCount': group.agentIds.length,
    };
  }
  
  /// 生成统计
  static Future<Map<String, dynamic>> generateStatistics(String groupId) async {
    final group = _groupBox?.get(groupId);
    if (group == null) return {};
    
    return {
      'groupId': groupId,
      'name': group.name,
      'memberCount': group.agentIds.length,
      'createdAt': group.createdAt,
      'lastActivity': group.lastActivityAt,
      'duration': group.lastActivityAt.difference(group.createdAt).inHours,
    };
  }
  
  /// 导出对话
  static Future<String> exportConversation(String groupId) async {
    // TODO: 实现对话导出逻辑
    return '';
  }
  
  /// 备份群聊
  static Future<void> backupGroup(String groupId) async {
    final group = _groupBox?.get(groupId);
    if (group != null) {
      // TODO: 实现群聊备份逻辑
    }
  }
  
  /// 获取所有群聊
  static List<ChatGroup> getAllGroups() {
    final groups = (_groupBox?.values.toList() ?? []);
    groups.sort((a, b) => b.lastActivityAt.compareTo(a.lastActivityAt));
    return groups;
  }
  
  /// 获取最近的群聊
  static List<ChatGroup> getRecentGroups({int limit = 5}) {
    return getAllGroups().take(limit).toList();
  }
  
  /// 搜索群聊
  static List<ChatGroup> searchGroups(String query) {
    final lowerQuery = query.toLowerCase();
    return getAllGroups().where((group) {
      return group.name.toLowerCase().contains(lowerQuery) ||
          group.description.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}

