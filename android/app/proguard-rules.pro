# Flutter-specific rules
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Hive - keep model classes
-keep class com.example.pilo.** { *; }
-keep @com.hive.annotations.HiveType class * { *; }

# ML Kit - prevent stripping native bridge classes
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.mlkit.**

# MediaPipe
-keep class com.google.mediapipe.** { *; }
-dontwarn com.google.mediapipe.**

# In-App Purchases
-keep class com.android.billingclient.** { *; }
-dontwarn com.android.billingclient.**

# Keep native methods
-keepclassmembers class * {
    native <methods>;
}
