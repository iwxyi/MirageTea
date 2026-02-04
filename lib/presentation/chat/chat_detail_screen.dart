import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mirage_tea/core/managers/chat_group_manager.dart';
import 'package:mirage_tea/core/managers/agent_manager.dart';
import 'package:mirage_tea/core/models/chat_models.dart';
import 'package:mirage_tea/core/models/agent_models.dart';
import 'package:mirage_tea/core/services/civilization_service.dart';
import 'package:mirage_tea/core/theme/animations.dart';
import 'package:mirage_tea/core/theme/mirage_tea_theme.dart';


/// 群聊详情页（核心页面）
class ChatDetailScreen extends ConsumerStatefulWidget {
  final String groupId;
  
  const ChatDetailScreen({super.key, required this.groupId});
  
  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}
class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen>
    with TickerProviderStateMixin {
  ChatGroup? _group;
  final List<ChatMessage> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  bool _isRunning = false;
  AnimationController? _animationController;
  
  @override
  void initState() {
    super.initState();
    _loadGroup();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }
  
  @override
  void dispose() {
    _messageController.dispose();
    _animationController?.dispose();
    super.dispose();
  }
  
  void _loadGroup() {
    _group = ChatGroupManager.loadGroup(widget.groupId);
    if (_group != null) {
      setState(() {
        _isRunning = _group!.state == ChatGroupState.running;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_group?.name ?? '群聊'),
            if (_group?.currentTopic != null)
              Text(
                _group!.currentTopic!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        actions: [
          _buildStateIndicator(),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showMoreOptions(context),
          ),
        ],
      ),
      body: Row(
        children: [
          // 消息显示区
          Expanded(
            child: Column(
              children: [
                // 消息列表
                Expanded(
                  child: _buildMessageList(context),
                ),
                
                // 输入区域
                _buildInputArea(context),
              ],
            ),
          ),
          
          // AI成员面板（桌面端显示）
          if (false)
            _buildAgentPanel(context),
        ],
      ),
      // 控制面板
      endDrawer: Drawer(
              child: _buildAgentPanel(context),
            ),
    );
  }
  
  Widget _buildStateIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isRunning)
          AnimatedBuilder(
            animation: _animationController!,
            builder: (context, child) {
              return Transform.rotate(
                angle: _animationController!.value * 2 * 3.14,
                child: child,
              );
            },
            child: const Icon(
              Icons.lens,
              color: Colors.green,
              size: 8,
            ),
          ),
        const SizedBox(width: 4),
        Text(
          _isRunning ? '进行中' : '已暂停',
          style: TextStyle(
            color: _isRunning ? Colors.green : Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
  
  Widget _buildMessageList(BuildContext context) {
    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.coffee,
              size: 64,
              color: Colors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '还没有消息，开始茶话会吧',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _startConversation,
              icon: const Icon(Icons.play_arrow),
              label: Text('开始对话'),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageBubble(context, message, index);
      },
    );
  }
  
  Widget _buildMessageBubble(
    BuildContext context, 
    ChatMessage message,
    int index,
  ) {
    final isUser = message.type == MessageType.user;
    final isSystem = message.type == MessageType.system;
    
    if (isSystem) {
      return _buildSystemMessage(context, message);
    }
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isUser
                ? [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.8),
                  ]
                : [
                    Theme.of(context).colorScheme.surface,
                    Theme.of(context).colorScheme.surfaceVariant,
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isUser)
              FutureBuilder<AIAgent?>(
                future: _getAgent(message.agentId),
                builder: (context, snapshot) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: MirageTeaTheme.getAgentColor(message.agentId),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            snapshot.data?.name[0] ?? message.agentId[0],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        snapshot.data?.name ?? message.agentId,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: MirageTeaTheme.getAgentColor(message.agentId),
                        ),
                      ),
                    ],
                  );
                },
              ),
            const SizedBox(height: 4),
            Text(
              message.content,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isUser ? Colors.white : null,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSystemMessage(BuildContext context, ChatMessage message) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          message.content,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
  
  Widget _buildInputArea(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {},
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: '以"泡茶人"身份发言...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: _sendMessage,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send),
            color: Theme.of(context).colorScheme.primary,
            onPressed: () => _sendMessage(_messageController.text),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAgentPanel(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
        ),
      ),
      child: Column(
        children: [
          // 控制按钮
          _buildControlButtons(context),
          const Divider(),
          
          // AI成员列表
          Expanded(
            child: _buildAgentList(context),
          ),
          
          // 文明状态
          _buildCivilizationPanel(context),
        ],
      ),
    );
  }
  
  Widget _buildControlButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FilledButton.icon(
            onPressed: _isRunning ? _pauseConversation : _startConversation,
            icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
            label: Text(_isRunning ? '暂停对话' : '开始对话'),
            style: FilledButton.styleFrom(
              backgroundColor: _isRunning ? Colors.orange : Colors.green,
            ),
          ),
          OutlinedButton.icon(
            onPressed: _stopConversation,
            icon: const Icon(Icons.stop),
            label: Text('停止对话'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAgentList(BuildContext context) {
    if (_group == null || _group!.agentIds.isEmpty) {
      return Center(
        child: Text(
          '还没有添加AI茶友',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey,
          ),
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _group!.agentIds.length,
      itemBuilder: (context, index) {
        return FutureBuilder<AIAgent?>(
          future: _getAgent(_group!.agentIds[index]),
          builder: (context, snapshot) {
            final agent = snapshot.data;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: MirageTeaTheme.getAgentColor(
                    _group!.agentIds[index],
                  ),
                  child: Text(
                    agent?.name[0] ?? _group!.agentIds[index][0],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(agent?.name ?? '未知AI'),
                subtitle: Text(
                  agent?.personality.traits.join(', ') ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.more_vert),
              ),
            );
          },
        );
      },
    );
  }
  
  Widget _buildCivilizationPanel(BuildContext context) {
    final civState = CivilizationService.getCivilizationState(widget.groupId);
    if (civState == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🏛️ 文明状态',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildEraIndicator(civState.era),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('时代 ${civState.era}'),
                    LinearProgressIndicator(
                      value: civState.awakeningLevel,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '消息数: ${civState.totalMessages}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
  
  Widget _buildEraIndicator(int era) {
    final colors = MirageTeaTheme.eraColors;
    final labels = ['原始', '启蒙', '繁荣', '黄金', '永恒'];
    
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: colors[era],
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          era.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  
  Future<AIAgent?> _getAgent(String agentId) async {
    // TODO: 从AgentManager获取
    return null;
  }
  
  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
  
  void _startConversation() async {
    await ChatGroupManager.startConversation(widget.groupId);
    setState(() {
      _isRunning = true;
    });
  }
  
  void _pauseConversation() async {
    await ChatGroupManager.pauseConversation(widget.groupId);
    setState(() {
      _isRunning = false;
    });
  }
  
  void _stopConversation() async {
    await ChatGroupManager.stopConversation(widget.groupId);
    setState(() {
      _isRunning = false;
    });
  }
  
  void _sendMessage(String content) {
    if (content.trim().isEmpty) return;
    
    // TODO: 发送消息
    _messageController.clear();
  }
  
  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.group_add),
            title: const Text('添加AI茶友'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('群聊设置'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.save),
            title: const Text('导出对话'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('删除群聊', style: TextStyle(color: Colors.red)),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

