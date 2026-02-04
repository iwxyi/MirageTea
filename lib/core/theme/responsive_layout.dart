import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mirage_tea/core/theme/theme_controller.dart';
import 'mirage_tea_theme.dart';
/// 响应式布局控制器
class ResponsiveLayout {
  // 断点定义
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  
  // 根据屏幕宽度获取布局类型
  static LayoutType getLayoutType(double width) {
    if (width < mobileBreakpoint) {
      return LayoutType.mobile;
    } else if (width < tabletBreakpoint) {
      return LayoutType.tablet;
    } else {
      return LayoutType.desktop;
    }
  }
  
  // 获取面板可见性
  static PanelConfig getPanelConfig(LayoutType type) {
    switch (type) {
      case LayoutType.mobile:
        return const PanelConfig(
          showNavigationRail: false,
          showSidePanel: false,
          navigationType: NavigationType.bottomBar,
          chatListWidth: 1.0,
          chatDetailWidth: 1.0,
          sidePanelWidth: 0.0,
        );
      case LayoutType.tablet:
        return const PanelConfig(
          showNavigationRail: true,
          showSidePanel: false,
          navigationType: NavigationType.rail,
          chatListWidth: 0.4,
          chatDetailWidth: 0.6,
          sidePanelWidth: 0.0,
        );
      case LayoutType.desktop:
        return const PanelConfig(
          showNavigationRail: true,
          showSidePanel: true,
          navigationType: NavigationType.drawer,
          chatListWidth: 0.25,
          chatDetailWidth: 0.5,
          sidePanelWidth: 0.25,
        );
    }
  }
}
enum LayoutType {
  mobile,
  tablet,
  desktop,
}
enum NavigationType {
  bottomBar,
  rail,
  drawer,
}
class PanelConfig {
  final bool showNavigationRail;
  final bool showSidePanel;
  final NavigationType navigationType;
  final double chatListWidth;
  final double chatDetailWidth;
  final double sidePanelWidth;
  
  const PanelConfig({
    required this.showNavigationRail,
    required this.showSidePanel,
    required this.navigationType,
    required this.chatListWidth,
    required this.chatDetailWidth,
    required this.sidePanelWidth,
  });
}
/// 响应式布局Provider
final layoutTypeProvider = StateProvider<LayoutType>((ref) => LayoutType.mobile);
final panelConfigProvider = Provider<PanelConfig>((ref) {
  final layoutType = ref.watch(layoutTypeProvider);
  return ResponsiveLayout.getPanelConfig(layoutType);
});
/// 响应式布局组件
class ResponsiveScaffold extends ConsumerWidget {
  final Widget body;
  final Widget? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Widget? endDrawer;
  final bool showChatList;
  final Widget? chatListPanel;
  final Widget? sidePanel;
  
  const ResponsiveScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.endDrawer,
    this.showChatList = false,
    this.chatListPanel,
    this.sidePanel,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final panelConfig = ref.watch(panelConfigProvider);
    
    switch (panelConfig.navigationType) {
      case NavigationType.bottomBar:
        return Scaffold(
          appBar: AppBar(
            title: title,
            actions: actions,
          ),
          body: body,
          floatingActionButton: floatingActionButton,
          bottomNavigationBar: bottomNavigationBar,
          drawer: drawer,
          endDrawer: endDrawer,
        );
        
      case NavigationType.rail:
        return Scaffold(
          appBar: AppBar(
            title: title,
            actions: actions,
          ),
          body: Row(
            children: [
              NavigationRail(
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('首页'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.chat),
                    label: Text('群聊'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.people),
                    label: Text('角色'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.account_balance),
                    label: Text('文明'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.settings),
                    label: Text('设置'),
                  ),
                ],
                selectedIndex: _getCurrentIndex(context),
                onDestinationSelected: (index) => _navigateTo(context, index),
              ),
              Expanded(
                child: showChatList
                    ? Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * panelConfig.chatListWidth,
                            child: chatListPanel ?? const SizedBox.shrink(),
                          ),
                          Expanded(child: body),
                        ],
                      )
                    : body,
              ),
            ],
          ),
          floatingActionButton: floatingActionButton,
          endDrawer: endDrawer,
        );
        
      case NavigationType.drawer:
        return Scaffold(
          appBar: AppBar(
            title: title,
            actions: actions,
          ),
          body: Row(
            children: [
              NavigationRail(
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('首页'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.chat),
                    label: Text('群聊'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.people),
                    label: Text('角色'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.account_balance),
                    label: Text('文明'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.settings),
                    label: Text('设置'),
                  ),
                ],
                selectedIndex: _getCurrentIndex(context),
                onDestinationSelected: (index) => _navigateTo(context, index),
              ),
              showChatList
                  ? SizedBox(
                      width: MediaQuery.of(context).size.width * panelConfig.chatListWidth,
                      child: chatListPanel ?? const SizedBox.shrink(),
                    )
                  : const SizedBox.shrink(),
              Expanded(
                child: showChatList
                    ? Row(
                        children: [
                          Expanded(child: body),
                          if (panelConfig.showSidePanel && sidePanel != null)
                            SizedBox(
                              width: MediaQuery.of(context).size.width * panelConfig.sidePanelWidth,
                              child: sidePanel,
                            ),
                        ],
                      )
                    : body,
              ),
            ],
          ),
          drawer: drawer,
          endDrawer: endDrawer,
        );
    }
  }
  
  int _getCurrentIndex(BuildContext context) {
    final route = ModalRoute.of(context)?.settings.name;
    switch (route) {
      case '/home':
        return 0;
      case '/chats':
        return 1;
      case '/agents':
        return 2;
      case '/civilization':
        return 3;
      case '/settings':
        return 4;
      default:
        return 0;
    }
  }
  
  void _navigateTo(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed('/home');
        break;
      case 1:
        Navigator.of(context).pushReplacementNamed('/chats');
        break;
      case 2:
        Navigator.of(context).pushReplacementNamed('/agents');
        break;
      case 3:
        Navigator.of(context).pushReplacementNamed('/civilization');
        break;
      case 4:
        Navigator.of(context).pushReplacementNamed('/settings');
        break;
    }
  }
}

