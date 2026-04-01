plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

configurations.all {
    resolutionStrategy {
        force("androidx.browser:browser:1.8.0")
        force("androidx.activity:activity-ktx:1.9.3")
        force("androidx.activity:activity:1.9.3")
        force("androidx.core:core-ktx:1.13.1")
        force("androidx.core:core:1.13.1")
        force("androidx.navigationevent:navigationevent-android:1.0.0")
    }
}

android {
    namespace = "com.example.fusion_fiesta"
    compileSdk = 36
    ndkVersion = "28.2.13676358"

    compileOptions {
        // 1. Enable Core Library Desugaring (Required for Local Notifications)
        isCoreLibraryDesugaringEnabled = true

        // 2. Set Java Compatibility (Modern for Flutter)
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.example.fusion_fiesta"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Enable MultiDex if your app grows large (Good practice)
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            // Optional: meaningful obfuscation
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // 3. Add Desugaring Library Dependency
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")

    // Add MultiDex if enabled above
    implementation("androidx.multidex:multidex:2.0.1")
}

kotlin {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    }
}