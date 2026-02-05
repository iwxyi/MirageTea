import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mirage_tea/core/managers/chat_group_manager.dart';
import 'package:mirage_tea/core/managers/agent_manager.dart';
import 'package:mirage_tea/core/models/chat_models.dart';
import 'package:mirage_tea/core/models/agent_models.dart';
import 'package:mirage_tea/core/theme/mirage_tea_theme.dart';
import 'package:mirage_tea/presentation/chat/chat_group_settings_screen.dart';

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
        title: Text(
          _group?.name ?? '群聊',
          style: const TextStyle(fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          _buildStateIndicator(),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () => _openGroupSettings(context),
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
        ],
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
  
  void _openGroupSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatGroupSettingsScreen(groupId: widget.groupId),
      ),
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
              label: const Text('开始对话'),
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
  
  Future<AIAgent?> _getAgent(String agentId) async {
    return AgentManager.getAgent(agentId);
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
}
