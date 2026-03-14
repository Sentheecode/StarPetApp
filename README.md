# 星宠 (StarPet)

一款专为宠物爱好者打造的社交 App，支持宠物管理、社交、健康记录等功能。

## 项目结构

```
StarPetApp/
├── lib/
│   ├── main.dart          # 主逻辑（约 5300 行，所有功能都在这里）
│   └── storage_manager.dart # 数据持久化工具
├── android/               # Android 配置
├── ios/                   # iOS 配置
├── pubspec.yaml           # 依赖配置
└── README.md              # 本文件
```

## 主要功能

### 1. 首页（家园）
- 宠物信息展示
- 家园场景（装修中）
- 等级系统

### 2. 服务
- 宠物友好商场
- 宠物友好草坪
- 投毒点避雷

### 3. 社交
- 宠物动态分享

### 4. 设备
- 智能设备连接（开发中）

### 5. 我的
- 我的宠物管理
- 我的家园
- 每日签到
- 成就系统
- 主题设置
- **宠物社交**
- **疫苗提醒**
- **健康记录**

## 技术栈

- Flutter 3.x
- sqflite（本地数据库）
- SharedPreferences（键值存储）
- geolocator（定位）
- http（网络请求）

## 开发命令

```bash
# 安装依赖
flutter pub get

# 运行调试
flutter run

# 构建 Release APK
flutter build apk --release

# 构建 Debug APK
flutter build apk --debug
```

## 版本历史

| 版本 | 日期 | 更新内容 |
|------|------|----------|
| v2.23.0 | 2026-03-14 | 宠物社交/疫苗/健康记录移到我的页面 |
| v2.22.0 | 2026-03-14 | 新增宠物社交+疫苗提醒+健康记录 |
| v2.21.0 | 2026-03-14 | 优化启动流程+减小APK体积 |
| v2.20.0 | 2026-03-13 | 修复启动卡住问题 |

## 注意事项

- 所有业务逻辑都在 `lib/main.dart` 中
- 数据存储使用 JSON 文件（通过 StorageManager）
- Android 仅支持 arm64 架构（APK 体积优化）
- OTA 更新服务器地址需配置（见 OTAUpdater 类）
