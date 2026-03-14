import 'package:flutter/material.dart';
import '../services/data_manager.dart';
import '../services/ota_updater.dart';
import '../models/theme.dart';

// ==================== 关于我们页面 ====================
class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});
  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  bool _hasUpdate = false;
  bool _checking = false;
  String _latestVersion = '';
  
  @override
  void initState() {
    super.initState();
    _checkUpdate();
  }
  
  Future<void> _checkUpdate() async {
    setState(() => _checking = true);
    final updateInfo = await OTAUpdater.checkUpdate();
    if (updateInfo != null) {
      final serverVersion = updateInfo['versionCode'] ?? 1;
      if (serverVersion > OTAUpdater.currentVersionCode) {
        setState(() {
          _hasUpdate = true;
          _latestVersion = updateInfo['version'] ?? '新版本';
        });
      }
    }
    setState(() => _checking = false);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('关于我们', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: _checking 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.refresh),
            onPressed: _checkUpdate,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppTheme.primaryColor, AppTheme.secondaryColor]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(child: Text('🐾', style: TextStyle(fontSize: 50))),
                ),
                if (_hasUpdate)
                  Positioned(
                    right: 0, top: 0,
                    child: Container(
                      width: 20, height: 20,
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      child: const Center(child: Text('!', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('星宠', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('版本 ${OTAUpdater.currentVersion} | 主题: ${AppTheme.currentThemeIndex}', style: TextStyle(color: Colors.grey)),
            if (_hasUpdate) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _showUpdateDialog(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(20)),
                  child: Text('$_latestVersion 可更新', style: const TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ),
            ],
            const SizedBox(height: 30),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text('星宠是一款专为宠物爱好者打造的社交应用，在这里你可以记录宠物的成长，分享养宠乐趣。', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            ),
            const SizedBox(height: 40),
            Text('© 2026 StarPet', style: TextStyle(color: Colors.grey[400])),
          ],
        ),
      ),
    );
  }
  
  void _showUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('发现新版本'),
        content: Text('最新版本: $_latestVersion\n是否下载更新?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          TextButton(
            onPressed: () {
              OTAUpdater.downloadUpdate(context);
              Navigator.pop(context);
            },
            child: const Text('立即更新'),
          ),
        ],
      ),
    );
  }
}
