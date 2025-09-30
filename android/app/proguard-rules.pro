# Flutter Local Notifications
-keep class com.dexterous.** { *; }
-keep class androidx.core.app.NotificationCompat** { *; }
-keep class * extends androidx.core.app.NotificationCompat$Style { *; }

# Gson (utilisé par les notifications)
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Modèles de données des notifications
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Préserver les paramètres de type générique
-keepattributes Signature