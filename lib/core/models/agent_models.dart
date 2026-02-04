import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
part 'agent_models.g.dart';

// AI角色配置
@HiveType(typeId: 4)
class AIAgent extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  String name;
  
  @HiveField(2)
  String avatar;
  
  @HiveField(3)
  String description;
  
  @HiveField(4)
  AgentPersonality personality;
  
  @HiveField(5)
  AgentConfig config;
  
  @HiveField(6)
  DateTime createdAt;
  
  @HiveField(7)
  DateTime lastActiveAt;
  
  AIAgent({
    String? id,
    required this.name,
    this.avatar = '',
    this.description = '',
    required this.personality,
    AgentConfig? config,
    DateTime? createdAt,
    DateTime? lastActiveAt,
  })  : id = id ?? const Uuid().v4(),
        config = config ?? AgentConfig(),
        createdAt = createdAt ?? DateTime.now(),
        lastActiveAt = lastActiveAt ?? DateTime.now();
}

// AI人格特征
@HiveType(typeId: 5)
class AgentPersonality extends HiveObject {
  @HiveField(0)
  List<String> traits;
  
  @HiveField(1)
  List<String> speakingStyles;
  
  @HiveField(2)
  Map<String, int> preferences;
  
  @HiveField(3)
  Map<String, int> aversions;
  
  @HiveField(4)
  String backgroundStory;
  
  @HiveField(5)
  List<String> expertise;
  
  @HiveField(6)
  List<String> catchphrases;
  
  AgentPersonality({
    this.traits = const [],
    this.speakingStyles = const [],
    this.preferences = const {},
    this.aversions = const {},
    this.backgroundStory = '',
    this.expertise = const [],
    this.catchphrases = const [],
  });
}

// AI配置
@HiveType(typeId: 6)
class AgentConfig extends HiveObject {
  @HiveField(0)
  String modelType;
  
  @HiveField(1)
  String? apiKey;
  
  @HiveField(2)
  double temperature;
  
  @HiveField(3)
  int maxTokens;
  
  @HiveField(4)
  double speakingProbability;
  
  @HiveField(5)
  int responseDelayMs;
  
  AgentConfig({
    this.modelType = 'gpt-4',
    this.apiKey,
    this.temperature = 0.7,
    this.maxTokens = 1000,
    this.speakingProbability = 0.5,
    this.responseDelayMs = 0,
  });
}

// 角色模板
@HiveType(typeId: 7)
class AgentTemplate extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  String name;
  
  @HiveField(2)
  String description;
  
  @HiveField(3)
  AgentPersonality personality;
  
  @HiveField(4)
  List<String> tagIds;
  
  AgentTemplate({
    String? id,
    required this.name,
    this.description = '',
    required this.personality,
    this.tagIds = const [],
  }) : id = id ?? const Uuid().v4();
}

