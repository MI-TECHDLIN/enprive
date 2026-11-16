import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
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
        val localProps = Properties()
        if (localPropsFile.exists()) {
            localPropsFile.inputStream().use { stream ->
                localProps.load(stream)
            }
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

    testOptions {
        unitTests.isReturnDefaultValues = true
    }
    val pdfboxResDir = layout.buildDirectory.dir("generated/pdfboxTestResources").get().asFile
    sourceSets {
        getByName("test").resources.directories.add(pdfboxResDir.absolutePath)
    }
}

val pdfboxTestAssets by configurations.creating {
    isCanBeConsumed = false
    isCanBeResolved = true
    isTransitive = false
}

val preparePdfBoxTestResources by tasks.registering(Sync::class) {
    from(pdfboxTestAssets.elements.map { files -> files.map { zipTree(it.asFile) } }) {
        include("assets/com/tom_roush/pdfbox/**")
        eachFile {
            path = path.removePrefix("assets/")
        }
        includeEmptyDirs = false
    }
    into(layout.buildDirectory.dir("generated/pdfboxTestResources"))
}

tasks.configureEach {
    if (name == "processDebugUnitTestJavaRes" || name == "processReleaseUnitTestJavaRes") {
        dependsOn(preparePdfBoxTestResources)
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

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:33.7.0"))
    implementation("com.google.firebase:firebase-ai:18.2.0")
    implementation("com.google.firebase:firebase-ai-ondevice:16.0.0-beta08")
    implementation("com.google.firebase:firebase-appcheck-debug")
    implementation("com.google.firebase:firebase-appcheck-playintegrity")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.8.1")
    implementation("com.tom-roush:pdfbox-android:2.0.27.0")
    pdfboxTestAssets("com.tom-roush:pdfbox-android:2.0.27.0")
    testImplementation("junit:junit:4.13.2")
}
