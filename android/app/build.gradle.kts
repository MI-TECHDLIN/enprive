plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.enprive"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.enprive"
        // Min SDK 26 is required for Firebase AI Logic on-device (Gemini Nano)
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        val localPropsFile = rootProject.file("local.properties")
        val localProps = java.util.Properties()
        if (localPropsFile.exists()) {
            localPropsFile.inputStream().use { localProps.load(it) }
        }
        val appCheckDebugToken = localProps.getProperty("APP_CHECK_DEBUG_TOKEN") ?: ""
        manifestPlaceholders["firebaseAppCheckDebugSecret"] = appCheckDebugToken
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
