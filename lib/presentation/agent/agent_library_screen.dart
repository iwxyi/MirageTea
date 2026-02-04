import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mirage_tea/core/managers/agent_manager.dart';
import 'package:mirage_tea/core/models/agent_models.dart';
import 'package:mirage_tea/core/theme/animations.dart';
import 'package:mirage_tea/core/theme/mirage_tea_theme.dart';
import 'package:mirage_tea/core/theme/responsive_layout.dart';


/// AI角色库页
class AgentLibraryScreen extends ConsumerWidget {
  const AgentLibraryScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allAgents = AgentManager.getAllAgents();
    
    return ResponsiveScaffold(
      title: const Text('AI角色库'),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _showCreateAgentDialog(context),
        ),
      ],
      body: Column(
        children: [
          // 筛选标签
          _buildFilterChips(context),
          // 角色网格
          Expanded(
            child: allAgents.isEmpty
                ? _buildEmptyState(context)
                : _buildAgentGrid(context, allAgents),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateAgentDialog(context),
        icon: const Icon(Icons.add),
        label: Text('创建角色'),
      ),
    );
  }
  
  Widget _buildFilterChips(BuildContext context) {
    final filters = ['全部', '哲学家', '科学家', '诗人', '评论家', '自定义'];
    
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filters[index]),
              selected: index == 0,
              onSelected: (selected) {},
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildAgentGrid(BuildContext context, List<AIAgent> agents) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: agents.length,
      itemBuilder: (context, index) {
        final agent = agents[index];
        return Animations.scaleIn(
          child: _buildAgentCard(context, agent),
          delay: Duration(milliseconds: 50 * index),
        );
      },
    );
  }
  
  Widget _buildAgentCard(BuildContext context, AIAgent agent) {
    return Card(
      child: InkWell(
        onTap: () => _showAgentDetail(context, agent),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 头像
              Container(
                width: 64,
                height: 64,
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
                    agent.name[0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // 名称
              Text(
                agent.name,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              
              // 描述
              if (agent.description.isNotEmpty)
                Text(
                  agent.description,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              
              const Spacer(),
              
          // 性格标签
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: agent.personality.traits.take(3).map((trait) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  trait,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              );
            }).toList(),
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
            onPressed: () => _showCreateAgentDialog(context),
            icon: const Icon(Icons.add),
            label: Text('创建角色'),
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
        initialChildSize: 0.8,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 头部
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
                
                // 内容
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 头像和基本信息
                        Center(
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  MirageTeaTheme.getAgentColor(agent.id),
                                  MirageTeaTheme.getAgentColor(agent.id).withOpacity(0.6),
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                agent.name[0],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // 描述
                        if (agent.description.isNotEmpty)
                          Text(
                            agent.description,
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                        
                        const SizedBox(height: 24),
                        
                        // 性格特征
                        _buildSection(
                          context,
                          title: '性格特征',
                          children: agent.personality.traits.map((trait) {
                            return Chip(label: Text(trait));
                          }).toList(),
                        ),
                        
                        // 说话风格
                        if (agent.personality.speakingStyles.isNotEmpty)
                          _buildSection(
                            context,
                            title: '说话风格',
                            children: agent.personality.speakingStyles.map((style) {
                              return Chip(label: Text(style));
                            }).toList(),
                          ),
                        
                        // 专长领域
                        if (agent.personality.expertise.isNotEmpty)
                          _buildSection(
                            context,
                            title: '专长领域',
                            children: agent.personality.expertise.map((exp) {
                              return Chip(label: Text(exp));
                            }).toList(),
                          ),
                        
                        // 常用语
                        if (agent.personality.catchphrases.isNotEmpty)
                          _buildSection(
                            context,
                            title: '常用语',
                            children: agent.personality.catchphrases.map((phrase) {
                              return Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surfaceVariant,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text('"$phrase"'),
                              );
                            }).toList(),
                          ),
                        
                        // 背景故事
                        if (agent.personality.backgroundStory.isNotEmpty)
                          _buildSection(
                            context,
                            title: '背景故事',
                            children: [
                              Text(agent.personality.backgroundStory),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                
                // 操作按钮
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.edit),
                        label: const Text('编辑'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add),
                        label: const Text('添加到群聊'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: children,
          ),
        ],
      ),
    );
  }
  
  void _showCreateAgentDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const CreateAgentForm(),
    );
  }
}
/// 创建AI角色表单
class CreateAgentForm extends StatefulWidget {
  const CreateAgentForm({super.key});
  
  @override
  State<CreateAgentForm> createState() => _CreateAgentFormState();
}
class _CreateAgentFormState extends State<CreateAgentForm> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _backgroundController = TextEditingController();
  final _catchphrasesController = TextEditingController();
  List<String> _traits = [];
  List<String> _expertise = [];
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '创建角色',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 角色名称
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: '角色名称',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 角色描述
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: '角色描述',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  
                  // 性格特征
                  const Text('性格特征'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['哲学', '冷静', '深刻', '幽默', '好奇', '严谨', '浪漫', '敏感'].map((trait) {
                      return FilterChip(
                        label: Text(trait),
                        selected: _traits.contains(trait),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _traits.add(trait);
                            } else {
                              _traits.remove(trait);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  
                  // 专长领域
                  const Text('专长领域'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['哲学', '科学', '文学', '艺术', '历史', '技术'].map((exp) {
                      return FilterChip(
                        label: Text(exp),
                        selected: _expertise.contains(exp),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _expertise.add(exp);
                            } else {
                              _expertise.remove(exp);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  
                  // 背景故事
                  TextField(
                    controller: _backgroundController,
                    decoration: const InputDecoration(
                      labelText: '背景故事',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  
                  // 常用语
                  TextField(
                    controller: _catchphrasesController,
                    decoration: const InputDecoration(
                      labelText: '常用语（用逗号分隔）',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 创建按钮
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _createAgent,
              child: const Text('创建角色'),
            ),
          ),
        ],
      ),
    );
  }
  
  void _createAgent() async {
    final name = _nameController.text;
    if (name.isEmpty) return;
    
    final personality = AgentPersonality(
      traits: _traits,
      expertise: _expertise,
      backgroundStory: _backgroundController.text,
      catchphrases: _catchphrasesController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
    );
    
    await AgentManager.createAgent(
      name: name,
      description: _descriptionController.text,
      personality: personality,
    );
    
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}

