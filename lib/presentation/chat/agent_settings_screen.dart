import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mirage_tea/core/managers/agent_manager.dart';
import 'package:mirage_tea/core/models/agent_models.dart';

/// AI角色设置页面
class AgentSettingsScreen extends ConsumerStatefulWidget {
  final String agentId;
  
  const AgentSettingsScreen({super.key, required this.agentId});
  
  @override
  ConsumerState<AgentSettingsScreen> createState() => _AgentSettingsScreenState();
}

class _AgentSettingsScreenState extends ConsumerState<AgentSettingsScreen> {
  AIAgent? _agent;
  
  // 表单控制器
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _backgroundStoryController;
  late final TextEditingController _expertiseController;
  late final TextEditingController _catchphrasesController;
  late final TextEditingController _apiKeyController;
  
  // 滑块控制器
  double _temperature = 0.7;
  int _maxTokens = 1000;
  double _speakingProbability = 0.5;
  int _responseDelayMs = 0;
  
  @override
  void initState() {
    super.initState();
    _loadAgent();
  }
  
  void _loadAgent() async {
    final agent = await AgentManager.getAgent(widget.agentId);
    if (agent != null) {
      setState(() {
        _agent = agent;
        _nameController = TextEditingController(text: agent.name);
        _descriptionController = TextEditingController(text: agent.description);
        _backgroundStoryController = TextEditingController(text: agent.personality.backgroundStory);
        _expertiseController = TextEditingController(text: agent.personality.expertise.join('、'));
        _catchphrasesController = TextEditingController(text: agent.personality.catchphrases.join('、'));
        _apiKeyController = TextEditingController(text: agent.config.apiKey ?? '');
        _temperature = agent.config.temperature;
        _maxTokens = agent.config.maxTokens;
        _speakingProbability = agent.config.speakingProbability;
        _responseDelayMs = agent.config.responseDelayMs;
      });
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _backgroundStoryController.dispose();
    _expertiseController.dispose();
    _catchphrasesController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (_agent == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI茶友设置'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _saveAgent,
            child: const Text('保存'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 基本信息
          _buildSectionTitle('基本信息'),
          _buildTextField(
            controller: _nameController,
            label: '名称',
            icon: Icons.badge,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _descriptionController,
            label: '简介',
            icon: Icons.description,
            maxLines: 2,
          ),
          
          const SizedBox(height: 24),
          
          // 性格特征
          _buildSectionTitle('性格特征'),
          _buildTextField(
            controller: _backgroundStoryController,
            label: '背景故事',
            icon: Icons.auto_stories,
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _expertiseController,
            label: '专长领域（用顿号分隔）',
            icon: Icons.stars,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _catchphrasesController,
            label: '口头禅（用顿号分隔）',
            icon: Icons.record_voice_over,
          ),
          
          const SizedBox(height: 24),
          
          // 性格标签
          _buildSectionTitle('性格标签'),
          _buildTraitsSelector(),
          
          const SizedBox(height: 24),
          
          // AI配置
          _buildSectionTitle('AI配置'),
          _buildModelTypeSelector(),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _apiKeyController,
            label: 'API Key',
            icon: Icons.key,
            obscureText: true,
          ),
          const SizedBox(height: 24),
          
          // 参数调节
          _buildSlider(
            title: 'Temperature',
            value: _temperature,
            min: 0.0,
            max: 2.0,
            onChanged: (value) => setState(() => _temperature = value),
          ),
          _buildSlider(
            title: 'Max Tokens',
            value: _maxTokens.toDouble(),
            min: 100,
            max: 4000,
            divisions: 39,
            onChanged: (value) => setState(() => _maxTokens = value.toInt()),
          ),
          _buildSlider(
            title: '发言概率',
            value: _speakingProbability,
            min: 0.0,
            max: 1.0,
            onChanged: (value) => setState(() => _speakingProbability = value),
          ),
          _buildSlider(
            title: '回复延迟 (ms)',
            value: _responseDelayMs.toDouble(),
            min: 0,
            max: 5000,
            divisions: 50,
            onChanged: (value) => setState(() => _responseDelayMs = value.toInt()),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
        ),
      ),
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }
  
  Widget _buildTraitsSelector() {
    final allTraits = [
      '理性', '感性', '幽默', '严肃', '好奇', '沉稳', 
      '热情', '冷静', '创新', '传统', '冒险', '谨慎',
      '乐观', '悲观', '外向', '内向'
    ];
    
    final selectedTraits = _agent?.personality.traits ?? [];
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: allTraits.map((trait) {
        final isSelected = selectedTraits.contains(trait);
        return FilterChip(
          label: Text(trait),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _agent!.personality.traits.add(trait);
              } else {
                _agent!.personality.traits.remove(trait);
              }
            });
          },
        );
      }).toList(),
    );
  }
  
  Widget _buildModelTypeSelector() {
    final modelTypes = ['gpt-4', 'gpt-3.5-turbo', 'claude-3-opus', 'claude-3-sonnet', 'gemini-pro'];
    
    return FormField<String>(
      initialValue: _agent?.config.modelType ?? 'gpt-4',
      builder: (FormFieldState<String> state) {
        return InputDecorator(
          decoration: const InputDecoration(
            labelText: '模型类型',
            prefixIcon: Icon(Icons.model_training),
            border: OutlineInputBorder(),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: state.value,
              isExpanded: true,
              onChanged: (value) {
                state.didChange(value);
                _agent?.config.modelType = value!;
              },
              items: modelTypes.map((model) {
                return DropdownMenuItem(
                  value: model,
                  child: Text(model),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildSlider({
    required String title,
    required double value,
    required double min,
    required double max,
    int? divisions,
    required void Function(double) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            Text(
              value.toStringAsFixed(divisions != null ? 0 : 1),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }
  
  void _saveAgent() {
    if (_agent == null) return;
    
    _agent!.name = _nameController.text;
    _agent!.description = _descriptionController.text;
    _agent!.personality.backgroundStory = _backgroundStoryController.text;
    _agent!.personality.expertise = _expertiseController.text
        .split('、')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    _agent!.personality.catchphrases = _catchphrasesController.text
        .split('、')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    _agent!.config.apiKey = _apiKeyController.text.isEmpty ? null : _apiKeyController.text;
    _agent!.config.temperature = _temperature;
    _agent!.config.maxTokens = _maxTokens;
    _agent!.config.speakingProbability = _speakingProbability;
    _agent!.config.responseDelayMs = _responseDelayMs;
    
    // 保存到Hive
    _agent!.save();
    
    Navigator.of(context).pop();
  }
}

