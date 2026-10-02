plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePassword: String? by project
val keystoreAlias: String? by project


android {

    /// .... Flavor dimensions ---
    flavorDimensions += "flavor-type"

    productFlavors{
        create("jsAcademy"){
            dimension = "flavor-type"
            resValue(type = "string",name = "app_name",value = "Jai ShriRam Parent")
            applicationId = "com.vijayantech.jaishriramparent"
        }
        create("smartSchool"){
            dimension = "flavor-type"
            resValue(type = "string",name = "app_name",value = "Smart School Parent")
            applicationId = "com.vijayantech.smartschoolparent"
        }

        create("ssv"){
            dimension = "flavor-type"
            resValue(type = "string",name = "app_name",value = "SSV Sivagiri")
            applicationId = "com.vijayantech.ssv_sivagiri"
        }
        create("shreeKamadhenuSchool"){
            dimension = "flavor-type"
            resValue(type = "string",name = "app_name",value = "Shree Kamadhenu School")
            applicationId = "com.vijayantech.smart_school_parent"
        }
        create("classConnect"){
            dimension = "flavor-type"
            resValue(type = "string",name = "app_name",value = "Class Connect")
            applicationId = "com.vijayantech.class_connect"
        }
        create("kg"){
            dimension = "flavor-type"
            resValue(type = "string",name = "app_name",value = "KG Matric Hr. Sec. School")
            applicationId = "com.vijayantech.komarasamy_gounder_mhss"
        }
        create("kv"){
            dimension = "flavor-type"
            resValue(type = "string",name = "app_name",value = "Karunya Vidya Bhavan MHSS")
            applicationId = "com.vijayantech.karunya_vidya_bhavan_mhss"
        }
        create("mrs"){
            dimension = "flavor-type"
            resValue(type = "string",name = "app_name",value = "MRS Matric School")
            applicationId = "com.vijayantech.mrs"
        }

    }

    /// ... End flavor dimensions

    namespace = "com.vijayantech"
    compileSdk = 36
    ndkVersion = "27.0.12077973"


    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.vijayantech"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = 22
        versionName = "4.1.6"
        multiDexEnabled = true
    }

    signingConfigs {
        create("release") {
            storeFile = file("upload.jks")
            storePassword = keystorePassword
            keyAlias = keystoreAlias
            keyPassword = keystorePassword
        }
    }


    buildTypes {
        getByName("release") {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isDebuggable = false
            isShrinkResources = true
            // Disable stripping native debug symbols

        }
    }
}


dependencies {
    implementation("androidx.multidex:multidex:2.0.1")

    // Other dependencies...
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}


flutter {
    source = "../.."
}
