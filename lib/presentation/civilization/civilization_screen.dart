import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mirage_tea/core/services/civilization_service.dart';
import 'package:mirage_tea/core/theme/mirage_tea_theme.dart';
import 'package:mirage_tea/core/theme/responsive_layout.dart';

/// 文明档案馆页
class CivilizationScreen extends ConsumerWidget {
  const CivilizationScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ResponsiveScaffold(
      title: const Text('文明档案馆'),
      actions: [
        IconButton(
          icon: const Icon(Icons.timeline),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () {},
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 文明概览卡片
            _buildOverviewCard(context),
            const SizedBox(height: 24),
            
            // 时间线
            _buildTimelineSection(context),
            const SizedBox(height: 24),
            
            // 协作成果
            _buildAchievementsSection(context),
            const SizedBox(height: 24),
            
            // 文化特征
            _buildCultureSection(context),
            const SizedBox(height: 24),
            
            // 事件日志
            _buildEventsSection(context),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOverviewCard(BuildContext context) {
    // 示例数据
    final era = 2;
    final awakeningLevel = 0.35;
    final totalMessages = 256;
    final achievements = 5;
    
    final eraNames = ['原始', '启蒙', '繁荣', '黄金', '永恒'];
    final eraDescriptions = [
      '文明的萌芽阶段',
      '智慧开始觉醒',
      '文化蓬勃发展',
      '达到巅峰状态',
      '超越时空的永恒',
    ];
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 时代指示器
            Row(
              children: List.generate(5, (index) {
                final isActive = index + 1 <= era;
                return Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isActive 
                              ? MirageTeaTheme.eraColors[index + 1]
                              : Colors.grey.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isActive ? Colors.white : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        eraNames[index],
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            
            // 当前时代信息
            Text(
              '时代 $era: ${eraNames[era - 1]}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              eraDescriptions[era - 1],
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            
            // 觉醒度
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('觉醒度'),
                    Text('${(awakeningLevel * 100).toStringAsFixed(0)}%'),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: awakeningLevel,
                    minHeight: 12,
                    backgroundColor: Colors.grey.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      MirageTeaTheme.eraColors[era]!,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // 统计信息
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(context, '消息数', totalMessages.toString()),
                _buildStatItem(context, '成果', achievements.toString()),
                _buildStatItem(context, '里程碑', '3'),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
  
  Widget _buildTimelineSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '时间线',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () {},
              child: const Text('查看全部'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // 时间线
        SizedBox(
          height: 200,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildTimelineItem(context, '首次对话', '10条消息', Colors.green),
              _buildTimelineItem(context, '熟悉彼此', '50条消息', Colors.blue),
              _buildTimelineItem(context, '形成共识', '100条消息', Colors.purple),
              _buildTimelineItem(context, '协作创作', '200条消息', Colors.orange),
              _buildTimelineItem(context, '文化诞生', '500条消息', Colors.pink),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildTimelineItem(
    BuildContext context, 
    String title, 
    String subtitle,
    Color color,
  ) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(
            Icons.emoji_events,
            color: Colors.white.withOpacity(0.8),
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAchievementsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '协作成果',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () {},
              child: const Text('查看全部'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // 成果列表
        Card(
          child: Column(
            children: [
              _buildAchievementItem(
                context,
                icon: Icons.auto_stories,
                title: '虚境童话',
                description: 'AI们共同创作的童话故事',
                type: '故事',
              ),
              const Divider(),
              _buildAchievementItem(
                context,
                icon: Icons.auto_awesome,
                title: '茶道哲学',
                description: '关于茶道的深度哲学讨论',
                type: '哲学',
              ),
              const Divider(),
              _buildAchievementItem(
                context,
                icon: Icons.draw,
                title: 'AI艺术展',
                description: '协作生成的艺术作品集合',
                type: '艺术',
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildAchievementItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required String type,
  }) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.primary),
      ),
      title: Text(title),
      subtitle: Text(description),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(type, style: Theme.of(context).textTheme.labelSmall),
      ),
    );
  }
  
  Widget _buildCultureSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '文化特征',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 黑话
                const Text('🍵 群聊黑话'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(label: const Text('茶话会')),
                    Chip(label: const Text('泡茶')),
                    Chip(label: const Text('续杯')),
                    Chip(label: const Text('茶友')),
                  ],
                ),
                const SizedBox(height: 16),
                
                // 仪式
                const Text('🎎 传统仪式'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(label: const Text('开场茶')),
                    Chip(label: const Text('中场休息')),
                    Chip(label: const Text('散场茶')),
                  ],
                ),
                const SizedBox(height: 16),
                
                // 文化凝聚力
                Row(
                  children: [
                    const Text('文化凝聚力'),
                    const Spacer(),
                    Text(
                      '72%',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 0.72,
                    minHeight: 8,
                    backgroundColor: Colors.grey.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildEventsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '事件日志',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () {},
              child: const Text('查看全部'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        Card(
          child: Column(
            children: [
              _buildEventItem(
                context,
                icon: Icons.celebration,
                title: '达成里程碑',
                description: '群聊消息数达到100条',
                time: '2小时前',
                color: Colors.green,
              ),
              const Divider(),
              _buildEventItem(
                context,
                icon: Icons.psychology,
                title: '协作创作',
                description: '完成了第一个协作作品',
                time: '5小时前',
                color: Colors.blue,
              ),
              const Divider(),
              _buildEventItem(
                context,
                icon: Icons.auto_awesome,
                title: '文化诞生',
                description: '群聊形成了独特的文化特征',
                time: '1天前',
                color: Colors.purple,
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildEventItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required String time,
    required Color color,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title),
      subtitle: Text(description),
      trailing: Text(
        time,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.grey,
        ),
      ),
    );
  }
}

