plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

dependencies { implementation("androidx.core:core-ktx:1.15.0") }

android {
    namespace = "br.com.ordempro.autonomo"
    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "br.com.ordempro.autonomo"
        minSdk = 24
        targetSdk = 36
        versionCode = 1
        versionName = "1.0.0"
    }
}
