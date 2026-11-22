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
        // Production Android application ID (independent of Kotlin namespace = "com.example.enprive").
        applicationId = "com.mitechdlin.enprive"
        // Min SDK 26 is required for Firebase AI Logic on-device (Gemini Nano)
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    val keystorePropsFile = rootProject.file("key.properties")
    val keystoreProps = Properties()
    if (keystorePropsFile.exists()) {
        keystorePropsFile.inputStream().use { stream ->
            keystoreProps.load(stream)
        }
    }
    val releaseStorePath = keystoreProps.getProperty("storeFile")?.trim()
        ?.takeIf { it.isNotEmpty() }
        ?: System.getenv("ENPRIVE_RELEASE_STORE_FILE")?.trim()?.takeIf { it.isNotEmpty() }
    val releaseStorePassword = keystoreProps.getProperty("storePassword")?.trim()
        ?.takeIf { it.isNotEmpty() }
        ?: System.getenv("ENPRIVE_RELEASE_STORE_PASSWORD")?.trim()?.takeIf { it.isNotEmpty() }
    val releaseKeyAlias = keystoreProps.getProperty("keyAlias")?.trim()
        ?.takeIf { it.isNotEmpty() }
        ?: System.getenv("ENPRIVE_RELEASE_KEY_ALIAS")?.trim()?.takeIf { it.isNotEmpty() }
    val releaseKeyPassword = keystoreProps.getProperty("keyPassword")?.trim()
        ?.takeIf { it.isNotEmpty() }
        ?: System.getenv("ENPRIVE_RELEASE_KEY_PASSWORD")?.trim()?.takeIf { it.isNotEmpty() }
    val releaseStoreFile = releaseStorePath?.let { rootProject.file(it) }
    val hasReleaseSigning = releaseStoreFile != null &&
        releaseStoreFile.exists() &&
        releaseStorePassword != null &&
        releaseKeyAlias != null &&
        releaseKeyPassword != null

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                storeFile = releaseStoreFile
                storePassword = releaseStorePassword
                keyAlias = releaseKeyAlias
                keyPassword = releaseKeyPassword
            }
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                logger.lifecycle(
                    "[Enprive Build] Release keystore not configured (android/key.properties or ENPRIVE_RELEASE_* env vars missing); producing unsigned release artifacts.",
                )
                null
            }
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
    implementation(platform("com.google.firebase:firebase-bom:35.2.0"))
    implementation("com.google.firebase:firebase-ai")
    implementation("com.google.firebase:firebase-ai-ondevice:16.0.0-beta08")
    debugImplementation("com.google.firebase:firebase-appcheck-debug")
    implementation("com.google.firebase:firebase-appcheck-playintegrity")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.8.1")
    implementation("com.tom-roush:pdfbox-android:2.0.27.0")
    pdfboxTestAssets("com.tom-roush:pdfbox-android:2.0.27.0")
    testImplementation("junit:junit:4.13.2")
    androidTestImplementation("androidx.test:runner:1.7.0")
    androidTestImplementation("androidx.test.ext:junit:1.3.0")
}
