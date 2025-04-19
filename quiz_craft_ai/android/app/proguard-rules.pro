# Keep all ML Kit text recognition classes
-keep class com.google.mlkit.vision.text.** { *; }
-keep class com.google.android.gms.** { *; }

# Remove unused ML Kit language models to fix missing class errors
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
