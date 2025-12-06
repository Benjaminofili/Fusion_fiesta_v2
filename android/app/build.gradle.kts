plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.fusion_fiesta"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // Ensure this matches your installed NDK or remove if not needed

    compileOptions {
        // 1. Enable Core Library Desugaring (Required for Local Notifications)
        isCoreLibraryDesugaringEnabled = true

        // 2. Set Java Compatibility to Java 8 (Standard for Flutter)
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
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