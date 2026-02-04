import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mirage_tea/core/models/memory_models.dart';
import 'package:uuid/uuid.dart';

/// 记忆服务 -package:uuid/u 管理AI的短期记忆、长期记忆和核心记忆
class MemoryService {
  static const String _shortTermBoxName = 'short_term_memory';
  static const String _longTermBoxName = 'long_term_memory';
  
  static Box<List<String>>? _shortTermBox;
  static Box<Memory>? _longTermBox;
  
  // 短期记忆最大条数
  static const int _maxShortTermMemories = 50;
  
  static Future<void> initialize() async {
    await Hive.openBox<Memory>(_longTermBoxName);
    _longTermBox = Hive.box<Memory>(_longTermBoxName);
  }
  
  /// 存储新记忆
  static Future<Memory> storeMemory({
    required String agentId,
    required String content,
    MemoryType type = MemoryType.episodic,
    double importance = 0.5,
    List<String>? relatedMemoryIds,
  }) async {
    final memory = Memory(
      id: const Uuid().v4(),
      agentId: agentId,
      content: content,
      type: type,
      importance: importance,
      relatedMemoryIds: relatedMemoryIds ?? [],
    );
    
    await _longTermBox!.put(memory.id, memory);
    
    // 如果重要性高，加入短期记忆
    if (importance > 0.7) {
      await _addToShortTermMemory(agentId, memory.id);
    }
    
    return memory;
  }
  
  /// 检索相关记忆
  static Future<List<Memory>> retrieveRelevantMemories({
    required String agentId,
    required String query,
    int limit = 10,
  }) async {
    final memories = _longTermBox!.values
        .where((m) => m.agentId == agentId)
        .toList()
          ..sort((a, b) => b.importance.compareTo(a.importance));
    
    // 简单关键词匹配 - 实际项目中应使用向量相似度搜索
    final keywords = query.toLowerCase().split(' ');
    final relevantMemories = memories.where((memory) {
      final content = memory.content.toLowerCase();
      return keywords.any((keyword) => content.contains(keyword));
    }).take(limit).toList();
    
    // 更新访问时间
    for (final memory in relevantMemories) {
      memory.lastAccessedAt = DateTime.now();
      await memory.save();
    }
    
    return relevantMemories;
  }
  
  /// 获取短期记忆（最近N条）
  static Future<List<Memory>> getShortTermMemories(String agentId) async {
    final memoryIds = _shortTermBox?.get(agentId) ?? [];
    final memories = <Memory>[];
    
    for (final id in memoryIds) {
      final memory = _longTermBox!.get(id);
      if (memory != null) {
        memories.add(memory);
      }
    }
    
    return memories;
  }
  
  /// 获取长期记忆摘要
  static Future<String> getLongTermMemorySummary(String agentId) async {
    final memories = _longTermBox!.values
        .where((m) => m.agentId == agentId && m.importance > 0.6)
        .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt))
          ..take(20);
    
    if (memories.isEmpty) return '';
    
    final sb = StringBuffer();
    sb.writeln('重要记忆摘要：');
    for (final memory in memories) {
      sb.writeln('- ${memory.content}');
    }
    
    return sb.toString();
  }
  
  /// 记忆摘要生成
  static Future<void> summarizeMemories(String agentId) async {
    // TODO: 使用AI生成记忆摘要，合并相似记忆
  }
  
  /// 遗忘低重要性记忆
  static Future<void> forgetLowImportanceMemories(String agentId) async {
    final threshold = 0.2;
    final toDelete = <String>[];
    
    for (final memory in _longTermBox!.values) {
      if (memory.agentId == agentId && memory.importance < threshold) {
        toDelete.add(memory.id);
      }
    }
    
    for (final id in toDelete) {
      await _longTermBox!.delete(id);
    }
  }
  
  /// 计算记忆重要性
  static double calculateMemoryImportance(String content, String context) {
    // 简单的启发式计算
    var importance = 0.5;
    
    // 检测情感词
    final emotionalWords = ['喜欢', '讨厌', '爱', '恨', '开心', '难过', '生气'];
    if (emotionalWords.any((word) => content.contains(word))) {
      importance += 0.2;
    }
    
    // 检测重要事件
    final eventWords = ['第一次', '决定', '承诺', '发现', '发明'];
    if (eventWords.any((word) => content.contains(word))) {
      importance += 0.15;
    }
    
    // 检测人物名
    final namePattern = RegExp(r'[张王李赵刘陈杨黄吴周徐孙马朱胡郭何高林罗郑梁谢宋唐许邓冯韩曹曾彭萧蔡潘田董袁于余叶蒋杜苏魏程吕丁沈任姚卢傅钟姜崔谭陆汪范金石廖贾夏韦傅方邹熊白秦孟卓郝龚');
    if (namePattern.hasMatch(content)) {
      importance += 0.1;
    }
    
    return importance.clamp(0.0, 1.0);
  }
  
  /// 添加到短期记忆
  static Future<void> _addToShortTermMemory(String agentId, String memoryId) async {
    _shortTermBox ??= await Hive.openBox<List<String>>(_shortTermBoxName);
    
    final existing = _shortTermBox!.get(agentId) ?? [];
    final updated = [memoryId, ...existing];
    
    if (updated.length > _maxShortTermMemories) {
      updated.removeLast();
    }
    
    await _shortTermBox!.put(agentId, updated);
  }
  
  /// 提取实体（人物/概念）
  static List<String> extractEntities(String content) {
    // 简单的实体提取 - 实际项目中应使用NER
    final entities = <String>[];
    final patterns = [
      RegExp(r'[张王李赵刘陈杨黄吴周徐孙马朱胡郭何高林罗郑梁谢宋唐许邓冯韩曹曾彭萧蔡潘田董袁于余叶蒋杜苏魏程吕丁沈任姚卢傅钟姜崔谭陆汪范金石廖贾夏韦傅方邹熊白秦孟卓郝龚]{1,2}'),
      RegExp(r'[^\s]{2,4}(?:老师|博士|教授|先生|女士)'),
    ];
    
    for (final pattern in patterns) {
      entities.addAll(pattern.allMatches(content).map((m) => m.group(0)!));
    }
    
    return entities.toSet().toList();
  }
}

