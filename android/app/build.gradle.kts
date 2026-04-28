import com.android.build.gradle.internal.dsl.BaseAppModuleExtension
import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("org.jetbrains.kotlin.plugin.compose")
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use { stream ->
        localProperties.load(stream)
    }
}

val flutterVersionCode = localProperties.getProperty("flutter.versionCode")?.toIntOrNull() ?: 1
val flutterVersionName = localProperties.getProperty("flutter.versionName") ?: "1.0"

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

val composeVersion = "1.4.8"

android {
    namespace = "cn.rang.pomelo"
    
    compileSdk = 36

    ndkVersion = "29.0.14206865"

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    sourceSets {
        named("main") {
            java.srcDirs("src/main/kotlin")
        }
    }

    buildFeatures {
        compose = true
    }

    composeOptions {
        kotlinCompilerExtensionVersion = composeVersion
    }

    defaultConfig {
        applicationId = "cn.rang.pomelo"
        minSdk = 24
        targetSdk = 35
        versionCode = flutterVersionCode
        versionName = flutterVersionName
        multiDexEnabled = true
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as? String
            keyPassword = keystoreProperties["keyPassword"] as? String
            storeFile = keystoreProperties["storeFile"]?.let { file(it as String) }
            storePassword = keystoreProperties["storePassword"] as? String
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
        }
        getByName("debug") {
            signingConfig = signingConfigs.getByName("release")
        }
    }

    flavorDimensions += "default"

    productFlavors {
        create("nightly") {
            dimension = "default"
            resValue("string", "app_name_en", "Pomelo Nightly")
            applicationIdSuffix = ".nightly"
            versionNameSuffix = "-nightly"
            signingConfig = signingConfigs.getByName("release")
        }
        create("dev") {
            dimension = "default"
            resValue("string", "app_name_en", "Pomelo Dev")
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            signingConfig = signingConfigs.getByName("release")
        }
        create("stable") {
            dimension = "default"
            resValue("string", "app_name_en", "Pomelo")
            signingConfig = signingConfigs.getByName("release")
        }
    }

    packagingOptions {
        resources.excludes += "DebugProbesKt.bin"
    }
}

flutter {
    source = "../.."
}

val glanceVersion = "1.1.1"
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    implementation("androidx.lifecycle:lifecycle-viewmodel-ktx:2.5.1")
    implementation("com.android.support:multidex:2.0.1")

    implementation("androidx.glance:glance-appwidget:$glanceVersion")
    implementation("androidx.glance:glance-appwidget-preview:$glanceVersion")
    implementation("androidx.glance:glance-preview:$glanceVersion")
    implementation("androidx.glance:glance-material3:$glanceVersion")
    implementation("androidx.glance:glance-material:$glanceVersion")
    implementation("androidx.work:work-runtime-ktx:2.8.1")

    implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.7.3")
    implementation("com.google.code.gson:gson:2.11.0")
}