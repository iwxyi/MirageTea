import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mirage_tea/core/managers/settings_manager.dart';
import 'package:mirage_tea/core/models/agent_models.dart';

/// AI模型管理器 - 封装各种AI模型的API调用
/// 
/// 注意：所有配置存储已迁移到 SettingsManager
class AIModelManager {
  // ==================== 服务商配置 ====================

  /// 服务商配置定义
  static final Map<String, APIConfig> _providerConfigs = {
    'openai': APIConfig(
      baseUrl: 'https://api.openai.com/v1',
      models: ['gpt-4o', 'gpt-4-turbo', 'gpt-4', 'gpt-3.5-turbo'],
    ),
    'anthropic': APIConfig(
      baseUrl: 'https://api.anthropic.com/v1',
      models: ['claude-3-5-sonnet-20241022', 'claude-3-opus-20240229', 'claude-3-sonnet-20240229'],
    ),
    'deepseek': APIConfig(
      baseUrl: 'https://api.deepseek.com',
      models: ['deepseek-chat', 'deepseek-reasoner'],
    ),
    'google': APIConfig(
      baseUrl: 'https://generativelanguage.googleapis.com/v1',
      models: ['gemini-1.5-pro', 'gemini-1.5-flash', 'gemini-1.0-pro'],
    ),
    'custom': APIConfig(
      baseUrl: '',
      models: [],
    ),
  };

  /// 获取所有服务商列表
  static List<Map<String, dynamic>> getProviders() {
    return [
      {'id': 'openai', 'name': 'OpenAI (GPT)', 'models': _providerConfigs['openai']!.models},
      {'id': 'anthropic', 'name': 'Anthropic (Claude)', 'models': _providerConfigs['anthropic']!.models},
      {'id': 'deepseek', 'name': 'DeepSeek', 'models': _providerConfigs['deepseek']!.models},
      {'id': 'google', 'name': 'Google (Gemini)', 'models': _providerConfigs['google']!.models},
      {'id': 'custom', 'name': '自定义', 'models': []},
    ];
  }

  /// 获取服务商配置
  static APIConfig? getProviderConfig(String provider) {
    return _providerConfigs[provider];
  }

  // ==================== 配置访问（使用 SettingsManager） ====================

  /// 获取当前选中的服务商
  static String get currentProvider => SettingsManager.aiProvider;

  /// 获取当前选中的模型
  static String get currentModel => SettingsManager.aiModel;

  /// 获取当前 API 地址
  static String get currentApiUrl => SettingsManager.aiApiUrl;

  /// 获取当前 API Key
  static String? get currentApiKey => SettingsManager.getApiKey(currentProvider);

  /// 获取当前完整配置（供外部使用）
  static Map<String, dynamic> get currentConfig {
    final provider = currentProvider;
    final providerConfig = getProviderConfig(provider);
    final isCustom = provider == 'custom';
    
    return {
      'provider': provider,
      'model': currentModel,
      'apiUrl': isCustom ? currentApiUrl : (providerConfig?.baseUrl ?? ''),
      'apiKey': currentApiKey ?? '',
      'isCustom': isCustom,
      'availableModels': providerConfig?.models ?? [],
    };
  }

  /// 判断是否已完整配置
  static bool get isConfigured {
    final apiKey = currentApiKey;
    return apiKey != null && apiKey.isNotEmpty && currentModel.isNotEmpty;
  }

  // ==================== 响应生成 ====================

  /// 生成响应（使用当前配置）
  static Future<String> generateResponse({
    required String agentId,
    required String groupId,
    required Map<String, dynamic> context,
  }) async {
    // TODO: 实现实际的AI API调用
    return _generateMockResponse(agentId, context);
  }

  // ==================== 提示词构建 ====================

  /// 生成提示词
  static String buildPrompt({
    required AIAgent agent,
    required Map<String, dynamic> context,
  }) {
    final sb = StringBuffer();
    
    sb.writeln('你是 ${agent.name}。');
    sb.writeln('性格特征: ${agent.personality.traits.join(', ')}。');
    sb.writeln('说话风格: ${agent.personality.speakingStyles.join(', ')}。');
    
    if (agent.personality.backgroundStory.isNotEmpty) {
      sb.writeln('背景故事: ${agent.personality.backgroundStory}。');
    }
    
    if (agent.personality.expertise.isNotEmpty) {
      sb.writeln('专长领域: ${agent.personality.expertise.join(', ')}。');
    }
    
    if (agent.personality.catchphrases.isNotEmpty) {
      sb.writeln('常用语: ${agent.personality.catchphrases.join(', ')}。');
    }
    
    final messages = context['messages'] as List?;
    if (messages != null && messages.isNotEmpty) {
      sb.writeln('\n最近的对话：');
      for (final msg in messages.take(10)) {
        sb.writeln('${msg['agentId']}: ${msg['content']}');
      }
    }
    
    final memories = context['relevantMemories'] as List?;
    if (memories != null && memories.isNotEmpty) {
      sb.writeln('\n相关记忆：');
      for (final memory in memories.take(5)) {
        sb.writeln('- ${memory['content']}');
      }
    }
    
    final civilizationState = context['civilizationState'];
    if (civilizationState != null) {
      sb.writeln('\n当前文明状态：');
      sb.writeln('- 时代: ${civilizationState['era']}');
      sb.writeln('- 觉醒度: ${civilizationState['awakeningLevel']?.toStringAsFixed(2)}');
    }
    
    sb.writeln('\n请根据以上信息，以${agent.name}的身份参与对话。');
    
    return sb.toString();
  }

  // ==================== API 调用方法 ====================

  /// 调用 OpenAI API
  static Future<String> callOpenAI({
    required String model,
    required String apiKey,
    required List<Map<String, String>> messages,
    double temperature = 0.7,
    int maxTokens = 1000,
  }) async {
    final dio = Dio();
    final response = await dio.post(
      '${_providerConfigs['openai']!.baseUrl}/chat/completions',
      options: Options(
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      ),
      data: {
        'model': model,
        'messages': messages,
        'temperature': temperature,
        'max_tokens': maxTokens,
      },
    );
    
    final data = response.data as Map<String, dynamic>;
    final content = data['choices']?[0]?['message']?['content'] ?? '';
    return content;
  }

  /// 调用 Anthropic API
  static Future<String> callAnthropic({
    required String model,
    required String apiKey,
    required String prompt,
    double temperature = 0.7,
    int maxTokens = 1000,
  }) async {
    final dio = Dio();
    final response = await dio.post(
      '${_providerConfigs['anthropic']!.baseUrl}/messages',
      options: Options(
        headers: {
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
          'Content-Type': 'application/json',
        },
      ),
      data: {
        'model': model,
        'prompt': prompt,
        'temperature': temperature,
        'max_tokens_to_sample': maxTokens,
      },
    );
    
    final data = response.data as Map<String, dynamic>;
    final content = data['completion'] ?? '';
    return content;
  }

  /// 调用 Google Gemini API
  static Future<String> callGemini({
    required String model,
    required String apiKey,
    required String prompt,
  }) async {
    final dio = Dio();
    final response = await dio.post(
      '${_providerConfigs['google']!.baseUrl}/models/$model:generateContent',
      queryParameters: {'key': apiKey},
      options: Options(
        headers: {'Content-Type': 'application/json'},
      ),
      data: {
        'contents': [{
          'parts': [{'text': prompt}],
        }],
      },
    );
    
    final data = response.data as Map<String, dynamic>;
    final content = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';
    return content;
  }

  /// 调用 DeepSeek API
  static Future<String> callDeepSeek({
    required String model,
    required String apiKey,
    required List<Map<String, String>> messages,
    double temperature = 0.7,
    int maxTokens = 1000,
  }) async {
    final dio = Dio();
    final response = await dio.post(
      '${_providerConfigs['deepseek']!.baseUrl}/chat/completions',
      options: Options(
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      ),
      data: {
        'model': model,
        'messages': messages,
        'temperature': temperature,
        'max_tokens': maxTokens,
      },
    );
    
    final data = response.data as Map<String, dynamic>;
    final content = data['choices']?[0]?['message']?['content'] ?? '';
    return content;
  }

  /// 调用自定义 API
  static Future<String> callCustom({
    required String apiUrl,
    required String model,
    required String apiKey,
    required List<Map<String, String>> messages,
    double temperature = 0.7,
    int maxTokens = 1000,
  }) async {
    final dio = Dio();
    final response = await dio.post(
      '$apiUrl/chat/completions',
      options: Options(
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      ),
      data: {
        'model': model,
        'messages': messages,
        'temperature': temperature,
        'max_tokens': maxTokens,
      },
    );
    
    final data = response.data as Map<String, dynamic>;
    final content = data['choices']?[0]?['message']?['content'] ?? '';
    return content;
  }

  /// 模拟响应（用于开发测试）
  static String _generateMockResponse(String agentId, Map<String, dynamic> context) {
    final responses = [
      '这是一个很有意思的观点！我想到了...',
      '让我从另一个角度来分析这个问题。',
      '我觉得我们可以这样理解...',
      '说到这个，我想起了...',
      '这个问题让我想到了一个相关的概念...',
    ];
    
    final random = DateTime.now().millisecond % responses.length;
    return responses[random];
  }
}

/// API配置
class APIConfig {
  final String baseUrl;
  final List<String> models;
  
  APIConfig({required this.baseUrl, required this.models});
}
