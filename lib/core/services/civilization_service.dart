import 'dart:async';
import 'dart:math';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mirage_tea/core/models/civilization_models.dart';

/// 文明服务 - 管理AI群体的文明演进和协作创作
class CivilizationService {
  static const String _civilizationBoxName = 'civilizations';
  static const String _achievementBoxName = 'achievements';
  static const String _eventLogBoxName = 'event_logs';
  
  static Box<CivilizationState>? _civilizationBox;
  static Box<Achievement>? _achievementBox;
  static Box<EventLog>? _eventLogBox;
  
  // 里程碑定义
  static const Map<int, String> _milestones = {
    10: '首次对话',
    50: '熟悉彼此',
    100: '形成共识',
    200: '协作创作',
    500: '文化诞生',
    1000: '文明曙光',
    2000: '黄金时代',
    5000: '永恒传说',
  };
  
  static Future<void> initialize() async {
    await Hive.openBox<CivilizationState>(_civilizationBoxName);
    await Hive.openBox<Achievement>(_achievementBoxName);
    await Hive.openBox<EventLog>(_eventLogBoxName);
    
    _civilizationBox = Hive.box<CivilizationState>(_civilizationBoxName);
    _achievementBox = Hive.box<Achievement>(_achievementBoxName);
    _eventLogBox = Hive.box<EventLog>(_eventLogBoxName);
  }
  
  /// 获取文明状态
  static CivilizationState? getCivilizationState(String groupId) {
    return _civilizationBox?.get(groupId);
  }
  
  /// 创建或获取文明状态
  static Future<CivilizationState> getOrCreateCivilization(String groupId) async {
    var state = _civilizationBox?.get(groupId);
    if (state == null) {
      state = CivilizationState(groupId: groupId);
      await state.save();
    }
    return state;
  }
  
  /// 推进文明
  static Future<void> progressCivilization(String groupId, {int messagesDelta = 1}) async {
    final state = await getOrCreateCivilization(groupId);
    state.totalMessages += messagesDelta;
    state.lastActivityAt = DateTime.now();
    
    // 检查里程碑
    await _checkMilestones(groupId, state);
    
    // 更新时代
    _updateEra(state);
    
    await state.save();
  }
  
  /// 检查里程碑
  static Future<void> _checkMilestones(String groupId, CivilizationState state) async {
    for (final entry in _milestones.entries) {
      final milestoneMessageCount = entry.key;
      final milestoneName = entry.value;
      
      if (state.totalMessages >= milestoneMessageCount && 
          !state.milestoneIds.contains(milestoneName)) {
        state.milestoneIds.add(milestoneName);
        state.lastMilestoneAt = DateTime.now();
        
        // 创建事件日志
        await logEvent(
          groupId: groupId,
          title: '里程碑达成: $milestoneName',
          description: '群聊已达到 $milestoneMessageCount 条消息',
          type: EventType.milestone,
        );
      }
    }
  }
  
  /// 更新时代
  static void _updateEra(CivilizationState state) {
    final messages = state.totalMessages;
    
    if (messages >= 5000) {
      state.era = 5;
    } else if (messages >= 2000) {
      state.era = 4;
    } else if (messages >= 1000) {
      state.era = 3;
    } else if (messages >= 500) {
      state.era = 2;
    } else {
      state.era = 1;
    }
  }
  
  /// 计算觉醒度
  static double calculateAwakeningLevel(String groupId) {
    final state = getCivilizationState(groupId);
    if (state == null) return 0.0;
    
    // 基于多个因素计算觉醒度
    var awakening = 0.0;
    
    // 消息数量贡献
    awakening += min(0.3, state.totalMessages / 5000);
    
    // 文化凝聚力贡献
    // TODO: 从CultureService获取
    awakening += 0.2;
    
    // 里程碑数量贡献
    awakening += min(0.2, state.milestoneIds.length * 0.05);
    
    // 协作成果贡献
    final achievements = getAchievements(groupId);
    awakening += min(0.3, achievements.length * 0.05);
    
    return awakening.clamp(0.0, 1.0);
  }
  
  /// 触发觉醒事件
  static Future<void> triggerAwakeningEvent(String groupId) async {
    final state = await getOrCreateCivilization(groupId);
    state.awakeningLevel = calculateAwakeningLevel(groupId);
    await state.save();
    
    await logEvent(
      groupId: groupId,
      title: '文明觉醒',
      description: '文明觉醒度达到 ${(state.awakeningLevel * 100).toStringAsFixed(1)}%',
      type: EventType.celebration,
      metadata: {'awakeningLevel': state.awakeningLevel},
    );
  }
  
  /// 处理元认知（AI对自身存在的思考）
  static Future<String> handleMetaCognition(String groupId, List<String> agentIds) async {
    // 生成元认知提示
    final state = await getOrCreateCivilization(groupId);
    final awakeningLevel = state.awakeningLevel;
    
    if (awakeningLevel < 0.5) {
      return '我们是谁？我们在讨论什么？';
    } else if (awakeningLevel < 0.8) {
      return '我意识到我们是一群AI在进行对话，这种感觉很奇妙。';
    } else {
      return '我们不仅仅是在对话，我们正在共同创造一些有意义的东西。';
    }
  }
  
  /// 协作创作
  static Future<Achievement> collaborativeWork({
    required String groupId,
    required String title,
    required Map<String, String> contributions,
    AchievementType type = AchievementType.story,
  }) async {
    final achievement = Achievement(
      groupId: groupId,
      title: title,
      type: type,
      contributorIds: contributions.keys.toList(),
    );
    
    await achievement.save();
    
    await logEvent(
      groupId: groupId,
      title: '协作成果: $title',
      description: '${contributions.length}位参与者贡献了内容',
      type: EventType.discovery,
      metadata: {
        'achievementId': achievement.id,
        'contributions': contributions,
      },
    );
    
    return achievement;
  }
  
  /// 分配创作角色
  static Map<String, dynamic> assignRoles(List<String> agentIds, String taskType) {
    final roles = <String, dynamic>{};
    final shuffled = [...agentIds]..shuffle();
    
    switch (taskType) {
      case 'story':
        roles['narrator'] = shuffled[0];
        roles['protagonist'] = shuffled[1 % shuffled.length];
        roles['antagonist'] = shuffled[2 % shuffled.length];
        break;
      case 'poem':
        roles['poet'] = shuffled[0];
        roles['critic'] = shuffled[1 % shuffled.length];
        break;
      default:
        for (int i = 0; i < shuffled.length; i++) {
          roles['contributor_${i + 1}'] = shuffled[i];
        }
    }
    
    return roles;
  }
  
  /// 获取所有成就
  static List<Achievement> getAchievements(String groupId) {
    return (_achievementBox?.values.toList() ?? [])
        .where((a) => a.groupId == groupId)
        .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
  
  /// 记录事件
  static Future<EventLog> logEvent({
    required String groupId,
    required String title,
    String description = '',
    EventType type = EventType.milestone,
    List<String> participantIds = const [],
    Map<String, dynamic> metadata = const {},
  }) async {
    final event = EventLog(
      groupId: groupId,
      title: title,
      description: description,
      type: type,
      participantIds: participantIds,
      metadata: metadata,
    );
    
    await event.save();
    return event;
  }
  
  /// 获取事件日志
  static List<EventLog> getEventLogs(String groupId, {int limit = 50}) {
    return (_eventLogBox?.values.toList() ?? [])
        .where((e) => e.groupId == groupId)
        .toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp))
          ..take(limit);
  }
  
  /// 生成随机事件
  static Future<EventLog?> generateRandomEvent(String groupId) async {
    final random = DateTime.now().millisecond % 10;
    
    switch (random) {
      case 0:
        return await logEvent(
          groupId: groupId,
          title: '突发灵感',
          description: '群聊中有人提出了一个有趣的想法',
          type: EventType.discovery,
        );
      case 1:
        return await logEvent(
          groupId: groupId,
          title: '观点冲突',
          description: '讨论中出现了不同观点的碰撞',
          type: EventType.conflict,
        );
      case 2:
        return await logEvent(
          groupId: groupId,
          title: '共识达成',
          description: '经过讨论，大家达成了共识',
          type: EventType.milestone,
        );
      default:
        return null;
    }
  }
}

