import 'package:flutter/material.dart';
import 'package:mirage_tea/core/managers/agent_manager.dart';
import 'package:mirage_tea/core/managers/chat_group_manager.dart';
import 'package:mirage_tea/core/models/agent_models.dart';
import 'package:mirage_tea/core/theme/mirage_tea_theme.dart';
import 'package:mirage_tea/core/utils/ai_generator.dart';

/// AI角色参数编辑器页面 - 卡片式折叠设计
class AgentParameterEditorScreen extends StatefulWidget {
  final AIAgent? agent;
  final AgentParameters? initialParams;
  final String? initialName;
  final String? initialDescription;
  final bool isCreating;

  const AgentParameterEditorScreen({
    super.key,
    this.agent,
    this.initialParams,
    this.initialName,
    this.initialDescription,
    this.isCreating = false,
  });

  @override
  State<AgentParameterEditorScreen> createState() =>
      _AgentParameterEditorScreenState();
}

class _AgentParameterEditorScreenState
    extends State<AgentParameterEditorScreen> {
  late AgentParameters _params;
  List<String> _expertiseAreas = [];
  String? _selectedPreset;

  // 折叠状态
  bool _basicExpanded = true;
  bool _coreExpanded = true;
  bool _expertiseExpanded = true;
  bool _aiConfigExpanded = false; // AI配置默认折叠

  // 名字和描述控制器
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _customExpertiseController = TextEditingController();

  // AI名字建议列表和当前选中的建议
  List<String> _nameSuggestions = [];
  String? _selectedNameSuggestion;

  // AI配置控制器
  final _modelController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _apiUrlController = TextEditingController();

  // 是否使用全局配置
  bool _useGlobalConfig = true;

  // 可选的专业领域
  final List<String> _availableExpertise = [
    '哲学',
    '科学',
    '文学',
    '艺术',
    '历史',
    '技术',
    '商业',
    '心理学',
    '社会学',
    '经济学',
    '政治学',
    '数学',
    '物理',
    '化学',
    '生物',
    '医学',
    '法律',
    '教育',
    '设计',
    '音乐',
    '电影',
    '游戏',
    '编程',
    'AI',
    '玄学',
    '美食',
    '旅行',
  ];

  // 核心参数定义
  final List<_ParamDefinition> _coreParams = [
    _ParamDefinition(
      id: 'openness',
      title: '开放性',
      leftLabel: '保守谨慎',
      rightLabel: '开放接纳',
      icon: Icons.explore,
    ),
    _ParamDefinition(
      id: 'rationality',
      title: '理性度',
      leftLabel: '绝对理性',
      rightLabel: '高度感性',
      icon: Icons.psychology,
    ),
    _ParamDefinition(
      id: 'orderPreference',
      title: '秩序感',
      leftLabel: '随性自由',
      rightLabel: '秩序井然',
      icon: Icons.format_list_numbered,
    ),
    _ParamDefinition(
      id: 'socialEnergy',
      title: '社交能量',
      leftLabel: '安静内敛',
      rightLabel: '活跃外向',
      icon: Icons.groups,
    ),
    _ParamDefinition(
      id: 'cooperation',
      title: '合作倾向',
      leftLabel: '独立竞争',
      rightLabel: '协作共赢',
      icon: Icons.handshake,
    ),
    _ParamDefinition(
      id: 'empathy',
      title: '同理心',
      leftLabel: '逻辑至上',
      rightLabel: '共情温暖',
      icon: Icons.favorite,
    ),
    _ParamDefinition(
      id: 'expertiseDepth',
      title: '专业深度',
      leftLabel: '广博通才',
      rightLabel: '深度专家',
      icon: Icons.school,
    ),
    _ParamDefinition(
      id: 'creativity',
      title: '创造力',
      leftLabel: '务实稳健',
      rightLabel: '创意迸发',
      icon: Icons.lightbulb,
    ),
  ];

  @override
  void initState() {
    super.initState();

    // 初始化名字和描述
    if (widget.agent != null) {
      _nameController.text = widget.agent!.name;
      _descriptionController.text = widget.agent!.description;
      _params = widget.agent!.parameters.copyWith();
      _expertiseAreas =
          List<String>.from(widget.agent!.parameters.expertiseAreas);
    } else {
      if (widget.initialName != null) {
        _nameController.text = widget.initialName!;
      }
      if (widget.initialDescription != null) {
        _descriptionController.text = widget.initialDescription!;
      }
    }
    if (widget.initialParams != null) {
      _params = widget.initialParams!.copyWith();
      _expertiseAreas = List<String>.from(widget.initialParams!.expertiseAreas);
    } else {
      _params = AgentParameters();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _customExpertiseController.dispose();
    _modelController.dispose();
    _apiKeyController.dispose();
    _apiUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.agent != null ? '编辑角色' : '创建角色'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              switch (value) {
                case 'addToGroup':
                  _showAddToGroupDialog();
                  break;
                case 'reset':
                  _resetParams();
                  break;
                case 'delete':
                  _showDeleteConfirmDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              if (widget.agent != null)
                const PopupMenuItem(
                  value: 'addToGroup',
                  child: Text('添加到群聊'),
                ),
              const PopupMenuItem(
                value: 'reset',
                child: Text('重置'),
              ),
              if (widget.agent != null)
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('删除', style: TextStyle(color: Colors.red)),
                ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 预设模板
            _buildPresetSection(),

            // 基础信息卡片
            _buildCollapsibleCard(
              title: '基础信息',
              icon: Icons.info_outline,
              expanded: _basicExpanded,
              onToggle: () => setState(() => _basicExpanded = !_basicExpanded),
              children: [
                _buildNameField(),
                const SizedBox(height: 16),
                _buildDescriptionField(),
                const SizedBox(height: 16),
                _buildGenerateButton(),
              ],
            ),

            // 核心参数卡片
            _buildCollapsibleCard(
              title: '性格与行为',
              icon: Icons.face,
              expanded: _coreExpanded,
              onToggle: () => setState(() => _coreExpanded = !_coreExpanded),
              children: _coreParams.map((param) => _buildParamSlider(param)).toList(),
            ),

            // 专业领域卡片
            _buildCollapsibleCard(
              title: '专业领域',
              icon: Icons.star,
              expanded: _expertiseExpanded,
              onToggle: () =>
                  setState(() => _expertiseExpanded = !_expertiseExpanded),
              children: [_buildExpertiseSection()],
            ),

            // AI配置卡片
            _buildCollapsibleCard(
              title: 'AI接口配置',
              icon: Icons.api,
              expanded: _aiConfigExpanded,
              onToggle: () =>
                  setState(() => _aiConfigExpanded = !_aiConfigExpanded),
              children: [_buildAIConfigSection()],
            ),

            // 效果预览
            _buildEffectPreview(),

            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _save,
        icon: const Icon(Icons.check),
        label: const Text('保存'),
      ),
    );
  }

  Widget _buildPresetSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            '选择预设',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: PresetTemplates.templates.map((template) {
              final isSelected = _selectedPreset == template['id'];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPreset = template['id'];
                    _params =
                        AgentParameters.getPreset(template['id'] as String);
                    _expertiseAreas =
                        List<String>.from(_params.expertiseAreas);
                  });
                },
                child: Container(
                  width: 90,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (template['color'] as Color).withOpacity(0.3)
                        : Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(
                            color: template['color'] as Color, width: 2)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        template['icon'] as String,
                        style: const TextStyle(fontSize: 28),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        template['name'] as String,
                        style: Theme.of(context).textTheme.labelMedium,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCollapsibleCard({
    required String title,
    required IconData icon,
    required bool expanded,
    required VoidCallback onToggle,
    required List<Widget> children,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        children: [
          // 卡片头部（可点击展开/折叠）
          InkWell(
            onTap: onToggle,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: MirageTeaTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: MirageTeaTheme.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Icon(
                    expanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
          // 折叠内容
          if (expanded)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    // 如果没有建议，直接显示普通输入框
    if (_nameSuggestions.isEmpty) {
      return TextField(
        controller: _nameController,
        decoration: const InputDecoration(
          labelText: '角色名称',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.badge),
          hintText: '输入角色名称，或先填写介绍后点击AI生成',
        ),
        onChanged: (_) => setState(() {}),
      );
    }

    // 有建议时，使用输入框 + 下拉选择
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: '角色名称',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.badge),
            ),
            onChanged: (value) {
              _selectedNameSuggestion = null;
              setState(() {});
            },
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          height: 56,
          child: InputDecorator(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedNameSuggestion,
                hint: const Text('建议'),
                isExpanded: false,
                items: _nameSuggestions.map((suggestion) {
                  return DropdownMenuItem<String>(
                    value: suggestion,
                    child: Text(suggestion, maxLines: 1, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    _nameController.text = value;
                    _selectedNameSuggestion = value;
                    setState(() {});
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return TextField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: '角色介绍',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.description),
        helperText: '简短描述角色的定位和特点',
      ),
      maxLines: 3,
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildGenerateButton() {
    // 名字或介绍至少要有一个
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final canGenerate = name.isNotEmpty || description.isNotEmpty;

    return Align(
      alignment: Alignment.centerRight,
      child: FilledButton.icon(
        onPressed: canGenerate ? () => _generateAgentParams() : null,
        icon: const Icon(Icons.auto_awesome),
        label: const Text('AI智能生成参数'),
        style: FilledButton.styleFrom(
          backgroundColor: MirageTeaTheme.primary.withOpacity(0.1),
          foregroundColor: MirageTeaTheme.primary,
        ),
      ),
    );
  }

  /// AI生成角色参数（使用真实AI API）
  void _generateAgentParams() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    // 输出日志
    print('[AI生成] 开始生成参数');
    print('[AI生成] 角色名称: $name');
    print('[AI生成] 角色介绍: $description');

    // 显示等待对话框
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _AIGeneratingDialog(
        onCancel: () => Navigator.of(context).pop(),
      ),
    );

    try {
      // 调用真实的AI生成
      final result = await AIGenerator.generateAgentParameters(
        name: name,
        description: description,
        onProgress: (message) {
          print('[AI生成] $message');
        },
      );

      if (mounted) {
        Navigator.of(context).pop();

        // 更新名字建议列表
        setState(() {
          _nameSuggestions = result.nameSuggestions;
          
          // 如果有建议，自动选择第一个
          if (_nameSuggestions.isNotEmpty) {
            _selectedNameSuggestion = _nameSuggestions[0];
            _nameController.text = _nameSuggestions[0];
          }
          
          // 如果有优化后的描述，更新描述输入框
          if (result.optimizedDescription.isNotEmpty) {
            _descriptionController.text = result.optimizedDescription;
          }
          
          // 更新参数
          _params = result.parameters;
          _expertiseAreas = result.parameters.expertiseAreas;
        });

        print('[AI生成] 生成完成');
        print('[AI生成] 名字建议: $_nameSuggestions');
        print('[AI生成] 选中的名字: $_selectedNameSuggestion');
        if (result.optimizedDescription.isNotEmpty) {
          print('[AI生成] 已更新角色介绍');
        }
        print('[AI生成] 专业领域: $_expertiseAreas');
        print('[AI生成] 开放性: ${_params.openness}');
        print('[AI生成] 理性度: ${_params.rationality}');
        print('[AI生成] 社交能量: ${_params.socialEnergy}');
        print('[AI生成] 共情能力: ${_params.empathy}');
        print('[AI生成] 创造力: ${_params.creativity}');
        if (result.reasoning.isNotEmpty) {
          print('[AI生成] AI分析: ${result.reasoning}');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('参数生成完成！${_nameSuggestions.isNotEmpty ? '（已生成 ${_nameSuggestions.length} 个名字建议）' : ''}')),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        print('[AI生成] 生成失败: $e');

        // 显示错误对话框
        if (e is AIGenerationException) {
          _showErrorDialog(e.title, e.message);
        } else {
          _showErrorDialog('生成失败', '调用AI时发生错误：$e');
        }
      }
    }
  }

  /// 显示错误对话框
  void _showErrorDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: const TextStyle(color: Colors.red)),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 模拟生成结果（实际项目中替换为真实的AI API调用）
  void _simulateGenerateResult() {
    setState(() {
      // 根据输入调整参数
      final desc = _descriptionController.text.toLowerCase();

      if (desc.contains('理性') || desc.contains('逻辑')) {
        _params = _params.copyWith(rationality: -0.7);
      } else if (desc.contains('感性') || desc.contains('情感')) {
        _params = _params.copyWith(rationality: 0.7);
      }

      if (desc.contains('创意') || desc.contains('艺术')) {
        _params = _params.copyWith(openness: 0.6, creativity: 0.7);
      }

      if (desc.contains('专业') || desc.contains('技术')) {
        _params = _params.copyWith(expertiseDepth: 0.7);
      }

      if (desc.contains('健谈') || desc.contains('社交')) {
        _params = _params.copyWith(socialEnergy: 0.7);
      }

      if (desc.contains('安静') || desc.contains('内向')) {
        _params = _params.copyWith(socialEnergy: 0.2);
      }

      // 添加专业领域
      if (_expertiseAreas.isEmpty) {
        if (desc.contains('编程') || desc.contains('技术') || desc.contains('AI')) {
          _expertiseAreas = ['编程', 'AI', '技术'];
        } else if (desc.contains('艺术') || desc.contains('设计')) {
          _expertiseAreas = ['艺术', '设计', '美学'];
        } else if (desc.contains('哲学') || desc.contains('思考')) {
          _expertiseAreas = ['哲学', '心理学', '思考'];
        } else if (desc.contains('历史') || desc.contains('文化')) {
          _expertiseAreas = ['历史', '文化', '研究'];
        } else if (desc.contains('商业') || desc.contains('经济')) {
          _expertiseAreas = ['商业', '经济', '管理'];
        } else {
          _expertiseAreas = ['哲学', '生活', '思考'];
        }
      }
    });
  }

  Widget _buildParamSlider(_ParamDefinition param) {
    final double min = param.id == 'openness' ||
            param.id == 'rationality' ||
            param.id == 'orderPreference'
        ? -1.0
        : 0.0;
    final double max = 1.0;
    final divisions = param.id == 'openness' ||
            param.id == 'rationality' ||
            param.id == 'orderPreference'
        ? 20
        : 10;

    return StatefulBuilder(
      builder: (context, setState) {
        final value = _getParamValue(param.id);
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(param.icon, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      param.title,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Text(
                    value.toStringAsFixed(value == value.roundToDouble() ? 0 : 1),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: MirageTeaTheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                ),
                child: Slider(
                  value: value,
                  min: min,
                  max: max,
                  divisions: divisions,
                  activeColor: MirageTeaTheme.primary,
                  inactiveColor: Colors.grey.withOpacity(0.3),
                  onChanged: (v) {
                    setState(() {
                      _setParamValue(param.id, v);
                    });
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      param.leftLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      param.rightLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
              // 实时描述
              Text(
                AgentParameters.getParameterDescription(param.id, value),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: MirageTeaTheme.primary,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }

  double _getParamValue(String id) {
    switch (id) {
      case 'openness':
        return _params.openness;
      case 'rationality':
        return _params.rationality;
      case 'orderPreference':
        return _params.orderPreference;
      case 'socialEnergy':
        return _params.socialEnergy;
      case 'cooperation':
        return _params.cooperation;
      case 'empathy':
        return _params.empathy;
      case 'expertiseDepth':
        return _params.expertiseDepth;
      case 'creativity':
        return _params.creativity;
      default:
        return 0;
    }
  }

  void _setParamValue(String id, double value) {
    switch (id) {
      case 'openness':
        _params.openness = value;
        break;
      case 'rationality':
        _params.rationality = value;
        break;
      case 'orderPreference':
        _params.orderPreference = value;
        break;
      case 'socialEnergy':
        _params.socialEnergy = value;
        break;
      case 'cooperation':
        _params.cooperation = value;
        break;
      case 'empathy':
        _params.empathy = value;
        break;
      case 'expertiseDepth':
        _params.expertiseDepth = value;
        break;
      case 'creativity':
        _params.creativity = value;
        break;
    }
  }

  Widget _buildExpertiseSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 自定义输入
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _customExpertiseController,
                decoration: const InputDecoration(
                  labelText: '添加自定义领域',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onSubmitted: (_) => _addCustomExpertise(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add_circle, color: MirageTeaTheme.primary),
              onPressed: _addCustomExpertise,
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 已选择的领域标签
        if (_expertiseAreas.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _expertiseAreas.map((area) {
              return Chip(
                label: Text(area),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  setState(() {
                    _expertiseAreas.remove(area);
                  });
                },
              );
            }).toList(),
          ),
        const SizedBox(height: 12),

        // 预设选项
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              _availableExpertise
                  .where((area) => !_expertiseAreas.contains(area))
                  .map((area) {
            return ActionChip(
              label: Text(area),
              onPressed: () {
                setState(() {
                  _expertiseAreas.add(area);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  void _addCustomExpertise() {
    final text = _customExpertiseController.text.trim();
    if (text.isNotEmpty && !_expertiseAreas.contains(text)) {
      setState(() {
        _expertiseAreas.add(text);
        _customExpertiseController.clear();
      });
    }
  }

  Widget _buildAIConfigSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 使用全局配置开关
        SwitchListTile(
          value: _useGlobalConfig,
          onChanged: (value) {
            setState(() {
              _useGlobalConfig = value;
            });
          },
          title: const Text('使用全局配置'),
          subtitle: const Text(
            '继承系统设置中的API配置',
            style: TextStyle(fontSize: 12),
          ),
          activeColor: MirageTeaTheme.primary,
        ),

        if (!_useGlobalConfig) ...[
          const SizedBox(height: 8),
          // 自定义配置表单
          _buildTextField(
            controller: _modelController,
            label: '模型名称',
            icon: Icons.model_training,
            hint: '如: gpt-4, claude-3-sonnet',
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _apiKeyController,
            label: 'API Key',
            icon: Icons.key,
            obscureText: true,
            hint: '请输入您的API密钥',
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _apiUrlController,
            label: 'API 地址',
            icon: Icons.link,
            hint: '如: https://api.openai.com/v1',
          ),
          const SizedBox(height: 8),
          Text(
            '提示：如无需自定义配置，建议使用全局配置以简化管理',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
          ),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon, size: 20),
        hintText: hint,
        isDense: true,
      ),
    );
  }

  Widget _buildEffectPreview() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MirageTeaTheme.primary.withOpacity(0.1),
            MirageTeaTheme.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MirageTeaTheme.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.preview, color: MirageTeaTheme.primary),
              const SizedBox(width: 8),
              Text(
                '效果预览',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: MirageTeaTheme.primary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildEffectItem('发言频率:', _getEffectText('frequency')),
          _buildEffectItem('发言风格:', _getEffectText('style')),
          _buildEffectItem('话题偏好:', _getEffectText('topic')),
          _buildEffectItem('互动方式:', _getEffectText('interaction')),
        ],
      ),
    );
  }

  Widget _buildEffectItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            TextSpan(
              text: label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: ' $value'),
          ],
        ),
      ),
    );
  }

  String _getEffectText(String type) {
    switch (type) {
      case 'frequency':
        final energy = _params.socialEnergy;
        if (energy < 0.3) return '较低，被动发言';
        if (energy < 0.6) return '适中，有选择地发言';
        return '较高，积极主动';
      case 'style':
        final rationality = _params.rationality;
        final creativity = _params.creativity;
        if (rationality < -0.5) return '逻辑严谨，数据引用多';
        if (rationality > 0.5) return '情感丰富，个人体验多';
        if (creativity > 0.7) return '比喻丰富，富有想象';
        if (creativity < 0.3) return '具体可行，步骤清晰';
        return '平衡表达';
      case 'topic':
        final depth = _params.expertiseDepth;
        if (depth > 0.7) return '深入专业领域分析';
        if (depth < 0.3) return '广泛涉猎多领域';
        return '理论与实践结合';
      case 'interaction':
        final coop = _params.cooperation;
        final empathy = _params.empathy;
        if (coop > 0.7 && empathy > 0.7) return '调和矛盾，寻求共识';
        if (coop < 0.3) return '挑战观点，争取主导';
        if (empathy > 0.7) return '关注他人情感';
        return '友好交流';
      default:
        return '';
    }
  }

  void _resetParams() {
    setState(() {
      _params = AgentParameters();
      _selectedPreset = null;
      _expertiseAreas = [];
      _useGlobalConfig = true;
      _modelController.clear();
      _apiKeyController.clear();
      _apiUrlController.clear();
    });
  }

  /// 显示添加到群聊对话框
  void _showAddToGroupDialog() {
    if (widget.agent == null) return;

    final allGroups = ChatGroupManager.getAllGroups();

    if (allGroups.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先创建一个群聊')),
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
                    final alreadyAdded = group.agentIds.contains(widget.agent!.id);

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
                            await ChatGroupManager.addAgent(groupId, widget.agent!.id);
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

  /// 显示删除确认对话框
  void _showDeleteConfirmDialog() {
    if (widget.agent == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除角色'),
        content: Text('确定要删除角色 "${widget.agent!.name}" 吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(context).pop();
              AgentManager.deleteAgent(widget.agent!.id);
              if (context.mounted) {
                Navigator.of(context).pop(); // 返回上一页
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

  void _save() async {
    print('[保存] _save 被调用');
    String name = _nameController.text.trim();
    print('[保存] 名字: "$name"');
    print('[保存] _nameSuggestions: $_nameSuggestions');
    print('[保存] _selectedNameSuggestion: $_selectedNameSuggestion');

    // 如果名字为空，但有AI建议，自动使用第一个建议
    if (name.isEmpty && _nameSuggestions.isNotEmpty) {
      name = _nameSuggestions[0];
      _nameController.text = name;
      print('[保存] 自动使用第一个名字建议: $name');
    }

    if (name.isEmpty) {
      print('[保存] 名字为空，显示错误提示');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入角色名称')),
      );
      return;
    }

    final params = _params.copyWith(expertiseAreas: _expertiseAreas);
    print('[保存] 参数已准备: openness=${params.openness}');

    if (widget.agent != null) {
      print('[保存] 更新现有角色: ${widget.agent!.id}');
      // 更新现有角色
      widget.agent!.name = name;
      widget.agent!.description = _descriptionController.text.trim();
      widget.agent!.parameters = params;
      await AgentManager.updateAgent(widget.agent!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('角色已更新')),
        );
      }
    } else {
      print('[保存] 创建新角色...');
      // 直接创建角色
      final personality = params.toPersonalityTraits();
      final agent = await AgentManager.createAgent(
        name: name,
        description: _descriptionController.text.trim(),
        personality: personality,
      );
      
      if (mounted) {
        if (agent != null) {
          print('[保存] ✅ 角色创建成功: ${agent.id}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('角色 "$name" 创建成功')),
          );
        } else {
          print('[保存] ❌ 角色创建失败');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('角色创建失败')),
          );
        }
        // 返回上一页
        Navigator.of(context).pop();
      }
    }
    print('[保存] _save 完成');
  }
}

/// AI生成中对话框 - 支持实时进度显示
class _AIGeneratingDialog extends StatefulWidget {
  final VoidCallback onCancel;

  const _AIGeneratingDialog({required this.onCancel});

  @override
  State<_AIGeneratingDialog> createState() => _AIGeneratingDialogState();
}

class _AIGeneratingDialogState extends State<_AIGeneratingDialog> {
  String _statusMessage = '正在准备生成...';

  @override
  void initState() {
    super.initState();
    // 延迟一下再显示，让对话框先渲染
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _statusMessage = '正在构建生成提示词...';
        });
      }
    });
  }

  void updateStatus(String message) {
    if (mounted) {
      setState(() {
        _statusMessage = message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('AI智能生成'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_statusMessage),
          const SizedBox(height: 16),
          const LinearProgressIndicator(),
          const SizedBox(height: 16),
          TextButton(
            onPressed: widget.onCancel,
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }
}

/// 参数定义
class _ParamDefinition {
  final String id;
  final String title;
  final String leftLabel;
  final String rightLabel;
  final IconData icon;

  const _ParamDefinition({
    required this.id,
    required this.title,
    required this.leftLabel,
    required this.rightLabel,
    required this.icon,
  });
}

/// 角色创建结果
class AgentCreationResult {
  final String name;
  final String description;
  final AgentParameters parameters;

  AgentCreationResult({
    required this.name,
    required this.description,
    required this.parameters,
  });
}
