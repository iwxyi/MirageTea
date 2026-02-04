import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mirage_tea/core/models/agent_models.dart';

/// AI模型管理器 - 封装各种AI模型的API调用
class AIModelManager {
  static const String _baseConfigBoxName = 'ai_config';
  
  static Box<Map<String, dynamic>>? _configBox;
  
  // API配置
  static final Map<String, APIConfig> _apiConfigs = {
    'openai': APIConfig(
      baseUrl: 'https://api.openai.com/v1',
      models: ['gpt-4', 'gpt-4-turbo', 'gpt-3.5-turbo'],
    ),
    'anthropic': APIConfig(
      baseUrl: 'https://api.anthropic.com/v1',
      models: ['claude-3-opus-20240229', 'claude-3-sonnet-20240229', 'claude-3-haiku-20240307'],
    ),
    'google': APIConfig(
      baseUrl: 'https://generativelanguage.googleapis.com/v1',
      models: ['gemini-pro', 'gemini-ultra'],
    ),
    'deepseek': APIConfig(
      baseUrl: 'https://api.deepseek.com/v1',
      models: ['deepseek-chat'],
    ),
  };
  
  static Future<void> initialize() async {
    await Hive.openBox<Map<String, dynamic>>(_baseConfigBoxName);
    _configBox = Hive.box<Map<String, dynamic>>(_baseConfigBoxName);
  }
  
  /// 获取可用的模型列表
  static List<String> getAvailableModels() {
    return _apiConfigs.values.expand((c) => c.models).toList();
  }
  
  /// 获取API配置
  static APIConfig? getAPIConfig(String provider) {
    return _apiConfigs[provider];
  }
  
  /// 保存API密钥
  static Future<void> saveAPIKey(String provider, String apiKey) async {
    await _configBox!.put('api_key_$provider', {'key': apiKey});
  }
  
  /// 获取API密钥
  static String? getAPIKey(String provider) {
    return _configBox?.get('api_key_$provider')?['key'];
  }
  
  /// 生成响应
  static Future<String> generateResponse({
    required String agentId,
    required String groupId,
    required Map<String, dynamic> context,
  }) async {
    // TODO: 实现实际的AI API调用
    // 这里返回模拟响应用于开发测试
    
    return _generateMockResponse(agentId, context);
  }
  
  /// 生成提示词
  static String buildPrompt({
    required AIAgent agent,
    required Map<String, dynamic> context,
  }) {
    final sb = StringBuffer();
    
    // 系统提示
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
    
    // 添加对话历史
    final messages = context['messages'] as List?;
    if (messages != null && messages.isNotEmpty) {
      sb.writeln('\n最近的对话：');
      for (final msg in messages.take(10)) {
        sb.writeln('${msg['agentId']}: ${msg['content']}');
      }
    }
    
    // 添加记忆
    final memories = context['relevantMemories'] as List?;
    if (memories != null && memories.isNotEmpty) {
      sb.writeln('\n相关记忆：');
      for (final memory in memories.take(5)) {
        sb.writeln('- ${memory['content']}');
      }
    }
    
    // 添加文明状态
    final civilizationState = context['civilizationState'];
    if (civilizationState != null) {
      sb.writeln('\n当前文明状态：');
      sb.writeln('- 时代: ${civilizationState['era']}');
      sb.writeln('- 觉醒度: ${civilizationState['awakeningLevel']?.toStringAsFixed(2)}');
    }
    
    sb.writeln('\n请根据以上信息，以${agent.name}的身份参与对话。');
    
    return sb.toString();
  }
  
  /// 调用OpenAI API
  static Future<String> callOpenAI({
    required String model,
    required String apiKey,
    required List<Map<String, String>> messages,
    double temperature = 0.7,
    int maxTokens = 1000,
  }) async {
    final dio = Dio();
    
    final response = await dio.post(
      '${_apiConfigs['openai']!.baseUrl}/chat/completions',
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
  
  /// 调用Anthropic API
  static Future<String> callAnthropic({
    required String model,
    required String apiKey,
    required String prompt,
    double temperature = 0.7,
    int maxTokens = 1000,
  }) async {
    final dio = Dio();
    
    final response = await dio.post(
      '${_apiConfigs['anthropic']!.baseUrl}/messages',
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
  
  /// 调用Google Gemini API
  static Future<String> callGemini({
    required String model,
    required String apiKey,
    required String prompt,
  }) async {
    final dio = Dio();
    
    final response = await dio.post(
      '${_apiConfigs['google']!.baseUrl}/models/$model:generateContent',
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
  
  /// 调用DeepSeek API
  static Future<String> callDeepSeek({
    required String model,
    required String apiKey,
    required List<Map<String, String>> messages,
    double temperature = 0.7,
    int maxTokens = 1000,
  }) async {
    final dio = Dio();
    
    final response = await dio.post(
      '${_apiConfigs['deepseek']!.baseUrl}/chat/completions',
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

