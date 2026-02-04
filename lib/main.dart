import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mirage_tea/core/theme/theme_controller.dart';
import 'package:mirage_tea/core/services/services_initializer.dart';
import 'package:mirage_tea/presentation/home/home_screen.dart';
import 'package:mirage_tea/presentation/chat/chat_list_screen.dart';
import 'package:mirage_tea/presentation/chat/chat_detail_screen.dart';
import 'package:mirage_tea/presentation/agent/agent_library_screen.dart';
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
        '/': (context) => const HomeScreen(),
        '/home': (context) => const HomeScreen(),
        '/chats': (context) => const ChatListScreen(),
        '/agents': (context) => const AgentLibraryScreen(),
        '/civilization': (context) => const CivilizationScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) => const HomeScreen());
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
