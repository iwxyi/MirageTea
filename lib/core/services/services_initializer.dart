import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mirage_tea/core/services/memory_service.dart';
import 'package:mirage_tea/core/services/relationship_service.dart';
import 'package:mirage_tea/core/services/culture_service.dart';
import 'package:mirage_tea/core/services/civilization_service.dart';
import 'package:mirage_tea/core/services/conversation_scheduler.dart';
import 'package:mirage_tea/core/services/ai_model_manager.dart';

class ServicesInitializer {
  static Future<void> initialize() async {
    // 初始化Hive数据库
    await _initHive();
    
    // 初始化各服务
    await _initServices();
  }
  
  static Future<void> _initHive() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(documentsDir.path);
    
    // 注册Hive适配器
    // TODO: 添加更多Adapter
  }
  
  static Future<void> _initServices() async {
    // 初始化各服务
    await MemoryService.initialize();
    await RelationshipService.initialize();
    await CultureService.initialize();
    await CivilizationService.initialize();
    await ConversationScheduler.initialize();
    await AIModelManager.initialize();
  }
}

