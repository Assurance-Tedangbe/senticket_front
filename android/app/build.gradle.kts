plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // appliquer Google Services à l'app
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.senticket_front"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // ✅ AJOUTER — corrige l'erreur flutter_local_notifications
        isCoreLibraryDesugaringEnabled = true
        // coreLibraryDesugaringEnabled true  // ✅ AJOUTER
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    // ✅ Nouvelle syntaxe — remplace le bloc kotlinOptions déprécié
    kotlinOptions {
        jvmTarget = "17"
        //jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.senticket_front"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // ✅ Syntaxe Kotlin DSL — pas de 'true' sans '='
        multiDexEnabled = true  // ✅ AJOUTER
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
//apply plugin: 'com.google.gms.google-services'
dependencies {
    // ✅ Syntaxe Kotlin DSL — parenthèses et guillemets doubles
    // ✅ AJOUTER — bibliothèque de desugaring
    // coreLibraryDesugaring("com.android.tools.build:desugaring:2.1.5")
    // ✅ Bon artifact — note: com.android.tools (pas com.android.tools.build)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}