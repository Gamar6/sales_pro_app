import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val signingPropertiesFile = rootProject.file("key.properties")
val signingProperties = Properties()

if (!signingPropertiesFile.exists()) {
    throw GradleException(
        "Missing android/key.properties. Release signing cannot continue."
    )
}

signingPropertiesFile.inputStream().use {
    signingProperties.load(it)
}

val requiredSigningProperties = listOf(
    "storePassword",
    "keyPassword",
    "keyAlias",
    "storeFile"
)

requiredSigningProperties.forEach { propertyName ->
    if (signingProperties.getProperty(propertyName).isNullOrBlank()) {
        throw GradleException(
            "Missing '$propertyName' in android/key.properties."
        )
    }
}

android {
    namespace = "id.co.fivafood.salesapp"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "id.co.fivafood.salesapp"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val keystoreFile = rootProject.file(
                "app/${signingProperties.getProperty("storeFile")}"
            )

            if (!keystoreFile.isFile) {
                throw GradleException(
                    "Release keystore file was not found."
                )
            }

            storeFile = keystoreFile
            storePassword = signingProperties.getProperty("storePassword")
            keyAlias = signingProperties.getProperty("keyAlias")
            keyPassword = signingProperties.getProperty("keyPassword")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}