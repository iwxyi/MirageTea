import 'package:flutter/material.dart';
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
  
  @HiveField(8)
  AgentParameters parameters;
  
  AIAgent({
    String? id,
    required this.name,
    this.avatar = '',
    this.description = '',
    required this.personality,
    AgentConfig? config,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    AgentParameters? parameters,
  })  : id = id ?? const Uuid().v4(),
        config = config ?? AgentConfig(),
        createdAt = createdAt ?? DateTime.now(),
        lastActiveAt = lastActiveAt ?? DateTime.now(),
        parameters = parameters ?? AgentParameters();
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

// AI核心参数（8参数系统）
@HiveType(typeId: 9)
class AgentParameters extends HiveObject {
  @HiveField(0)
  double openness;
  
  @HiveField(1)
  double rationality;
  
  @HiveField(2)
  double orderPreference;
  
  @HiveField(3)
  double socialEnergy;
  
  @HiveField(4)
  double cooperation;
  
  @HiveField(5)
  double empathy;
  
  @HiveField(6)
  double expertiseDepth;
  
  @HiveField(7)
  double creativity;
  
  @HiveField(8)
  List<String> expertiseAreas;
  
  @HiveField(9)
  String speakingStyle;
  
  AgentParameters({
    this.openness = 0,
    this.rationality = 0,
    this.orderPreference = 0,
    this.socialEnergy = 0.5,
    this.cooperation = 0.5,
    this.empathy = 0.5,
    this.expertiseDepth = 0.5,
    this.creativity = 0.5,
    this.expertiseAreas = const [],
    this.speakingStyle = 'balanced',
  });

  AgentParameters copyWith({
    double? openness,
    double? rationality,
    double? orderPreference,
    double? socialEnergy,
    double? cooperation,
    double? empathy,
    double? expertiseDepth,
    double? creativity,
    List<String>? expertiseAreas,
    String? speakingStyle,
  }) {
    return AgentParameters(
      openness: openness ?? this.openness,
      rationality: rationality ?? this.rationality,
      orderPreference: orderPreference ?? this.orderPreference,
      socialEnergy: socialEnergy ?? this.socialEnergy,
      cooperation: cooperation ?? this.cooperation,
      empathy: empathy ?? this.empathy,
      expertiseDepth: expertiseDepth ?? this.expertiseDepth,
      creativity: creativity ?? this.creativity,
      expertiseAreas: expertiseAreas ?? List<String>.from(this.expertiseAreas),
      speakingStyle: speakingStyle ?? this.speakingStyle,
    );
  }

  /// 转换为 AgentPersonality
  AgentPersonality toPersonalityTraits() {
    return AgentPersonality(
      traits: _generateTraitsFromParams(),
      speakingStyles: [speakingStyle],
      catchphrases: [],
      expertise: expertiseAreas,
      backgroundStory: '',
    );
  }

  /// 根据参数生成性格特征描述
  List<String> _generateTraitsFromParams() {
    final traits = <String>[];
    
    // 根据开放性
    if (openness > 0.5) {
      traits.add('开放思维');
    } else if (openness < -0.5) {
      traits.add('保守传统');
    }
    
    // 根据理性度
    if (rationality > 0.5) {
      traits.add('理性冷静');
    } else if (rationality < -0.5) {
      traits.add('感性热情');
    }
    
    // 根据秩序偏好
    if (orderPreference > 0.5) {
      traits.add('条理清晰');
    } else if (orderPreference < -0.5) {
      traits.add('随性自由');
    }
    
    // 根据社交能量
    if (socialEnergy > 0.7) {
      traits.add('外向活泼');
    } else if (socialEnergy < 0.3) {
      traits.add('内向安静');
    }
    
    // 根据合作意愿
    if (cooperation > 0.7) {
      traits.add('团队协作');
    } else if (cooperation < 0.3) {
      traits.add('独立自主');
    }
    
    // 根据共情能力
    if (empathy > 0.7) {
      traits.add('善解人意');
    } else if (empathy < 0.3) {
      traits.add('客观理性');
    }
    
    // 根据专业深度
    if (expertiseDepth > 0.7) {
      traits.add('专业精深');
    } else if (expertiseDepth < 0.3) {
      traits.add('博学多才');
    }
    
    // 根据创造力
    if (creativity > 0.7) {
      traits.add('富有创意');
    } else if (creativity < 0.3) {
      traits.add('务实稳重');
    }
    
    return traits;
  }

  Map<String, dynamic> toJson() {
    return {
      'openness': openness,
      'rationality': rationality,
      'orderPreference': orderPreference,
      'socialEnergy': socialEnergy,
      'cooperation': cooperation,
      'empathy': empathy,
      'expertiseDepth': expertiseDepth,
      'creativity': creativity,
      'expertiseAreas': expertiseAreas,
      'speakingStyle': speakingStyle,
    };
  }

  static AgentParameters fromJson(Map<String, dynamic> json) {
    return AgentParameters(
      openness: (json['openness'] as num).toDouble(),
      rationality: (json['rationality'] as num).toDouble(),
      orderPreference: (json['orderPreference'] as num).toDouble(),
      socialEnergy: (json['socialEnergy'] as num).toDouble(),
      cooperation: (json['cooperation'] as num).toDouble(),
      empathy: (json['empathy'] as num).toDouble(),
      expertiseDepth: (json['expertiseDepth'] as num).toDouble(),
      creativity: (json['creativity'] as num).toDouble(),
      expertiseAreas: List<String>.from(json['expertiseAreas'] ?? []),
      speakingStyle: json['speakingStyle'] ?? 'balanced',
    );
  }

  static AgentParameters getPreset(String templateId) {
    switch (templateId) {
      case 'scholar':
        return AgentParameters(
          openness: 0.3, rationality: -0.8, orderPreference: 0.6,
          socialEnergy: 0.5, cooperation: 0.8, empathy: 0.3,
          expertiseDepth: 0.9, creativity: 0.4,
          expertiseAreas: ['哲学', '科学'],
        );
      case 'artist':
        return AgentParameters(
          openness: 0.9, rationality: 0.8, orderPreference: -0.7,
          socialEnergy: 0.7, cooperation: 0.3, empathy: 0.9,
          expertiseDepth: 0.2, creativity: 0.9,
          expertiseAreas: ['艺术', '文学'],
        );
      case 'entrepreneur':
        return AgentParameters(
          openness: 0.6, rationality: -0.4, orderPreference: 0.2,
          socialEnergy: 0.9, cooperation: 0.3, empathy: 0.5,
          expertiseDepth: 0.4, creativity: 0.8,
          expertiseAreas: ['商业', '科技'],
        );
      case 'mediator':
        return AgentParameters(
          openness: 0.1, rationality: 0.5, orderPreference: 0.8,
          socialEnergy: 0.4, cooperation: 0.9, empathy: 0.8,
          expertiseDepth: 0.6, creativity: 0.3,
          expertiseAreas: ['心理学', '社会学'],
        );
      case 'debater':
        return AgentParameters(
          openness: 0.7, rationality: -0.6, orderPreference: -0.3,
          socialEnergy: 0.7, cooperation: 0.2, empathy: 0.2,
          expertiseDepth: 0.6, creativity: 0.7,
          expertiseAreas: ['哲学', '辩论', '逻辑'],
        );
      case 'visionary':
        return AgentParameters(
          openness: 0.9, rationality: 0.6, orderPreference: -0.7,
          socialEnergy: 0.6, cooperation: 0.4, empathy: 0.7,
          expertiseDepth: 0.3, creativity: 0.9,
          expertiseAreas: ['创新', '未来学', '设计'],
        );
      default:
        return AgentParameters();
    }
  }

  static String getParameterDescription(String paramId, double value) {
    switch (paramId) {
      case 'openness':
        if (value < -0.5) return '内向、保守、关注细节';
        if (value < 0) return '略内向、传统、谨慎';
        if (value == 0) return '平衡';
        if (value < 0.5) return '略外向、开放、好奇';
        return '外向、冒险、创新';
      case 'rationality':
        if (value < -0.5) return '绝对理性、数据驱动、客观';
        if (value < 0) return '偏理性、逻辑优先';
        if (value == 0) return '平衡';
        if (value < 0.5) return '偏感性、情感驱动';
        return '高度感性、价值优先';
      case 'orderPreference':
        if (value < -0.5) return '混沌、打破常规';
        if (value < 0) return '略偏好变化';
        if (value == 0) return '平衡';
        if (value < 0.5) return '略偏好秩序';
        return '秩序、遵守规则';
      case 'socialEnergy':
        if (value < 0.3) return '安静观察者';
        if (value < 0.6) return '适度活跃';
        return '活跃主导者';
      case 'cooperation':
        if (value < 0.3) return '竞争、挑战他人';
        if (value < 0.6) return '平衡';
        return '合作、寻求共识';
      case 'empathy':
        if (value < 0.3) return '逻辑至上';
        if (value < 0.6) return '平衡';
        return '高度共情';
      case 'expertiseDepth':
        if (value < 0.3) return '全能通才、广泛涉猎';
        if (value < 0.6) return '平衡';
        return '深度专家、深入分析';
      case 'creativity':
        if (value < 0.3) return '务实、执行优先';
        if (value < 0.6) return '平衡';
        return '创意发散、大胆想象';
      default:
        return '';
    }
  }
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
  
  @HiveField(5)
  AgentParameters parameters;
  
  AgentTemplate({
    String? id,
    required this.name,
    this.description = '',
    required this.personality,
    this.tagIds = const [],
    AgentParameters? parameters,
  }) : id = id ?? const Uuid().v4(),
       parameters = parameters ?? AgentParameters();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'personality': {
        'traits': personality.traits,
        'speakingStyles': personality.speakingStyles,
        'backgroundStory': personality.backgroundStory,
        'expertise': personality.expertise,
        'catchphrases': personality.catchphrases,
      },
      'tagIds': tagIds,
      'parameters': parameters.toJson(),
    };
  }

  static AgentTemplate fromJson(Map<String, dynamic> json) {
    return AgentTemplate(
      id: json['id'] ?? const Uuid().v4(),
      name: json['name'] ?? '未命名模板',
      description: json['description'] ?? '',
      personality: AgentPersonality(
        traits: List<String>.from(json['personality']?['traits'] ?? []),
        speakingStyles: List<String>.from(json['personality']?['speakingStyles'] ?? []),
        backgroundStory: json['personality']?['backgroundStory'] ?? '',
        expertise: List<String>.from(json['personality']?['expertise'] ?? []),
        catchphrases: List<String>.from(json['personality']?['catchphrases'] ?? []),
      ),
      tagIds: List<String>.from(json['tagIds'] ?? []),
      parameters: json['parameters'] != null 
          ? AgentParameters.fromJson(json['parameters']) 
          : AgentParameters(),
    );
  }
}

// 预设模板常量
class PresetTemplates {
  /// 私有构造函数，防止实例化
  PresetTemplates._();

  static const List<Map<String, dynamic>> templates = [
    {'id': 'scholar', 'name': '学者型', 'description': '理性、深思熟虑', 'icon': '🎓', 'color': Colors.blue},
    {'id': 'artist', 'name': '艺术家型', 'description': '感性、富有创造力', 'icon': '🎨', 'color': Colors.purple},
    {'id': 'entrepreneur', 'name': '企业家型', 'description': '务实、果断', 'icon': '💼', 'color': Colors.orange},
    {'id': 'mediator', 'name': '调解者型', 'description': '同理心强、善于调和', 'icon': '🕊️', 'color': Colors.green},
    {'id': 'debater', 'name': '辩手型', 'description': '逻辑清晰、善于辩论', 'icon': '⚔️', 'color': Colors.red},
    {'id': 'visionary', 'name': '梦想家型', 'description': '充满想象力、创新思维', 'icon': '💡', 'color': Colors.cyan},
  ];
}
