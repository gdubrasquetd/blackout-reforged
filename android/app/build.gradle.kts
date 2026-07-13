import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing comes from android/key.properties, which is gitignored and
// must never be committed (see android/.gitignore). It doesn't exist in this
// checkout -- generate your own upload keystore with `keytool` (see
// https://flutter.dev/to/reference-keystore) and create the file yourself:
//
//   storePassword=<password>
//   keyPassword=<password>
//   keyAlias=upload
//   storeFile=<path to the .jks, absolute or relative to android/app>
//
// Without it, release builds fall back to the debug keystore so `flutter
// build apk --release` still works locally -- but a debug-signed build must
// never be uploaded to the Play Store.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseSigning = keystorePropertiesFile.exists()
if (hasReleaseSigning) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
}

android {
    namespace = "fr.guillaume.blackout"
    compileSdk = flutter.compileSdkVersion
    // Pinned above flutter.ndkVersion: shared_preferences_android and
    // url_launcher_android both require 27.0.12077973, higher than the
    // default Flutter ships (NDK is backward compatible, so this is safe).
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "fr.guillaume.blackout"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                // No android/key.properties yet -- fall back to the debug
                // keystore so local `flutter build apk --release` still
                // works. This build is NOT suitable for Play Store upload.
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}
