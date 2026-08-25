# Keep these rules so Flutter plugins keep working with R8 minify.
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# video_player / ExoPlayer
-keep class com.google.android.exoplayer2.** { *; }
-dontwarn com.google.android.exoplayer2.**

# Keep Gson/reflection-style models if added later
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes EnclosingMethod
