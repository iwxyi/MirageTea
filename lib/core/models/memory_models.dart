import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
part 'memory_models.g.dart';

// AI记忆
@HiveType(typeId: 8)
class Memory extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String agentId;
  
  @HiveField(2)
  String content;
  
  @HiveField(3)
  MemoryType type;
  
  @HiveField(4)
  double importance;
  
  @HiveField(5)
  DateTime createdAt;
  
  @HiveField(6)
  DateTime lastAccessedAt;
  
  @HiveField(7)
  List<String> relatedMemoryIds;
  
  @HiveField(8)
  Map<String, dynamic> metadata;
  
  @HiveField(9)
  List<double>? embedding;
  
  Memory({
    String? id,
    required this.agentId,
    required this.content,
    this.type = MemoryType.episodic,
    this.importance = 0.5,
    DateTime? createdAt,
    DateTime? lastAccessedAt,
    this.relatedMemoryIds = const [],
    this.metadata = const {},
    this.embedding,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        lastAccessedAt = lastAccessedAt ?? DateTime.now();
}

@HiveType(typeId: 9)
enum MemoryType {
  @HiveField(0)
  episodic,      // 情景记忆
  @HiveField(1)
  semantic,      // 语义记忆
  @HiveField(2)
  procedural,    // 程序性记忆
  @HiveField(3)
  emotional,     // 情感记忆
}

// 关系数据
@HiveType(typeId: 10)
class Relationship extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String agentId1;
  
  @HiveField(2)
  final String agentId2;
  
  @HiveField(3)
  double affinity;         // 好感度 (-1.0 ~ 1.0)
  
  @HiveField(4)
  double trust;            // 信任度 (0.0 ~ 1.0)
  
  @HiveField(5)
  int interactionCount;    // 互动次数
  
  @HiveField(6)
  DateTime lastInteractionAt;
  
  @HiveField(7)
  List<String> sharedMemories;
  
  @HiveField(8)
  Map<String, dynamic> history;
  
  Relationship({
    String? id,
    required this.agentId1,
    required this.agentId2,
    this.affinity = 0.0,
    this.trust = 0.5,
    this.interactionCount = 0,
    DateTime? lastInteractionAt,
    this.sharedMemories = const [],
    this.history = const {},
  })  : id = id ?? const Uuid().v4(),
        lastInteractionAt = lastInteractionAt ?? DateTime.now();
}

// 关系类型
enum RelationshipType {
  friend,
  rival,
  neutral,
  mentor,
  student,
}

