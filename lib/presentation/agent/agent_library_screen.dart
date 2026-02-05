import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mirage_tea/core/managers/agent_manager.dart';
import 'package:mirage_tea/core/managers/chat_group_manager.dart';
import 'package:mirage_tea/core/models/agent_models.dart';
import 'package:mirage_tea/core/theme/mirage_tea_theme.dart';
import 'agent_parameter_editor_screen.dart';


/// AI角色库页（作为主屏幕的内容区域）
class AgentLibraryContent extends ConsumerWidget {
  const AgentLibraryContent({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ValueListenableBuilder<List<AIAgent>>(
      valueListenable: AgentManager.getAgentsListenable(),
      builder: (context, allAgents, child) {
        if (allAgents.isEmpty) {
          return _buildEmptyState(context);
        }
        return _buildAgentList(context, allAgents);
      },
    );
  }
  
  Widget _buildAgentList(BuildContext context, List<AIAgent> agents) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: agents.length,
      itemBuilder: (context, index) {
        final agent = agents[index];
        return _buildAgentCard(context, agent);
      },
    );
  }
  
  Widget _buildAgentCard(BuildContext context, AIAgent agent) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: () => Navigator.of(context).pushNamed('/agent/${agent.id}/edit'),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      MirageTeaTheme.getAgentColor(agent.id),
                      MirageTeaTheme.getAgentColor(agent.id).withOpacity(0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    agent.name.isNotEmpty ? agent.name[0] : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      agent.name,
                      style: Theme.of(context).textTheme.bodyLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (agent.description.isNotEmpty)
                      Text(
                        agent.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey.withOpacity(0.5),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.psychology,
            size: 80,
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '还没有AI角色，来创建一个吧',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              print('[AgentLibrary] 点击创建角色按钮');
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AgentParameterEditorScreen(isCreating: true),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('创建角色模板'),
          ),
        ],
      ),
    );
  }
  
  void _showAgentDetail(BuildContext context, AIAgent agent) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      agent.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  MirageTeaTheme.getAgentColor(agent.id),
                                  MirageTeaTheme.getAgentColor(agent.id).withOpacity(0.6),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                agent.name.isNotEmpty ? agent.name[0] : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (agent.description.isNotEmpty)
                          Text(
                            agent.description,
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        const SizedBox(height: 16),
                        _buildParamsSection(context, agent),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AgentParameterEditorScreen(agent: agent),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('编辑'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _showAddToGroupDialog(context, agent),
                        icon: const Icon(Icons.group_add),
                        label: const Text('添加到群聊'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showDeleteConfirmDialog(context, agent),
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    label: const Text('删除', style: TextStyle(color: Colors.red)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildParamsSection(BuildContext context, AIAgent agent) {
    final params = agent.parameters;
    
    final items = <String>[];
    
    if (params.expertiseAreas.isNotEmpty) {
      items.add('专长：${params.expertiseAreas.join("、")}');
    }
    
    if (params.speakingStyle.isNotEmpty && params.speakingStyle != 'balanced') {
      items.add('风格：${params.speakingStyle}');
    }
    
    final traits = <String>[];
    if (params.openness > 0.7) traits.add('开放');
    else if (params.openness < 0.3) traits.add('保守');
    
    if (params.rationality > 0.7) traits.add('理性');
    else if (params.rationality < 0.3) traits.add('感性');
    
    if (params.socialEnergy > 0.7) traits.add('外向');
    else if (params.socialEnergy < 0.3) traits.add('内向');
    
    if (params.empathy > 0.7) traits.add('高同理心');
    else if (params.empathy < 0.3) traits.add('低同理心');
    
    if (traits.isNotEmpty) {
      items.add('性格：${traits.join("、")}');
    }
    
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            item,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        );
      }).toList(),
    );
  }
  
  void _showAddToGroupDialog(BuildContext context, AIAgent agent) {
    Navigator.of(context).pop();
    
    final allGroups = ChatGroupManager.getAllGroups();
    
    if (allGroups.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('没有群聊'),
          content: const Text('请先创建一个群聊'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('确定'),
            ),
          ],
        ),
      );
      return;
    }
    
    final selectedGroups = <String>{};
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('添加到群聊'),
              content: SizedBox(
                width: 300,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: allGroups.length,
                  itemBuilder: (context, index) {
                    final group = allGroups[index];
                    final alreadyAdded = group.agentIds.contains(agent.id);
                    
                    return CheckboxListTile(
                      title: Text(group.name),
                      subtitle: alreadyAdded
                          ? const Text('已添加', style: TextStyle(color: Colors.green))
                          : null,
                      value: alreadyAdded || selectedGroups.contains(group.id),
                      onChanged: alreadyAdded
                          ? null
                          : (value) {
                              setState(() {
                                if (value == true) {
                                  selectedGroups.add(group.id);
                                } else {
                                  selectedGroups.remove(group.id);
                                }
                              });
                            },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('取消'),
                ),
                FilledButton(
                  onPressed: selectedGroups.isEmpty
                      ? null
                      : () async {
                          for (final groupId in selectedGroups) {
                            await ChatGroupManager.addAgent(groupId, agent.id);
                          }
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('已添加到群聊')),
                            );
                          }
                        },
                  child: const Text('添加'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  void _showDeleteConfirmDialog(BuildContext context, AIAgent agent) {
    Navigator.of(context).pop();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除角色'),
        content: Text('确定要删除角色「${agent.name}」吗？这将从所有群聊中移除此角色，且无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final allGroups = ChatGroupManager.getAllGroups();
              for (final group in allGroups) {
                if (group.agentIds.contains(agent.id)) {
                  group.agentIds.remove(agent.id);
                  await group.save();
                }
              }
              
              await AgentManager.deleteAgent(agent.id);
              
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('角色已删除')),
                );
              }
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
