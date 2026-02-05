import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mirage_tea/core/managers/agent_manager.dart';
import 'package:mirage_tea/core/theme/theme_controller.dart';
import 'package:mirage_tea/core/services/services_initializer.dart';
import 'package:mirage_tea/presentation/main_screen.dart';
import 'package:mirage_tea/presentation/chat/chat_detail_screen.dart';
import 'package:mirage_tea/presentation/agent/agent_parameter_editor_screen.dart';
import 'package:mirage_tea/presentation/civilization/civilization_screen.dart';
import 'package:mirage_tea/presentation/settings/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化服务
  await ServicesInitializer.initialize();

  runApp(
    const ProviderScope(
      child: MirageTeaApp(),
    ),
  );
}

class MirageTeaApp extends ConsumerWidget {
  const MirageTeaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: '虚境茶话会',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeMode,
      locale: locale,
      initialRoute: '/',
      routes: {
        '/': (context) => const MainScreen(),
        '/main': (context) => const MainScreen(),
        '/chat/:id': (context) => ChatDetailScreen(groupId: ''),
        '/create-agent': (context) => AgentParameterEditorScreen(isCreating: true),
        '/agent-editor': (context) => const AgentParameterEditorScreen(),
        '/civilization': (context) => const CivilizationScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name?.startsWith('/chat/') == true) {
          final id = settings.name!.split('/')[2];
          return MaterialPageRoute(
            builder: (context) => ChatDetailScreen(groupId: id),
          );
        }
        if (settings.name?.startsWith('/agent/') == true &&
            settings.name!.endsWith('/edit')) {
          final id = settings.name!.split('/')[2];
          final agent = AgentManager.getAgent(id);
          return MaterialPageRoute(
            builder: (context) => AgentParameterEditorScreen(agent: agent),
          );
        }
        return MaterialPageRoute(builder: (context) => const MainScreen());
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
