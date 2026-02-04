import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mirage_tea/core/managers/chat_group_manager.dart';
import 'package:mirage_tea/core/theme/animations.dart';
import 'package:mirage_tea/core/theme/responsive_layout.dart';
import 'package:mirage_tea/core/models/chat_models.dart';

/// 群聊列表页
class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allGroups = ChatGroupManager.getAllGroups();
    
    return ResponsiveScaffold(
      title: const Text('群聊'),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => _showSearchDialog(context),
        ),
      ],
      body: Column(
        children: [
          _buildSearchBar(context),
          Expanded(
            child: allGroups.isEmpty
                ? _buildEmptyState(context)
                : _buildChatList(context, allGroups),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateGroupDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: '搜索群聊...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
        ),
        onChanged: (value) {
          // TODO: 实现搜索过滤
        },
      ),
    );
  }
  
  Widget _buildChatList(BuildContext context, List<ChatGroup> groups) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return Animations.listItem(
          child: _buildChatCard(context, group),
          index: index,
        );
      },
    );
  }
  
  Widget _buildChatCard(BuildContext context, ChatGroup group) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.of(context).pushNamed('/chat/${group.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    radius: 24,
                    child: Text(
                      group.name.isNotEmpty ? group.name[0] : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (group.description.isNotEmpty)
                          Text(
                            group.description,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  _buildStateBadge(context, group.state),
                ],
              ),
              if (group.currentTopic != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '📌 ${group.currentTopic}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.people, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${group.agentIds.length} 位AI茶友',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  Text(
                    _formatTime(group.lastActivityAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStateBadge(BuildContext context, ChatGroupState state) {
    Color color;
    String text;
    
    switch (state) {
      case ChatGroupState.running:
        color = Colors.green;
        text = '进行中';
        break;
      case ChatGroupState.paused:
        color = Colors.orange;
        text = '已暂停';
        break;
      case ChatGroupState.stopped:
        color = Colors.grey;
        text = '已停止';
        break;
      default:
        color = Colors.blue;
        text = '空闲';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
  
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.coffee,
              size: 80,
              color: Colors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              '还没有群聊，来创建一个吧',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _showCreateGroupDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('新建群聊'),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    
    return '${time.month}/${time.day}';
  }
  
  void _showSearchDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              autofocus: true,
              decoration: const InputDecoration(
                hintText: '搜索群聊...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(label: const Text('全部'), selected: false, onSelected: (v) {}),
                FilterChip(label: const Text('进行中'), selected: false, onSelected: (v) {}),
                FilterChip(label: const Text('已暂停'), selected: false, onSelected: (v) {}),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _showCreateGroupDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        height: MediaQuery.of(context).size.height * 0.8,
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
  final _topicController = TextEditingController();
  List<String> _selectedAgents = [];
  
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
        
        // 群聊名称
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: '群聊名称',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        
        // 群聊描述
        TextField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: '群聊描述（可选）',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        
        // 话题
        TextField(
          controller: _topicController,
          decoration: const InputDecoration(
            labelText: '讨论话题（可选）',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),
        
        // 选择AI角色
        Text(
          '选择AI茶友',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.8,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              final agentNames = ['思考者', '探索者', '吟游诗人', '评论家'];
              return _buildAgentCard(context, agentNames[index], index);
            },
          ),
        ),
        
        const SizedBox(height: 16),
        
        // 创建按钮
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _selectedAgents.isEmpty ? null : () => _createGroup(context),
            child: const Text('创建群聊'),
          ),
        ),
      ],
    );
  }
  
  Widget _buildAgentCard(BuildContext context, String name, int index) {
    final isSelected = _selectedAgents.contains(name);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedAgents.remove(name);
          } else {
            _selectedAgents.add(name);
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary 
                : Colors.grey,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected 
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(name.isNotEmpty ? name[0] : '?'),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
  
  void _createGroup(BuildContext context) async {
    final name = _nameController.text;
    if (name.isEmpty) return;
    
    final group = await ChatGroupManager.createGroup(
      name: name,
      description: _descriptionController.text,
      topic: _topicController.text.isEmpty ? null : _topicController.text,
      agentIds: _selectedAgents,
    );
    
    if (mounted) {
      Navigator.of(context).pop();
      Navigator.of(context).pushNamed('/chat/${group.id}');
    }
  }
}
