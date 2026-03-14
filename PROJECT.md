# StarPetApp 项目说明

## 快速上手

这是 **星宠** Flutter 项目，一个宠物爱好者社交 App。

### 项目路径
- `~/StarPetApp/` - Flutter 项目根目录
- `~/StarPetApp/lib/main.dart` - **所有代码都在这一个文件里**（约 5300 行）

### 常用命令

```bash
# 进入项目目录
cd ~/StarPetApp

# 安装依赖
flutter pub get

# 运行调试
flutter run

# 构建 Release APK
flutter build apk --release

# 构建 Debug APK
flutter build apk --debug
```

### 项目结构（简化版）

```
StarPetApp/
├── lib/
│   ├── main.dart           # 全部代码
│   └── storage_manager.dart # 数据存储
├── android/                 # Android 配置
├── pubspec.yaml            # 依赖配置
└── README.md
```

### 主要功能模块

在 `lib/main.dart` 中：

1. **DataManager** - 数据管理类
   - 用户数据、宠物数据
   - 疫苗记录、健康记录
   - 成就系统、金币系统

2. **StarPetApp** - 主应用（5个Tab）
   - 首页（家园）
   - 服务（同城服务）
   - 社交
   - 设备
   - 我的

3. **各功能页面**
   - PetListPage - 宠物列表
   - AddPetPage - 添加宠物
   - SignInPage - 每日签到
   - AchievementsPage - 成就
   - ThemeSettingsPage - 主题设置
   - **PetSocialPage** - 宠物社交
   - **VaccinePage** - 疫苗提醒
   - **HealthRecordPage** - 健康记录
   - PetMallPage - 宠物商场
   - PetLawnPage - 宠物草坪
   - BlacklistPage - 投毒避雷

### 数据存储

- 使用 `StorageManager` 读写 JSON 文件
- 路径：`应用文档目录/starpet_data.json`

### APK 构建输出

- Release: `build/app/outputs/flutter-apk/app-release.apk`
- Debug: `build/app/outputs/flutter-apk/app-debug.apk`

### GitHub

- 仓库: https://github.com/Sentheecode/StarPetApp
- Release: https://github.com/Sentheecode/StarPetApp/releases

---

**提示**: 所有新功能开发只需修改 `lib/main.dart` 一个文件！
