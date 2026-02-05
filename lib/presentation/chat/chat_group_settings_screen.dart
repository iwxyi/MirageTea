import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mirage_tea/core/managers/chat_group_manager.dart';
import 'package:mirage_tea/core/managers/agent_manager.dart';
import 'package:mirage_tea/core/models/chat_models.dart';
import 'package:mirage_tea/core/models/agent_models.dart';
import 'package:mirage_tea/presentation/chat/agent_settings_screen.dart';

/// 群聊设置页面
class ChatGroupSettingsScreen extends ConsumerStatefulWidget {
  final String groupId;
  
  const ChatGroupSettingsScreen({super.key, required this.groupId});
  
  @override
  ConsumerState<ChatGroupSettingsScreen> createState() => _ChatGroupSettingsScreenState();
}

class _ChatGroupSettingsScreenState extends ConsumerState<ChatGroupSettingsScreen> {
  ChatGroup? _group;
  List<AIAgent> _agents = [];
  bool _isExpanded = false;
  
  @override
  void initState() {
    super.initState();
    _loadGroup();
    _loadAgents();
  }
  
  void _loadGroup() {
    _group = ChatGroupManager.loadGroup(widget.groupId);
  }
  
  void _loadAgents() async {
    if (_group != null) {
      final agents = <AIAgent>[];
      for (final id in _group!.agentIds) {
        final agent = await AgentManager.getAgent(id);
        if (agent != null) agents.add(agent);
      }
      setState(() {
        _agents = agents;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('聊天信息'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          // AI茶友列表（网格形式）
          _buildAgentGridSection(),
          
          const Divider(height: 32),
          
          // 群聊名称
          _buildEditItem(
            context,
            title: '群聊名称',
            value: _group?.name ?? '',
            icon: Icons.edit,
            onTap: () => _showEditDialog(
              context,
              title: '修改群聊名称',
              initialValue: _group?.name ?? '',
              onConfirm: (value) {
                ChatGroupManager.updateGroup(widget.groupId, name: value);
                setState(() {
                  _group = ChatGroupManager.loadGroup(widget.groupId);
                });
              },
            ),
          ),
          
          // 话题
          _buildEditItem(
            context,
            title: '话题',
            value: _group?.currentTopic ?? '未设置',
            icon: Icons.topic,
            onTap: () => _showEditDialog(
              context,
              title: '修改讨论主题',
              initialValue: _group?.currentTopic ?? '',
              onConfirm: (value) {
                ChatGroupManager.updateGroup(widget.groupId, topic: value.isEmpty ? null : value);
                setState(() {
                  _group = ChatGroupManager.loadGroup(widget.groupId);
                });
              },
            ),
          ),
          
          const Divider(height: 32),
          
          // 活动统计
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('活动统计'),
            subtitle: const Text('查看文明档案馆'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/civilization');
            },
          ),
          
          const Divider(height: 32),
          
          // 查找聊天记录（置灰）
          ListTile(
            leading: Icon(Icons.search, color: Colors.grey[400]),
            title: const Text('查找聊天记录', style: TextStyle(color: Colors.grey)),
            enabled: false,
          ),
          
          // 清空聊天记录
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('清空聊天记录'),
            onTap: () => _confirmClearMessages(context),
          ),
          
          // 删除群聊
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('删除群聊', style: TextStyle(color: Colors.red)),
            onTap: () => _confirmDeleteGroup(context),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAgentGridSection() {
    final maxRows = 4;
    final itemsPerRow = 4;
    final maxVisible = maxRows * itemsPerRow;
    final showExpandButton = _agents.length > maxVisible;
    final visibleAgents = _isExpanded || !showExpandButton 
        ? _agents 
        : _agents.take(maxVisible).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AI茶友 (${_agents.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              if (showExpandButton)
                GestureDetector(
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  child: Row(
                    children: [
                      Text(
                        _isExpanded ? '收起' : '更多群成员',
                        style: TextStyle(color: Colors.blue[400], fontSize: 14),
                      ),
                      Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.blue[400],
                        size: 20,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            ...visibleAgents.map((agent) => _buildAgentGridItem(context, agent)),
            if (_agents.isNotEmpty) _buildAddAgentButton(context),
          ],
        ),
      ],
    );
  }
  
  Widget _buildAddAgentButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAddAgentDialog(context),
      child: SizedBox(
        width: 64,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 2,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(
                Icons.add,
                size: 28,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '添加',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAgentGridItem(BuildContext context, AIAgent agent) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AgentSettingsScreen(agentId: agent.id),
          ),
        );
      },
      child: SizedBox(
        width: 64,
        child: Column(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: _parseAgentColor(agent.avatar),
              child: Text(
                agent.name[0],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              agent.name,
              style: const TextStyle(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _parseAgentColor(String avatar) {
    if (avatar.startsWith('Color(')) {
      final hex = avatar.replaceAll('Color(', '').replaceAll(')', '');
      return Color(int.parse(hex));
    }
    return Colors.blue;
  }
  
  Widget _buildEditItem(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
  
  void _showEditDialog(
    BuildContext context, {
    required String title,
    required String initialValue,
    required void Function(String) onConfirm,
  }) {
    final controller = TextEditingController(text: initialValue);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm(controller.text);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
  
  void _confirmClearMessages(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空聊天记录'),
        content: const Text('确定要清空所有聊天记录吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: 清空聊天记录
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
  
  void _confirmDeleteGroup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除群聊'),
        content: const Text('确定要删除这个群聊吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(context).pop(); // 关闭确认对话框
              Navigator.of(context).pop(); // 关闭设置页面
              ChatGroupManager.deleteGroup(widget.groupId);
              // 使用 popUntil 回到群聊列表
              Future.delayed(Duration.zero, () {
                if (mounted) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              });
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
  
  void _showAddAgentDialog(BuildContext context) {
    final allAgents = AgentManager.getAllAgents();
    final existingIds = _agents.map((a) => a.id).toSet();
    final availableAgents = allAgents.where((a) => !existingIds.contains(a.id)).toList();

    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '添加AI茶友',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          if (availableAgents.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                '没有可添加的AI角色',
                style: TextStyle(color: Colors.grey[500]),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: availableAgents.length,
                itemBuilder: (context, index) {
                  final agent = availableAgents[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Text(agent.name[0]),
                    ),
                    title: Text(agent.name),
                    subtitle: Text(agent.description),
                    onTap: () async {
                      Navigator.of(context).pop();
                      await ChatGroupManager.addAgent(widget.groupId, agent.id);
                      _loadGroup();
                      _loadAgents();
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

