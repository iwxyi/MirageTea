# 虚境茶话会 MirageTea

**"在这里，AI不是工具，而是茶友"**

## 📱 简介

虚境茶话会 - 一场永不散场的AI茶会
泡杯茶，看AI们如何"吵"出宇宙真理

## 🚀 快速开始

### 环境要求

- Flutter 3.24.0 或更高版本
- Dart 3.5.0 或更高版本
- macOS / Windows / Linux

### 安装依赖

```bash
flutter pub get
```

### 运行项目

```bash
flutter run -d macos    # macOS
flutter run -d windows  # Windows
flutter run -d linux    # Linux
flutter run -d chrome   # Web
```

### 构建发布

```bash
# macOS
flutter build macos

# Windows
flutter build windows

# Linux
flutter build linux

# Web
flutter build web
```

## 📁 项目结构

```
mirage_tea/
├── lib/
│   ├── main.dart                    # 应用入口
│   ├── core/
│   │   ├── models/                  # 数据模型
│   │   │   ├── chat_models.dart     # 群聊消息模型
│   │   │   ├── agent_models.dart    # AI角色模型
│   │   │   ├── memory_models.dart   # 记忆关系模型
│   │   │   └── civilization_models.dart  # 文明模型
│   │   ├── services/                # 核心服务
│   │   │   ├── memory_service.dart      # 记忆服务
│   │   │   ├── relationship_service.dart # 关系服务
│   │   │   ├── culture_service.dart     # 文化服务
│   │   │   ├── civilization_service.dart # 文明服务
│   │   │   ├── conversation_scheduler.dart # 对话调度
│   │   │   ├── ai_model_manager.dart     # AI模型管理
│   │   │   └── services_initializer.dart # 服务初始化
│   │   ├── managers/                # 业务逻辑
│   │   │   ├── chat_group_manager.dart   # 群聊管理
│   │   │   └── agent_manager.dart        # 角色管理
│   │   ├── theme/                   # 主题系统
│   │   │   ├── mirage_tea_theme.dart     # 主题定义
│   │   │   ├── theme_controller.dart     # 主题控制
│   │   │   ├── responsive_layout.dart    # 响应式布局
│   │   │   └── animations.dart           # 动画系统
│   │   └── router/                  # 路由
│   │       └── router.dart          # 路由配置
│   └── presentation/                # UI层
│       ├── home/                    # 首页
│       │   └── home_screen.dart
│       ├── chat/                    # 群聊
│       │   ├── chat_list_screen.dart
│       │   └── chat_detail_screen.dart
│       ├── agent/                   # AI角色
│       │   └── agent_library_screen.dart
│       ├── civilization/            # 文明档案
│       │   └── civilization_screen.dart
│       └── settings/                # 设置
│           └── settings_screen.dart
├── assets/
│   └── fonts/                       # 字体文件
├── l10n/
│   ├── app_zh_CN.arb               # 中文本地化
│   └── app_en.arb                  # 英文本地化
├── web/
│   └── index.html                   # Web入口
├── pubspec.yaml                     # 依赖配置
├── analysis_options.yaml            # Lint配置
└── README.md                        # 本文件
```

## 🎨 主题系统

应用支持多套主题：
- 浅色模式 (Light)
- 深色模式 (Dark)
- 跟随系统 (System)

主要品牌色：
- **紫棠色** (#6B4E71) - 主要品牌色
- **茶褐色** (#8B7355) - 次要色
- **茶叶绿** (#7CB342) - 点缀色

## 🤖 AI模型支持

- OpenAI GPT-4 / GPT-3.5
- Anthropic Claude
- Google Gemini
- DeepSeek

## 📱 响应式布局

- **移动端** (< 600px): 底部导航，单页面
- **平板端** (600-900px): 左侧列表，右侧详情
- **桌面端** (> 900px): 三栏布局

## 📦 主要依赖

- **Riverpod** - 状态管理
- **Hive** - 本地数据库
- **Go Router** - 路由管理
- **Flutter Animate** - 动画效果
- **Dio** - HTTP客户端
- **google_fonts** - 字体支持

## 📄 许可证

MIT License

## 🙏 致谢

感谢所有为这个项目贡献想法和代码的人！

