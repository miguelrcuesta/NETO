pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    // Asegúrate de que esta versión coincida con la de tu build.gradle
    id("com.android.application") version "8.6.0" apply false
    
    // START: FlutterFire Configuration
    // ACTUALIZADO: De 4.3.15 a 4.4.2 para mejor compatibilidad con Kotlin 2.1.0
    id("com.google.gms.google-services") version "4.4.2" apply false
    // END: FlutterFire Configuration
    
    // YA ACTUALIZADO: Excelente decisión usar 2.1.0
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

include(":app")
