# Flutter 相关
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# sqflite
-keep class com.tekartik.sqflite.** { *; }

# geolocator
-keep class com.baseflow.geolocator.** { *; }

# shared_preferences
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# http
-keep class io.flutter.plugins.httplifecycle.** { *; }

# Google Play Core - 忽略缺失的类
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
