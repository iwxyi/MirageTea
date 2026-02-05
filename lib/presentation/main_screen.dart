import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mirage_tea/core/managers/agent_manager.dart';
import 'package:mirage_tea/core/managers/chat_group_manager.dart';
import 'package:mirage_tea/core/models/agent_models.dart';
import 'package:mirage_tea/core/models/chat_models.dart';
import 'package:mirage_tea/core/theme/mirage_tea_theme.dart';
import 'agent/agent_library_screen.dart';
import 'agent/create_agent_screen.dart';
import 'agent/agent_parameter_editor_screen.dart';
import 'civilization/civilization_screen.dart';
import 'settings/settings_screen.dart';

// 页面类型枚举
enum NavPage {
  chats,
  civilization,
  agents,
  topicTemplates,
  settings,
}

// 导航状态 provider
final currentNavPageProvider = StateProvider<NavPage>((ref) {
  return NavPage.chats;
});

/// 主屏幕 - 包含导航抽屉和内容区域
class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = ref.watch(currentNavPageProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_getPageTitle(currentPage)),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
        actions: currentPage == NavPage.chats
            ? [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {},
                ),
              ]
            : currentPage == NavPage.agents
                ? [
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {},
                    ),
                  ]
                : [],
      ),
      drawer: _buildDrawer(context, ref),
      body: _buildPageContent(context, ref, currentPage),
      floatingActionButton: currentPage == NavPage.chats
          ? FloatingActionButton(
              onPressed: () => _showCreateGroupDialog(context),
              child: const Icon(Icons.add),
            )
          : currentPage == NavPage.agents
              ? FloatingActionButton.extended(
                  onPressed: () => Navigator.of(context).pushNamed('/create-agent'),
                  icon: const Icon(Icons.add),
                  label: const Text('创建角色'),
                )
              : null,
    );
  }

  String _getPageTitle(NavPage page) {
    switch (page) {
      case NavPage.chats:
        return '群聊';
      case NavPage.civilization:
        return '文明活动';
      case NavPage.agents:
        return 'AI角色库';
      case NavPage.topicTemplates:
        return '话题模板';
      case NavPage.settings:
        return '设置';
    }
  }

  Widget _buildDrawer(BuildContext context, WidgetRef ref) {
    final currentPage = ref.watch(currentNavPageProvider);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF6200EE),
            ),
            accountName: Text('用户'),
            accountEmail: Text('mirage_tea@example.com'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                'M',
                style: TextStyle(fontSize: 32, color: Color(0xFF6200EE)),
              ),
            ),
          ),
          _buildDrawerItem(
            context,
            ref,
            icon: Icons.chat,
            title: '群聊',
            page: NavPage.chats,
            isSelected: currentPage == NavPage.chats,
          ),
          _buildDrawerItem(
            context,
            ref,
            icon: Icons.auto_awesome,
            title: 'AI角色库',
            page: NavPage.agents,
            isSelected: currentPage == NavPage.agents,
          ),
          _buildDrawerItem(
            context,
            ref,
            icon: Icons.bar_chart,
            title: '文明活动',
            page: NavPage.civilization,
            isSelected: currentPage == NavPage.civilization,
          ),
          _buildDrawerItem(
            context,
            ref,
            icon: Icons.topic,
            title: '话题模板',
            page: NavPage.topicTemplates,
            isSelected: currentPage == NavPage.topicTemplates,
          ),
          const Divider(),
          _buildDrawerItem(
            context,
            ref,
            icon: Icons.settings,
            title: '设置',
            page: NavPage.settings,
            isSelected: currentPage == NavPage.settings,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String title,
    required NavPage page,
    required bool isSelected,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: isSelected,
      selectedTileColor: Colors.grey[200],
      onTap: () {
        Navigator.of(context).pop();
        if (!isSelected) {
          ref.read(currentNavPageProvider.notifier).state = page;
        }
      },
    );
  }

  Widget _buildPageContent(BuildContext context, WidgetRef ref, NavPage page) {
    switch (page) {
      case NavPage.chats:
        return _buildChatsPage(context);
      case NavPage.agents:
        return _buildAgentsPage(context);
      case NavPage.civilization:
        return _buildCivilizationPage(context);
      case NavPage.topicTemplates:
        return _buildTopicTemplatesPage(context);
      case NavPage.settings:
        return _buildSettingsPage(context);
    }
  }

  Widget _buildChatsPage(BuildContext context) {
    return StreamBuilder<List<ChatGroup>>(
      stream: ChatGroupManager.groupsStream,
      initialData: ChatGroupManager.getAllGroups(),
      builder: (context, snapshot) {
        final allGroups = snapshot.data ?? [];
        
        if (allGroups.isEmpty) {
          return _buildEmptyState(
            context,
            icon: Icons.chat_bubble_outline,
            message: '还没有群聊',
            buttonText: '新建群聊',
            onButtonPressed: () => _showCreateGroupDialog(context),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: allGroups.length,
          itemBuilder: (context, index) {
            final group = allGroups[index];
            return _buildChatItem(context, group);
          },
        );
      },
    );
  }

  Widget _buildChatItem(BuildContext context, ChatGroup group) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.of(context).pushNamed('/chat/${group.id}'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey[200]!),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  group.name.isNotEmpty ? group.name[0] : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          group.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _formatTime(group.lastActivityAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            group.currentTopic ?? group.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildStateIcon(group.state),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStateIcon(ChatGroupState state) {
    IconData icon;
    Color color;

    switch (state) {
      case ChatGroupState.running:
        icon = Icons.play_circle_filled;
        color = Colors.green;
        break;
      case ChatGroupState.paused:
        icon = Icons.pause_circle_outline;
        color = Colors.orange;
        break;
      case ChatGroupState.stopped:
        icon = Icons.stop_circle_outlined;
        color = Colors.grey;
        break;
      default:
        icon = Icons.chat_bubble_outline;
        color = Colors.grey[400]!;
    }

    return Icon(icon, size: 20, color: color);
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟';
    if (diff.inHours < 24) return '${diff.inHours}小时';
    if (diff.inDays < 7) return '${diff.inDays}天';

    return '${time.month}/${time.day}';
  }

  Widget _buildAgentsPage(BuildContext context) {
    return const AgentLibraryContent();
  }
  
  Widget _buildCivilizationPage(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            '文明活动统计',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pushNamed('/civilization'),
            icon: const Icon(Icons.bar_chart),
            label: const Text('查看详情'),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicTemplatesPage(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.topic,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            '话题模板',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsPage(BuildContext context) {
    return const SettingsScreen();
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String message,
    required String buttonText,
    required VoidCallback onButtonPressed,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onButtonPressed,
            icon: const Icon(Icons.add),
            label: Text(buttonText),
          ),
        ],
      ),
    );
  }

  void _showCreateGroupDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        height: MediaQuery.of(context).size.height * 0.75,
        child: const CreateGroupForm(),
      ),
    );
  }
}

/// 创建群聊表单
class CreateGroupForm extends StatefulWidget {
  const CreateGroupForm({super.key});

  @override
  State<CreateGroupForm> createState() => _CreateGroupFormState();
}

class _CreateGroupFormState extends State<CreateGroupForm> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '新建群聊',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: '群聊名称',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: '群聊描述（可选）',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _createGroup,
            child: const Text('创建群聊'),
          ),
        ),
      ],
    );
  }

  void _createGroup() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入群聊名称')),
      );
      return;
    }

    await ChatGroupManager.createGroup(
      name: name,
      description: _descriptionController.text.trim(),
    );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
