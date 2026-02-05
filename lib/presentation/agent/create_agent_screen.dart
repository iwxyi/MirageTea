import 'package:flutter/material.dart';
import 'agent_parameter_editor_screen.dart';

/// 创建AI角色模板页面 - 直接进入完整参数调整
class CreateAgentScreen extends StatefulWidget {
  const CreateAgentScreen({super.key});

  @override
  State<CreateAgentScreen> createState() => _CreateAgentScreenState();
}

class _CreateAgentScreenState extends State<CreateAgentScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 直接跳转到完整参数编辑页面
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateToFullEditor();
    });
  }

  void _navigateToFullEditor() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AgentParameterEditorScreen(
          initialName: _nameController.text,
          initialDescription: _descriptionController.text,
        ),
      ),
    );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('创建角色模板'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              '正在打开角色编辑器...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
