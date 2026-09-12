# Flutter wrapper rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep Refocus native service and receiver components
-keep class com.refocusagain.refocus_again.service.** { *; }
-keep class com.refocusagain.refocus_again.receiver.** { *; }
-keep class com.refocusagain.refocus_again.ui.** { *; }
-keep class com.refocusagain.refocus_again.blocking.** { *; }
-keep class com.refocusagain.refocus_again.bridge.** { *; }
-keep class com.refocusagain.refocus_again.apps.** { *; }

# Strip verbose debug logs in release builds (security item 2/8)
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int d(...);
}
