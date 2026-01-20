import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.flashit"
    compileSdk = 36 // Updated to the latest compile SDK version
    ndkVersion = "29.0.14206865"
    defaultConfig {
        applicationId = "com.flashit"
        minSdk = flutter.minSdkVersion // Updated to the latest recommended minimum SDK version
        targetSdk = 34 // Updated to the latest target SDK version
        versionCode = 1
        versionName = "1.0.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17 // Updated to Java 17 for modern features
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17" // Ensure Kotlin uses Java 17
    }

    signingConfigs {
        create("release") {
            val properties = Properties()
            val keyPropertiesFile = rootProject.file("app/key.properties")
            if (keyPropertiesFile.exists()) {
                properties.load(keyPropertiesFile.inputStream())
            }

            storeFile = file(properties["storeFile"]?.toString() ?: "release-key.jks")
            storePassword = properties["storePassword"]?.toString()
            keyAlias = properties["keyAlias"]?.toString()
            keyPassword = properties["keyPassword"]?.toString()
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}
