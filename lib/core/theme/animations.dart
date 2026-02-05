import 'package:flutter/material.dart';
import 'mirage_tea_theme.dart';

/// 动画扩展组件
class Animations {
  /// 私有构造函数，防止实例化
  Animations._();

  // 淡入动画
  static Widget fadeIn({
    required Widget child,
    Duration delay = Duration.zero,
    Duration duration = MirageTeaTheme.defaultDuration,
  }) {
    return FutureBuilder(
      future: Future.delayed(delay),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AnimatedOpacity(
            opacity: 1.0,
            duration: duration,
            child: child,
          );
        }
        return AnimatedOpacity(
          opacity: 0.0,
          duration: Duration.zero,
          child: child,
        );
      },
    );
  }

  // 淡出动画
  static Widget fadeOut({
    required Widget child,
    Duration delay = Duration.zero,
    Duration duration = MirageTeaTheme.defaultDuration,
  }) {
    return FutureBuilder(
      future: Future.delayed(delay),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AnimatedOpacity(
            opacity: 0.0,
            duration: duration,
            child: child,
          );
        }
        return AnimatedOpacity(
          opacity: 1.0,
          duration: Duration.zero,
          child: child,
        );
      },
    );
  }

  // 滑入动画（从底部）
  static Widget slideInUp({
    required Widget child,
    Duration delay = Duration.zero,
    Duration duration = MirageTeaTheme.defaultDuration,
    double offset = 50,
  }) {
    return FutureBuilder(
      future: Future.delayed(delay),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AnimatedSlide(
            offset: Offset.zero,
            duration: duration,
            curve: MirageTeaTheme.defaultCurve,
            child: AnimatedOpacity(
              opacity: 1.0,
              duration: duration,
              child: Transform.translate(
                offset: Offset(0, offset),
                child: child,
              ),
            ),
          );
        }
        return AnimatedOpacity(
          opacity: 0.0,
          duration: Duration.zero,
          child: Transform.translate(
            offset: Offset(0, offset),
            child: child,
          ),
        );
      },
    );
  }

  // 滑入动画（从左侧）
  static Widget slideInLeft({
    required Widget child,
    Duration delay = Duration.zero,
    Duration duration = MirageTeaTheme.defaultDuration,
    double offset = 50,
  }) {
    return FutureBuilder(
      future: Future.delayed(delay),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AnimatedSlide(
            offset: Offset.zero,
            duration: duration,
            curve: MirageTeaTheme.defaultCurve,
            child: AnimatedOpacity(
              opacity: 1.0,
              duration: duration,
              child: Transform.translate(
                offset: Offset(-offset, 0),
                child: child,
              ),
            ),
          );
        }
        return AnimatedOpacity(
          opacity: 0.0,
          duration: Duration.zero,
          child: Transform.translate(
            offset: Offset(-offset, 0),
            child: child,
          ),
        );
      },
    );
  }

  // 滑入动画（从右侧）
  static Widget slideInRight({
    required Widget child,
    Duration delay = Duration.zero,
    Duration duration = MirageTeaTheme.defaultDuration,
    double offset = 50,
  }) {
    return FutureBuilder(
      future: Future.delayed(delay),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AnimatedSlide(
            offset: Offset.zero,
            duration: duration,
            curve: MirageTeaTheme.defaultCurve,
            child: AnimatedOpacity(
              opacity: 1.0,
              duration: duration,
              child: Transform.translate(
                offset: Offset(offset, 0),
                child: child,
              ),
            ),
          );
        }
        return AnimatedOpacity(
          opacity: 0.0,
          duration: Duration.zero,
          child: Transform.translate(
            offset: Offset(offset, 0),
            child: child,
          ),
        );
      },
    );
  }

  // 缩放动画
  static Widget scaleIn({
    required Widget child,
    Duration delay = Duration.zero,
    Duration duration = MirageTeaTheme.defaultDuration,
    double scale = 0.8,
  }) {
    return FutureBuilder(
      future: Future.delayed(delay),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AnimatedScale(
            scale: 1.0,
            duration: duration,
            curve: MirageTeaTheme.defaultCurve,
            child: AnimatedOpacity(
              opacity: 1.0,
              duration: duration,
              child: Transform.scale(
                scale: scale,
                child: child,
              ),
            ),
          );
        }
        return AnimatedOpacity(
          opacity: 0.0,
          duration: Duration.zero,
          child: Transform.scale(
            scale: scale,
            child: child,
          ),
        );
      },
    );
  }

  // 弹跳动画
  static Widget bounceIn({
    required Widget child,
    Duration delay = Duration.zero,
    Duration duration = MirageTeaTheme.longDuration,
  }) {
    return FutureBuilder(
      future: Future.delayed(delay),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AnimatedScale(
            scale: 1.0,
            duration: duration,
            curve: Curves.elasticOut,
            child: AnimatedOpacity(
              opacity: 1.0,
              duration: duration,
              child: Transform.scale(
                scale: 0.8,
                child: child,
              ),
            ),
          );
        }
        return AnimatedOpacity(
          opacity: 0.0,
          duration: Duration.zero,
          child: Transform.scale(
            scale: 0.8,
            child: child,
          ),
        );
      },
    );
  }

  // 脉冲动画
  static Widget pulse({
    required Widget child,
    Duration delay = Duration.zero,
    Duration duration = MirageTeaTheme.defaultDuration,
  }) {
    return FutureBuilder(
      future: Future.delayed(delay),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AnimatedContainer(
            duration: duration,
            curve: Curves.easeInOut,
            transform: Matrix4.identity()..scale(1.05),
            child: AnimatedContainer(
              duration: duration,
              curve: Curves.easeInOut,
              transform: Matrix4.identity()..scale(1.0),
              child: child,
            ),
          );
        }
        return AnimatedContainer(
          duration: Duration.zero,
          transform: Matrix4.identity()..scale(1.05),
          child: child,
        );
      },
    );
  }

  // 打字机效果（文字渐显）
  static Widget typewriter({
    required String text,
    required TextStyle style,
    Duration delay = Duration.zero,
    Duration perChar = const Duration(milliseconds: 50),
  }) {
    return FutureBuilder(
      future: Future.delayed(delay),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AnimatedDefaultTextStyle(
            style: style,
            duration: Duration(milliseconds: perChar.inMilliseconds * text.length),
            child: Text(text),
          );
        }
        return Opacity(
          opacity: 0,
          child: Text(text, style: style),
        );
      },
    );
  }

  // 抖动动画（用于错误提示）
  static Widget shake({
    required Widget child,
    Duration delay = Duration.zero,
    Duration duration = MirageTeaTheme.defaultDuration,
  }) {
    return FutureBuilder(
      future: Future.delayed(delay),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AnimatedContainer(
            duration: duration,
            transform: Matrix4.identity()..translate(-5.0, 0),
            child: AnimatedContainer(
              duration: Duration(milliseconds: (duration.inMilliseconds / 4).round()),
              transform: Matrix4.identity()..translate(5.0, 0),
              child: child,
            ),
          );
        }
        return AnimatedContainer(
          duration: Duration.zero,
          transform: Matrix4.identity()..translate(-5.0, 0),
          child: child,
        );
      },
    );
  }

  // 列表项动画
  static Widget listItem({
    required Widget child,
    required int index,
    Duration duration = MirageTeaTheme.defaultDuration,
  }) {
    return FutureBuilder(
      future: Future.delayed(Duration(milliseconds: 50 * index)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AnimatedSlide(
            offset: Offset.zero,
            duration: duration,
            curve: MirageTeaTheme.defaultCurve,
            child: AnimatedOpacity(
              opacity: 1.0,
              duration: duration,
              child: Transform.translate(
                offset: Offset(0, 0.2 * 50),
                child: child,
              ),
            ),
          );
        }
        return AnimatedOpacity(
          opacity: 0.0,
          duration: Duration.zero,
          child: Transform.translate(
            offset: Offset(0, 0.2 * 50),
            child: child,
          ),
        );
      },
    );
  }

  // 渐变背景动画
  static Widget gradientBackground({
    required List<Color> colors,
    required Widget child,
    Duration duration = const Duration(seconds: 3),
  }) {
    return AnimatedContainer(
      duration: duration,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: child,
    );
  }

  // 悬浮动画
  static Widget floating({
    required Widget child,
    Duration delay = Duration.zero,
    Duration duration = const Duration(seconds: 3),
  }) {
    return FutureBuilder(
      future: Future.delayed(delay),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AnimatedContainer(
            duration: duration,
            curve: Curves.easeInOut,
            transform: Matrix4.identity()..translate(0, -10),
            child: AnimatedContainer(
              duration: duration,
              curve: Curves.easeInOut,
              transform: Matrix4.identity()..translate(0, 10),
              child: AnimatedContainer(
                duration: duration,
                curve: Curves.easeInOut,
                transform: Matrix4.identity()..translate(0, -10),
                child: child,
              ),
            ),
          );
        }
        return child;
      },
    );
  }
}
