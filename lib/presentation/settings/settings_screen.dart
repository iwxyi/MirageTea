import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mirage_tea/core/theme/theme_controller.dart';
import 'package:mirage_tea/core/theme/responsive_layout.dart';

/// 设置页
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ResponsiveScaffold(
      title: const Text('设置'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI模型配置
            _buildAISection(context),
            const SizedBox(height: 24),
            
            // 应用偏好
            _buildPreferencesSection(context, ref),
            const SizedBox(height: 24),
            
            // 数据管理
            _buildDataSection(context),
            const SizedBox(height: 24),
            
            // 关于/帮助
            _buildAboutSection(context),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAISection(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.model_training,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'AI模型配置',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          const Divider(),
          
          // OpenAI配置
          _buildSettingItem(
            context,
            title: 'OpenAI API Key',
            subtitle: '配置GPT模型的访问密钥',
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showAPIKeyDialog(context, 'openai'),
          ),
          
          // Anthropic配置
          _buildSettingItem(
            context,
            title: 'Anthropic API Key',
            subtitle: '配置Claude模型的访问密钥',
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showAPIKeyDialog(context, 'anthropic'),
          ),
          
          // DeepSeek配置
          _buildSettingItem(
            context,
            title: 'DeepSeek API Key',
            subtitle: '配置DeepSeek模型的访问密钥',
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showAPIKeyDialog(context, 'deepseek'),
          ),
          
          const Divider(),
          
          // 模型选择
          _buildSettingItem(
            context,
            title: '默认模型',
            subtitle: 'gpt-4-turbo',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ],
      ),
    );
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
                Icon(
                  Icons.palette,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  '应用偏好',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          const Divider(),
          
          // 主题模式
          _buildSettingItem(
            context,
            title: '主题模式',
            subtitle: '跟随系统',
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showThemeDialog(context, ref),
          ),
          
          // 语言
          _buildSettingItem(
            context,
            title: '语言',
            subtitle: '简体中文',
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLanguageDialog(context, ref),
          ),
          
          const Divider(),
          
          // 对话速度
          _buildSettingItem(
            context,
            title: '对话速度',
            subtitle: '2秒/条',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          
          // 通知设置
          _buildSwitchItem(
            context,
            title: '消息通知',
            subtitle: '有新消息时发送通知',
            value: true,
            onChanged: (value) {},
          ),
          
          // 自动保存
          _buildSwitchItem(
            context,
            title: '自动保存',
            subtitle: '自动保存对话内容',
            value: true,
            onChanged: (value) {},
          ),
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
                Icon(
                  Icons.storage,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  '数据管理',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          const Divider(),
          
          // 导出数据
          _buildSettingItem(
            context,
            title: '导出数据',
            subtitle: '导出所有群聊和设置',
            trailing: const Icon(Icons.download),
            onTap: () {},
          ),
          
          // 导入数据
          _buildSettingItem(
            context,
            title: '导入数据',
            subtitle: '从备份文件导入',
            trailing: const Icon(Icons.upload),
            onTap: () {},
          ),
          
          const Divider(),
          
          // 清理缓存
          _buildSettingItem(
            context,
            title: '清理缓存',
            subtitle: '释放存储空间',
            trailing: const Icon(Icons.delete_sweep),
            onTap: () => _showCleanCacheDialog(context),
          ),
          
          // 重置应用
          _buildSettingItem(
            context,
            title: '重置应用',
            subtitle: '清除所有数据并重新开始',
            trailing: const Icon(Icons.restart_alt),
            onTap: () => _showResetDialog(context),
            textColor: Colors.red,
          ),
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
                Icon(
                  Icons.info,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  '关于/帮助',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          const Divider(),
          
          // 版本信息
          _buildSettingItem(
            context,
            title: '版本',
            subtitle: 'v1.0.0',
            trailing: const Icon(Icons.info_outline),
            onTap: () {},
          ),
          
          // 用户协议
          _buildSettingItem(
            context,
            title: '用户协议',
            subtitle: '查看使用条款',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          
          // 隐私政策
          _buildSettingItem(
            context,
            title: '隐私政策',
            subtitle: '查看隐私保护措施',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          
          // 反馈
          _buildSettingItem(
            context,
            title: '反馈',
            subtitle: '提交问题或建议',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ],
      ),
    );
  }
  
  Widget _buildSettingItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
    Color? textColor,
  }) {
    return ListTile(
      title: Text(
        title,
        style: textColor != null ? TextStyle(color: textColor) : null,
      ),
      subtitle: Text(
        subtitle,
        style: textColor != null 
            ? TextStyle(color: textColor.withOpacity(0.7)) 
            : null,
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
  
  Widget _buildSwitchItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }
  
  void _showAPIKeyDialog(BuildContext context, String provider) {
    final providers = {
      'openai': 'OpenAI',
      'anthropic': 'Anthropic',
      'deepseek': 'DeepSeek',
    };
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('配置${providers[provider]} API Key'),
        content: TextField(
          decoration: const InputDecoration(
            labelText: 'API Key',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
  
  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择主题'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('浅色'),
              leading: Radio<ThemeMode>(
                value: ThemeMode.light,
                groupValue: ref.read(themeModeProvider),
                onChanged: (value) {
                  ref.read(themeModeProvider.notifier).state = value!;
                  Navigator.of(context).pop();
                },
              ),
              onTap: () {
                ref.read(themeModeProvider.notifier).state = ThemeMode.light;
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('深色'),
              leading: Radio<ThemeMode>(
                value: ThemeMode.dark,
                groupValue: ref.read(themeModeProvider),
                onChanged: (value) {
                  ref.read(themeModeProvider.notifier).state = value!;
                  Navigator.of(context).pop();
                },
              ),
              onTap: () {
                ref.read(themeModeProvider.notifier).state = ThemeMode.dark;
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('跟随系统'),
              leading: Radio<ThemeMode>(
                value: ThemeMode.system,
                groupValue: ref.read(themeModeProvider),
                onChanged: (value) {
                  ref.read(themeModeProvider.notifier).state = value!;
                  Navigator.of(context).pop();
                },
              ),
              onTap: () {
                ref.read(themeModeProvider.notifier).state = ThemeMode.system;
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择语言'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('简体中文'),
              onTap: () {
                ref.read(localeProvider.notifier).state = const Locale('zh', 'CN');
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('English'),
              onTap: () {
                ref.read(localeProvider.notifier).state = const Locale('en');
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _showCleanCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清理缓存'),
        content: const Text('确定要清理缓存吗？此操作不会删除您的对话数据。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              // TODO: 清理缓存
              Navigator.of(context).pop();
            },
            child: const Text('清理'),
          ),
        ],
      ),
    );
  }
  
  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重置应用'),
        content: const Text(
          '确定要重置应用吗？此操作将删除所有群聊、AI角色和对话记录，且无法撤销！',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              // TODO: 重置应用
              Navigator.of(context).pop();
            },
            child: const Text('确定重置'),
          ),
        ],
      ),
    );
  }
}

