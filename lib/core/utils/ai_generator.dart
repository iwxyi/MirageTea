import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:mirage_tea/core/managers/settings_manager.dart';
import 'package:mirage_tea/core/models/agent_models.dart';

/// AI生成器 - 封装通用的AI生成功能
///
/// 支持多种AI服务商的通用生成接口
class AIGenerator {
  /// 私有构造函数，防止实例化
  AIGenerator._();

  // ==================== 参数说明 ====================

  /// AI核心参数的详细说明（用于生成提示词）
  static const Map<String, String> parameterDescriptions = {
    'openness': '''
- openness（开放性）: 取值范围 -1.0 到 1.0
  - -1.0 = 极度保守，遵循传统和常规
  - 0.0 = 中性，既不特别开放也不保守
  - 1.0 = 极度开放，思维开放，愿意接受新事物
  示例：保守的图书管理员倾向 -0.8，创造性的艺术家倾向 0.8''',
    'rationality': '''
- rationality（理性度）: 取值范围 -1.0 到 1.0
  - -1.0 = 极度感性，情绪化决策
  - 0.0 = 中性，理性与感性平衡
  - 1.0 = 极度理性，逻辑优先
  示例：冷静的科学家倾向 0.9，情绪化的诗人倾向 -0.7''',
    'orderPreference': '''
- orderPreference（秩序偏好）: 取值范围 -1.0 到 1.0
  - -1.0 = 极度混乱，随性而为
  - 0.0 = 中性，有时有序有时随性
  - 1.0 = 极度有序，条理清晰
  示例：严谨的会计师倾向 0.9，随性的流浪艺术家倾向 -0.8''',
    'socialEnergy': '''
- socialEnergy（社交能量）: 取值范围 0 到 1.0
  - 0.0 = 极度内向，社交消耗能量
  - 0.5 = 中性
  - 1.0 = 极度外向，社交补充能量
  示例：安静的图书馆员倾向 0.2，热心的活动主持人倾向 0.9''',
    'cooperation': '''
- cooperation（合作意愿）: 取值范围 0 到 1.0
  - 0.0 = 完全独立，不喜欢合作
  - 0.5 = 中性，愿意在必要时合作
  - 1.0 = 极度合作导向，善于团队协作
  示例：独行侠倾向 0.2，团队领导者倾向 0.9''',
    'empathy': '''
- empathy（共情能力）: 取值范围 0 到 1.0
  - 0.0 = 缺乏共情，理性分析
  - 0.5 = 中等共情
  - 1.0 = 高度共情，能敏锐感受他人情绪
  示例：客观的法官倾向 0.2，善解人意的心理咨询师倾向 0.9''',
    'expertiseDepth': '''
- expertiseDepth（专业深度）: 取值范围 0 到 1.0
  - 0.0 = 博而不精，通才型
  - 0.5 = 中等深度
  - 1.0 = 极度专精，专家型
  示例：通才型记者倾向 0.3，领域专家倾向 0.9''',
    'creativity': '''
- creativity（创造力）: 取值范围 0 到 1.0
  - 0.0 = 极度保守，按部就班
  - 0.5 = 中等创造力
  - 1.0 = 极度创新，富有想象力
  示例：熟练的执行者倾向 0.3，富有想象力的发明家倾向 0.9''',
  };

  /// 说话风格选项
  static const List<String> speakingStyles = [
    'balanced',      // 平衡
    'concise',      // 简洁
    'verbose',      // 详细
    'humorous',     // 幽默
    'serious',     // 严肃
    'warm',         // 温暖
    'cold',         // 冷静
    'poetic',       // 诗意
    'technical',    // 技术性
    'casual',       // 随意
  ];

  /// 说话风格的中文描述
  static const Map<String, String> speakingStyleDescriptions = {
    'balanced': '平衡 - 语言自然流畅',
    'concise': '简洁 - 言简意赅，重点突出',
    'verbose': '详细 - 详尽说明，细节丰富',
    'humorous': '幽默 - 轻松有趣，善用玩笑',
    'serious': '严肃 - 正式严谨，一丝不苟',
    'warm': '温暖 - 和蔼可亲，充满关怀',
    'cold': '冷静 - 客观冷静，不带感情',
    'poetic': '诗意 - 优美生动，善用修辞',
    'technical': '技术性 - 专业术语，准确精确',
    'casual': '随意 - 轻松随意，不拘小节',
  };

  // ==================== 角色参数生成 ====================

  /// 生成角色参数
  ///
  /// [name] 角色名称
  /// [description] 角色介绍/描述
  /// [onProgress] 进度回调
  /// [onComplete] 完成回调
  /// [onError] 错误回调
  static Future<AgentGenerationResult> generateAgentParameters({
    required String name,
    required String description,
    void Function(String)? onProgress,
  }) async {
    final provider = SettingsManager.aiProvider;
    final model = SettingsManager.aiModel;
    final apiUrl = SettingsManager.aiApiUrl;
    final apiKey = SettingsManager.getApiKey(provider);

    // 检查配置
    if (apiKey == null || apiKey.isEmpty) {
      throw const AIGenerationException(
        'API Key 未配置',
        '请先在设置中配置 AI 服务商的 API Key',
      );
    }

    onProgress?.call('正在构建生成提示词...');

    // 构建提示词
    final prompt = _buildAgentGenerationPrompt(name, description);

    onProgress?.call('正在调用 $provider ($model) 生成参数...');

    // 调用 AI
    final response = await _callAI(
      provider: provider,
      model: model,
      apiUrl: apiUrl,
      apiKey: apiKey,
      prompt: prompt,
    );

    onProgress?.call('正在解析 AI 响应...');

    // 解析结果
    final parsedResult = _parseAgentGenerationResponse(response);

    onProgress?.call('生成完成！');

    return parsedResult;
  }

  /// 构建角色参数生成的提示词
  /// 
  /// 如果 [originalName] 为空，则只使用 [description] 生成，并提供多个名字建议
  /// 如果 [originalName] 不为空，则以该名字为基础生成参数
  static String _buildAgentGenerationPrompt(String originalName, String description) {
    final sb = StringBuffer();

    sb.writeln('你是一个专业的AI角色设计师。');
    sb.writeln();
    sb.writeln('请根据以下角色信息，设计一套合适的AI角色参数配置。');
    sb.writeln();
    sb.writeln('═══════════════════════════════════════════════════════════');
    sb.writeln('【角色基本信息】');
    if (originalName.isNotEmpty) {
      sb.writeln('名称: $originalName');
    }
    sb.writeln('介绍: $description');
    sb.writeln('═══════════════════════════════════════════════════════════');
    sb.writeln();
    
    // 如果没有提供名字，则要求生成多个名字建议
    if (originalName.isEmpty) {
      sb.writeln('═══════════════════════════════════════════════════════════');
      sb.writeln('【角色命名要求】');
      sb.writeln('请根据角色介绍，为该角色生成 5 个合适的名字（中文名或英文名均可）：');
      sb.writeln('- 名字应该符合角色的性格和背景');
      sb.writeln('- 名字应该简洁易记，有特色');
      sb.writeln('- 名字长度2-5个字符为佳');
      sb.writeln();
    }
    
    sb.writeln('═══════════════════════════════════════════════════════════');
    sb.writeln('【AI角色参数说明】');
    sb.writeln();
    sb.writeln('你需要为该角色设计以下8个核心参数（每个参数都有其特定含义和取值范围）：');
    sb.writeln();
    sb.writeln(parameterDescriptions['openness']!);
    sb.writeln();
    sb.writeln(parameterDescriptions['rationality']!);
    sb.writeln();
    sb.writeln(parameterDescriptions['orderPreference']!);
    sb.writeln();
    sb.writeln(parameterDescriptions['socialEnergy']!);
    sb.writeln();
    sb.writeln(parameterDescriptions['cooperation']!);
    sb.writeln();
    sb.writeln(parameterDescriptions['empathy']!);
    sb.writeln();
    sb.writeln(parameterDescriptions['expertiseDepth']!);
    sb.writeln();
    sb.writeln(parameterDescriptions['creativity']!);
    sb.writeln();
    sb.writeln('【说话风格】: 从以下选项中选择最合适的一个：');
    sb.writeln();
    for (final style in speakingStyles) {
      sb.writeln('  - $style: ${speakingStyleDescriptions[style]}');
    }
    sb.writeln();
    sb.writeln('【专长领域】: 列出3-5个该角色擅长的领域，用中文逗号分隔');
    sb.writeln();
    sb.writeln('═══════════════════════════════════════════════════════════');
    sb.writeln('【输出要求】');
    sb.writeln();
    sb.writeln('1. 根据角色的名称和介绍，分析其性格特点、行为模式和说话方式');
    sb.writeln('2. 为每个参数选择合适的取值（注意取值范围）');
    sb.writeln('3. 选择最匹配的说话风格');
    sb.writeln('4. 列出合适的专长领域');
    sb.writeln('5. 优化角色介绍，使其更加生动有趣，能体现角色的核心特点');
    if (originalName.isEmpty) {
      sb.writeln('6. 生成多个合适的角色名字');
    }
    sb.writeln();
    sb.writeln('请以JSON格式输出结果，包含以下字段：');
    sb.writeln();
    sb.writeln('```json');
    sb.writeln('{');
    sb.writeln('  "reasoning": "你对该角色的分析和参数选择理由（简要说明）",');
    sb.writeln('  "optimizedDescription": "基于角色设定优化后的生动介绍...",');
    if (originalName.isEmpty) {
      sb.writeln('  "nameSuggestions": ["名字1", "名字2", "名字3", "名字4", "名字5"],');
    }
    sb.writeln('  "parameters": {');
    sb.writeln('    "openness": 0.5,');
    sb.writeln('    "rationality": 0.5,');
    sb.writeln('    "orderPreference": 0.5,');
    sb.writeln('    "socialEnergy": 0.5,');
    sb.writeln('    "cooperation": 0.5,');
    sb.writeln('    "empathy": 0.5,');
    sb.writeln('    "expertiseDepth": 0.5,');
    sb.writeln('    "creativity": 0.5');
    sb.writeln('  },');
    sb.writeln('  "speakingStyle": "balanced",');
    sb.writeln('  "expertiseAreas": ["领域1", "领域2", "领域3"]');
    sb.writeln('}');
    sb.writeln('```');
    sb.writeln();
    sb.writeln('要求：');
    sb.writeln('- 参数值必须在你指定的范围内');
    sb.writeln('- 专长领域用中文');
    sb.writeln('- 优化后的介绍应该比原文更加生动有趣');
    if (originalName.isEmpty) {
      sb.writeln('- 名字建议要有特色，符合角色设定');
    }
    sb.writeln('- 输出的JSON必须是合法的、可解析的');
    sb.writeln('- 不要在JSON前后添加任何其他文字说明（只输出JSON本身）');
    sb.writeln();
    sb.writeln('请开始分析并输出JSON结果：');

    return sb.toString();
  }

  // ==================== 测试连接 ====================

  /// 测试AI连接
  ///
  /// [provider] 服务商ID
  /// [model] 模型名称
  /// [apiUrl] API 地址
  /// [apiKey] API Key
  static Future<String> testConnection({
    required String provider,
    required String model,
    required String apiUrl,
    required String apiKey,
  }) async {
    // 构建简单的测试提示词
    final testPrompt = '请回复"连接测试成功"，不要添加任何其他内容。';

    return await _callAI(
      provider: provider,
      model: model,
      apiUrl: apiUrl,
      apiKey: apiKey,
      prompt: testPrompt,
    );
  }

  /// 调用AI API
  static Future<String> _callAI({
    required String provider,
    required String model,
    required String apiUrl,
    required String apiKey,
    required String prompt,
  }) async {
    // 构建请求
    final requestUrl = _buildRequestUrl(provider, apiUrl);
    final headers = _buildHeaders(provider, apiKey);

    final requestBody = _buildRequestBody(provider, model, prompt);

    print('[AIGenerator] 调用 $provider API');
    print('[AIGenerator] URL: $requestUrl');
    print('[AIGenerator] Model: $model');
    print('[AIGenerator] Headers: $headers');
    print('[AIGenerator] Body: $requestBody');

    // 添加详细的连接超时配置
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      // 接受所有状态码
      validateStatus: (status) => true,
    ));

    // macOS 上可能需要禁用 SSL 验证（仅开发环境）
    // 注意：在生产环境中应该移除此配置
    try {
      final response = await dio.post(
        requestUrl,
        options: Options(
          headers: headers,
          // 允许自签名证书（开发环境）
          contentType: 'application/json',
        ),
        data: requestBody,
      );

      print('[AIGenerator] 响应状态码: ${response.statusCode}');
      print('[AIGenerator] 响应头: ${response.headers}');

      if (response.statusCode == 200) {
        final content = _parseResponse(provider, response.data);
        print('[AIGenerator] API调用成功，响应长度: ${content.length}字符');
        return content;
      } else {
        throw AIGenerationException(
          'API返回错误: ${response.statusCode}',
          _formatAPIError(provider, response.data),
        );
      }
    } on DioException catch (e) {
      print('[AIGenerator] Dio异常类型: ${e.type}');
      print('[AIGenerator] Dio异常消息: ${e.message}');
      print('[AIGenerator] 响应: ${e.response}');
      
      // 提供更详细的错误信息
      String errorDetail = '请检查网络连接和 API 配置';
      if (e.type == DioExceptionType.connectionError) {
        errorDetail = '无法连接到服务器。请检查:\n1. 网络连接是否正常\n2. API 地址是否正确\n3. 是否需要代理\n4. 防火墙是否阻止了请求';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorDetail = '服务器响应超时，请稍后重试';
      } else if (e.type == DioExceptionType.sendTimeout) {
        errorDetail = '请求发送超时，请检查网络连接';
      } else if (e.type == DioExceptionType.badResponse) {
        errorDetail = '服务器返回错误: ${e.response?.statusCode} - ${e.response?.statusMessage}';
        if (e.response?.statusCode == 401) {
          errorDetail = 'API Key 无效或已过期，请检查 API Key 配置';
        } else if (e.response?.statusCode == 403) {
          errorDetail = '访问被拒绝，请检查 API Key 权限';
        } else if (e.response?.statusCode == 429) {
          errorDetail = '请求频率超限，请稍后重试';
        }
      }
      
      throw AIGenerationException(
        '网络请求失败: ${e.message}',
        errorDetail,
      );
    }
  }

  /// 构建请求URL
  static String _buildRequestUrl(String provider, String customUrl) {
    switch (provider) {
      case 'openai':
        return 'https://api.openai.com/v1/chat/completions';
      case 'anthropic':
        return 'https://api.anthropic.com/v1/messages';
      case 'deepseek':
        return 'https://api.deepseek.com/chat/completions';
      case 'google':
        return 'https://generativelanguage.googleapis.com/v1/models/gemini-1.5-pro:generateContent';
      case 'custom':
        if (customUrl.isEmpty) {
          throw const AIGenerationException('自定义API未配置', '请在设置中配置自定义 API 地址');
        }
        return customUrl.endsWith('/')
            ? '${customUrl}chat/completions'
            : '$customUrl/chat/completions';
      default:
        throw AIGenerationException('不支持的服务商: $provider', '请选择支持的服务商');
    }
  }

  /// 构建请求头
  static Map<String, dynamic> _buildHeaders(String provider, String apiKey) {
    final headers = <String, dynamic>{
      'Content-Type': 'application/json',
    };

    switch (provider) {
      case 'openai':
        headers['Authorization'] = 'Bearer $apiKey';
        break;
      case 'anthropic':
        headers['x-api-key'] = apiKey;
        headers['anthropic-version'] = '2023-06-01';
        break;
      case 'deepseek':
        // DeepSeek 使用 Authorization header
        headers['Authorization'] = 'Bearer $apiKey';
        break;
      case 'google':
        headers['x-goog-api-key'] = apiKey;
        break;
      case 'custom':
        headers['Authorization'] = 'Bearer $apiKey';
        break;
    }

    return headers;
  }

  /// 构建请求体
  static Map<String, dynamic> _buildRequestBody(String provider, String model, String prompt) {
    switch (provider) {
      case 'openai':
      case 'deepseek':
      case 'custom':
        return {
          'model': model,
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.7,
          'max_tokens': 2000,
        };
      case 'anthropic':
        return {
          'model': model,
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.7,
          'max_tokens': 2000,
        };
      case 'google':
        return {
          'contents': [
            {'parts': [{'text': prompt}]}
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 2000,
          },
        };
      default:
        return {};
    }
  }

  /// 解析响应
  static String _parseResponse(String provider, dynamic responseData) {
    switch (provider) {
      case 'openai':
      case 'deepseek':
      case 'custom':
        final choices = responseData['choices'] as List;
        final message = choices[0]['message']['content'] as String;
        return message;
      case 'anthropic':
        final content = responseData['content'] as List;
        final text = content[0]['text'] as String;
        return text;
      case 'google':
        final candidates = responseData['candidates'] as List;
        final content = candidates[0]['content']['parts'][0]['text'] as String;
        return content;
      default:
        return '';
    }
  }

  /// 格式化API错误
  static String _formatAPIError(String provider, dynamic responseData) {
    if (responseData == null) return '未知错误';

    switch (provider) {
      case 'openai':
      case 'deepseek':
      case 'custom':
        final error = responseData['error'];
        if (error is Map) {
          return error['message']?.toString() ?? '未知错误';
        }
        return error?.toString() ?? '未知错误';
      case 'anthropic':
        final error = responseData['error'];
        if (error is Map) {
          return error['message']?.toString() ?? '未知错误';
        }
        return error?.toString() ?? '未知错误';
      case 'google':
        final error = responseData['error'];
        if (error is Map) {
          return error['message']?.toString() ?? '未知错误';
        }
        return error?.toString() ?? '未知错误';
      default:
        return '未知错误';
    }
  }

  // ==================== JSON 解析 ====================

  /// 解析AI生成的角色参数响应
  ///
  /// 兼容多种格式：
  /// - 纯JSON: {"reasoning": "...", "parameters": {...}}
  /// - Markdown代码块: ```json {...} ```
  /// - JSON前后有其他文字
  static AgentGenerationResult _parseAgentGenerationResponse(String response) {
    print('[AIGenerator] 原始响应长度: ${response.length}字符');
    print('[AIGenerator] 原始响应前500字符: ${response.substring(0, min(500, response.length))}');

    // 提取JSON
    final jsonStr = _extractJson(response);
    print('[AIGenerator] 提取的JSON: $jsonStr');

    // 解析JSON
    Map<String, dynamic> json;
    try {
      json = jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (e) {
      print('[AIGenerator] JSON解析失败: $e');
      throw AIGenerationException(
        '解析AI响应失败',
        'AI返回的内容无法解析为JSON格式，请稍后重试',
      );
    }

    // 提取名字建议
    final nameSuggestions = <String>[];
    final suggestions = json['nameSuggestions'];
    if (suggestions is List) {
      for (final item in suggestions) {
        if (item is String && item.trim().isNotEmpty) {
          nameSuggestions.add(item.trim());
        }
      }
    }
    print('[AIGenerator] 名字建议: $nameSuggestions');

    // 提取优化后的角色介绍
    final optimizedDescription = json['optimizedDescription'] as String? ?? '';
    print('[AIGenerator] 优化后的介绍: $optimizedDescription');

    // 提取参数
    final paramsJson = json['parameters'] as Map<String, dynamic>?;
    if (paramsJson == null) {
      throw AIGenerationException(
        '参数解析失败',
        'AI响应中缺少 parameters 字段',
      );
    }

    // 提取说话风格
    final speakingStyle = json['speakingStyle'] as String? ?? 'balanced';

    // 提取专长领域
    final expertiseAreas = <String>[];
    final areas = json['expertiseAreas'];
    if (areas is List) {
      for (final item in areas) {
        if (item is String) {
          expertiseAreas.add(item);
        }
      }
    }

    // 提取分析理由
    final reasoning = json['reasoning'] as String? ?? '';

    // 构建结果
    final parameters = AgentParameters(
      openness: _parseDouble(paramsJson['openness']),
      rationality: _parseDouble(paramsJson['rationality']),
      orderPreference: _parseDouble(paramsJson['orderPreference']),
      socialEnergy: _parseDouble(paramsJson['socialEnergy']),
      cooperation: _parseDouble(paramsJson['cooperation']),
      empathy: _parseDouble(paramsJson['empathy']),
      expertiseDepth: _parseDouble(paramsJson['expertiseDepth']),
      creativity: _parseDouble(paramsJson['creativity']),
      speakingStyle: speakingStyle,
      expertiseAreas: expertiseAreas,
    );

    print('[AIGenerator] 解析成功');
    print('[AIGenerator] 参数: openness=${parameters.openness}, rationality=${parameters.rationality}');
    print('[AIGenerator] 说话风格: ${parameters.speakingStyle}');
    print('[AIGenerator] 专长领域: ${parameters.expertiseAreas}');

    return AgentGenerationResult(
      parameters: parameters,
      reasoning: reasoning,
      nameSuggestions: nameSuggestions,
      optimizedDescription: optimizedDescription,
    );
  }

  /// 从任意文本中提取JSON
  ///
  /// 支持的格式：
  /// 1. 纯JSON: {"key": "value"}
  /// 2. Markdown代码块: ```json {"key": "value"} ``` 或 ``` {"key": "value"} ```
  /// 3. 前后有文字: "这是一些文字 {"key": "value"} 更多文字"
  static String _extractJson(String text) {
    // 移除 BOM
    var cleanedText = text.replaceAll('\uFEFF', '').trim();

    // 尝试查找 JSON 代码块
    final codeBlockPattern = RegExp(
      r'```(?:json)?\s*([\s\S]*?)\s*```',
      multiLine: true,
    );
    final codeBlockMatch = codeBlockPattern.firstMatch(cleanedText);
    if (codeBlockMatch != null) {
      cleanedText = codeBlockMatch.group(1)!.trim();
    }

    // 尝试找到最外层的花括号
    final firstBrace = cleanedText.indexOf('{');
    final lastBrace = cleanedText.lastIndexOf('}');

    if (firstBrace != -1 && lastBrace != -1 && lastBrace > firstBrace) {
      cleanedText = cleanedText.substring(firstBrace, lastBrace + 1);
    }

    // 移除可能存在的行首空格和注释
    cleanedText = cleanedText.trim();

    // 验证是否为有效的JSON
    try {
      jsonDecode(cleanedText);
      return cleanedText;
    } catch (_) {
      // 如果解析失败，尝试更多清理
      // 移除单行注释
      cleanedText = cleanedText.replaceAll(RegExp(r'//.*$', multiLine: true), '');
      // 移除尾随逗号
      cleanedText = cleanedText.replaceAll(RegExp(r',\s*([}\]])'), r'$1');

      // 再次尝试解析
      try {
        jsonDecode(cleanedText);
        return cleanedText;
      } catch (e) {
        // 如果还是失败，返回原始文本让上层处理
        print('[AIGenerator] JSON清理后仍解析失败，尝试原始文本');
        return text.replaceAll(RegExp(r'```(?:json)?\s*', multiLine: true), '')
                   .replaceAll('```', '')
                   .trim();
      }
    }
  }

  /// 安全解析double值
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.5;
    if (value is double) return value.clamp(-1.0, 1.0);
    if (value is int) return value.toDouble().clamp(-1.0, 1.0);
    if (value is String) {
      final parsed = double.tryParse(value);
      return (parsed ?? 0.5).clamp(-1.0, 1.0);
    }
    return 0.5;
  }

  /// 取最小值辅助函数
  static int min(int a, int b) => a < b ? a : b;
}

/// AI生成结果
class AgentGenerationResult {
  final AgentParameters parameters;
  final String reasoning;
  final List<String> nameSuggestions; // 角色名字建议列表
  final String optimizedDescription; // 优化后的角色介绍

  AgentGenerationResult({
    required this.parameters,
    this.reasoning = '',
    this.nameSuggestions = const [],
    this.optimizedDescription = '',
  });
}

/// AI生成异常
class AIGenerationException implements Exception {
  final String title;
  final String message;

  const AIGenerationException(this.title, this.message);

  @override
  String toString() => '$title: $message';
}
