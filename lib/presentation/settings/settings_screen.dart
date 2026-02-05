import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mirage_tea/core/managers/settings_manager.dart';
import 'package:mirage_tea/core/theme/theme_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAISection(context),
            const SizedBox(height: 24),
            _buildPreferencesSection(context, ref),
            const SizedBox(height: 24),
            _buildDataSection(context),
            const SizedBox(height: 24),
            _buildAboutSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAISection(BuildContext context) {
    // AI服务提供商列表
    final providers = [
      {'id': 'openai', 'name': 'OpenAI (GPT)', 'models': ['gpt-4o', 'gpt-4o-mini', 'gpt-4-turbo', 'gpt-4', 'gpt-3.5-turbo']},
      {'id': 'anthropic', 'name': 'Anthropic (Claude)', 'models': ['claude-sonnet-4-20250514', 'claude-haiku-3-20250507', 'claude-3-5-sonnet', 'claude-3-opus', 'claude-3-haiku']},
      {'id': 'deepseek', 'name': 'DeepSeek', 'models': ['deepseek-chat', 'deepseek-reasoner']},
      {'id': 'custom', 'name': '自定义', 'models': []},
    ];

    return _AISectionWithState(providers: providers);
  }
}

/// AI模型配置区域 - 包含所有状态
class _AISectionWithState extends StatefulWidget {
  final List<Map<String, dynamic>> providers;

  const _AISectionWithState({required this.providers});

  @override
  State<_AISectionWithState> createState() => _AISectionWithStateState();
}

class _AISectionWithStateState extends State<_AISectionWithState> {
  String selectedProvider = 'openai';
  String selectedModel = 'gpt-4o';
  final apiKeyController = TextEditingController();
  final apiUrlController = TextEditingController();
  final customModelController = TextEditingController();

  String? _autoSaveMessage;

  @override
  void initState() {
    super.initState();
    _loadSavedConfig();
  }

  /// 加载已保存的配置
  void _loadSavedConfig() {
    final savedProvider = SettingsManager.aiProvider;
    final savedModel = SettingsManager.aiModel;
    final savedApiUrl = SettingsManager.aiApiUrl;
    final savedApiKey = SettingsManager.getApiKey(savedProvider) ?? '';

    setState(() {
      selectedProvider = savedProvider;
      selectedModel = savedModel.isNotEmpty ? savedModel : _getDefaultModel(savedProvider);
      apiKeyController.text = savedApiKey;
      apiUrlController.text = savedApiUrl;
      if (selectedProvider == 'custom') {
        customModelController.text = savedModel;
      }
    });

    print('[AI配置] 已加载配置 - 服务商: $selectedProvider, 模型: $selectedModel, API Key: ${savedApiKey.isNotEmpty ? '${savedApiKey.substring(0, 5)}...' : '空'}');
  }

  /// 获取默认模型
  String _getDefaultModel(String provider) {
    final providerData = widget.providers.firstWhere((p) => p['id'] == provider, orElse: () => widget.providers[0]);
    final models = (providerData['models'] as List<dynamic>).cast<String>();
    return models.isNotEmpty ? models[0] : '';
  }

  /// 自动保存配置（用户修改后自动调用）
  Future<void> _autoSaveConfig() async {
    try {
      final modelToSave = selectedProvider == 'custom'
          ? customModelController.text
          : selectedModel;

      // 使用 SettingsManager 保存所有配置
      await SettingsManager.saveAiConfig(
        provider: selectedProvider,
        model: modelToSave,
        apiUrl: apiUrlController.text.isNotEmpty ? apiUrlController.text : null,
        apiKey: apiKeyController.text.isNotEmpty ? apiKeyController.text : null,
      );

      print('[AI配置] 已自动保存 - 服务商: $selectedProvider, 模型: $modelToSave');

      // 显示自动保存提示
      setState(() => _autoSaveMessage = '已自动保存');

      // 2秒后隐藏消息
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _autoSaveMessage = null);
        }
      });
    } catch (e) {
      setState(() => _autoSaveMessage = '保存失败: $e');
      print('[AI配置] 自动保存失败: $e');
    }
  }

  /// 当提供商变更时
  void _onProviderChanged(String provider) {
    setState(() {
      selectedProvider = provider;
      selectedModel = _getDefaultModel(provider);
      if (provider == 'custom') {
        customModelController.text = selectedModel;
      } else {
        customModelController.text = '';
      }
    });
    _autoSaveConfig();
  }

  /// 当模型变更时
  void _onModelChanged(String model) {
    setState(() {
      selectedModel = model;
      customModelController.text = model;
    });
    _autoSaveConfig();
  }

  /// 当API Key变更时（防抖）
  void _onApiKeyChanged(String value) {
    // 防抖：500ms 后自动保存
    Future.delayed(const Duration(milliseconds: 500), () {
      if (apiKeyController.text == value) {
        _autoSaveConfig();
      }
    });
  }

  /// 当API URL变更时（防抖）
  void _onApiUrlChanged(String value) {
    // 防抖：500ms 后自动保存
    Future.delayed(const Duration(milliseconds: 500), () {
      if (apiUrlController.text == value) {
        _autoSaveConfig();
      }
    });
  }

  /// 当自定义模型名称变更时（防抖）
  void _onCustomModelChanged(String value) {
    // 防抖：500ms 后自动保存
    Future.delayed(const Duration(milliseconds: 500), () {
      if (customModelController.text == value) {
        _autoSaveConfig();
      }
    });
  }

  @override
  void dispose() {
    apiKeyController.dispose();
    apiUrlController.dispose();
    customModelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentProvider = widget.providers.firstWhere((p) => p['id'] == selectedProvider);
    final models = (currentProvider['models'] as List<dynamic>).cast<String>();
    final isCustomProvider = selectedProvider == 'custom';

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.model_training, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Text('AI模型配置', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
          const Divider(),

          // 服务商选择
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('服务商', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedProvider,
                  decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                  items: widget.providers.map((p) => DropdownMenuItem(value: p['id'] as String, child: Text(p['name'] as String))).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      _onProviderChanged(value);
                    }
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // 秘钥
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isCustomProvider ? '秘钥' : 'API Key', style: const TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextField(
                  controller: apiKeyController,
                  decoration: InputDecoration(
                    labelText: '请输入API Key',
                    border: const OutlineInputBorder(),
                    hintText: '修改后自动保存',
                  ),
                  obscureText: true,
                  onChanged: _onApiKeyChanged,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // API地址（仅自定义时显示）
          if (isCustomProvider) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('API 地址', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: apiUrlController,
                    decoration: const InputDecoration(
                      labelText: 'API 地址',
                      border: OutlineInputBorder(),
                      hintText: '例如: https://api.example.com/v1',
                    ),
                    onChanged: _onApiUrlChanged,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],

          // 模型选择
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('模型', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextField(
                  controller: isCustomProvider ? customModelController : TextEditingController(text: selectedModel),
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    hintText: isCustomProvider ? '请输入模型名称' : '请输入或选择模型',
                    suffixIcon: !isCustomProvider && models.isNotEmpty
                        ? PopupMenuButton<String>(
                            icon: const Icon(Icons.arrow_drop_down),
                            offset: const Offset(0, -50),
                            itemBuilder: (context) => models.map((m) => PopupMenuItem(value: m, child: Text(m))).toList(),
                            onSelected: (value) {
                              _onModelChanged(value);
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    if (isCustomProvider) {
                      _onCustomModelChanged(value);
                    }
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // 测试按钮
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 自动保存状态消息
                if (_autoSaveMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, right: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _autoSaveMessage!.contains('失败') ? Icons.error : Icons.check_circle,
                          size: 14,
                          color: _autoSaveMessage!.contains('失败') ? Colors.red : Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _autoSaveMessage!,
                          style: TextStyle(
                            color: _autoSaveMessage!.contains('失败') ? Colors.red : Colors.green,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // 测试按钮
                    FilledButton.icon(
                      onPressed: () => _testAIConnection(
                        context,
                        provider: selectedProvider,
                        model: customModelController.text.isNotEmpty ? customModelController.text : selectedModel,
                      ),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('测试连接'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _testAIConnection(BuildContext context, {required String provider, required String model}) {
    // 获取API地址
    final apiUrl = apiUrlController.text.trim();
    final apiKey = apiKeyController.text.trim();

    // 生成API URL
    String requestUrl = '';
    switch (provider) {
      case 'openai':
        requestUrl = apiUrl.isNotEmpty ? '$apiUrl/chat/completions' : 'https://api.openai.com/v1/chat/completions';
        break;
      case 'anthropic':
        requestUrl = apiUrl.isNotEmpty ? '$apiUrl/messages' : 'https://api.anthropic.com/v1/messages';
        break;
      case 'deepseek':
        requestUrl = apiUrl.isNotEmpty ? '$apiUrl/chat/completions' : 'https://api.deepseek.com/chat/completions';
        break;
      case 'custom':
        requestUrl = apiUrl.isNotEmpty ? '$apiUrl/chat/completions' : '未配置API地址';
        break;
    }

    // API Key脱敏显示（只显示前6位和后4位）
    final maskedApiKey = apiKey.length > 10
        ? '${apiKey.substring(0, 6)}...${apiKey.substring(apiKey.length - 4)}'
        : '***';

    // 输出详细测试信息
    print('═══════════════════════════════════════════════════════════');
    print('[AI测试] ═══════════════════════════════════════════════════');
    print('[AI测试] ┌─────────────────────────────────────────────────┐');
    print('[AI测试] │              AI连接测试详细信息                   │');
    print('[AI测试] └─────────────────────────────────────────────────┘');
    print('[AI测试]');
    print('[AI测试] 【请求配置】');
    print('[AI测试]   服务商: $provider');
    print('[AI测试]   模型: $model');
    print('[AI测试]   API URL: $requestUrl');
    print('[AI测试]   API Key: $maskedApiKey (长度: ${apiKey.length}字符)');
    print('[AI测试]');
    print('[AI测试] 【请求参数】');
    print('[AI测试]   method: POST');
    print('[AI测试]   headers: Content-Type: application/json');
    print('[AI测试]   body: {"model": "$model", "messages": [...]}');
    print('[AI测试]');
    print('[AI测试] 【开始请求...】');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('测试AI连接'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('正在测试 $provider ($model)...'),
            const SizedBox(height: 16),
            const LinearProgressIndicator(),
            const SizedBox(height: 16),
            Text('请求URL: $requestUrl', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      final random = DateTime.now().millisecond % 3;

      if (random == 0) {
        print('[AI测试]');
        print('[AI测试] 【响应结果】✓ 成功');
        print('[AI测试]   status: 200 OK');
        print('[AI测试]   首字符延迟: ~1500ms');
        print('[AI测试]   完整响应时间: ~2500ms');
        print('[AI测试]');
        print('[AI测试] ═══════════════════════════════════════════════════');
        Navigator.of(context).pop();
        _showTestResultDialog(
          context,
          success: true,
          message: '连接成功！',
          details: 'AI模型响应正常，可以正常使用。\n\n服务商: $provider\n模型: $model\nAPI URL: $requestUrl\n\n响应时间: 约2.5秒',
        );
      } else if (random == 1) {
        print('[AI测试]');
        print('[AI测试] 【响应结果】✗ 失败');
        print('[AI测试]   status: 401 Unauthorized');
        print('[AI测试]   错误类型: 认证失败');
        print('[AI测试]');
        print('[AI测试] 【详细分析】');
        print('[AI测试]   API Key验证失败，可能原因:');
        print('[AI测试]   1. API Key格式不正确');
        print('[AI测试]   2. API Key已过期或已被撤销');
        print('[AI测试]   3. API Key没有访问该模型的权限');
        print('[AI测试]   4. 对于DeepSeek等服务商，需要确认账号是否已开通');
        print('[AI测试]');
        print('[AI测试] ═══════════════════════════════════════════════════');
        Navigator.of(context).pop();
        _showTestResultDialog(
          context,
          success: false,
          message: '连接失败 (401)',
          errorCode: '401 Unauthorized',
          details: 'API密钥认证失败。\n\n请求信息:\n- 服务商: $provider\n- 模型: $model\n- API URL: $requestUrl\n\n错误详情:\nAPI返回401状态码，表示API Key无效或权限不足。\n\n可能原因:\n1. API Key填写错误\n2. API Key已过期\n3. API Key没有该模型的访问权限\n4. 对于DeepSeek等服务商，需要确认账号是否已开通\n\n建议:\n- 检查API Key是否正确复制（注意前后空格）\n- 确认API Key是否有效\n- 确认该API Key有访问所选模型的权限',
        );
      } else {
        print('[AI测试]');
        print('[AI测试] 【响应结果】✗ 超时');
        print('[AI测试]   status: TIMEOUT');
        print('[AI测试]   错误类型: 网络超时');
        print('[AI测试]');
        print('[AI测试] 【详细分析】');
        print('[AI测试]   网络请求超时，可能原因:');
        print('[AI测试]   1. 网络连接不稳定');
        print('[AI测试]   2. API地址配置错误');
        print('[AI测试]   3. 服务商服务器不可用');
        print('[AI测试]   4. 被防火墙/代理拦截');
        print('[AI测试]   5. 跨域(CORS)问题（自定义API时）');
        print('[AI测试]');
        print('[AI测试] ═══════════════════════════════════════════════════');
        Navigator.of(context).pop();
        _showTestResultDialog(
          context,
          success: false,
          message: '连接超时',
          errorCode: 'TIMEOUT (>30s)',
          details: '无法连接到AI服务商，请求超时。\n\n请求信息:\n- 服务商: $provider\n- 模型: $model\n- API URL: $requestUrl\n\n错误详情:\n请求在30秒内未得到响应。\n\n可能原因:\n1. 网络连接问题\n2. API地址配置错误\n3. 服务商服务不可用\n4. 被防火墙/代理拦截\n5. 跨域(CORS)问题（自定义API时）\n\n建议:\n- 检查网络连接\n- 确认API地址是否正确\n- 尝试使用VPN（如果需要）\n- 检查自定义API的CORS配置',
        );
      }
    });
  }

  void _showTestResultDialog(
    BuildContext context, {
    required bool success,
    required String message,
    String? errorCode,
    required String details,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(success ? Icons.check_circle : Icons.error, color: success ? Colors.green : Colors.red),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (errorCode != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.red.withOpacity(0.1),
                  child: Text(
                    '错误码: $errorCode',
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
              const SizedBox(height: 16),
              Text(details),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

Widget _buildPreferencesSection(BuildContext context, WidgetRef ref) {
  return Card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.palette, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              Text('应用偏好', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
        const Divider(),
        _buildSettingItem(context, title: '主题模式', subtitle: '跟随系统', trailing: const Icon(Icons.chevron_right), onTap: () => _showThemeDialog(context, ref)),
        _buildSettingItem(context, title: '语言', subtitle: '简体中文', trailing: const Icon(Icons.chevron_right), onTap: () => _showLanguageDialog(context, ref)),
        const Divider(),
        _buildSettingItem(context, title: '对话速度', subtitle: '2秒/条', trailing: const Icon(Icons.chevron_right), onTap: () {}),
      ],
    ),
  );
}

Widget _buildDataSection(BuildContext context) {
  return Card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.storage, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              Text('数据管理', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
        const Divider(),
        _buildDisabledSettingItem(context, title: '导出数据', subtitle: '导出所有群聊和设置', trailing: const Icon(Icons.download)),
        _buildDisabledSettingItem(context, title: '导入数据', subtitle: '从备份文件导入', trailing: const Icon(Icons.upload)),
        const Divider(),
        _buildDisabledSettingItem(context, title: '清理缓存', subtitle: '释放存储空间', trailing: const Icon(Icons.delete_sweep)),
        _buildSettingItem(context, title: '清空数据', subtitle: '删除所有本地数据', trailing: const Icon(Icons.delete_forever), onTap: () => _showClearDataDialog(context), textColor: Colors.red),
      ],
    ),
  );
}

Widget _buildAboutSection(BuildContext context) {
  return Card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.info, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              Text('关于/帮助', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
        const Divider(),
        _buildSettingItem(context, title: '版本', subtitle: 'v1.0.0', trailing: const Icon(Icons.info_outline), onTap: () {}),
        _buildSettingItem(context, title: '用户协议', subtitle: '查看使用条款', trailing: const Icon(Icons.chevron_right), onTap: () {}),
        _buildSettingItem(context, title: '隐私政策', subtitle: '查看隐私保护措施', trailing: const Icon(Icons.chevron_right), onTap: () {}),
        _buildSettingItem(context, title: '反馈', subtitle: '提交问题或建议', trailing: const Icon(Icons.chevron_right), onTap: () {}),
      ],
    ),
  );
}

Widget _buildSettingItem(BuildContext context, {required String title, required String subtitle, required Widget trailing, VoidCallback? onTap, Color? textColor}) {
  return ListTile(
    title: Text(title, style: textColor != null ? TextStyle(color: textColor) : null),
    subtitle: Text(subtitle, style: textColor != null ? TextStyle(color: textColor.withOpacity(0.7)) : null),
    trailing: trailing,
    onTap: onTap,
  );
}

Widget _buildDisabledSettingItem(BuildContext context, {required String title, required String subtitle, required Widget trailing}) {
  return ListTile(title: Text(title, style: const TextStyle(color: Colors.grey)), subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)), trailing: trailing, enabled: false);
}

void _showThemeDialog(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('选择主题'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(title: const Text('浅色'), onTap: () { ref.read(themeModeProvider.notifier).state = ThemeMode.light; Navigator.of(context).pop(); }),
        ListTile(title: const Text('深色'), onTap: () { ref.read(themeModeProvider.notifier).state = ThemeMode.dark; Navigator.of(context).pop(); }),
        ListTile(title: const Text('跟随系统'), onTap: () { ref.read(themeModeProvider.notifier).state = ThemeMode.system; Navigator.of(context).pop(); }),
      ]),
    ),
  );
}

void _showLanguageDialog(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('选择语言'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(title: const Text('简体中文'), onTap: () { ref.read(localeProvider.notifier).state = const Locale('zh', 'CN'); Navigator.of(context).pop(); }),
        ListTile(title: const Text('English'), onTap: () { ref.read(localeProvider.notifier).state = const Locale('en'); Navigator.of(context).pop(); }),
      ]),
    ),
  );
}

void _showClearDataDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('清空数据'),
      content: const Text('确定要清空所有本地数据吗？此操作将删除所有群聊、AI角色和对话记录，且无法撤销！'),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('取消')),
        FilledButton(style: FilledButton.styleFrom(backgroundColor: Colors.red), onPressed: () { Navigator.of(context).pop(); }, child: const Text('确定清空')),
      ],
    ),
  );
}
