// Lifa Android app. Step 2: hosts the design-system gallery. Flavours per D-011 / 08-platforms §8.2:
// gms (Google Play) and hms (Huawei AppGallery) share all code except provider implementations under src/gms and src/hms.
plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.android)
    alias(libs.plugins.kotlin.compose)
    alias(libs.plugins.roborazzi)
}

android {
    namespace = "za.co.lifa"
    compileSdk = 36
    defaultConfig {
        applicationId = "za.co.lifa"
        minSdk = 29 // Android 10 (NFR-DEV-001)
        targetSdk = 36
        versionCode = 1
        versionName = "0.1.0"
    }
    flavorDimensions += "distribution"
    productFlavors {
        create("gms") {
            dimension = "distribution"
            buildConfigField("String", "CHANNEL", "\"google_play\"")
        }
        create("hms") {
            dimension = "distribution"
            buildConfigField("String", "CHANNEL", "\"huawei_appgallery\"")
        }
    }
    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"))
        }
    }
    testOptions {
        unitTests {
            isIncludeAndroidResources = true
        }
    }
    buildFeatures {
        buildConfig = true
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
}

kotlin {
    jvmToolchain(17)
}

dependencies {
    implementation(project(":core:design"))
    implementation(libs.androidx.core.ktx)
    implementation(libs.androidx.activity.compose)
    implementation(platform(libs.compose.bom))
    implementation(libs.compose.foundation)

    // Store screenshots: the real MainActivity of each flavour, rendered on the JVM (StoreScreenshotTest).
    testImplementation(platform(libs.compose.bom))
    testImplementation(libs.junit)
    testImplementation(libs.robolectric)
    testImplementation(libs.compose.ui.test.junit4)
    testImplementation(libs.roborazzi)
    testImplementation(libs.roborazzi.compose)
    testImplementation(libs.androidx.test.core)
    debugImplementation(libs.compose.ui.test.manifest)
}

// The hms flavour must never pull Google Play services or Firebase (08-platforms §8.2).
tasks.register("checkHmsHasNoGms") {
    val runtime = configurations.named("hmsReleaseRuntimeClasspath")
    doLast {
        val bad = runtime.get().incoming.resolutionResult.allComponents
            .map { it.id.displayName }
            .filter { it.startsWith("com.google.android.gms") || it.startsWith("com.google.firebase") }
        check(bad.isEmpty()) { "hms flavour depends on Google services: $bad" }
    }
}
