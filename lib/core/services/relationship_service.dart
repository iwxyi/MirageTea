import 'dart:async';
import 'dart:math';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mirage_tea/core/models/memory_models.dart';

/// 关系服务 - 管理AI之间的关系网络
class RelationshipService {
  static const String _relationshipBoxName = 'relationships';
  
  static Box<Relationship>? _relationshipBox;
  
  static Future<void> initialize() async {
    await Hive.openBox<Relationship>(_relationshipBoxName);
    _relationshipBox = Hive.box<Relationship>(_relationshipBoxName);
  }
  
  /// 获取两个AI之间的关系
  static Relationship? getRelationship(String agentId1, String agentId2) {
    final sortedIds = [agentId1, agentId2]..sort();
    final key = '${sortedIds[0]}_${sortedIds[1]}';
    return _relationshipBox?.get(key);
  }
  
  /// 创建或更新关系
  static Future<Relationship> updateRelationship({
    required String agentId1,
    required String agentId2,
    double affinityChange = 0.0,
    double trustChange = 0.0,
    bool hasSharedMemory = false,
  }) async {
    final sortedIds = [agentId1, agentId2]..sort();
    final key = '${sortedIds[0]}_${sortedIds[1]}';
    
    var relationship = _relationshipBox?.get(key);
    if (relationship == null) {
      relationship = Relationship(
        id: key,
        agentId1: sortedIds[0],
        agentId2: sortedIds[1],
      );
    }
    
    // 更新关系数据
    relationship.affinity = (relationship.affinity + affinityChange).clamp(-1.0, 1.0);
    relationship.trust = (relationship.trust + trustChange).clamp(0.0, 1.0);
    relationship.interactionCount++;
    relationship.lastInteractionAt = DateTime.now();
    
    if (hasSharedMemory) {
      relationship.sharedMemories.add(DateTime.now().toIso8601String());
    }
    
    await relationship.save();
    return relationship;
  }
  
  /// 计算好感度
  static double calculateAffinity(String agentId1, String agentId2) {
    final relationship = getRelationship(agentId1, agentId2);
    return relationship?.affinity ?? 0.0;
  }
  
  /// 计算信任度
  static double calculateTrust(String agentId1, String agentId2) {
    final relationship = getRelationship(agentId1, agentId2);
    return relationship?.trust ?? 0.5;
  }
  
  /// 获取互动倾向（是否支持/反对某AI的观点）
  static double getInteractionInclination(String agentId1, String agentId2) {
    final relationship = getRelationship(agentId1, agentId2);
    if (relationship == null) return 0.0;
    
    // 基于好感度和信任度计算互动倾向
    return relationship.affinity * 0.7 + (relationship.trust - 0.5) * 0.3;
  }
  
  /// 是否应该支持某AI的观点
  static bool shouldSupport(String agentId, String targetId) {
    final inclination = getInteractionInclination(agentId, targetId);
    return inclination > 0.3;
  }
  
  /// 是否应该反对某AI的观点
  static bool shouldOppose(String agentId, String targetId) {
    final inclination = getInteractionInclination(agentId, targetId);
    return inclination < -0.3;
  }
  
  /// 获取所有关系（用于关系图）
  static List<Relationship> getAllRelationships() {
    return _relationshipBox?.values.toList() ?? [];
  }
  
  /// 获取某个AI的所有关系
  static List<Relationship> getAgentRelationships(String agentId) {
    return (_relationshipBox?.values.toList() ?? [])
        .where((r) => r.agentId1 == agentId || r.agentId2 == agentId)
        .toList();
  }
  
  /// 检测小团体/社区
  static List<List<String>> detectClusters(List<String> agentIds) {
    // 简化的社区检测 - 基于好感度阈值
    final clusters = <List<String>>[];
    final visited = <String>{};
    
    for (final agentId in agentIds) {
      if (visited.contains(agentId)) continue;
      
      final cluster = <String>[];
      final queue = [agentId];
      
      while (queue.isNotEmpty) {
        final current = queue.removeAt(0);
        if (visited.contains(current)) continue;
        
        visited.add(current);
        cluster.add(current);
        
        // 找到高度关联的AI
        for (final otherId in agentIds) {
          if (otherId == current || visited.contains(otherId)) continue;
          
          final affinity = calculateAffinity(current, otherId);
          if (affinity > 0.5) {
            queue.add(otherId);
          }
        }
      }
      
      if (cluster.isNotEmpty) {
        clusters.add(cluster);
      }
    }
    
    return clusters;
  }
  
  /// 分析群体动态
  static Map<String, dynamic> analyzeGroupDynamics(List<String> agentIds) {
    final dynamics = <String, dynamic>{};
    final relationships = getAgentRelationships(agentIds.first);
    
    // 计算平均好感度
    double totalAffinity = 0;
    int count = 0;
    for (final r in relationships) {
      if (agentIds.contains(r.agentId1) && agentIds.contains(r.agentId2)) {
        totalAffinity += r.affinity;
        count++;
      }
    }
    dynamics['averageAffinity'] = count > 0 ? totalAffinity / count : 0.0;
    
    // 检测最活跃的关系
    Relationship? mostActive;
    int maxInteractions = 0;
    for (final r in relationships) {
      if (r.interactionCount > maxInteractions) {
        maxInteractions = r.interactionCount;
        mostActive = r;
      }
    }
    dynamics['mostActiveRelationship'] = mostActive;
    
    // 检测小团体
    dynamics['clusters'] = detectClusters(agentIds);
    
    return dynamics;
  }
  
  /// 批量更新关系（用于事件影响）
  static Future<void> batchUpdateRelationships(
    String agentId, 
    Map<String, double> affinityChanges,
  ) async {
    for (final entry in affinityChanges.entries) {
      await updateRelationship(
        agentId1: agentId,
        agentId2: entry.key,
        affinityChange: entry.value,
      );
    }
  }
}

