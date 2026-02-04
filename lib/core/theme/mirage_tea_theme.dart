import 'package:flutter/material.dart';
import 'package:mirage_tea/core/theme/theme_controller.dart';
/// 虚境茶话会主题定义
/// 使用Material Design 3设计语言
class MirageTeaTheme {
  // 主题颜色
  static const Color primary = Color(0xFF6B4E71);       // 紫棠色 - 主要品牌色
  static const Color primaryVariant = Color(0xFF4A3550); // 深紫棠色
  static const Color secondary = Color(0xFF8B7355);     // 茶褐色 - 次要色
  static const Color secondaryVariant = Color(0xFF6B5742);
  static const Color tertiary = Color(0xFF7CB342);      // 茶叶绿 - 点缀色
  
  // 语义颜色
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // 背景色 - 浅色
  static const Color backgroundLight = Color(0xFFFAF8F5); // 米白色
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF5F0E8);
  
  // 背景色 - 深色
  static const Color backgroundDark = Color(0xFF1A1A1A);
  static const Color surfaceDark = Color(0xFF2D2D2D);
  static const Color surfaceVariantDark = Color(0xFF3D3D3D);
  
  // 文字颜色
  static const Color onPrimaryLight = Color(0xFFFFFFFF);
  static const Color onSecondaryLight = Color(0xFFFFFFFF);
  static const Color onBackgroundLight = Color(0xFF1C1B1F);
  static const Color onSurfaceLight = Color(0xFF1C1B1F);
  
  static const Color onPrimaryDark = Color(0xFFFFFFFF);
  static const Color onSecondaryDark = Color(0xFFFFFFFF);
  static const Color onBackgroundDark = Color(0xFFE6E1E5);
  static const Color onSurfaceDark = Color(0xFFE6E1E5);
  
  // AI角色颜色
  static const List<Color> agentColors = [
    Color(0xFFE91E63), // 粉红
    Color(0xFF9C27B0), // 紫色
    Color(0xFF3F51B5), // 靛蓝
    Color(0xFF2196F3), // 蓝色
    Color(0xFF009688), // 青色
    Color(0xFF4CAF50), // 绿色
    Color(0xFFFF9800), // 橙色
    Color(0xFFFF5722), // 深橙
    Color(0xFF795548), // 棕色
    Color(0xFF607D8B), // 蓝灰
  ];
  
  // 文明时代颜色
  static const Map<int, Color> eraColors = {
    1: Color(0xFF9E9E9E), // 原始 - 灰色
    2: Color(0xFF8BC34A), // 启蒙 - 浅绿
    3: Color(0xFF03A9F4), // 繁荣 - 蓝色
    4: Color(0xFF9C27B0), // 黄金 - 紫色
    5: Color(0xFFFFD700), // 永恒 - 金色
  };
  
  // 获取AI角色颜色
  static Color getAgentColor(String agentId) {
    final index = agentId.hashCode.abs() % agentColors.length;
    return agentColors[index];
  }
  
  // 浅色主题
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
        tertiary: tertiary,
        surface: surfaceLight,
        background: backgroundLight,
        error: error,
      ),
      // 文字主题
      textTheme: _buildTextTheme(ThemeData.light().textTheme),
      // 组件主题
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      cardTheme: CardTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 2,
      ),
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: primary.withOpacity(0.2),
        labelTextStyle: MaterialStateProperty.all(
          const TextStyle(fontSize: 12),
        ),
      ),
      // 动画曲线
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
  
  // 深色主题
  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
        tertiary: tertiary,
        surface: surfaceDark,
        background: backgroundDark,
        error: error,
        brightness: Brightness.dark,
      ),
      // 文字主题
      textTheme: _buildTextTheme(ThemeData.dark().textTheme),
      // 组件主题
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      cardTheme: CardTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        color: surfaceVariantDark,
      ),
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: primary.withOpacity(0.3),
        labelTextStyle: MaterialStateProperty.all(
          const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
  
  // 构建文字主题
  static TextTheme _buildTextTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: const TextStyle(
        fontFamily: 'NotoSerifSC',
        fontWeight: FontWeight.w700,
      ),
      displayMedium: const TextStyle(
        fontFamily: 'NotoSerifSC',
        fontWeight: FontWeight.w700,
      ),
      displaySmall: const TextStyle(
        fontFamily: 'NotoSerifSC',
        fontWeight: FontWeight.w700,
      ),
      headlineLarge: const TextStyle(
        fontFamily: 'NotoSerifSC',
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: const TextStyle(
        fontFamily: 'NotoSerifSC',
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: const TextStyle(
        fontFamily: 'NotoSerifSC',
        fontWeight: FontWeight.w600,
      ),
      titleLarge: const TextStyle(
        fontFamily: 'NotoSansSC',
        fontWeight: FontWeight.w600,
      ),
      titleMedium: const TextStyle(
        fontFamily: 'NotoSansSC',
        fontWeight: FontWeight.w500,
      ),
      titleSmall: const TextStyle(
        fontFamily: 'NotoSansSC',
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: const TextStyle(
        fontFamily: 'NotoSansSC',
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: const TextStyle(
        fontFamily: 'NotoSansSC',
        fontWeight: FontWeight.w400,
      ),
      bodySmall: const TextStyle(
        fontFamily: 'NotoSansSC',
        fontWeight: FontWeight.w400,
      ),
      labelLarge: const TextStyle(
        fontFamily: 'NotoSansSC',
        fontWeight: FontWeight.w500,
      ),
      labelMedium: const TextStyle(
        fontFamily: 'NotoSansSC',
        fontWeight: FontWeight.w500,
      ),
      labelSmall: const TextStyle(
        fontFamily: 'NotoSansSC',
        fontWeight: FontWeight.w500,
      ),
    );
  }
  
  // 动画曲线
  static const Curve defaultCurve = Curves.easeInOutCubic;
  static const Duration defaultDuration = Duration(milliseconds: 300);
  static const Duration longDuration = Duration(milliseconds: 500);
}

