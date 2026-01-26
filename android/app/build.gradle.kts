plugins {
    id("com.android.application")
    id("kotlin-android")
    // Plugin Flutter phải được áp dụng sau Android và Kotlin plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.chronos"
    // Sử dụng SDK 34 để fix triệt để lỗi lStar (yêu cầu API 31+)
    compileSdk = 34

    // FIX LỖI NDK: Cập nhật chính xác phiên bản mà hệ thống yêu cầu
    // Bạn cần vào Android Studio tải bản này về như hướng dẫn bên dưới
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.chronos"

        // minSdk 21 là mức an toàn cho các máy Android cũ vẫn chạy được Isar
        minSdk = flutter.minSdkVersion
        targetSdk = 34

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Signing với debug key để có thể build nhanh và chạy thử ngay
            signingConfig = signingConfigs.getByName("debug")

            // Tạm thời để false để tránh lỗi khi đóng gói tài nguyên
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}
