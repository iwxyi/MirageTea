import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
part 'chat_models.g.dart';

// 群聊配置
@HiveType(typeId: 0)
class ChatGroup extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  String name;
  
  @HiveField(2)
  String description;
  
  @HiveField(3)
  List<String> agentIds;
  
  @HiveField(4)
  String? currentTopic;
  
  @HiveField(5)
  DateTime createdAt;
  
  @HiveField(6)
  DateTime lastActivityAt;
  
  @HiveField(7)
  ChatGroupState state;
  
  ChatGroup({
    String? id,
    required this.name,
    this.description = '',
    this.agentIds = const [],
    this.currentTopic,
    DateTime? createdAt,
    DateTime? lastActivityAt,
    this.state = ChatGroupState.idle,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        lastActivityAt = lastActivityAt ?? DateTime.now();
}

@HiveType(typeId: 1)
enum ChatGroupState {
  @HiveField(0)
  idle,
  
  @HiveField(1)
  running,
  
  @HiveField(2)
  paused,
  
  @HiveField(3)
  stopped,
}

// 消息记录
@HiveType(typeId: 2)
class ChatMessage extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String groupId;
  
  @HiveField(2)
  final String agentId;
  
  @HiveField(3)
  final String content;
  
  @HiveField(4)
  final DateTime timestamp;
  
  @HiveField(5)
  MessageType type;
  
  @HiveField(6)
  Map<String, dynamic> metadata;
  
  ChatMessage({
    String? id,
    required this.groupId,
    required this.agentId,
    required this.content,
    DateTime? timestamp,
    this.type = MessageType.normal,
    this.metadata = const {},
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();
}

@HiveType(typeId: 3)
enum MessageType {
  @HiveField(0)
  normal,
  
  @HiveField(1)
  system,
  
  @HiveField(2)
  user,
  
  @HiveField(3)
  event,
}

