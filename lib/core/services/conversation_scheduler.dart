import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mirage_tea/core/models/chat_models.dart';
import 'memory_service.dart';
import 'relationship_service.dart';
import 'culture_service.dart';
import 'civilization_service.dart';
import 'ai_model_manager.dart';

/// 对话调度服务 - 控制AI发言顺序和对话节奏
class ConversationScheduler {
  static const String _messageBoxName = 'messages';
  static const String _groupStateBoxName = 'group_states';
  
  static Box<ChatMessage>? _messageBox;
  static Box<dynamic>? _groupStateBox;
  
  // 控制参数
  static const int _minMessagesBeforeRepeat = 3; // 最小发言间隔
  static const double _baseSpeakingProbability = 0.3; // 基础发言概率
  static const int _defaultPaceMs = 2000; // 默认节奏间隔
  
  // 状态
  static bool _isRunning = false;
  static String? _currentGroupId;
  static Timer? _paceTimer;
  static List<String> _recentSpeakers = [];
  
  static Future<void> initialize() async {
    await Hive.openBox<ChatMessage>(_messageBoxName);
    await Hive.openBox<dynamic>(_groupStateBoxName);
    _messageBox = Hive.box<ChatMessage>(_messageBoxName);
    _groupStateBox = Hive.box<dynamic>(_groupStateBoxName);
  }
  
  /// 开始对话
  static Future<void> startConversation(String groupId) async {
    if (_isRunning) {
      await stopConversation();
    }
    
    _currentGroupId = groupId;
    _isRunning = true;
    
    // 初始化群聊状态
    await _initGroupState(groupId);
    
    // 开始调度循环
    _startSchedulerLoop();
  }
  
  /// 暂停对话
  static Future<void> pauseConversation() async {
    _isRunning = false;
    _paceTimer?.cancel();
    _paceTimer = null;
    
    // 保存状态
    if (_currentGroupId != null) {
      await _saveGroupState(_currentGroupId!);
    }
  }
  
  /// 恢复对话
  static Future<void> resumeConversation() async {
    if (_currentGroupId == null) return;
    
    _isRunning = true;
    _startSchedulerLoop();
  }
  
  /// 停止对话
  static Future<void> stopConversation() async {
    _isRunning = false;
    _paceTimer?.cancel();
    _paceTimer = null;
    
    if (_currentGroupId != null) {
      await _saveGroupState(_currentGroupId!);
    }
    
    _currentGroupId = null;
    _recentSpeakers.clear();
  }
  
  /// 调度循环
  static void _startSchedulerLoop() {
    if (!_isRunning || _currentGroupId == null) return;
    
    _paceTimer = Timer.periodic(
      Duration(milliseconds: _defaultPaceMs),
      (_) async {
        if (!_isRunning) return;
        
        await _processTurn();
      },
    );
  }
  
  /// 处理一轮对话
  static Future<void> _processTurn() async {
    if (_currentGroupId == null) return;
    
    final groupState = _getGroupState(_currentGroupId!);
    final agentIds = groupState['agentIds'] as List<String>;
    
    // 选择下一个发言者
    final speakerId = await _selectNextSpeaker(agentIds);
    if (speakerId == null) return;
    
    _recentSpeakers.add(speakerId);
    if (_recentSpeakers.length > _minMessagesBeforeRepeat * 2) {
      _recentSpeakers.removeAt(0);
    }
    
    // 获取发言紧迫性
    final urgency = await _calculateSpeakingUrgency(speakerId, agentIds);
    
    // 生成响应
    final response = await _generateResponse(speakerId);
    
    // 创建消息
    final message = ChatMessage(
      groupId: _currentGroupId!,
      agentId: speakerId,
      content: response,
      type: MessageType.normal,
    );
    
    await message.save();
    
    // 更新服务
    await _updateServices(speakerId, response);
  }
  
  /// 选择下一个发言者
  static Future<String?> _selectNextSpeaker(List<String> agentIds) async {
    if (agentIds.isEmpty) return null;
    
    final candidates = <String, double>{};
    
    for (final agentId in agentIds) {
      // 避免连续发言
      if (_recentSpeakers.isNotEmpty && _recentSpeakers.last == agentId) {
        continue;
      }
      
      // 计算发言概率
      var probability = _baseSpeakingProbability;
      
      // 基于关系计算支持倾向
      final otherAgents = agentIds.where((id) => id != agentId);
      for (final otherId in otherAgents) {
        if (RelationshipService.shouldSupport(agentId, otherId)) {
          probability += 0.1;
        }
        if (RelationshipService.shouldOppose(agentId, otherId)) {
          probability -= 0.05;
        }
      }
      
      candidates[agentId] = probability;
    }
    
    if (candidates.isEmpty) {
      // 如果都被过滤，返回随机agent
      return agentIds[DateTime.now().millisecond % agentIds.length];
    }
    
    // 根据概率选择
    final total = candidates.values.reduce((a, b) => a + b);
    var random = Random().nextDouble() * total;
    
    for (final entry in candidates.entries) {
      random -= entry.value;
      if (random <= 0) {
        return entry.key;
      }
    }
    
    return candidates.keys.first;
  }
  
  /// 计算发言紧迫性
  static Future<double> _calculateSpeakingUrgency(
    String agentId, 
    List<String> agentIds,
  ) async {
    var urgency = 0.5;
    
    // 距离上次发言越远，紧迫性越高
    final recentIndex = _recentSpeakers.lastIndexOf(agentId);
    if (recentIndex >= 0) {
      urgency += 0.1 * (5 - recentIndex);
    } else {
      urgency += 0.3;
    }
    
    // 根据关系计算
    for (final otherId in agentIds) {
      if (RelationshipService.shouldSupport(agentId, otherId)) {
        urgency += 0.05;
      }
    }
    
    return urgency.clamp(0.0, 1.0);
  }
  
  /// 生成响应
  static Future<String> _generateResponse(String agentId) async {
    if (_currentGroupId == null) return '';
    
    // 获取上下文
    final context = await _buildContext(agentId);
    
    // 调用AI模型生成响应
    final response = await AIModelManager.generateResponse(
      agentId: agentId,
      groupId: _currentGroupId!,
      context: context,
    );
    
    return response;
  }
  
  /// 构建上下文
  static Future<Map<String, dynamic>> _buildContext(String agentId) async {
    if (_currentGroupId == null) return {};
    
    final messages = _getRecentMessages(_currentGroupId!, limit: 10);
    final shortTermMemories = await MemoryService.getShortTermMemories(agentId);
    final relevantMemories = await MemoryService.retrieveRelevantMemories(
      agentId: agentId,
      query: messages.map((m) => m.content).join(' '),
      limit: 5,
    );
    final culture = CultureService.getCulture(_currentGroupId!);
    final civilizationState = CivilizationService.getCivilizationState(_currentGroupId!);
    
    return {
      'messages': messages,
      'shortTermMemories': shortTermMemories,
      'relevantMemories': relevantMemories,
      'culture': culture,
      'civilizationState': civilizationState,
      'recentSpeakers': _recentSpeakers,
    };
  }
  
  /// 更新各服务
  static Future<void> _updateServices(String agentId, String content) async {
    if (_currentGroupId == null) return;
    
    // 更新记忆
    final importance = MemoryService.calculateMemoryImportance(content, '');
    await MemoryService.storeMemory(
      agentId: agentId,
      content: content,
      importance: importance,
    );
    
    // 更新关系（所有其他参与者）
    // TODO: 获取实际参与讨论的agentIds
    // for (final otherId in agentIds) {
    //   await RelationshipService.updateRelationship(
    //     agentId1: agentId,
    //     agentId2: otherId,
    //   );
    // }
    
    // 更新文明
    await CivilizationService.progressCivilization(_currentGroupId!);
    
    // 更新文化
    await CultureService.evolveCulture(_currentGroupId!);
  }
  
  /// 获取最近消息
  static List<ChatMessage> _getRecentMessages(String groupId, {int limit = 20}) {
    return (_messageBox?.values.toList() ?? [])
        .where((m) => m.groupId == groupId)
        .toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp))
          ..take(limit)
          ..toList()
          ..reversed;
  }
  
  /// 检测话题漂移
  static Future<bool> _detectTopicDrift(String groupId) async {
    final messages = _getRecentMessages(groupId, limit: 10);
    if (messages.length < 5) return false;
    
    // 简单的话题漂移检测 - 检查关键词变化
    final recentKeywords = _extractKeywords(
      messages.take(5).map((m) => m.content).join(' '),
    );
    final olderKeywords = _extractKeywords(
      messages.skip(5).take(5).map((m) => m.content).join(' '),
    );
    
    final overlap = recentKeywords.where((k) => olderKeywords.contains(k)).length;
    return overlap / recentKeywords.length < 0.3;
  }
  
  /// 引入新话题
  static Future<void> _introduceNewTopic(String groupId) async {
    // TODO: 实现话题引入逻辑
  }
  
  /// 保持话题连贯性
  static Future<void> _maintainCohesion(String groupId) async {
    if (await _detectTopicDrift(groupId)) {
      await _introduceNewTopic(groupId);
    }
  }
  
  /// 提取关键词
  static List<String> _extractKeywords(String content) {
    // 简单的关键词提取
    final words = content.split(RegExp(r'\s+|，|。|！|？'))
        .where((w) => w.length >= 2 && w.length <= 5)
        .toSet()
        .toList();
    
    return words.take(10).toList();
  }
  
  /// 初始化群聊状态
  static Future<void> _initGroupState(String groupId) async {
    await _groupStateBox!.put('${groupId}_last_activity', DateTime.now());
  }
  
  /// 获取群聊状态
  static Map<String, dynamic> _getGroupState(String groupId) {
    // 从数据库获取或返回默认值
    return {
      'agentIds': [],
      'lastActivity': DateTime.now(),
    };
  }
  
  /// 保存群聊状态
  static Future<void> _saveGroupState(String groupId) async {
    await _groupStateBox!.put('${groupId}_last_activity', DateTime.now());
  }
  
  /// 用户干预 - 插入用户消息
  static Future<void> insertUserMessage(String groupId, String content) async {
    final message = ChatMessage(
      groupId: groupId,
      agentId: 'user',
      content: content,
      type: MessageType.user,
    );
    
    await message.save();
    
    // 重置最近发言者
    _recentSpeakers.clear();
  }
}

