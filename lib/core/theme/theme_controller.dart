import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';

// 主题模式枚举
enum ThemeModeType {
  light,
  dark,
  system,
}

// 将 ThemeModeType 转换为 ThemeMode
ThemeMode _toThemeMode(ThemeModeType type) {
  switch (type) {
    case ThemeModeType.light:
      return ThemeMode.light;
    case ThemeModeType.dark:
      return ThemeMode.dark;
    case ThemeModeType.system:
      return ThemeMode.system;
  }
}

// 主题模式Provider (返回 ThemeMode 以便直接使用)
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.system;
});

// 主题模式控制器
class ThemeModeController extends StateNotifier<ThemeModeType> {
  ThemeModeController() : super(ThemeModeType.system);

  void setThemeMode(ThemeModeType mode) {
    state = mode;
  }

  void toggleTheme() {
    switch (state) {
      case ThemeModeType.light:
        state = ThemeModeType.dark;
        break;
      case ThemeModeType.dark:
        state = ThemeModeType.system;
        break;
      case ThemeModeType.system:
        state = ThemeModeType.light;
        break;
    }
  }
}

// 语言环境Provider
final localeProvider = StateProvider<Locale?>((ref) => const Locale('zh', 'CN'));

// 语言环境控制器
class LocaleController extends StateNotifier<Locale?> {
  LocaleController() : super(const Locale('zh', 'CN'));

  void setLocale(Locale? locale) {
    state = locale;
  }

  void toggleLocale() {
    if (state?.languageCode == 'zh') {
      state = const Locale('en');
    } else {
      state = const Locale('zh', 'CN');
    }
  }
}
