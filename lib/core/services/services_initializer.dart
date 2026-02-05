import 'package:mirage_tea/core/managers/settings_manager.dart';
import 'package:mirage_tea/core/managers/agent_manager.dart';
import 'package:mirage_tea/core/managers/chat_group_manager.dart';

/// 服务初始化器 - 应用启动时初始化所有服务
class ServicesInitializer {
  /// 私有构造函数，防止实例化
  ServicesInitializer._();

  /// 初始化所有服务
  static Future<void> initialize() async {
    try {
      print('[初始化] 开始初始化服务...');

      // 1. 初始化配置系统（最先，其他服务依赖配置）
      await SettingsManager.initialize();
      print('[初始化] ✓ SettingsManager');

      // 2. 初始化 AI 模型管理器
      // 注意：配置已由 SettingsManager 管理，AIModelManager 不再需要独立的 Hive box
      print('[初始化] ✓ AIModelManager');

      // 3. 初始化 Agent Manager
      await AgentManager.initialize();
      print('[初始化] ✓ AgentManager');

      // 4. 初始化 Chat Group Manager
      await ChatGroupManager.initialize();
      print('[初始化] ✓ ChatGroupManager');

      print('[初始化] 所有服务初始化完成！');
    } catch (e) {
      print('[初始化] 初始化失败: $e');
      rethrow;
    }
  }
}
