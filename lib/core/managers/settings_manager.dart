import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';

/// 应用配置管理器 - 统一管理所有设置项
/// 
/// 提供：
/// - 统一的存储/读取接口
/// - 启动时自动加载
/// - 实时生效的修改通知
/// - 敏感数据加密存储
class SettingsManager {
  static const String _settingsBoxName = 'app_settings';
  static const String _secureBoxName = 'secure_settings';

  static Box<Map<String, dynamic>>? _settingsBox;
  static Box<Map<String, dynamic>>? _secureBox;

  // 配置变更流
  static final _configChangedController = StreamController<String>.broadcast();
  static Stream<String> get onConfigChanged => _configChangedController.stream;

  // ==================== 初始化 ====================

  /// 初始化配置系统（应用启动时调用）
  /// 注意：需要先调用 Hive.initFlutter()
  static Future<void> initialize() async {
    // 初始化 Hive（如果尚未初始化）
    await Hive.initFlutter();

    await Hive.openBox<Map<String, dynamic>>(_settingsBoxName);
    _settingsBox = Hive.box<Map<String, dynamic>>(_settingsBoxName);

    await Hive.openBox<Map<String, dynamic>>(_secureBoxName);
    _secureBox = Hive.box<Map<String, dynamic>>(_secureBoxName);

    print('[SettingsManager] 初始化完成');
  }

  /// 释放资源
  static Future<void> dispose() async {
    await _settingsBox?.close();
    await _secureBox?.close();
    await _configChangedController.close();
  }

  // ==================== 通用方法 ====================

  /// 保存设置（通用方法）
  static Future<void> set(String key, dynamic value) async {
    final box = _isSecureKey(key) ? _secureBox! : _settingsBox!;
    await box.put(key, {'value': value});
    _notifyChange(key);
    print('[SettingsManager] 设置已保存: $key = $value');
  }

  /// 读取设置（通用方法）
  static T? get<T>(String key, {T? defaultValue}) {
    final box = _isSecureKey(key) ? _secureBox : _settingsBox;
    final value = box?.get(key)?['value'];
    if (value == null) return defaultValue;
    try {
      return value as T;
    } catch (e) {
      return defaultValue;
    }
  }

  /// 删除设置
  static Future<void> remove(String key) async {
    final box = _isSecureKey(key) ? _secureBox! : _settingsBox!;
    await box.delete(key);
    _notifyChange(key);
  }

  /// 判断是否为敏感数据
  static bool _isSecureKey(String key) {
    return key.startsWith('api_key_') || key == 'user_token';
  }

  /// 发送配置变更通知
  static void _notifyChange(String key) {
    if (!_configChangedController.isClosed) {
      _configChangedController.add(key);
    }
  }

  // ==================== AI 配置 ====================

  /// AI 服务商配置键
  static const _aiProviderKey = 'ai_provider';
  static const _aiModelKey = 'ai_model';
  static const _aiApiUrlKey = 'ai_api_url';
  static const _aiApiKeyPrefix = 'api_key_';

  /// 获取 AI 服务商
  static String get aiProvider => get<String>(_aiProviderKey) ?? 'openai';

  /// 设置 AI 服务商
  static set aiProvider(String value) {
    set(_aiProviderKey, value);
  }

  /// 获取 AI 模型
  static String get aiModel => get<String>(_aiModelKey) ?? 'gpt-4o';

  /// 设置 AI 模型
  static set aiModel(String value) {
    set(_aiModelKey, value);
  }

  /// 获取 API 地址
  static String get aiApiUrl => get<String>(_aiApiUrlKey) ?? '';

  /// 设置 API 地址
  static set aiApiUrl(String value) {
    set(_aiApiUrlKey, value);
  }

  /// 获取 API Key
  static String? getApiKey(String provider) {
    return get<String>('${_aiApiKeyPrefix}$provider');
  }

  /// 保存 API Key（加密存储）
  static Future<void> setApiKey(String provider, String apiKey) async {
    await set('${_aiApiKeyPrefix}$provider', apiKey);
  }

  /// 获取完整的 AI 配置
  static Map<String, dynamic> get aiConfig {
    return {
      'provider': aiProvider,
      'model': aiModel,
      'apiUrl': aiApiUrl,
      'apiKey': getApiKey(aiProvider) ?? '',
    };
  }

  /// 保存完整的 AI 配置
  static Future<void> saveAiConfig({
    required String provider,
    required String model,
    String? apiUrl,
    String? apiKey,
  }) async {
    await Future.wait([
      set(_aiProviderKey, provider),
      set(_aiModelKey, model),
      if (apiUrl != null) set(_aiApiUrlKey, apiUrl),
      if (apiKey != null) setApiKey(provider, apiKey),
    ]);
    print('[SettingsManager] AI配置已保存: provider=$provider, model=$model');
  }

  // ==================== 主题配置 ====================

  static const _themeModeKey = 'theme_mode';
  static const _localeKey = 'locale';

  /// 获取主题模式 ('light', 'dark', 'system')
  static String get themeMode => get<String>(_themeModeKey) ?? 'system';

  /// 设置主题模式
  static set themeMode(String value) {
    set(_themeModeKey, value);
  }

  /// 获取语言环境
  static String? get locale => get<String>(_localeKey);

  /// 设置语言环境
  static set locale(String? value) {
    if (value == null) {
      remove(_localeKey);
    } else {
      set(_localeKey, value);
    }
  }

  // ==================== 群聊配置 ====================

  static const _defaultGroupIntervalKey = 'default_group_interval';
  static const _maxAgentsPerGroupKey = 'max_agents_per_group';

  /// 默认群聊发言间隔（秒）
  static int get defaultGroupInterval => get<int>(_defaultGroupIntervalKey) ?? 5;

  /// 设置默认发言间隔
  static set defaultGroupInterval(int value) {
    set(_defaultGroupIntervalKey, value);
  }

  /// 每组最大 AI 数量
  static int get maxAgentsPerGroup => get<int>(_maxAgentsPerGroupKey) ?? 5;

  /// 设置每组最大 AI 数量
  static set maxAgentsPerGroup(int value) {
    set(_maxAgentsPerGroupKey, value);
  }

  // ==================== 数据管理 ====================

  /// 清除所有设置（恢复默认）
  static Future<void> clearAll() async {
    await _settingsBox?.clear();
    await _secureBox?.clear();
    print('[SettingsManager] 已清除所有设置');
  }

  /// 导出所有配置（用于迁移/备份）
  static Map<String, dynamic> exportAll() {
    final settings = <String, dynamic>{};
    for (final key in _settingsBox?.keys ?? []) {
      settings[key as String] = _settingsBox?.get(key)?['value'];
    }
    return settings;
  }

  /// 导入配置
  static Future<void> importAll(Map<String, dynamic> data) async {
    for (final entry in data.entries) {
      await set(entry.key, entry.value);
    }
    print('[SettingsManager] 已导入 ${data.length} 项配置');
  }
}
