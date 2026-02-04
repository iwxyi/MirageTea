import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
part 'civilization_models.g.dart';

// 文明状态
@HiveType(typeId: 11)
class CivilizationState extends HiveObject {
  @HiveField(0)
  final String groupId;
  
  @HiveField(1)
  int era;                 // 时代 (1 = 原始, 2 = 启蒙, 3 = 繁荣, 4 = 黄金, 5 = 永恒)
  
  @HiveField(2)
  double awakeningLevel;   // 觉醒度 (0.0 ~ 1.0)
  
  @HiveField(3)
  int totalMessages;       // 总消息数
  
  @HiveField(4)
  DateTime createdAt;
  
  @HiveField(5)
  DateTime lastMilestoneAt;

  @HiveField(6)
  DateTime lastActivityAt;

  @HiveField(7)
  List<String> milestoneIds;
  
  CivilizationState({
    String? id,
    required this.groupId,
    this.era = 1,
    this.awakeningLevel = 0.0,
    this.totalMessages = 0,
    DateTime? createdAt,
    DateTime? lastMilestoneAt,
    DateTime? lastActivityAt,
    this.milestoneIds = const [],
  })  : createdAt = createdAt ?? DateTime.now(),
        lastMilestoneAt = lastMilestoneAt ?? DateTime.now(),
        lastActivityAt = lastActivityAt ?? DateTime.now();
}

// 文化特征
@HiveType(typeId: 12)
class Culture extends HiveObject {
  @HiveField(0)
  final String groupId;
  
  @HiveField(1)
  String name;             // 文化名称
  
  @HiveField(2)
  List<String> slang;      // 黑话词汇
  
  @HiveField(3)
  List<String> rituals;    // 仪式/传统
  
  @HiveField(4)
  Map<String, int> values; // 价值观
  
  @HiveField(5)
  double cohesion;        // 文化凝聚力
  
  @HiveField(6)
  DateTime createdAt;
  
  Culture({
    String? id,
    required this.groupId,
    this.name = '',
    this.slang = const [],
    this.rituals = const [],
    this.values = const {},
    this.cohesion = 0.0,
    DateTime? createdAt,
  })  : createdAt = createdAt ?? DateTime.now();
}

// 文明成果
@HiveType(typeId: 13)
class Achievement extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String groupId;
  
  @HiveField(2)
  String title;
  
  @HiveField(3)
  String description;
  
  @HiveField(4)
  AchievementType type;
  
  @HiveField(5)
  List<String> contributorIds;
  
  @HiveField(6)
  DateTime createdAt;
  
  Achievement({
    String? id,
    required this.groupId,
    required this.title,
    this.description = '',
    this.type = AchievementType.other,
    this.contributorIds = const [],
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();
}

@HiveType(typeId: 14)
enum AchievementType {
  @HiveField(0)
  story,
  @HiveField(1)
  poem,
  @HiveField(2)
  philosophy,
  @HiveField(3)
  discovery,
  @HiveField(4)
  art,
  @HiveField(5)
  other,
}

// 事件日志
@HiveType(typeId: 15)
class EventLog extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String groupId;
  
  @HiveField(2)
  String title;
  
  @HiveField(3)
  String description;
  
  @HiveField(4)
  EventType type;
  
  @HiveField(5)
  List<String> participantIds;
  
  @HiveField(6)
  DateTime timestamp;
  
  @HiveField(7)
  Map<String, dynamic> metadata;
  
  EventLog({
    String? id,
    required this.groupId,
    required this.title,
    this.description = '',
    this.type = EventType.milestone,
    this.participantIds = const [],
    DateTime? timestamp,
    this.metadata = const {},
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();
}

@HiveType(typeId: 16)
enum EventType {
  @HiveField(0)
  milestone,
  @HiveField(1)
  crisis,
  @HiveField(2)
  discovery,
  @HiveField(3)
  conflict,
  @HiveField(4)
  celebration,
}

