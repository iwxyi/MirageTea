import 'dart:async';
import 'dart:math';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mirage_tea/core/models/civilization_models.dart';

/// 文化服务 - 管理AI群体的文化特征和黑话
class CultureService {
  static const String _cultureBoxName = 'cultures';
  
  static Box<Culture>? _cultureBox;
  
  static Future<void> initialize() async {
    await Hive.openBox<Culture>(_cultureBoxName);
    _cultureBox = Hive.box<Culture>(_cultureBoxName);
  }
  
  /// 获取群聊文化
  static Culture? getCulture(String groupId) {
    return _cultureBox?.get(groupId);
  }
  
  /// 创建或获取文化
  static Future<Culture> getOrCreateCulture(String groupId) async {
    var culture = _cultureBox?.get(groupId);
    if (culture == null) {
      culture = Culture(
        id: groupId,
        groupId: groupId,
        name: '${groupId.substring(0, 4)}文化',
      );
      await culture.save();
    }
    return culture;
  }
  
  /// 注册新黑话
  static Future<void> registerSlang(String groupId, String slang) async {
    final culture = await getOrCreateCulture(groupId);
    if (!culture.slang.contains(slang)) {
      culture.slang.add(slang);
      await culture.save();
    }
  }
  
  /// 创建仪式
  static Future<void> createRitual(String groupId, String ritual) async {
    final culture = await getOrCreateCulture(groupId);
    if (!culture.rituals.contains(ritual)) {
      culture.rituals.add(ritual);
      await culture.save();
    }
  }
  
  /// 黑话检测器
  static bool slangDetector(String content, List<String> slangs) {
    for (final slang in slangs) {
      if (content.contains(slang)) return true;
    }
    return false;
  }
  
  /// 词频分析
  static Map<String, int> frequencyAnalyzer(List<String> messages) {
    final frequency = <String, int>{};
    
    for (final message in messages) {
      final words = message.split(RegExp(r'\s+|，|。|！|？'));
      for (final word in words) {
        if (word.length >= 2) {
          frequency[word] = (frequency[word] ?? 0) + 1;
        }
      }
    }
    
    return frequency;
  }
  
  /// 模式匹配
  static List<String> patternMatcher(String content, List<RegExp> patterns) {
    final matches = <String>[];
    for (final pattern in patterns) {
      matches.addAll(pattern.allMatches(content).map((m) => m.group(0)!));
    }
    return matches;
  }
  
  /// 计算文化传播概率
  static double calculateSpreadProbability(String cultureElement, int usageCount) {
    // 使用S型曲线模拟传播概率
    final baseProbability = 0.3;
    final growthRate = 0.1;
    return baseProbability + (1 - baseProbability) / (1 + exp(-growthRate * (usageCount - 10)));
  }
  
  /// 文化进化
  static Future<void> evolveCulture(String groupId) async {
    final culture = await getOrCreateCulture(groupId);
    
    // 根据消息频率更新文化凝聚力
    // 频繁互动提高凝聚力
    if (culture.cohesion < 1.0) {
      culture.cohesion = min(1.0, culture.cohesion + 0.01);
      await culture.save();
    }
  }
  
  /// 影响AI使用特定文化元素
  static Future<void> influenceAgents(String groupId, String cultureElement) async {
    // 增加文化元素的使用频率
    final culture = await getOrCreateCulture(groupId);
    
    // 记录使用历史（简化版）
    culture.values[cultureElement] = (culture.values[cultureElement] ?? 0) + 1;
    await culture.save();
  }
  
  /// 获取文化报告
  static Future<Map<String, dynamic>> getCultureReport(String groupId) async {
    final culture = await getOrCreateCulture(groupId);
    
    return {
      'name': culture.name,
      'slangCount': culture.slang.length,
      'ritualCount': culture.rituals.length,
      'cohesion': culture.cohesion,
      'topValues': culture.values.entries.take(5).toList(),
      'createdAt': culture.createdAt,
    };
  }
  
  /// 可视化文化网络（返回数据结构）
  static Map<String, dynamic> visualizeCultureNetwork(String groupId) {
    final culture = getCulture(groupId);
    if (culture == null) return {};
    
    return {
      'nodes': [
        {'id': 'culture', 'label': culture.name, 'type': 'culture'},
        ...culture.slang.map((s) => {'id': s, 'label': s, 'type': 'slang'}),
        ...culture.rituals.map((r) => {'id': r, 'label': r, 'type': 'ritual'}),
      ],
      'edges': [
        ...culture.slang.map((s) => {'from': 'culture', 'to': s}),
        ...culture.rituals.map((r) => {'from': 'culture', 'to': r}),
      ],
    };
  }
}

